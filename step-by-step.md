
# 编译 #

从`https://github.com/lintool/Mr.LDA`下载Mr.LDA.zip, 运行:

    cocktail@linux-nlp:~/proj/soft> unzip Mr.LDA.zip
    cocktail@linux-nlp:~/proj/soft> cd Mr.LDA 
    cocktail@linux-nlp:~/proj/soft/Mr.LDA> ant
    ...
    BUILD SUCCESSFUL
    Total time: 4 seconds
  
    cocktail@linux-nlp:~/proj/soft/Mr.LDA> ant export
    ...
    export:
      Building jar: /home/cocktail/proj/soft/Mr.LDA/bin/Mr.LDA-0.0.1.jar

    BUILD SUCCESSFUL
    Total time: 38 seconds
  
    cocktail@linux-nlp:~/proj/soft/Mr.LDA> ll bin
    total 22438
    -rw-r--r-- 1 cocktail users 22951880 2013-03-20 17:12 Mr.LDA-0.0.1.jar
  
# 准备语料 #

  Mr. LDA takes raw text file as input, every row in the text file represents a stand-alone document. 
  Document title and content are separated by a tab ('\t'), and words in the content are 
  separated by a space (' '). The raw input text file should look like this:

    'Big Bang Theory' Brings Stephen Hawking on as Guest Star	'The Big Bang Theory' is getting a visit from Stephen Hawking. The renowned theoretical physicist will guest-star on the April 5 episode of the CBS comedy, the network said Monday. In the cameo, Hawking visits uber-geek Sheldon Cooper (Jim Parsons) at work 'to share his beautiful mind with his most ardent admirer,' according to CBS. Executive producer Bill Prady said that having Hawking on the show had long been a goal, though it seemed unattainable. When people would ask us who a dream guest star' for the show would be, we would always joke and say Stephen Hawking knowing that it was a long shot of astronomical proportions, Prady said. In fact, we're not exactly sure how we got him. It's the kind of mystery that could only be understood by, say, a Stephen Hawking. Hawking, known for his book A Brief History of Time, has appeared on television comedies before, albeit in voice work. Hawking has done a guest spot on 'Futurama' and appeared as himself on several episodes of 'The Simpsons.'
    The World's Best Gourmet Pizza: 'Tropical Pie' Wins Highest Honor	To make the world's best pizza you'll need dough, mozzarella cheese and some top shelf tequila. On Thursday, top pizza-makers from around the globe competed for the title of 'World's Best Pizza' at the International Pizza Expo in Las Vegas. At stake was $10,000 and the highest honor in the industry. This year's big winner was anything but traditional. The 'Tropical Pie' - a blend melted asiago and mozzarella cheese, topped with shrimps, thinly sliced and twisted limes, a fresh mango salsa, all resting on a rich pineapple cream sauce infused with Patron. The recipe, devised by mad pizza scientist Andrew Scudera of Goodfella's Brick Oven Pizza in Staten Island, was months in the making.ame up with idea to use tequila, but it was a collaboration,' Andrew tells Shine. 'Everyone here at the restaurant dived in and gave their input, helping to perfect the recipe by the time we brought it to the show.' The competition in Vegas was steep-particularly in the 'gourmet' category, where the Tropical Pie was entered. 
  
  将上述两个文档放到`test-corpus.txt`文件中, 得到测试使用的语料文件.
  
    test@TianJin-10-168-128-44:~/peacock/Mr.LDA> ll
    总计 22448
    -rw-r--r-- 1 test users 22951880 2013-03-20 14:27 Mr.LDA-0.0.1.jar
    -rw-r--r-- 1 test users     2147 2013-03-20 15:35 test-corpus.txt

# 转化为训练程序需要格式 #

  将文件`test-corpus.txt`上传到hdfs, 使用工具`ParseCorpus`生成训练程序`VariationalInference`需要的语料格式.
  
    hadoop fs -put test-corpus.txt /user/test/xueminzhao/mrlda/test/raw-corpus
  
    hadoop jar Mr.LDA-0.0.1.jar cc.mrlda.ParseCorpus \
     -input /user/test/xueminzhao/mrlda/test/raw-corpus/test-corpus.txt \
     -output /user/test/xueminzhao/mrlda/test/corpus
  
    hadoop fs -ls /user/test/xueminzhao/mrlda/test/corpus                                 
    Found 3 items
    drwxr-xr-x   - test supergroup          0 2013-03-20 15:47 /user/test/xueminzhao/mrlda/test/corpus/document
    -rw-r--r--   3 test supergroup       5068 2013-03-20 15:46 /user/test/xueminzhao/mrlda/test/corpus/term
    -rw-r--r--   3 test supergroup        233 2013-03-20 15:46 /user/test/xueminzhao/mrlda/test/corpus/title
  
  File `term` stores the mapping between a unique token and its unique integer ID. 
  Similarly, `title` stores the mapping between a document title to its unique integer ID. 
  Both of these two files are in sequence file format, key-ed by `IntWritable.java` and value-d by `Text.java`.
  
    hadoop jar Mr.LDA-0.0.1.jar edu.umd.cloud9.io.ReadSequenceFile /user/test/xueminzhao/mrlda/test/corpus/term | more
    
    13/03/20 16:48:01 INFO util.NativeCodeLoader: Loaded the native-hadoop library
    13/03/20 16:48:01 INFO zlib.ZlibFactory: Successfully loaded & initialized native-zlib library
    13/03/20 16:48:01 INFO compress.CodecPool: Got brand-new decompressor
    Reading /user/test/xueminzhao/mrlda/test/corpus/term...

    Key type: class org.apache.hadoop.io.IntWritable
    Value type: class org.apache.hadoop.io.Text

    Record 0
    Key: 1
    Value: hawking
    ----------------------------------------
    Record 1
    Key: 2
    Value: pizza
    ----------------------------------------
  
    hadoop jar Mr.LDA-0.0.1.jar edu.umd.cloud9.io.ReadSequenceFile /user/test/xueminzhao/mrlda/test/corpus/title
    
    Reading /user/test/xueminzhao/mrlda/test/corpus/title...

    Key type: class org.apache.hadoop.io.IntWritable
    Value type: class org.apache.hadoop.io.Text

    Record 0
    Key: 1
    Value: 'Big Bang Theory' Brings Stephen Hawking on as Guest Star
    ----------------------------------------
    Record 1
    Key: 2
    Value: The World's Best Gourmet Pizza: 'Tropical Pie' Wins Highest Honor
    ----------------------------------------
    2 records read.
  
  The data format for Mr. LDA package is defined in `class Document.java`. 
  It consists an `HMapII.java` object, storing all `word:count` pairs in a document using an `integer:integer` hash map. 
  Take note that the word index starts from 1, whereas index 0 is reserved for system message.
  
    hadoop jar Mr.LDA-0.0.1.jar edu.umd.cloud9.io.ReadSequenceFile /user/test/xueminzhao/mrlda/test/corpus/document/part-00000
    
    Reading /user/test/xueminzhao/mrlda/test/corpus/document/part-00000...

    Key type: class org.apache.hadoop.io.IntWritable
    Value type: class cc.mrlda.Document

    Record 0
    Key: 2
    Value: content: 2:6 8:2 12:2 14:2 15:2 17:2 16:2 19:2 20:2 23:2 22:2 25:2 28:1 31:1 30:1 34:1 35:1 33:1 39:1 36:1 37:1 42:1 43:1 40:1 41:1 46:1 45:1 51:1 54:1 53:1 52:1 58:1 62:1 61:1 68:1 69:1 64:1 73:1 74:1 75:1 85:1 84:1 83:1 82:1 93:1 94:1 89:1 91:1 90:1 102:1 103:1 100:1 98:1 97:1 111:1 109:1 107:1 104:1 117:1 115:1 114:1 112:1 126:1 125:1 124:1 121:1 138:1 143:1 129:1 131:1 133:1 134:1 153:1 154:1 157:1 158:1 159:1 147:1 150:1 175:1 172:1 163:1 162:1 161:1 165:1 178:1 177:1 180:1 181:1 
    gamma:  null
    ----------------------------------------
    1 records read.

# 训练 #

  训练工具为`VariationalInference`, 其支持`从原始语料开始训练`/`从之前暂停的任务恢复训练`/`使用Held-out数据Test模型`.

## 从原始语料开始训练 ##

  `VariationalInference`支持的输入文件格式就是`ParseCorpus`的输出目录中的document目录下的文件格式.
  
    hadoop jar Mr.LDA-0.0.1.jar cc.mrlda.VariationalInference \
     -input /user/test/xueminzhao/mrlda/test/corpus/document \
     -output /user/test/xueminzhao/mrlda/test/train \
     -term 100 \
     -topic 2 \
     -iteration 30 \
     -mapper 2 \
     -reducer 2 \
     -localmerge
    
    ...
    13/03/20 18:06:34 INFO mrlda.VariationalInference: Log likelihood after iteration 9 is -980.11
    13/03/20 18:06:34 INFO mrlda.VariationalInference: Model converged after 9 iterations...
    
    hadoop fs -ls /user/test/xueminzhao/mrlda/test/train
    Found 21 items
    -rw-r--r--   3 test supergroup        135 2013-03-20 17:04 /user/test/xueminzhao/mrlda/test/train/alpha0
    -rw-r--r--   3 test supergroup        135 2013-03-20 17:04 /user/test/xueminzhao/mrlda/test/train/alpha1
    -rw-r--r--   3 test supergroup        135 2013-03-20 17:32 /user/test/xueminzhao/mrlda/test/train/alpha2
    -rw-r--r--   3 test supergroup        135 2013-03-20 17:45 /user/test/xueminzhao/mrlda/test/train/alpha3
    -rw-r--r--   3 test supergroup        135 2013-03-20 17:46 /user/test/xueminzhao/mrlda/test/train/alpha4
    -rw-r--r--   3 test supergroup        135 2013-03-20 17:46 /user/test/xueminzhao/mrlda/test/train/alpha5
    -rw-r--r--   3 test supergroup        135 2013-03-20 17:47 /user/test/xueminzhao/mrlda/test/train/alpha6
    -rw-r--r--   3 test supergroup        135 2013-03-20 17:48 /user/test/xueminzhao/mrlda/test/train/alpha7
    -rw-r--r--   3 test supergroup        135 2013-03-20 18:05 /user/test/xueminzhao/mrlda/test/train/alpha8
    -rw-r--r--   3 test supergroup        135 2013-03-20 18:06 /user/test/xueminzhao/mrlda/test/train/alpha9
    -rw-r--r--   3 test supergroup       2351 2013-03-20 17:22 /user/test/xueminzhao/mrlda/test/train/beta1
    -rw-r--r--   3 test supergroup       2352 2013-03-20 17:44 /user/test/xueminzhao/mrlda/test/train/beta2
    -rw-r--r--   3 test supergroup       2364 2013-03-20 17:45 /user/test/xueminzhao/mrlda/test/train/beta3
    -rw-r--r--   3 test supergroup       2333 2013-03-20 17:46 /user/test/xueminzhao/mrlda/test/train/beta4
    -rw-r--r--   3 test supergroup       1873 2013-03-20 17:47 /user/test/xueminzhao/mrlda/test/train/beta5
    -rw-r--r--   3 test supergroup        958 2013-03-20 17:48 /user/test/xueminzhao/mrlda/test/train/beta6
    -rw-r--r--   3 test supergroup        962 2013-03-20 18:04 /user/test/xueminzhao/mrlda/test/train/beta7
    -rw-r--r--   3 test supergroup        958 2013-03-20 18:05 /user/test/xueminzhao/mrlda/test/train/beta8
    -rw-r--r--   3 test supergroup        961 2013-03-20 18:06 /user/test/xueminzhao/mrlda/test/train/beta9
    drwxr-xr-x   - test supergroup          0 2013-03-20 18:06 /user/test/xueminzhao/mrlda/test/train/gamma9
    drwxr-xr-x   - test supergroup          0 2013-03-20 18:06 /user/test/xueminzhao/mrlda/test/train/temp
    
    hadoop fs -ls /user/test/xueminzhao/mrlda/test/train/gamma9
    Found 2 items
    -rw-r--r--   3 test supergroup        355 2013-03-20 18:05 /user/test/xueminzhao/mrlda/test/train/gamma9/gamma_gamma-m-00000
    -rw-r--r--   3 test supergroup        345 2013-03-20 18:05 /user/test/xueminzhao/mrlda/test/train/gamma9/gamma_gamma-m-00001

    hadoop fs -ls /user/test/xueminzhao/mrlda/test/train/temp
    Found 3 items
    -rw-r--r--   3 test supergroup          0 2013-03-20 18:06 /user/test/xueminzhao/mrlda/test/train/temp/_SUCCESS
    drwxr-xr-x   - test supergroup          0 2013-03-20 18:05 /user/test/xueminzhao/mrlda/test/train/temp/_logs
    -rw-r--r--   3 test supergroup        138 2013-03-20 18:05 /user/test/xueminzhao/mrlda/test/train/temp/part-00001