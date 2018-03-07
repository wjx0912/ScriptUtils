#!/bin/bash
#usage: ./create_dts_diff_v2.x.sh path1 path2
__new_dir=$1
__old_dir=$2

#===========================================================
#WARNING:
#do *NOT* modify below
#===========================================================
work_dir=`pwd`
pushd $__new_dir > /dev/null || exit
new_dir=`pwd`
popd             > /dev/null || exit
pushd $__old_dir > /dev/null || exit
old_dir=`pwd`
popd             > /dev/null || exit
cd $work_dir

result_dir=DIFF_`date +"%Y%m%d_%H%M%S"`
result_filename=$work_dir/$result_dir/result.txt
result_filename_temp=$work_dir/$result_dir/result.txt.tmp
new_dir_len=${#new_dir}
old_dir_len=${#old_dir}
echo "begin time: `date`"
mkdir $result_dir
echo "new dir: $new_dir"
echo "old dir: $old_dir"
echo "create dir $result_dir, now scan directory......"

if [[ ! -d ${new_dir} ]];then
	echo "new: $new_dir not exist"
	exit
fi
if [[ ! -d ${old_dir} ]];then
	echo "old: $old_dir not exist"
	exit
fi

filt_file() {
	sed "/$1/d" $result_filename > $result_filename_temp
	cp -f $result_filename_temp $result_filename
	rm -f $result_filename_temp
}

diff -x .git -r -q $new_dir $old_dir >     $result_filename
filt_file .repo
filt_file .git
filt_file .svn
echo "scan directory finish"
echo ""
mkdir -p $result_dir/_NEW
mkdir -p $result_dir/_OLD

count=`wc $result_filename | awk '{print $1}'`
current=0

cat $result_filename | while read line
do      
	current=`expr $current + 1`
	if echo $line | grep Only; then
		path1=`echo $line| awk -F '[ :]' '{print $3}'`
		filename1=`echo $line| awk -F '[ :]' '{print $5}'`
		if echo $line | grep $new_dir > /dev/null; then
			filename2=${path1:new_dir_len+1}
			#echo "in new dir"
			#echo "path1: $path1, filename1: $filename1"
			#echo "filename2: $filename2"
			mkdir -p $result_dir/_NEW/$filename2
			cp -fr $path1/$filename1 $result_dir/_NEW/$filename2/$filename1
		else
			filename2=${path1:old_dir_len+1}
			mkdir -p $result_dir/_OLD/$filename2
			cp -fr $path1/$filename1 $result_dir/_OLD/$filename2/$filename1
			#echo "in old dir: $filename2"
			#echo "path1: $path1, filename1: $filename1"
		fi
	fi
	if echo $line | grep Files; then
		filename1_new=`echo $line | awk '{print $2}'`
		filename1_old=`echo $line | awk '{print $4}'`
		filename2_new=`dirname  $filename1_new`
		filename2_old=`dirname  $filename1_old`
		filename3_new=`basename $filename1_new`
		filename3_old=`basename $filename1_old`
		filename4_new=${filename2_new:new_dir_len+1}
		filename4_old=${filename2_old:old_dir_len+1}

		mkdir -p $result_dir/_NEW/$filename4_new
		mkdir -p $result_dir/_OLD/$filename4_old
		cp -f $filename1_new $result_dir/_NEW/$filename4_new
		cp -f $filename1_old $result_dir/_OLD/$filename4_old
	fi
done
echo ""
echo "all finish"