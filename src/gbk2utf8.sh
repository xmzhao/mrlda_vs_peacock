
dir=/user/test/xueminzhao/mrlda/sosoquerylog/raw_corpus
for i in `seq 0 199`; do
  filename=`printf "part-%05d" $i`
  path=$dir/$filename
  hadoop fs -get $path part-tmp
  iconv -f CP936 -t UTF-8 part-tmp >$filename
  hadoop fs -rmr $path
  hadoop fs -put $filename $path
  rm -rf part-tmp $filename
done
  
