CREATE DATABASE csm_database;

CREATE ROLE csm_client WITH
    NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT LOGIN PASSWORD 'csm123';

GRANT CONNECT ON DATABASE csm_database TO csm_client;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO csm_client;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO csm_client;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO csm_client;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO csm_client;


CREATE TABLE companies
(
    cia_nit    SERIAL PRIMARY KEY,
    cia_lname  VARCHAR(50) NOT NULL UNIQUE,
    cia_cname  VARCHAR(50) NOT NULL,
    cia_status BOOLEAN DEFAULT TRUE
);

CREATE TABLE jobpositions
(
    jpo_id     SERIAL PRIMARY KEY,
    jpo_nam    VARCHAR(50)  NOT NULL,
    jpo_des    VARCHAR(100) NOT NULL,
    jpo_status BOOLEAN DEFAULT TRUE
);

CREATE TABLE employees
(
    emp_id     SERIAL PRIMARY KEY,
    emp_fn     VARCHAR(50) NOT NULL,
    emp_ln     VARCHAR(50) NOT NULL,
    emp_cui    VARCHAR(13) NOT NULL UNIQUE,
    emo_ema    VARCHAR(50) NOT NULL UNIQUE,
    emp_status BOOLEAN   DEFAULT TRUE,
    emp_system TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    emp_cia    INTEGER REFERENCES companies (cia_nit),
    emp_job    INTEGER REFERENCES jobpositions (jpo_id)
);

CREATE TABLE users
(
    usr_id       SERIAL PRIMARY KEY,
    usr_login    VARCHAR(50)  NOT NULL UNIQUE,
    usr_pws      VARCHAR(150) NOT NULL,
    usr_workload INT       DEFAULT 0,
    usr_status   BOOLEAN   DEFAULT TRUE,
    usr_system   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usr_emp      INTEGER REFERENCES employees (emp_id)
);

CREATE TABLE role
(
    rol_id     SERIAL PRIMARY KEY,
    rol_nam    VARCHAR(20) NOT NULL UNIQUE,
    rol_actor  VARCHAR(35) NOT NULL UNIQUE,
    rol_des    VARCHAR(100),
    rol_status BOOLEAN DEFAULT TRUE
);

CREATE TABLE users_roles
(
    usr_id INTEGER REFERENCES users (usr_id),
    rol_id INTEGER REFERENCES role (rol_id),
    PRIMARY KEY (usr_id, rol_id)
);

CREATE TABLE nits
(
    nit_id   SERIAL PRIMARY KEY,
    nit_num  VARCHAR(12)  NOT NULL UNIQUE,
    nim_name VARCHAR(50)  NOT NULL,
    nit_ema  VARCHAR(50)  NOT NULL UNIQUE,
    nit_add  VARCHAR(100) NOT NULL,
    nit_pho  VARCHAR(10)  NOT NULL UNIQUE
);

CREATE TABLE entitytypes
(
    ety_id   SERIAL PRIMARY KEY,
    ety_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE providers
(
    prv_id     SERIAL PRIMARY KEY,
    prv_nit    INTEGER REFERENCES nits (nit_id),
    prv_ety    INTEGER REFERENCES entitytypes (ety_id),
    prv_status BOOLEAN DEFAULT TRUE
);

CREATE TABLE periods
(
    per_id    SERIAL PRIMARY KEY,
    per_start DATE NOT NULL,
    per_end   DATE NOT NULL
);

CREATE TABLE requesttypes
(
    reqt_id   SERIAL PRIMARY KEY,
    reqt_type VARCHAR(50) NOT NULL UNIQUE,
    reqt_des  VARCHAR(100)
);

CREATE TABLE requestscounter
(
    reqtc_period INTEGER REFERENCES periods (per_id),
    reqtc_type   INTEGER REFERENCES requesttypes (reqt_id),
    reqtc_count  INTEGER DEFAULT 0,
    PRIMARY KEY (reqtc_period, reqtc_type)
);

CREATE TABLE requeststates
(
    reqs_id   SERIAL PRIMARY KEY,
    reqs_name VARCHAR(50) NOT NULL UNIQUE,
    reqs_des  VARCHAR(100)
);

CREATE TABLE documenttype
(
    doc_id   SERIAL PRIMARY KEY,
    doc_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE states
(
    sts_id     SERIAL PRIMARY KEY,
    sts_state1 VARCHAR(50) NOT NULL UNIQUE,
    sts_state2 VARCHAR(50),
    sts_des    VARCHAR(100),
    sts_doc    BOOLEAN DEFAULT FALSE,
    sts_por    BOOLEAN DEFAULT FALSE,
    sts_sam    BOOLEAN DEFAULT FALSE,
    sts_req    BOOLEAN DEFAULT FALSE
);

CREATE TABLE states_lines
(
    stl_state INTEGER REFERENCES states (sts_id),
    stl_line  INTEGER REFERENCES states (sts_id),
    PRIMARY KEY (stl_state, stl_line)
);

CREATE TABLE requests
(
    req_id       SERIAL PRIMARY KEY,
    req_type     INTEGER REFERENCES requesttypes (reqt_id),
    req_num      INTEGER     NOT NULL,
    req_date     DATE DEFAULT CURRENT_DATE,
    req_doctype  INTEGER REFERENCES documenttype (doc_id),
    req_docnum   INTEGER     NOT NULL,
    req_provider INTEGER REFERENCES providers (prv_id),
    req_email    VARCHAR(50) NOT NULL,
    req_nit      INTEGER REFERENCES nits (nit_id),
    req_state    INTEGER REFERENCES requeststates (reqs_id),
    req_reject   VARCHAR(100)
);

CREATE TABLE samples
(
    samp_id      SERIAL PRIMARY KEY,
    samp_request INTEGER REFERENCES requests (req_id),
    samp_number  VARCHAR(25) NOT NULL,
    samp_descrip VARCHAR(100),
    samp_portion VARCHAR(2),
    samp_reject  VARCHAR(100),
    samp_reverse SMALLINT DEFAULT 0,
    samp_notify  DATE,
    samp_state   INTEGER REFERENCES states (sts_id)
);

CREATE TABLE sampleportions
(
    sampp_id     SERIAL PRIMARY KEY,
    sampp_sample INTEGER REFERENCES samples (samp_id),
    sampp_state  INTEGER REFERENCES states (sts_id)
);

CREATE TABLE documenttypes
(
    doc_id   SERIAL PRIMARY KEY,
    doc_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE sampledocuments
(
    smd_id     SERIAL PRIMARY KEY,
    smd_num    BIGINT       NULL,
    smd_path   VARCHAR(150) NOT NULL,
    smd_system TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    smd_status BOOLEAN   DEFAULT TRUE,
    smd_type   INTEGER REFERENCES documenttypes (doc_id),
    smd_sample INTEGER REFERENCES samples (samp_id)
);

CREATE TABLE logtypes
(
    log_id   SERIAL PRIMARY KEY,
    log_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE logs
(
    log_id          SERIAL PRIMARY KEY,
    log_requesttype INTEGER REFERENCES requesttypes (reqt_id),
    log_sample      INTEGER REFERENCES samples (samp_id),
    log_samplenum   VARCHAR(25),
    log_rolmade     INTEGER REFERENCES role (rol_id),
    log_usermade    INTEGER REFERENCES users (usr_id),
    log_state       INTEGER REFERENCES states (sts_id),
    log_type        INTEGER REFERENCES logtypes (log_id),
    log_assigned    INTEGER REFERENCES users (usr_id),
    log_system      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    log_email       BOOLEAN NOT NULL,
    log_title       VARCHAR(100),
    log_reason      VARCHAR(100),
    log_userstatus  BOOLEAN NOT NULL
);