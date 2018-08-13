
set version_url "https://raw.githubusercontent.com/thkl/HM-SoundTouch/master/VERSION"
set package_url "https://github.com/thkl/HM-SoundTouch/raw/master/hm-soundtouch.tar.gz"

set cmd ""
if {[info exists env(QUERY_STRING)]} {
	regexp {cmd=([^&]+)} $env(QUERY_STRING) match cmd
}
if {$cmd == "download"} {
	puts "<html><head><meta http-equiv=\"refresh\" content=\"0; url=${package_url}\" /></head></html>"
} else {
	puts [exec /usr/bin/wget -q --no-check-certificate -O- "${version_url}"]
}
