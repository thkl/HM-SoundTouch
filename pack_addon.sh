#!/bin/sh -e

version=$(cat VERSION)
addon_file="$(pwd)/hm-soundtouch.tar.gz"
tmp_dir=$(mktemp -d)

for f in VERSION update_script update_addon soundtouch addon www lib etc; do
	[ -e  $f ] && cp -a $f "${tmp_dir}/"
done
chmod 755 "${tmp_dir}/update_script"

cd ${tmp_dir};
tar --exclude=.* --exclude=._* -czvf "${addon_file}" *
rm -rf "${tmp_dir}"
