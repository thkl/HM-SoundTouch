#!/bin/tclsh

#  Soundtouch Homematic TCL Stuff
#  2018 by thkl
#  https://github.com/thkl/HM-SoundTouch


load tclrega.so

source /usr/local/addons/soundtouch/lib/soundtouch.tcl
source /usr/local/addons/soundtouch/lib/log.tcl

set ip [lindex $argv 0]

### MAIN
  ::log::log info "HM Soundtouch"

::soundtouch::checkConfig

if {[info exists ip]} {

  set result [::soundtouch::addPlayer $ip]
  if {$result == -1} {
	::log::log error "Player with $ip exists"
  } else {
	::log::log error "Player with $ip added"
  }
  
} else {
  ::log::log error "must provide a ip"
}
  ::log::log info "exiting ..."
