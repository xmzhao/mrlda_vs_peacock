
# Experiment 1 #

raw_corpus/part-00000

num_docs: 45w

num_topics: 100

vocab_size: 106000

num_mappers: 100

num_reducers: 20

total_iterations: 500

time: 33h15min

    ~/peacock/Mr.LDA> nohup hadoop jar Mr.LDA-0.0.1.jar cc.mrlda.VariationalInference \
      -input /user/test/xueminzhao/mrlda/sosoquerylog/corpus/document \
      -output /user/test/xueminzhao/mrlda/sosoquerylog/train \
      -term 106000 \
      -topic 100 \
      -iteration 500 \
      -mapper 100 \
      -reducer 20 \
      -localmerge \
      >vi.log 2>&1 &

![logllhood curve](images/exp1-logllhood.png)

[topic top words of iteration 40](ttw/exp1-ttw.40)

[topic top words of iteration 100](ttw/exp1-ttw.100)

[topic top words of iteration 200](ttw/exp1-ttw.200)

[topic top words of iteration 500](ttw/exp1-ttw.500)

# Experiment 2 #

raw_corpus/part-00[0,1]*

num_docs: 94,787,423

vocab_size: 275,027

    ~/peacock/Mr.LDA2> nohup hadoop jar Mr.LDA-0.0.1.jar cc.mrlda.VariationalInference \
      -input /user/test/xueminzhao/mrlda/sosoquerylog2/corpus/document \
      -output /user/test/xueminzhao/mrlda/sosoquerylog2/train \
      -term 275027 \
      -topic 1000 \
      -iteration 300 \
      -mapper 100 \
      -reducer 20 \
      -localmerge \
      >vi.log 2>&1 &  

