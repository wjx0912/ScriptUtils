#!/bin/bash
url_source_prefix="http://username:password@192.168.7.163:65065/username"
url_dest_prefix="http://username:password@192.168.7.163:65163/username"

copy_prj() {
	echo "===========>>>>>>>>>"
	echo $url_source_prefix"/"$1".git ---> "$url_dest_prefix"/"$1".git"
	git clone --bare $url_source_prefix/$1.git
	cd $1.git
	git push --mirror $url_dest_prefix/$1.git
	cd ..
	rm $1.git -fr
	echo "===========<<<<<<<<<"
}

projects="prj1 prj2 prj3"
for prj in $projects
do
	copy_prj $prj
done


