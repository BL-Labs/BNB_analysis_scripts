REGISTER pignlproc.jar

total = LOAD '/user/hd/bnb/*'
      USING pignlproc.storage.unstrippedNTriplesLoader()
      AS (subj: chararray, prop: chararray, obj: chararray);

sampleset = SAMPLE total 0.1;

STORE sampleset INTO '/user/hd/bnbsample' USING PigStorage(' ');
