load tclrega.so
sourceOnce /usr/local/addons/soundtouch/lib/log.tcl


namespace eval rega {
	
}

proc ::rega::addVariable {name type subtype} {
  ::log::log info "creating variable $name at your ccu"
  set str_rega ""
  append str_rega "if (!dom.GetObject(\"$name\")) {\n"
  append str_rega "object vars = dom.GetObject( ID_SYSTEM_VARIABLES );\n"
  append str_rega "object newVar = dom.CreateObject( OT_VARDP );\n"
  append str_rega "newVar.Name(\"$name\");\n"
  append str_rega "newVar.ValueType($type);\n"
  append str_rega "newVar.ValueSubType($subtype);\n"
  append str_rega "vars.Add(newVar.ID());\n"
  append str_rega "}"
  rega_script $str_rega
}


proc ::rega::setVariable {name value} {
	rega_script "var sv = dom.GetObject('$name');if (sv) {if (sv.State() != $value) { sv.State($value);}}"
}

proc ::rega::setStrVariable {name value} {
	rega_script "var sv = dom.GetObject('$name');if (sv) {if (sv.State() != '$value') { sv.State('$value');}}"
}