#!/bin/tclsh

load tclrega.so
set logtag "soundtouch.tcl"
set logfacility "local1"
set path "/usr/local/addons/soundtouch/"
# 0=panic, 1=alert 2=crit 3=err 4=warn 5=notice 6=info 7=debug
set loglevel 7

set loglevels {panic alert crit err warn notice info debug}
set ip [lindex $argv 0]
set cmd [lindex $argv 1]
set arg [lindex $argv 2]

proc log {lvl msg} {
    global logtag
    global logfacility
    global loglevel
    global loglevels

    set lvlnum [lsearch $loglevels $lvl]

    if {$lvlnum <= $loglevel} {
      if {$lvlnum <= 3} {
        catch {exec logger -s -t $logtag -p $logfacility.$lvl $msg}
      } else {
        puts "$lvl: $msg"
        catch {exec logger -t $logtag -p $logfacility.$lvl $msg}
      }
    }
}

proc getState {ip} {
  global path
  set url "http://$ip:8090/now_playing"
  set data [exec $path/curl --silent $url]
  regexp source=\"STANDBY\" $data match i
  if [info exists match] {
    rega_script "var sv = dom.GetObject('BOSE_POWER_$ip');if (sv) {sv.State(false);}"
  } else {
    rega_script "var sv = dom.GetObject('BOSE_POWER_$ip');if (sv) {sv.State(true);}"
  }
  regexp {<playStatus>(.*?)</playStatus>} $data match i
  rega_script "var sv = dom.GetObject('BOSE_STATE_$ip');if (sv) {sv.State('$i');}"
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

proc getVolume {ip} {
  global path
  set url "http://$ip:8090/volume"
  set data [exec $path/curl --silent $url]
  regexp {<actualvolume>([0-9]{1,3})</actualvolume>} $data match i
  rega_script "var sv = dom.GetObject('BOSE_VOLUME_$ip');if (sv) {sv.State($i);}"
}

if {[info exists ip]} {

	if {$cmd=="touch"} {
  		keyAction $ip $arg "press"
  		keyAction $ip $arg "release"
	}

  if {$cmd=="volume"} {
	  if {[info exists arg]} {
      	setVolume $ip $arg
        getVolume $ip
	  } else {
		    getVolume $ip
    }
  }

  getState $ip
  getVolume $ip

} else {
    log info "missing ip"
}
