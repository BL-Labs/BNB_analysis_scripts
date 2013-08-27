titles_raw = LOAD '/user/hd/bnbslices/titles/part*'
      AS (subj: chararray, prop: chararray, obj: chararray, type: int);

labels = LOAD '/user/hd/bnbslices/labels/part*'
      AS (subj: chararray, prop: chararray, obj: chararray, type: int);

enidlist_raw = LOAD '/user/hd/enidlist'
           USING PigStorage()
           AS (work: chararray);

enidlist = distinct enidlist_raw;

works = JOIN enidlist by work, titles_raw by subj, labels by subj;

titles_unordered = FOREACH works GENERATE enidlist::work, titles_raw::obj, labels::obj;

titles = ORDER titles_unordered BY enidlist::work ASC;

rmf enidresults
STORE titles INTO '/user/hd/enidresults';
