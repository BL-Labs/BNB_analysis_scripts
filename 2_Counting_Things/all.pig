REGISTER pigUtils.jar

raw = LOAD '/user/hd/bnb/BNB*'
      USING pigUtils.ntriples.nTriplesLoader()
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

persons_authors = DISTINCT persons_authors;

-- Authorship from orgs

orgs_created_full = JOIN orgs by org, created by creator, labels by uri;

orgs_created = FOREACH orgs_created_full 
                     GENERATE orgs::org as org,
                              created::bnbid as bnbid,
                              labels::label as orgname;

orgs_created = DISTINCT orgs_created;

-- Works Agents directly contributed to
contributed_raw = FILTER raw 
               BY prop == 'http://www.bl.uk/schemas/bibliographic/blterms#hasContributedTo';

contributed = FOREACH contributed_raw GENERATE subj as contrib, obj as bnbid;

-- Contributions from Persons

persons_contrib_full = JOIN persons by person, contributed by contrib, labels by uri;

persons_contrib = FOREACH persons_contrib_full 
                     GENERATE persons::person as person,
                              contributed::bnbid as bnbid,
                              labels::label as personname;

-- Contributions from orgs

orgs_contrib_full = JOIN orgs by org, contributed by contrib, labels by uri;

orgs_contrib = FOREACH orgs_contrib_full 
                     GENERATE orgs::org as org,
                              contributed::bnbid as bnbid,
                              labels::label as orgname;

-- Remove duplicates
persons_contrib = DISTINCT persons_contrib;
orgs_contrib = DISTINCT orgs_contrib;

-- Clear previous storage directories
rmf creators
rmf contributions

-- Count person contribs
persons_contrib_outputs = GROUP persons_contrib by person;
persons_contrib_count = FOREACH persons_contrib_outputs GENERATE group, COUNT(persons_contrib) as works;

persons_contrib_sortedfreq = ORDER persons_contrib_count BY works DESC;

-- Count person contribs
orgs_contrib_outputs = GROUP orgs_contrib by org;
orgs_contrib_count = FOREACH orgs_contrib_outputs GENERATE group, COUNT(orgs_contrib) as works;

orgs_contrib_sortedfreq = ORDER orgs_contrib_count BY works DESC;

-- Store contributions and counts
STORE persons_contrib_sortedfreq INTO 'contributions/persons_contrib_count';
STORE persons_contrib_outputs INTO 'contributions/persons_contrib';

STORE orgs_contrib_sortedfreq INTO 'contributions/orgs_contrib_count';
STORE orgs_contrib_outputs INTO 'contributions/orgs_contrib';


-- Count person contribs
persons_created_outputs = GROUP persons_authors by person;
persons_count = FOREACH persons_created_outputs GENERATE group, COUNT(persons_authors) as works;

persons_sortedfreq = ORDER persons_count BY works DESC;

-- Count person contribs
orgs_created_outputs = GROUP orgs_created by org;
orgs_count = FOREACH orgs_created_outputs GENERATE group, COUNT(orgs_created) as works;

orgs_sortedfreq = ORDER orgs_count BY works DESC;

STORE persons_sortedfreq INTO 'creators/persons_author_count';
STORE persons_created_outputs INTO 'creators/persons_authors';

STORE orgs_sortedfreq INTO 'creators/orgs_created_count';
STORE orgs_created_outputs INTO 'creators/orgs_created_works';

