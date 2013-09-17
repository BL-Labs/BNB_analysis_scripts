REGISTER pigUtils.jar

total = LOAD '/user/hd/bnb/*'
      USING pigUtils.ntriples.unstrippedNTriplesLoader()
      AS (subj: chararray, prop: chararray, obj: chararray);

sampleset = SAMPLE total 0.1;

STORE sampleset INTO '/user/hd/bnbsample' USING PigStorage(' ');
