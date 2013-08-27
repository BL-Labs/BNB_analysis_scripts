REGISTER pigUtils.jar

raw = LOAD '/user/hd/bnb/BNB*'
      USING pigUtils.ntriples.nTriplesLoader()
      AS (subj: chararray, prop: chararray, obj: chararray, type: int);

titles = FILTER raw 
         BY prop == 'http://purl.org/dc/terms/title'
         OR prop == 'http://purl.org/dc/terms/alternative';

labels = FILTER raw BY prop == 'http://www.w3.org/2000/01/rdf-schema#label';

authors = FILTER raw BY prop == 'http://www.bl.uk/schemas/bibliographic/blterms#hasCreated';

contrib = FILTER raw BY prop == 'http://www.bl.uk/schemas/bibliographic/blterms#hasContributedTo';

subjects = FILTER raw BY prop == 'http://purl.org/dc/terms/subjects';

pubevent = FILTER raw 
           BY prop == 'http://www.bl.uk/schemas/bibliographic/blterms#publication'
           OR prop == 'http://www.bl.uk/schemas/bibliographic/blterms#publicationStart'
           OR prop == 'http://www.bl.uk/schemas/bibliographic/blterms#publicationEnd';

dates = FILTER raw
        BY prop == 'http://purl.org/NET/c4dm/event.owl#time';

rmf /user/hd/bnbslices
STORE titles INTO '/user/hd/bnbslices/titles';
STORE labels INTO '/user/hd/bnbslices/labels';
STORE authors INTO '/user/hd/bnbslices/authors';
STORE contrib INTO '/user/hd/bnbslices/contrib';
STORE subjects INTO '/user/hd/bnbslices/subjects';
STORE pubevent INTO '/user/hd/bnbslices/pubevents';
STORE dates INTO '/user/hd/bnbslices/dates';
