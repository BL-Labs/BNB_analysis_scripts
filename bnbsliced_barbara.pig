titles_raw = LOAD '/user/hd/bnbslices/titles/part*'
      AS (subj: chararray, prop: chararray, obj: chararray, type: int);

labels = LOAD '/user/hd/bnbslices/labels/part*'
      AS (subj: chararray, prop: chararray, obj: chararray, type: int);

barblist_raw = LOAD '/user/hd/barblist'
           USING PigStorage()
           AS (work: chararray);

barblist = distinct barblist_raw;

works_unlabelled = JOIN barblist by work, titles_raw by subj;

works = JOIN works_unlabelled by barblist::work left outer, labels by subj;

titles_unordered = FOREACH works GENERATE barblist::work, titles_raw::obj, labels::obj;

titles = ORDER titles_unordered BY barblist::work ASC;

rmf barbresults
STORE titles INTO '/user/hd/barbresults';
