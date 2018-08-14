#!/bin/tclsh
#  Soundtouch Homematic TCL Stuff
#  2018 by thkl
#  https://github.com/thkl/HM-SoundTouch


load tclrega.so
set path "/usr/local/addons/soundtouch/"

source $path/lib/ini.tcl
source $path/lib/log.tcl

set config_file "/usr/local/etc/config/soundtouch.cfg"

set name_or_ip [lindex $argv 0]
set cmd [lindex $argv 1]
set arg [lindex $argv 2]


proc checkConfig {} {
  global config_file
  if {![file exists $config_file]} {
	 set fo [open $config_file "w"] 	  
	 puts $fo "#SoundTouch Config"
	 close $fo
  }
}

proc getPlayer {player_name} {
  global config_file
  set ip_address ""
  set config [ini::open $config_file r]
  if {[::ini::exists $config $player_name]} {
	 set ip_address [ini::value $config $player_name "ip_address"]
  } else {
	  ::log::log error "$name not in ini"
  }
  ini::close $config
  return $ip_address
}

proc getState {ip playername} {
  global path
  set url "http://$ip:8090/now_playing"
  set data [exec $path/curl --silent $url]
  regexp source=\"STANDBY\" $data match i
  if [info exists match] {
    rega_script "var sv = dom.GetObject('BOSE_POWER_$playername');if (sv) {if (sv.State() != false) { sv.State(false);}}"
  } else {
    rega_script "var sv = dom.GetObject('BOSE_POWER_$playername');if (sv) {if (sv.State() != true) { sv.State(true);}}"
  }
  
  regexp {<playStatus>(.*?)</playStatus>} $data match i
  if [info exists match] {
	  rega_script "var sv = dom.GetObject('BOSE_STATE_$playername');if (sv) {if (sv.State() != '$i') { sv.State('$i');}}"
  }
  
  regexp {<itemName>(.*?)</itemName>} $data match i
  if [info exists match] {
	  rega_script "var sv = dom.GetObject('BOSE_TRACK_$playername');if (sv) {if (sv.State() != '$i') { sv.State('$i');}}"
  }
}

proc keyAction {ip key state} {
  global path
  set url "http://$ip:8090/key"
  set parameter " <key state=\'$state\' sender=\'Gabbo\'>$key</key>'"
  set header "Content-Type: text/plain; charset=utf-8"
  exec $path/curl --silent --data $parameter -H $header $url
}

proc setVolume {ip volume} {
  global path
  set url "http://$ip:8090/volume"
  set parameter " <volume>$volume</volume>"
  set header "Content-Type: text/plain; charset=utf-8"
  exec $path/curl --silent --data $parameter -H $header $url
}

proc getVolume {ip playername} {
  global path
  set url "http://$ip:8090/volume"
  set data [exec $path/curl --silent $url]
  regexp {<actualvolume>([0-9]{1,3})</actualvolume>} $data match i
  rega_script "var sv = dom.GetObject('BOSE_VOLUME_$playername');if (sv) {sv.State($i);}"
}

### MAIN

checkConfig

if {$argc > 0} {

# Check if name_or_ip is a IP
	set playername  $name_or_ip
	
	if {![regexp {^(?:(\d{1,2})|(1\d{2})|(2[0-4]\d)|(25[0-5]))(?:\.((\d{1,2})|(1\d{2})|(2[0-4]\d)|(25[0-5]))){3}$} $name_or_ip]} {
       set player_ip [expr {[getPlayer $name_or_ip]}]
	} else {
       set player_ip  $name_or_ip
    }
	
	
	if {$cmd=="touch"} {
  		keyAction $player_ip $arg "press"
  		keyAction $player_ip $arg "release"
	}

    if {$cmd=="volume"} {
	  if {[info exists arg]} {
      	setVolume $player_ip $arg
         getVolume $player_ip $playername
	  } else {
		    getVolume $player_ip
    }
   }

  getState $player_ip $playername						
  getVolume $player_ip $playername

} else {
	# run thru all players and update the state
	set config [ini::open $config_file r]
	foreach player_name [ini::sections $config] {
	  ::log::log debug "Query Player $player_name "
  	  set ip_address [ini::value $config $player_name "ip_address"]
	  ::log::log debug "... at $ip_address ..."
  	  getState $ip_address $player_name
	  ::log::log debug "done ..."
    }
    ini::close $config
}
