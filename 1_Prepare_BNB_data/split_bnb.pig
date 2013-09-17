REGISTER pigUtils.jar

raw = LOAD '/user/hd/bnb/BNB*'
      USING pigUtils.ntriples.nTriplesLoader()
      AS (subj: chararray, prop: chararray, obj: chararray, type: int);

titles = FILTER raw 
         BY prop == 'http://purl.org/dc/terms/title'
         OR prop == 'http://purl.org/dc/terms/alternative';

titles = DISTINCT titles;

labels = FILTER raw BY prop == 'http://www.w3.org/2000/01/rdf-schema#label';
labels = DISTINCT labels;

authors = FILTER raw BY prop == 'http://www.bl.uk/schemas/bibliographic/blterms#hasCreated';
authors = DISTINCT authors;

contrib = FILTER raw BY prop == 'http://www.bl.uk/schemas/bibliographic/blterms#hasContributedTo';
contrib = DISTINCT contrib;

subjects = FILTER raw BY prop == 'http://purl.org/dc/terms/subject';
subjects = DISTINCT subjects;

simplepubevent = FILTER raw 
           BY prop == 'http://www.bl.uk/schemas/bibliographic/blterms#publication';
simplepubevent = DISTINCT simplepubevent;

pubevent = FILTER raw 
           BY prop == 'http://www.bl.uk/schemas/bibliographic/blterms#publication'
           OR prop == 'http://www.bl.uk/schemas/bibliographic/blterms#publicationStart'
           OR prop == 'http://www.bl.uk/schemas/bibliographic/blterms#publicationEnd';
pubevent = DISTINCT pubevent;

dates = FILTER raw
        BY prop == 'http://purl.org/NET/c4dm/event.owl#time';
dates = DISTINCT dates;

rmf /user/hd/bnbslices
STORE titles INTO '/user/hd/bnbslices/titles';
STORE labels INTO '/user/hd/bnbslices/labels';
STORE authors INTO '/user/hd/bnbslices/authors';
STORE contrib INTO '/user/hd/bnbslices/contrib';
STORE subjects INTO '/user/hd/bnbslices/subjects';
STORE pubevent INTO '/user/hd/bnbslices/pubevents';
STORE simplepubevent INTO '/user/hd/bnbslices/simplepubevents';
STORE dates INTO '/user/hd/bnbslices/dates';
