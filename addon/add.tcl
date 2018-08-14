#!/bin/tclsh
#!/bin/tclsh
#  Soundtouch Homematic TCL Stuff
#  2018 by thkl
#  https://github.com/thkl/HM-SoundTouch


load tclrega.so
source /usr/local/addons/soundtouch/lib/ini.tcl
source /usr/local/addons/soundtouch/lib/log.tcl

set config_file "/usr/local/etc/config/soundtouch.cfg"
set ip [lindex $argv 0]
set path "/usr/local/addons/soundtouch/"


proc checkConfig {} {
  global config_file
  if {![file exists $config_file]} {
	 set fo [open $config_file "w"] 	  
	 puts $fo "#SoundTouch Config"
	 close $fo
  }
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

### MAIN
  ::log::log info "HM Soundtouch"

checkConfig

if {[info exists ip]} {

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
} else {
  ::log::log error "must provide a ip"
}
  ::log::log info "exiting ..."
