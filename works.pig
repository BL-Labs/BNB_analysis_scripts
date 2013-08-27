REGISTER pigUtils.jar

raw_total = LOAD '/user/hd/bnb/BNB*'
      USING pigUtils.ntriples.nTriplesLoader()
      AS (subj: chararray, prop: chararray, obj: chararray, type: int);

raw = SAMPLE raw_total 0.05;

enidlist = LOAD '/user/hd/enidlist'
           USING PigStorage()
           AS (work: chararray);

titles_raw = FILTER raw 
             BY prop == 'http://purl.org/dc/terms/title';

works = JOIN enidlist by work, titles_raw by subj;

titles_unordered = FOREACH works GENERATE enidlist::work, titles_raw::obj;

titles = ORDER titles_unordered BY enidlist::work ASC;

STORE titles INTO '/user/hd/enidresults';
