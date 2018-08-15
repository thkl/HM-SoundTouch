#!/bin/tclsh

#  Soundtouch Homematic TCL Stuff
#  2018 by thkl
#  https://github.com/thkl/HM-SoundTouch

package require HomeMatic

source /usr/local/addons/soundtouch/lib/ini.tcl
source /usr/local/addons/soundtouch/lib/log.tcl
set path "/usr/local/addons/soundtouch/"

source /www/once.tcl
sourceOnce /www/cgi.tcl

set config_file "/usr/local/etc/config/soundtouch.cfg"

proc checkConfig {} {
  global config_file
  if {![file exists $config_file]} {
	 set fo [open $config_file "w"] 	  
	 puts $fo "#SoundTouch Config"
	 close $fo
  }
}

checkConfig


proc action_put_page {} {
puts {
<html>
<head>
	<meta charset="UTF-8">
	<meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.1.1/jquery.min.js" integrity="sha256-hVVnYaiADRTO2PzUGmuLJr8BLUSjGIZsDYGmIJLv2b8=" crossorigin="anonymous"></script>
	<script src="https://cdnjs.cloudflare.com/ajax/libs/i18next/8.1.0/i18next.min.js" ></script>
	<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery-i18next/1.2.0/jquery-i18next.min.js" ></script>
	<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/semantic-ui/2.2.7/semantic.min.css" integrity="sha256-wT6CFc7EKRuf7uyVfi+MQNHUzojuHN2pSw0YWFt2K5E=" crossorigin="anonymous" />
	<script src="https://cdnjs.cloudflare.com/ajax/libs/semantic-ui/2.2.7/semantic.min.js" integrity="sha256-flVaeawsBV96vCHiLmXn03IRJym7+ZfcLVvUWONCas8=" crossorigin="anonymous"></script>
	<script src="app.js?1=2">	</script>

	<style>
	</style>
	<title data-i18n="title">HM SoundTouch</title>
	<body>
	<div style="position: fixed; left: 50%; top: 2vh; z-index: 2000">
		<div style="position: relative; left: -50%;">
			<div class="ui container">
				<div id="message" class="ui message hidden" style="margin-left: 100px; margin-right: 100px; min-height: 50px; min-width: 340px">
					<i class="close icon" onclick="clear_message();"></i>
				</div>
			</div>
		</div>
	</div>

	<div style="padding-top: 5vw; padding-bottom: 5vw" class="ui container">
		<h1 class="ui center aligned dividing header" data-i18n="title">Homematic CCU Bose Soundtouch AddIn</h1>
	
		<h2 class="ui header">
			<i class="wifi icon"></i>
			<div data-i18n="listplayer" class="content">Player
			</div>
		</h2>
		<div class="ui list" id="listplayer">
			<table id="listplayer-info" class="ui celled stackable table">
				<thead>
					<tr>
						<th data-i18n="player_name">Player Name</th>
						<th data-i18n="player_ip">IP Address</th>
						<th data-i18n="player_ctrl"></th>
					</tr>
				</thead>
				<tbody>
				</tbody>
			</table>
	</div>
    
    <h2 class="ui header">
			<i class="info icon"></i>
			<div class="content">Info</div>
		</h2>
		<div style="width: 100%" class="ui">
			<table id="info-info" class="ui celled stackable table">
				<thead>
				<tbody>
				</tbody>
            </table>
		</div>
		
		
	</body>
	<script type="text/javascript">
	  getPlayer()
      getInfo()
	</script>
	</html>
}
}

proc action_removeplayer {} {
   catch { import name }
   global config_file
   set config [ini::open $config_file r+]
   if {[::ini::exists $config $name]} {
     ini::delete $config $name
	 ini::commit $config
   }
   ini::close $config
}

proc addVariable {name type subtype} {
  ::log::log info "creating variable $name at your ccu"
  set rega ""
  append rega "if (!dom.GetObject(\"$name\")) {\n"
  append rega "object vars = dom.GetObject( ID_SYSTEM_VARIABLES );\n"
  append rega "object newVar = dom.CreateObject( OT_VARDP );\n"
  append rega "newVar.Name(\"$name\");\n"
  append rega "newVar.ValueType($type);\n"
  append rega "newVar.ValueSubType($subtype);\n"
  append rega "vars.Add(newVar.ID());\n"
  append rega "}"
  rega_script $rega
}



proc action_addplayer {} {
   catch { import ip }
   global config_file
   global path
   set url "http://$ip:8090/info"
   set data [exec $path/curl --silent $url]
   regexp {<name>(.*?)</name>} $data match i
   
   if [info exists match] {
	    ::log::log info "Player $i found ..."
	    set config [ini::open $config_file r+]
		if {![::ini::exists $config $i]} {
			::log::log info "added $i to config"
			ini::set $config $i "ip_address" $ip
			ini::commit $config
			addVariable "BOSE_POWER_$i" "2" "2"
			addVariable "BOSE_STATE_$i" "20" "11"
			addVariable "BOSE_TRACK_$i" "20" "11"
			addVariable "BOSE_VOLUME_$i" "4" "0"
		} else {
			::log::log info "$i exists allready in config"
		}
		ini::close $config
  }
}

proc action_listplayer {} {
    global config_file
	set config [ini::open $config_file r]
	
	puts "Content-Type: application/json"
	puts "Status: 200 OK";
	puts ""
	puts "\["
    
	set first 1
	foreach player_name [ini::sections $config] {
		set ip_address [ini::value $config $player_name "ip_address"]
		
		if {$first == 1} {
			set first 0
         } else {
             puts ","
         }
		puts "\{\"name\":\"$player_name\",\"ip\":\"$ip_address\"\}"
     }
     puts "\]"
	ini::close $config
}


cgi_eval {
  
  cgi_debug -on
  cgi_input
  
  catch {
    import debug
    cgi_debug -on
  }
 
set action "put_page"
 catch { import action }
 action_$action
}
