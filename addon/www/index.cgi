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
 puts "Content-Type: text/html"
 puts "Status: 200 OK";
 puts ""
 puts "<meta http-equiv=\"refresh\" content=\"0; url=index.html\">"
}

proc action_removeplayer {} {
   catch { import name }
   ::soundtouch::deletePlayer $name
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

proc action_getVersion {} {
	set fileHandle [open /usr/local/addons/soundtouch/VERSION r]
	set version [string map {"\n" "" "\r" ""} [read $fileHandle]]
	
	puts "Content-Type: application/json"
	puts "Status: 200 OK";
	puts ""
	puts "{\"version\":\"$version\"}"
	close $fileHandle
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
