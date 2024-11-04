

CREATE TABLE tenant (
    id SERIAL,
    name VARCHAR(100),
    description VARCHAR(255)
);


CREATE TABLE person (
    id SERIAL,
    name VARCHAR(100),
    birth_date DATE,
    metadata JSONB
);

CREATE TABLE institution (
    id SERIAL,
    tenant_id INTEGER,
    name VARCHAR(100),
    location VARCHAR(100),
    details JSONB
);

CREATE TABLE course (
    id SERIAL,
    tenant_id INTEGER,
    institution_id INTEGER,
    name VARCHAR(100),
    duration INTEGER,
    details JSONB
);

---------------RESPOSTA 7-----------------------------------------   
--- UTILIZAR A TENANT, POIS É A VOLUMETRIA É VIAVEL PARA CRIAR O PARTICIONAMENTO E OBTER MELHOR PERFORMANCE, LEMBRANDO QUE AS CONSULTAS DEVERÁ FILTRAR SEMPRE  "tenant_id"

CREATE TABLE enrollment (
    id SERIAL,
    tenant_id INTEGER,
    institution_id INTEGER,
    person_id INTEGER,
    enrollment_date DATE,
    status VARCHAR(20)
)  PARTITION BY RANGE (tenant_id);

---------------- ADICIONANDO COLUNAS ----------------------------------------
alter table tenant ADD dat_exlusao DATE DEFAULT '3000-12-31' ;
alter table person ADD dat_exlusao DATE DEFAULT '3000-12-31' ;
alter table institution ADD dat_exlusao DATE DEFAULT '3000-12-31' ;
alter table course ADD dat_exlusao DATE DEFAULT '3000-12-31' ;
alter table enrollment ADD dat_exlusao DATE DEFAULT '3000-12-31' ;

---------------- ADICIONANDO CRIAÇÃO CHAVE PRIMEIRA ----------------------------------------
ALTER TABLE tenant ADD PRIMARY KEY (id);
ALTER TABLE person ADD PRIMARY KEY (id);
ALTER TABLE institution ADD PRIMARY KEY (id);
ALTER TABLE course ADD PRIMARY KEY (id);
ALTER TABLE enrollment ADD PRIMARY KEY (id);

---------------- ADICIONANDO INDEX ----------------------------------------
CREATE INDEX idx_tenant_001 ON tenant (dat_exlusao);
CREATE INDEX idx_person_001 ON person (dat_exlusao);
CREATE INDEX idx_institution_001 ON institution (tenant_id);
CREATE INDEX idx_institution_002 ON institution (dat_exlusao);
CREATE INDEX idx_institution_003 ON institution (tenant_id, dat_exlusao);
CREATE INDEX idx_course_001 ON course (tenant_id);
CREATE INDEX idx_course_002 ON course (institution_id);
CREATE INDEX idx_course_003 ON course (dat_exlusao);
CREATE INDEX idx_enrollment_001 ON enrollment (institution_id);
CREATE INDEX idx_enrollment_002 ON enrollment (person_id);
CREATE INDEX idx_enrollment_003 ON enrollment (dat_exlusao);
CREATE INDEX idx_enrollment_004 ON enrollment (tenant_id, institution_id, dat_exlusao);


---------------- ADICIONANDO INDEX UNIQUE ----------------------------------------
CREATE UNIQUE INDEX idx_enrollment_U_001 ON enrollment (tenant_id, institution_id , person_id, dat_exlusao)  WHERE institution_id IS NOT NULL and dat_exlusao = '3000-12-31'  ;

---------------- ADICIONANDO FK ----------------------------------------
ALTER TABLE institution
ADD CONSTRAINT institution_fk_001 FOREIGN KEY (tenant_id) REFERENCES tenant(id);

ALTER TABLE course
ADD CONSTRAINT course_fk_001 FOREIGN KEY (tenant_id) REFERENCES tenant(id);

ALTER TABLE course
ADD CONSTRAINT course_fk_002 FOREIGN KEY (institution_id) REFERENCES institution(id);

ALTER TABLE enrollment
ADD CONSTRAINT enrollment_fk_001 FOREIGN KEY (tenant_id) REFERENCES tenant(id);

ALTER TABLE enrollment
ADD CONSTRAINT enrollment_fk_002 FOREIGN KEY (institution_id) REFERENCES institution(id);

ALTER TABLE enrollment
ADD CONSTRAINT enrollment_fk_003 FOREIGN KEY (person_id) REFERENCES person(id);


---------------RESPOSTA 5-----------------------------------------
SELECT name, count(*) qte 
  FROM course  
 WHERE tenant_id = ? 
   AND institution_id = ? 
   AND dat_exlusao = '3000-12-31' 
   AND details @> ? 
 GROUP BY name;
   
---------------RESPOSTA 6-----------------------------------------   
SELECT id,  person_id 
FROM enrollment  E1
WHERE dat_exlusao = '3000-12-31'
AND EXISTS ( SELECT 1 FROM  institution Y1 WHERE Y1.ID = E1.institution_id AND Y1.dat_exlusao = '3000-12-31')
AND EXISTS ( SELECT 1 FROM  tenant Y1 WHERE Y1.ID = E1.tenant_id AND Y1.dat_exlusao = '3000-12-31')
AND E1.institution_id = ?
AND E1.tenant_id = ?


---------------RESPOSTA 8-----------------------------------------   
---------------- ADICIONANDO COLUNAS DATA CRIAÇÃO REGISTRO ----------------------------------------
--------------- FOI ADICIONADO VARIOS INDEX O QUE ACHEI NECESSÁRIO PARA FACILITAR AS PESQUISAS
alter table tenant ADD dat_cadastro_reg DATE DEFAULT CURRENT_DATE ;
alter table person ADD dat_cadastro_reg DATE DEFAULT CURRENT_DATE ;
alter table institution ADD dat_cadastro_reg DATE DEFAULT CURRENT_DATE ;
alter table course ADD dat_cadastro_reg DATE DEFAULT CURRENT_DATE ;
alter table enrollment ADD dat_cadastro_reg DATE DEFAULT CURRENT_DATE ;


