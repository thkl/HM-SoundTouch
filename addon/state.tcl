#!/bin/tclsh
#  Soundtouch Homematic TCL Stuff
#  2018 by thkl
#  https://github.com/thkl/HM-SoundTouch


set path "/usr/local/addons/soundtouch/"
source $path/lib/log.tcl
source /usr/local/addons/soundtouch/lib/soundtouch.tcl


set name_or_ip [lindex $argv 0]
set cmd [lindex $argv 1]
set arg [lindex $argv 2]



### MAIN

::soundtouch::checkConfig

if {$argc > 0} {

# Check if name_or_ip is a IP
	set playername  $name_or_ip
	
	if {![regexp {^(?:(\d{1,2})|(1\d{2})|(2[0-4]\d)|(25[0-5]))(?:\.((\d{1,2})|(1\d{2})|(2[0-4]\d)|(25[0-5]))){3}$} $name_or_ip]} {
       set player_ip [expr {[::soundtouch::getPlayerIP $name_or_ip]}]
	} else {
       set player_ip  $name_or_ip
    }
	
	
	if {$cmd=="touch"} {
  		::soundtouch::keyAction $player_ip $arg "press"
  		::soundtouch::keyAction $player_ip $arg "release"
	}

    if {$cmd=="volume"} {
	  if {[info exists arg]} {
      	::soundtouch::setVolume $player_ip $arg
        ::soundtouch::getVolume $player_ip $playername
	  } else {
		::soundtouch::getVolume $player_ip $playername
    }
   }

   if {$cmd=="createzone"} {
	   	::soundtouch::createZone $playername $arg
   }

   if {$cmd=="addplayers"} {
	   	::soundtouch::addPlayerToZone $playername $arg
   }

   if {$cmd=="removeplayers"} {
	   	::soundtouch::removePlayerFromZone $playername $arg
   }


  if {$player_ip != ""} {
  	::soundtouch::getState $player_ip $playername						
  	::soundtouch::getVolume $player_ip $playername
  }
  
} else {
  ::soundtouch::queryAll 	
}
