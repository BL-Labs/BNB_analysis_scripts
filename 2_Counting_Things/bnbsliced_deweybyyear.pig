subjects_raw = LOAD '/user/hd/bnbslices/subjects/part*'
      AS (subj: chararray, prop: chararray, obj: chararray, type: int);

simplepubevents = LOAD '/user/hd/bnbslices/simplepubevents/part*'
      AS (subj: chararray, prop: chararray, obj: chararray, type: int);

dates = LOAD '/user/hd/bnbslices/dates/part*'
      AS (subj: chararray, prop: chararray, obj: chararray, type: int);

-- Get just the dewey
-- eg http://bnb.data.bl.uk/id/concept/ddc/e18/428.4071

uri_subjects = FILTER subjects_raw BY SUBSTRING(obj, 33, 36) == 'ddc';

subjects = FOREACH uri_subjects 
               GENERATE subj as work, 
                        SUBSTRING(obj, 37, 50) as deweynumber;

-- Join the pub events with the dates
pubdates_joined = JOIN simplepubevents by obj, dates by subj;

pubdates = FOREACH pubdates_joined
             GENERATE simplepubevents::subj as work, dates::obj as date;

-- Join the subjects to the works and group by date
-- Inner join, as we don't care about works without a dewey uri
subjects_by_dates_join = JOIN subjects by work, pubdates by work;

subjects_by_date_distinct = DISTINCT subjects_by_dates_join;

subjects_by_date = FOREACH subjects_by_date_distinct
                    GENERATE SUBSTRING(subjects::deweynumber, 0, 6) as deweynumber,
                             SUBSTRING(pubdates::date, 37,41) as date;

subject_count_group = GROUP subjects_by_date by (deweynumber, date);

subject_counts = FOREACH subject_count_group
                    GENERATE group.deweynumber as deweynumber,
                             group.date as date,
                             COUNT(subjects_by_date) as number;

subject_counts_ordered = ORDER subject_counts BY date, deweynumber;

rmf deweybydate

STORE subject_counts_ordered INTO 'deweybydate';

