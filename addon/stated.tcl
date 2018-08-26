#!/bin/tclsh
#  Soundtouch Homematic TCL Stuff
#  2018 by thkl
#  https://github.com/thkl/HM-SoundTouch

source /usr/local/addons/soundtouch/lib/soundtouch.tcl
source /usr/local/addons/soundtouch/lib/log.tcl
set refreshtime 20

proc main_loop {} {
  	set refreshtime [::soundtouch::loadSettings "refresh" 20]
	if { [catch { query_all $refreshtime  } errormsg] } {
		log::log error "Error: '${errormsg}'"
		after 120000 main_loop
	} else {
		set rfr [expr {$refreshtime * 1000}]
#do not refresh under 5 seconds
		if {$rfr > 4999} {
			after $rfr main_loop
		} else {
			after 5000 main_loop
		}
	}
}

proc query_all {refreshTime} {
	# ignore refresh < 0
	if {$refreshTime > 0} {
		::soundtouch::queryAll
	}
}


if { "[lindex $argv 0 ]" != "daemon" } {
	catch {
		foreach dpid [split [exec pidof [file tail $argv0]] " "] {
			if {[pid] != $dpid} {
				exec kill $dpid
				log::log info "killed"
			}
		}
	}
	if { "[lindex $argv 0 ]" != "stop" } {
		log::log info "Daemonizing"
		exec $argv0 daemon &
	}
} else {
	::soundtouch::checkConfig
	log::log info "main loop init"
#	cd /
#	foreach fd {stdin stdout stderr} {
#		close $fd
#	}
	log::log info "main loop running"
	after 10 main_loop
	vwait forever
}
exit 0