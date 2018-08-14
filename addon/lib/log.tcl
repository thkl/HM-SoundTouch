namespace eval log {
	variable logtag "soundtouch.tcl"
	variable logfacility "local1"
	variable path "/usr/local/addons/soundtouch/"
	# 0=panic, 1=alert 2=crit 3=err 4=warn 5=notice 6=info 7=debug
	variable loglevel 7
	variable loglevels {panic alert crit err warn notice info debug}
}


proc ::log::log {lvl msg} {
    variable logtag
    variable logfacility
    variable loglevel
    variable loglevels

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