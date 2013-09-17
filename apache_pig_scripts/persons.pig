REGISTER pigUtils.jar

raw = LOAD '/user/hd/bnbsample/part*'
      USING pigUtils.ntriples.nTriplesLoader()
      AS (subj: chararray, prop: chararray, obj: chararray, type: int);

agents_raw = FILTER raw 
             BY prop == 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type' 
             AND obj == 'http://xmlns.com/foaf/0.1/Person';

agents = FOREACH agents_raw GENERATE subj as author;

agents10 = LIMIT agents 10;
rmf /user/hd/personfreq/debugtables/agents
STORE agents10 INTO '/user/hd/personfreq/debugtables/agents';
