#!/bin/tclsh
#  Soundtouch Homematic TCL Stuff
#  2018 by thkl
#  https://github.com/thkl/HM-SoundTouch

source /www/once.tcl

sourceOnce /usr/local/addons/soundtouch/lib/ini.tcl
sourceOnce /usr/local/addons/soundtouch/lib/log.tcl
sourceOnce /usr/local/addons/soundtouch/lib/rega.tcl


namespace eval soundtouch {
	variable config_file "/usr/local/etc/config/soundtouch.cfg"
	variable path "/usr/local/addons/soundtouch/"
	
	variable lock_start_port 12123
	variable lock_socket
	variable lock_id_config_file 1
}


proc ::soundtouch::lock {lock_id} {
	variable lock_socket
	variable lock_start_port
	set port [expr { $lock_start_port + $lock_id }]
	set tn 0
	# 'socket already in use' error will be our lock detection mechanism
	while {1} {
		set tn [expr {$tn + 1}]
		if { [catch {socket -server dummy_accept $port} sock] } {
			if {$tn > 10} {
				# We do not flood our log
				break
			}
			after 25
		} else {
			set lock_socket($lock_id) $sock
			break
		}
	}
}


proc ::soundtouch::loadSettings {key defaultValue} {
	variable config_file
	variable lock_id_config_file
	lock $lock_id_config_file
	set config [ini::open $config_file r]
	set result [ini::value $config "common" $key $defaultValue]
	ini::close $config
	un_lock $lock_id_config_file
	return $result
}

proc ::soundtouch::saveSettings {key value} {
	variable config_file
	variable lock_id_config_file
	set config [ini::open $config_file r+]
	ini::set $config "common" $key $value
	ini::commit $config
	ini::close $config
	un_lock $lock_id_config_file
}

proc ::soundtouch::un_lock {lock_id} {
	variable lock_socket
	if {[info exists lock_socket($lock_id)]} {
		if { [catch {close $lock_socket($lock_id)} errormsg] } {
			# here is a error .. we dont care
		}
		unset lock_socket($lock_id)
	}
}

proc ::soundtouch::checkConfig {} {
  variable config_file
  if {![file exists $config_file]} {
	 set fo [open $config_file "w"] 	  
	 puts $fo "#SoundTouch Config"
	 close $fo
  }
}

proc ::soundtouch::addPlayer {playerIP} {
	variable path
	variable config_file
	variable lock_id_config_file
	set url "http://$playerIP:8090/info"
	set data [exec $path/curl --silent $url]
	regexp {<name>(.*?)</name>} $data match playerName
	regexp {<info deviceID="(.*?)">} $data match playerID

	if [info exists match] {
	    ::log::log info "Player $playerName found ..."
	    lock $lock_id_config_file
	    set config [ini::open $config_file r+]
	    # Check if player allready exists
		if {![::ini::exists $config $playerName]} {
			::log::log info "added $playerName to config"
			ini::set $config $playerName "ip_address" $playerIP
			#id needed for further updates 
			ini::set $config $playerName "deviceID" $playerID
			ini::commit $config
			#add variables to ccu
			::rega::addVariable "BOSE_POWER_$playerName" "2" "2"
			::rega::addVariable "BOSE_STATE_$playerName" "20" "11"
			::rega::addVariable "BOSE_TRACK_$playerName" "20" "11"
			::rega::addVariable "BOSE_VOLUME_$playerName" "4" "0"
		} else {
			::log::log info "$playerName exists allready in config"
		}
		ini::close $config
		un_lock $lock_id_config_file
    }
	return -1
}    

proc ::soundtouch::listPlayer {} {
	variable config_file
	variable lock_id_config_file
	set first 1
	set result "\["
	lock $lock_id_config_file
	set config [ini::open $config_file r]
	foreach player_name [ini::sections $config] {
	  if {$player_name != "common"} {
		set ip_address [ini::value $config $player_name "ip_address"]
		
		if {$first == 1} {
			set first 0
         } else {
             append result ","
         }
		append result "\{\"name\":\"$player_name\",\"ip\":\"$ip_address\"\}"
     }
    }
    append result "\]"
	ini::close $config
	un_lock $lock_id_config_file
	return $result
}

proc ::soundtouch::deletePlayer {name} {
   variable config_file
   variable lock_id_config_file
   lock $lock_id_config_file
   set config [ini::open $config_file r+]
   if {[::ini::exists $config $name]} {
     ini::delete $config $name
	 ini::commit $config
   }
   ini::close $config
   un_lock $lock_id_config_file
}


proc ::soundtouch::getPlayerIP {player_name} {
  variable config_file
  variable lock_id_config_file
  set ip_address ""
  lock $lock_id_config_file
  set config [ini::open $config_file r]
  if {[::ini::exists $config $player_name]} {
	 set ip_address [ini::value $config $player_name "ip_address"]
  } else {
	  ::log::log error "$player_name not in ini"
  }
  ini::close $config
  un_lock $lock_id_config_file
  return $ip_address
}

proc ::soundtouch::getPlayerID {player_name} {
  variable config_file
  variable lock_id_config_file
  set playerId ""
  lock $lock_id_config_file
  set config [ini::open $config_file r]
  if {[::ini::exists $config $player_name]} {
	 set playerId [ini::value $config $player_name "deviceID"]
  } else {
	  ::log::log error "$player_name not in ini"
  }
  ini::close $config
  un_lock $lock_id_config_file
  return $playerId
}

proc ::soundtouch::getState {ip playername} {
  variable path
  set url "http://$ip:8090/now_playing"
  set data [exec $path/curl --silent $url]
  regexp source=\"STANDBY\" $data match i
  if [info exists match] {
	  ::rega::setVariable "BOSE_POWER_$playername" false
  } else {
	  ::rega::setVariable "BOSE_POWER_$playername" true
  }
  
  regexp {<playStatus>(.*?)</playStatus>} $data match i
  if [info exists match] {
	  ::rega::setStrVariable "BOSE_STATE_$playername" $i
  }
  
  regexp {<itemName>(.*?)</itemName>} $data match i
  if [info exists match] {
	  ::rega::setStrVariable "BOSE_TRACK_$playername" $i
  }
}

proc ::soundtouch::keyAction {ip key state} {
  variable path
  set url "http://$ip:8090/key"
  set parameter " <key state=\'$state\' sender=\'Gabbo\'>$key</key>'"
  set header "Content-Type: text/plain; charset=utf-8"
  exec $path/curl --silent --data $parameter -H $header $url
}

proc ::soundtouch::setVolume {ip volume} {
  variable path
  set url "http://$ip:8090/volume"
  set parameter " <volume>$volume</volume>"
  set header "Content-Type: text/plain; charset=utf-8"
  exec $path/curl --silent --data $parameter -H $header $url
}


proc ::soundtouch::wsplit {str sepStr} {
    if {![regexp $sepStr $str]} {
        return $str}
    set strList {}
    set pattern (.*?)$sepStr
    while {[regexp $pattern $str match left]} {
        lappend strList $left
        regsub $pattern $str {} str
    }
    lappend strList $str
    return $strList
}

proc ::soundtouch::createZoneRequest {master slaveList} {
  set slaves [wsplit $slaveList ","]
  set masterID [getPlayerID $master]
  set masterIp [getPlayerIP $master]
  if {$masterID != ""} {
	  set xml " <zone master=\"$masterID\">"
	  foreach slave $slaves {
		  set slaveIp [getPlayerIP $slave]
		  set slaveId [getPlayerID $slave]
		  append xml "<member ipaddress=\"$slaveIp\">$slaveId</member>"
	  }
	  append xml "</zone>"
      return $xml
  } else {
	  ::log::log error "Master not found"
	  return ""
  }
}

proc ::soundtouch::createZone {master slaveList} {
  variable path
  set masterIp [getPlayerIP $master]
  set xml [createZoneRequest $master $slaveList]
  if {$xml != ""} {
	  set url "http://$masterIp:8090/setZone"
	  set header "Content-Type: text/plain; charset=utf-8"
	  exec $path/curl --silent --data $xml -H $header $url
  }
}

proc ::soundtouch::removePlayerFromZone {master slaveList} {
  variable path
  set masterIp [getPlayerIP $master]
  set xml [_createZoneRequest $master $slaveList]
  if {$xml != ""} {
	  set url "http://$masterIp:8090/removeZoneSlave"
	  set header "Content-Type: text/plain; charset=utf-8"
	  exec $path/curl --silent --data $xml -H $header $url
  }
}

proc ::soundtouch::addPlayerToZone {master slaveList} {
  variable path
  set masterIp [getPlayerIP $master]
  set xml [_createZoneRequest $master $slaveList]
  if {$xml != ""} {
	  set url "http://$masterIp:8090/addZoneSlave"
	  set header "Content-Type: text/plain; charset=utf-8"
	  exec $path/curl --silent --data $xml -H $header $url
  }
}


proc ::soundtouch::removePlayer {master slaveList} {
  variable path
  set slaves [wsplit $slaveList ","]
  set masterID [getPlayerID $master]
  set masterIp [getPlayerIP $master]
  if {$masterID != ""} {
	  set xml " <zone master=\"$masterID\">"
	  foreach slave $slaves {
		  set slaveIp [getPlayerIP $slave]
		  set slaveId [getPlayerID $slave]
		  append xml "<member ipaddress=\"$slaveIp\">$slaveId</member>"
	  }
	  append xml "</zone>"
	  variable path
	  set url "http://$masterIp:8090/removeZoneSlave"
	  set header "Content-Type: text/plain; charset=utf-8"
	  exec $path/curl --silent --data $xml -H $header $url
  }
}

proc ::soundtouch::getVolume {ip playername} {
  variable path
  set url "http://$ip:8090/volume"
  set data [exec $path/curl --silent $url]
  regexp {<actualvolume>([0-9]{1,3})</actualvolume>} $data match i
  rega_script "var sv = dom.GetObject('BOSE_VOLUME_$playername');if (sv) {sv.State($i);}"
}

proc ::soundtouch::queryAll {} {
	# run thru all players and update the state
	variable config_file
	variable lock_id_config_file
	lock $lock_id_config_file
	set config [ini::open $config_file r]
	foreach player_name [ini::sections $config] {
	# do not use common section as a player
	  if {$player_name != "common"} {
  	  	set ip_address [ini::value $config $player_name "ip_address"]
  	  	getState $ip_address $player_name
  	  	getVolume $ip_address $player_name
  	  }
    }
    ini::close $config
	un_lock $lock_id_config_file
}

