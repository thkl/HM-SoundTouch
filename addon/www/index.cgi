#!/bin/tclsh

#  Soundtouch Homematic TCL Stuff
#  2018 by thkl
#  https://github.com/thkl/HM-SoundTouch

package require HomeMatic

source /usr/local/addons/soundtouch/lib/ini.tcl
source /usr/local/addons/soundtouch/lib/log.tcl
source /usr/local/addons/soundtouch/lib/soundtouch.tcl

source /www/once.tcl
sourceOnce /www/cgi.tcl

::soundtouch::checkConfig


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
						<th data-i18n="player_name" width="25%">Player Name</th>
						<th data-i18n="player_ip" width="25%">IP Address</th>
						<th data-i18n="player_ctrl" width="50%"></th>
					</tr>
				</thead>
				<tbody>
				</tbody>
			</table>
	</div>
    
    <h2 class="ui header">
			<i class="info icon"></i>
			<div class="content">Daemon</div>
		</h2>
		<div style="width: 100%" class="ui">
			<table id="idaemon" class="ui celled stackable table">
				<thead><tr><th width="50%">Refresh</th><th width="50%"></th></tr></thead>
				<tbody>
					<tr><td><input type="text" name="refresh" id="refresh" /></td><td><div class="ui green basic button" id="saveRefresh" onClick="saveRefresh()">Save</div></td></tr>
					<tr><td colspan="2">The addon will auto refresh the status of all know Soundtouch devices at the given interval. Set to -1 will disable the auto refresh.</td></tr>
				</tbody>
            </table>
		</div>
    
    <h2 class="ui header">
			<i class="info icon"></i>
			<div class="content">Info</div>
		</h2>
		<div style="width: 100%" class="ui">
			<table id="info-info" class="ui celled stackable table">
				<thead><tr><th data-i18n="info"></th></thead>
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
   ::soundtouch::removePlayer $name
}

proc action_setRefresh {} {
   catch { import refresh }
   ::soundtouch::saveSettings "refresh" $refresh
   puts "Content-Type: application/json"
	puts "Status: 200 OK";
	puts ""
	puts "{\"refresh\":$refresh}"
}


proc action_getRefresh {} {
   catch { import refresh }
   set refreshtime [::soundtouch::loadSettings "refresh" 20]
   puts "Content-Type: application/json"
	puts "Status: 200 OK";
	puts ""
	puts "{\"refresh\":$refreshtime}"
}


proc action_addplayer {} {
   catch { import ip }
   ::soundtouch::addPlayer $ip
}

proc action_listplayer {} {
	puts "Content-Type: application/json"
	puts "Status: 200 OK";
	puts ""
	puts [::soundtouch::listPlayer]
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
