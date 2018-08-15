A simple tcl wrapper to control your Bose SoundTouch devices.

Install this https://github.com/thkl/HM-SoundTouch/raw/master/hm-soundtouch.tar.gz at your ccu and reboot.

Then there is a small readme at http://ccuip/addons/soundtouch/. You may control your SoundTouch devices via system.Exec("/usr/local/addons/soundtouch/state.tcl NAME COMMAND ARGUMENT")
... but please see the readme ...


Sample Scripts:

Add a new Player to config

```
string stdout;string stderr;
system.Exec("/usr/local/addons/soundtouch/add.tcl 192.168.___.___",&stderr,&stdout);
WriteLine(stderr);
```

This will ask the player for its name and add it to the config. See output for any messages.
If a new player was found, this will also create all variables for that device at your ccu. 

You may also add new players via the webconfig at http://ccuip/addons/soundtouch/


Switch SoundTouch with name Test off

```
string name = "Test";
string stdout;string stderr;
system.Exec("/usr/local/addons/soundtouch/state.tcl "#name,&stderr,&stdout);
if (dom.GetObject("BOSE_POWER_"#name).State()==true) {
  system.Exec("/usr/local/addons/soundtouch/state.tcl "#name#" touch POWER",&stderr,&stdout);
}
```


Switch SoundTouch with name Test on and play Preset 1

```
string name = "Test";
string stdout;string stderr;
system.Exec("/usr/local/addons/soundtouch/state.tcl "#name,&stderr,&stdout);
if (dom.GetObject("BOSE_POWER_"#name).State()==false) {
  system.Exec("/usr/local/addons/soundtouch/state.tcl "#name#" touch POWER",&stderr,&stdout);
  system.Exec("/usr/local/addons/soundtouch/state.tcl "#name#" volume 20",&stderr,&stdout);
}
system.Exec("/usr/local/addons/soundtouch/state.tcl "#name#" touch PRESET_1",&stderr,&stdout);
system.Exec("/usr/local/addons/soundtouch/state.tcl "#name#" touch PLAY",&stderr,&stdout);
```


Query all known players and update ccu variables

```
string stdout;string stderr;
system.Exec("/usr/local/addons/soundtouch/state.tcl",&stderr,&stdout);
```
