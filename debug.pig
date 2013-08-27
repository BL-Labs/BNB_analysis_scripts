REGISTER pigUtils.jar

raw = LOAD '/user/hd/bnb/BNB_201207_nTriples_f4'
      USING pigUtils.ntriples.nTriplesLoader() 
      AS (subj: chararray, prop: chararray, obj: chararray, objflag: int);

rmf /user/hd/raw
STORE raw INTO '/user/hd/raw';
