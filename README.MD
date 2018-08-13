A simple tcl wrapper to control your Bose SoundTouch devices.

Install this https://github.com/thkl/HM-SoundTouch/raw/master/hm-soundtouch.tar.gz at your ccu and reboot.

Then there is a small readme at http://ccuip/addons/soundtouch/. You may control your SoundTouch devices via system.Exec("/usr/local/addons/soundtouch/state.tcl IP COMMAND ARGUMENT")
... but please see the readme ...


Sample Scripts:

Switch SoundTouch off

`
string ip = "192.168.___.___";

string stdout;string stderr;

system.Exec("/usr/local/addons/soundtouch/state.tcl "#ip,&stderr,&stdout);

if (dom.GetObject("BOSE_POWER_"#ip).State()==true) {

system.Exec("/usr/local/addons/soundtouch/state.tcl "#ip#" touch POWER",&stderr,&stdout);

}
`


Switch SoundTouch on and play Preset 1

`
string ip = "192.168.___.___";

string stdout;string stderr;

system.Exec("/usr/local/addons/soundtouch/state.tcl "#ip,&stderr,&stdout);

if (dom.GetObject("BOSE_POWER_"#ip).State()==false) {

system.Exec("/usr/local/addons/soundtouch/state.tcl "#ip#" touch POWER",&stderr,&stdout);

system.Exec("/usr/local/addons/soundtouch/state.tcl "#ip#" volume 20",&stderr,&stdout);

}

system.Exec("/usr/local/addons/soundtouch/state.tcl "#ip#" touch PRESET_1",&stderr,&stdout);

system.Exec("/usr/local/addons/soundtouch/state.tcl "#ip#" touch PLAY",&stderr,&stdout);
`
