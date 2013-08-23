REGISTER pignlproc.jar

raw = LOAD '/user/hd/bnbsample/part*'
      USING pignlproc.storage.nTriplesLoader()
      AS (subj: chararray, prop: chararray, obj: chararray, type: int);

-- rdfs:labels
labels = FILTER raw BY prop == 'http://www.w3.org/2000/01/rdf-schema#label';
labels = foreach labels generate subj as uri, obj as label;

-- People
persons_raw = FILTER raw 
             BY prop == 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type'
             AND obj == 'http://xmlns.com/foaf/0.1/Person';

persons = FOREACH persons_raw GENERATE subj as person;

-- Orgs
orgs_raw = FILTER raw 
	     BY prop == 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type'
	     AND obj == 'http://xmlns.com/foaf/0.1/Organization';

orgs = FOREACH orgs_raw GENERATE subj as org;


-- Works Agents directly created
created_raw = FILTER raw 
               BY prop == 'http://www.bl.uk/schemas/bibliographic/blterms#hasCreated';

created = FOREACH created_raw GENERATE subj as creator, obj as bnbid;

-- Authors

persons_authors_full = JOIN persons by person, created by creator, labels by uri;

persons_authors = FOREACH persons_authors_full 
                     GENERATE persons::person as person,
                              created::bnbid as bnbid,
                              labels::label as personname;

-- Authorship from orgs

orgs_created_full = JOIN orgs by org, created by creator, labels by uri;

orgs_created = FOREACH orgs_created_full 
                     GENERATE orgs::org as org,
                              created::bnbid as bnbid,
                              labels::label as orgname;

-- Remove duplicates
persons_authors = DISTINCT persons_authors;
orgs_created = DISTINCT orgs_created;

-- Clear previous storage directories
rmf /user/hd/creators

-- Count person contribs
persons_created_outputs = GROUP persons_authors by person;
persons_count = FOREACH persons_created_outputs GENERATE group, COUNT(persons_authors) as works;

persons_sortedfreq = ORDER persons_count BY works DESC;

-- Count person contribs
orgs_created_outputs = GROUP orgs_created by org;
orgs_count = FOREACH orgs_created_outputs GENERATE group, COUNT(orgs_contrib) as works;

orgs_sortedfreq = ORDER orgs_count BY works DESC;

STORE persons_sortedfreq INTO '/user/hd/creators/persons_author_count';
STORE persons_created_outputs INTO '/user/hd/creators/persons_authors';

STORE orgs_sortedfreq INTO '/user/hd/creators/orgs_created_count';
STORE orgs_created_outputs INTO '/user/hd/creators/orgs_created_works';

