-- 
--  l'intégration des csv est plus simple depuis dbeaver surtout pour les données INSEE
/* Intégration des données */

-- 2011
DROP TABLE IF EXISTS "public".emploi_act_2011_2013;
CREATE TABLE "public".emploi_act_2011_2013(
    insee varchar(6),
    nom_commune varchar,
    PXX_POP1564	real,
    PXX_POP1524	real,
    PXX_POP2554	real,
    PXX_POP5564	real,
    PXX_H1564	real,
    PXX_H1524	real,
    PXX_H2554	real,
    PXX_H5564	real,
    PXX_F1564	real,
    PXX_F1524	real,
    PXX_F2554	real,
    PXX_F5564	real,
    PXX_ACT1564	real,
    PXX_ACT1524	real,
    PXX_ACT2554	real,
    PXX_ACT5564	real,
    PXX_HACT1564	real,
    PXX_HACT1524	real,
    PXX_HACT2554	real,
    PXX_HACT5564	real,
    PXX_FACT1564	real,
    PXX_FACT1524	real,
    PXX_FACT2554	real,
    PXX_FACT5564	real,
    PXX_ACTOCC1564	real,
    PXX_ACTOCC1524	real,
    PXX_ACTOCC2554	real,
    PXX_ACTOCC5564	real,
    PXX_HACTOCC1564	real,
    PXX_HACTOCC1524	real,
    PXX_HACTOCC2554	real,
    PXX_HACTOCC5564	real,
    PXX_FACTOCC1564	real,
    PXX_FACTOCC1524	real,
    PXX_FACTOCC2554	real,
    PXX_FACTOCC5564	real,
    PXX_CHOM1564	real,
    PXX_HCHOM1564	real,
    PXX_HCHOM1524	real,
    PXX_HCHOM2554	real,
    PXX_HCHOM5564	real,
    PXX_FCHOM1564	real,
    PXX_FCHOM1524	real,
    PXX_FCHOM2554	real,
    PXX_FCHOM5564	real,
    PXX_INACT1564	real,
    PXX_ETUD1564	real,
    PXX_RETR1564	real,
    PXX_AINACT1564	real,
    CXX_ACT1564	real,
    CXX_ACT1564_CS1	real,
    CXX_ACT1564_CS2	real,
    CXX_ACT1564_CS3	real,
    CXX_ACT1564_CS4	real,
    CXX_ACT1564_CS5	real,
    CXX_ACT1564_CS6	real,
    CXX_ACTOCC1564	real,
    CXX_ACTOCC1564_CS1	real,
    CXX_ACTOCC1564_CS2	real,
    CXX_ACTOCC1564_CS3	real,
    CXX_ACTOCC1564_CS4	real,
    CXX_ACTOCC1564_CS5	real,
    CXX_ACTOCC1564_CS6	real,
    PXX_EMPLT	real,
    PXX_ACTOCC	real,
    PXX_POP15P	real,
    PXX_ACT15P	real,
    PXX_EMPLT_SAL	real,
    PXX_EMPLT_FSAL	real,
    PXX_EMPLT_SALTP	real,
    PXX_EMPLT_NSAL	real,
    PXX_EMPLT_FNSAL	real,
    PXX_EMPLT_NSALTP	real,
    CXX_EMPLT	real,
    CXX_EMPLT_CS1	real,
    CXX_EMPLT_CS2	real,
    CXX_EMPLT_CS3	real,
    CXX_EMPLT_CS4	real,
    CXX_EMPLT_CS5	real,
    CXX_EMPLT_CS6	real,
    CXX_EMPLT_AGRI	real,
    CXX_EMPLT_INDUS	real,
    CXX_EMPLT_CONST	real,
    CXX_EMPLT_CTS	real,
    CXX_EMPLT_APESAS	real,
    CXX_EMPLT_F	real,
    CXX_AGRILT_F	real,
    CXX_INDUSLT_F	real,
    CXX_CONSTLT_F	real,
    CXX_CTSLT_F	real,
    CXX_APESASLT_F	real,
    CXX_EMPLT_SAL	real,
    CXX_AGRILT_SAL	real,
    CXX_INDUSLT_SAL	real,
    CXX_CONSTLT_SAL	real,
    CXX_CTSLT_SAL	real,
    CXX_APESASLT_SAL	real,
    CXX_AGRILT_FSAL	real,
    CXX_INDUSLT_FSAL	real,
    CXX_CONSTLT_FSAL	real,
    CXX_CTSLT_FSAL	real,
    CXX_APESASLT_FSAL	real,
    CXX_AGRILT_NSAL	real,
    CXX_INDUSLT_NSAL	real,
    CXX_CONSTLT_NSAL	real,
    CXX_CTSLT_NSAL	real,
    CXX_APESASLT_NSAL	real,
    CXX_AGRILT_FNSAL	real,
    CXX_INDUSLT_FNSAL	real,
    CXX_CONSTLT_FNSAL	real,
    CXX_CTSLT_FNSAL	real,
    CXX_APESASLT_FNSAL	real
);
COPY public.emploi_act_2011_2013
FROM 'C:\Users\salah\OneDrive\Bureau\TRAVAIL\GIT\scripts_sgevt\PROD\t0_cogugaison\4_Results_Step_n2_DATA_COGugaison_2019\Emploi\emploi-act-2011_2013.csv'
DELIMITER ',' CSV HEADER ENCODING 'UTF-8' NULL 'NA';

-- 2012
DROP TABLE IF EXISTS "public".emploi_act_2012_2014;
CREATE TABLE "public".emploi_act_2012_2014(
    insee varchar(6),
    nom_commune varchar,
    PXX_POP1564	real,
    PXX_POP1524	real,
    PXX_POP2554	real,
    PXX_POP5564	real,
    PXX_H1564	real,
    PXX_H1524	real,
    PXX_H2554	real,
    PXX_H5564	real,
    PXX_F1564	real,
    PXX_F1524	real,
    PXX_F2554	real,
    PXX_F5564	real,
    PXX_ACT1564	real,
    PXX_ACT1524	real,
    PXX_ACT2554	real,
    PXX_ACT5564	real,
    PXX_HACT1564	real,
    PXX_HACT1524	real,
    PXX_HACT2554	real,
    PXX_HACT5564	real,
    PXX_FACT1564	real,
    PXX_FACT1524	real,
    PXX_FACT2554	real,
    PXX_FACT5564	real,
    PXX_ACTOCC1564	real,
    PXX_ACTOCC1524	real,
    PXX_ACTOCC2554	real,
    PXX_ACTOCC5564	real,
    PXX_HACTOCC1564	real,
    PXX_HACTOCC1524	real,
    PXX_HACTOCC2554	real,
    PXX_HACTOCC5564	real,
    PXX_FACTOCC1564	real,
    PXX_FACTOCC1524	real,
    PXX_FACTOCC2554	real,
    PXX_FACTOCC5564	real,
    PXX_CHOM1564	real,
    PXX_HCHOM1564	real,
    PXX_HCHOM1524	real,
    PXX_HCHOM2554	real,
    PXX_HCHOM5564	real,
    PXX_FCHOM1564	real,
    PXX_FCHOM1524	real,
    PXX_FCHOM2554	real,
    PXX_FCHOM5564	real,
    PXX_INACT1564	real,
    PXX_ETUD1564	real,
    PXX_RETR1564	real,
    PXX_AINACT1564	real,
    CXX_ACT1564	real,
    CXX_ACT1564_CS1	real,
    CXX_ACT1564_CS2	real,
    CXX_ACT1564_CS3	real,
    CXX_ACT1564_CS4	real,
    CXX_ACT1564_CS5	real,
    CXX_ACT1564_CS6	real,
    CXX_ACTOCC1564	real,
    CXX_ACTOCC1564_CS1	real,
    CXX_ACTOCC1564_CS2	real,
    CXX_ACTOCC1564_CS3	real,
    CXX_ACTOCC1564_CS4	real,
    CXX_ACTOCC1564_CS5	real,
    CXX_ACTOCC1564_CS6	real,
    PXX_EMPLT	real,
    PXX_ACTOCC	real,
    PXX_POP15P	real,
    PXX_ACT15P	real,
    PXX_EMPLT_SAL	real,
    PXX_EMPLT_FSAL	real,
    PXX_EMPLT_SALTP	real,
    PXX_EMPLT_NSAL	real,
    PXX_EMPLT_FNSAL	real,
    PXX_EMPLT_NSALTP	real,
    CXX_EMPLT	real,
    CXX_EMPLT_CS1	real,
    CXX_EMPLT_CS2	real,
    CXX_EMPLT_CS3	real,
    CXX_EMPLT_CS4	real,
    CXX_EMPLT_CS5	real,
    CXX_EMPLT_CS6	real,
    CXX_EMPLT_AGRI	real,
    CXX_EMPLT_INDUS	real,
    CXX_EMPLT_CONST	real,
    CXX_EMPLT_CTS	real,
    CXX_EMPLT_APESAS	real,
    CXX_EMPLT_F	real,
    CXX_AGRILT_F	real,
    CXX_INDUSLT_F	real,
    CXX_CONSTLT_F	real,
    CXX_CTSLT_F	real,
    CXX_APESASLT_F	real,
    CXX_EMPLT_SAL	real,
    CXX_AGRILT_SAL	real,
    CXX_INDUSLT_SAL	real,
    CXX_CONSTLT_SAL	real,
    CXX_CTSLT_SAL	real,
    CXX_APESASLT_SAL	real,
    CXX_AGRILT_FSAL	real,
    CXX_INDUSLT_FSAL	real,
    CXX_CONSTLT_FSAL	real,
    CXX_CTSLT_FSAL	real,
    CXX_APESASLT_FSAL	real,
    CXX_AGRILT_NSAL	real,
    CXX_INDUSLT_NSAL	real,
    CXX_CONSTLT_NSAL	real,
    CXX_CTSLT_NSAL	real,
    CXX_APESASLT_NSAL	real,
    CXX_AGRILT_FNSAL	real,
    CXX_INDUSLT_FNSAL	real,
    CXX_CONSTLT_FNSAL	real,
    CXX_CTSLT_FNSAL	real,
    CXX_APESASLT_FNSAL	real
);
COPY public.emploi_act_2012_2014
FROM 'C:\Users\salah\OneDrive\Bureau\TRAVAIL\GIT\scripts_sgevt\PROD\t0_cogugaison\4_Results_Step_n2_DATA_COGugaison_2019\Emploi\emploi-act-2012_2014.csv'
DELIMITER ',' CSV HEADER ENCODING 'UTF-8' NULL 'NA';

--2013
DROP TABLE IF EXISTS "public".emploi_act_2013_2015;
CREATE TABLE "public".emploi_act_2013_2015(
    insee varchar(6),
    nom_commune varchar,
    PXX_POP1564	real,
    PXX_POP1524	real,
    PXX_POP2554	real,
    PXX_POP5564	real,
    PXX_H1564	real,
    PXX_H1524	real,
    PXX_H2554	real,
    PXX_H5564	real,
    PXX_F1564	real,
    PXX_F1524	real,
    PXX_F2554	real,
    PXX_F5564	real,
    PXX_ACT1564	real,
    PXX_ACT1524	real,
    PXX_ACT2554	real,
    PXX_ACT5564	real,
    PXX_HACT1564	real,
    PXX_HACT1524	real,
    PXX_HACT2554	real,
    PXX_HACT5564	real,
    PXX_FACT1564	real,
    PXX_FACT1524	real,
    PXX_FACT2554	real,
    PXX_FACT5564	real,
    PXX_ACTOCC1564	real,
    PXX_ACTOCC1524	real,
    PXX_ACTOCC2554	real,
    PXX_ACTOCC5564	real,
    PXX_HACTOCC1564	real,
    PXX_HACTOCC1524	real,
    PXX_HACTOCC2554	real,
    PXX_HACTOCC5564	real,
    PXX_FACTOCC1564	real,
    PXX_FACTOCC1524	real,
    PXX_FACTOCC2554	real,
    PXX_FACTOCC5564	real,
    PXX_CHOM1564	real,
    PXX_HCHOM1564	real,
    PXX_HCHOM1524	real,
    PXX_HCHOM2554	real,
    PXX_HCHOM5564	real,
    PXX_FCHOM1564	real,
    PXX_FCHOM1524	real,
    PXX_FCHOM2554	real,
    PXX_FCHOM5564	real,
    PXX_INACT1564	real,
    PXX_ETUD1564	real,
    PXX_RETR1564	real,
    PXX_AINACT1564	real,
    CXX_ACT1564	real,
    CXX_ACT1564_CS1	real,
    CXX_ACT1564_CS2	real,
    CXX_ACT1564_CS3	real,
    CXX_ACT1564_CS4	real,
    CXX_ACT1564_CS5	real,
    CXX_ACT1564_CS6	real,
    CXX_ACTOCC1564	real,
    CXX_ACTOCC1564_CS1	real,
    CXX_ACTOCC1564_CS2	real,
    CXX_ACTOCC1564_CS3	real,
    CXX_ACTOCC1564_CS4	real,
    CXX_ACTOCC1564_CS5	real,
    CXX_ACTOCC1564_CS6	real,
    PXX_EMPLT	real,
    PXX_ACTOCC	real,
    PXX_POP15P	real,
    PXX_ACT15P	real,
    PXX_EMPLT_SAL	real,
    PXX_EMPLT_FSAL	real,
    PXX_EMPLT_SALTP	real,
    PXX_EMPLT_NSAL	real,
    PXX_EMPLT_FNSAL	real,
    PXX_EMPLT_NSALTP	real,
    CXX_EMPLT	real,
    CXX_EMPLT_CS1	real,
    CXX_EMPLT_CS2	real,
    CXX_EMPLT_CS3	real,
    CXX_EMPLT_CS4	real,
    CXX_EMPLT_CS5	real,
    CXX_EMPLT_CS6	real,
    CXX_EMPLT_AGRI	real,
    CXX_EMPLT_INDUS	real,
    CXX_EMPLT_CONST	real,
    CXX_EMPLT_CTS	real,
    CXX_EMPLT_APESAS	real,
    CXX_EMPLT_F	real,
    CXX_AGRILT_F	real,
    CXX_INDUSLT_F	real,
    CXX_CONSTLT_F	real,
    CXX_CTSLT_F	real,
    CXX_APESASLT_F	real,
    CXX_EMPLT_SAL	real,
    CXX_AGRILT_SAL	real,
    CXX_INDUSLT_SAL	real,
    CXX_CONSTLT_SAL	real,
    CXX_CTSLT_SAL	real,
    CXX_APESASLT_SAL	real,
    CXX_AGRILT_FSAL	real,
    CXX_INDUSLT_FSAL	real,
    CXX_CONSTLT_FSAL	real,
    CXX_CTSLT_FSAL	real,
    CXX_APESASLT_FSAL	real,
    CXX_AGRILT_NSAL	real,
    CXX_INDUSLT_NSAL	real,
    CXX_CONSTLT_NSAL	real,
    CXX_CTSLT_NSAL	real,
    CXX_APESASLT_NSAL	real,
    CXX_AGRILT_FNSAL	real,
    CXX_INDUSLT_FNSAL	real,
    CXX_CONSTLT_FNSAL	real,
    CXX_CTSLT_FNSAL	real,
    CXX_APESASLT_FNSAL	real
);
COPY public.emploi_act_2013_2015
FROM 'C:\Users\salah\OneDrive\Bureau\TRAVAIL\GIT\scripts_sgevt\PROD\t0_cogugaison\4_Results_Step_n2_DATA_COGugaison_2019\Emploi\emploi-act-2013_2015.csv'
DELIMITER ',' CSV HEADER ENCODING 'UTF-8' NULL 'NA';

--2014
DROP TABLE IF EXISTS "public".emploi_act_2014_2016;
CREATE TABLE "public".emploi_act_2014_2016(
    insee varchar(6),
    nom_commune varchar,
    PXX_POP1564	real,
    PXX_POP1524	real,
    PXX_POP2554	real,
    PXX_POP5564	real,
    PXX_H1564	real,
    PXX_H1524	real,
    PXX_H2554	real,
    PXX_H5564	real,
    PXX_F1564	real,
    PXX_F1524	real,
    PXX_F2554	real,
    PXX_F5564	real,
    PXX_ACT1564	real,
    PXX_ACT1524	real,
    PXX_ACT2554	real,
    PXX_ACT5564	real,
    PXX_HACT1564	real,
    PXX_HACT1524	real,
    PXX_HACT2554	real,
    PXX_HACT5564	real,
    PXX_FACT1564	real,
    PXX_FACT1524	real,
    PXX_FACT2554	real,
    PXX_FACT5564	real,
    PXX_ACTOCC1564	real,
    PXX_ACTOCC1524	real,
    PXX_ACTOCC2554	real,
    PXX_ACTOCC5564	real,
    PXX_HACTOCC1564	real,
    PXX_HACTOCC1524	real,
    PXX_HACTOCC2554	real,
    PXX_HACTOCC5564	real,
    PXX_FACTOCC1564	real,
    PXX_FACTOCC1524	real,
    PXX_FACTOCC2554	real,
    PXX_FACTOCC5564	real,
    PXX_CHOM1564	real,
    PXX_HCHOM1564	real,
    PXX_HCHOM1524	real,
    PXX_HCHOM2554	real,
    PXX_HCHOM5564	real,
    PXX_FCHOM1564	real,
    PXX_FCHOM1524	real,
    PXX_FCHOM2554	real,
    PXX_FCHOM5564	real,
    PXX_INACT1564	real,
    PXX_ETUD1564	real,
    PXX_RETR1564	real,
    PXX_AINACT1564	real,
    CXX_ACT1564	real,
    CXX_ACT1564_CS1	real,
    CXX_ACT1564_CS2	real,
    CXX_ACT1564_CS3	real,
    CXX_ACT1564_CS4	real,
    CXX_ACT1564_CS5	real,
    CXX_ACT1564_CS6	real,
    CXX_ACTOCC1564	real,
    CXX_ACTOCC1564_CS1	real,
    CXX_ACTOCC1564_CS2	real,
    CXX_ACTOCC1564_CS3	real,
    CXX_ACTOCC1564_CS4	real,
    CXX_ACTOCC1564_CS5	real,
    CXX_ACTOCC1564_CS6	real,
    PXX_EMPLT	real,
    PXX_ACTOCC	real,
    PXX_POP15P	real,
    PXX_ACT15P	real,
    PXX_EMPLT_SAL	real,
    PXX_EMPLT_FSAL	real,
    PXX_EMPLT_SALTP	real,
    PXX_EMPLT_NSAL	real,
    PXX_EMPLT_FNSAL	real,
    PXX_EMPLT_NSALTP	real,
    CXX_EMPLT	real,
    CXX_EMPLT_CS1	real,
    CXX_EMPLT_CS2	real,
    CXX_EMPLT_CS3	real,
    CXX_EMPLT_CS4	real,
    CXX_EMPLT_CS5	real,
    CXX_EMPLT_CS6	real,
    CXX_EMPLT_AGRI	real,
    CXX_EMPLT_INDUS	real,
    CXX_EMPLT_CONST	real,
    CXX_EMPLT_CTS	real,
    CXX_EMPLT_APESAS	real,
    CXX_EMPLT_F	real,
    CXX_AGRILT_F	real,
    CXX_INDUSLT_F	real,
    CXX_CONSTLT_F	real,
    CXX_CTSLT_F	real,
    CXX_APESASLT_F	real,
    CXX_EMPLT_SAL	real,
    CXX_AGRILT_SAL	real,
    CXX_INDUSLT_SAL	real,
    CXX_CONSTLT_SAL	real,
    CXX_CTSLT_SAL	real,
    CXX_APESASLT_SAL	real,
    CXX_AGRILT_FSAL	real,
    CXX_INDUSLT_FSAL	real,
    CXX_CONSTLT_FSAL	real,
    CXX_CTSLT_FSAL	real,
    CXX_APESASLT_FSAL	real,
    CXX_AGRILT_NSAL	real,
    CXX_INDUSLT_NSAL	real,
    CXX_CONSTLT_NSAL	real,
    CXX_CTSLT_NSAL	real,
    CXX_APESASLT_NSAL	real,
    CXX_AGRILT_FNSAL	real,
    CXX_INDUSLT_FNSAL	real,
    CXX_CONSTLT_FNSAL	real,
    CXX_CTSLT_FNSAL	real,
    CXX_APESASLT_FNSAL	real
);
COPY public.emploi_act_2014_2016
FROM 'C:\Users\salah\OneDrive\Bureau\TRAVAIL\GIT\scripts_sgevt\PROD\t0_cogugaison\4_Results_Step_n2_DATA_COGugaison_2019\Emploi\emploi-act-2014_2016.csv'
DELIMITER ',' CSV HEADER ENCODING 'UTF-8' NULL 'NA';

--2015
DROP TABLE IF EXISTS "public".emploi_act_2015_2017;
CREATE TABLE "public".emploi_act_2015_2017(
    insee varchar(6),
    nom_commune varchar,
    PXX_POP1564	real,
    PXX_POP1524	real,
    PXX_POP2554	real,
    PXX_POP5564	real,
    PXX_H1564	real,
    PXX_H1524	real,
    PXX_H2554	real,
    PXX_H5564	real,
    PXX_F1564	real,
    PXX_F1524	real,
    PXX_F2554	real,
    PXX_F5564	real,
    PXX_ACT1564	real,
    PXX_ACT1524	real,
    PXX_ACT2554	real,
    PXX_ACT5564	real,
    PXX_HACT1564	real,
    PXX_HACT1524	real,
    PXX_HACT2554	real,
    PXX_HACT5564	real,
    PXX_FACT1564	real,
    PXX_FACT1524	real,
    PXX_FACT2554	real,
    PXX_FACT5564	real,
    PXX_ACTOCC1564	real,
    PXX_ACTOCC1524	real,
    PXX_ACTOCC2554	real,
    PXX_ACTOCC5564	real,
    PXX_HACTOCC1564	real,
    PXX_HACTOCC1524	real,
    PXX_HACTOCC2554	real,
    PXX_HACTOCC5564	real,
    PXX_FACTOCC1564	real,
    PXX_FACTOCC1524	real,
    PXX_FACTOCC2554	real,
    PXX_FACTOCC5564	real,
    PXX_CHOM1564	real,
    PXX_HCHOM1564	real,
    PXX_HCHOM1524	real,
    PXX_HCHOM2554	real,
    PXX_HCHOM5564	real,
    PXX_FCHOM1564	real,
    PXX_FCHOM1524	real,
    PXX_FCHOM2554	real,
    PXX_FCHOM5564	real,
    PXX_INACT1564	real,
    PXX_ETUD1564	real,
    PXX_RETR1564	real,
    PXX_AINACT1564	real,
    CXX_ACT1564	real,
    CXX_ACT1564_CS1	real,
    CXX_ACT1564_CS2	real,
    CXX_ACT1564_CS3	real,
    CXX_ACT1564_CS4	real,
    CXX_ACT1564_CS5	real,
    CXX_ACT1564_CS6	real,
    CXX_ACTOCC1564	real,
    CXX_ACTOCC1564_CS1	real,
    CXX_ACTOCC1564_CS2	real,
    CXX_ACTOCC1564_CS3	real,
    CXX_ACTOCC1564_CS4	real,
    CXX_ACTOCC1564_CS5	real,
    CXX_ACTOCC1564_CS6	real,
    PXX_EMPLT	real,
    PXX_ACTOCC	real,
    PXX_POP15P	real,
    PXX_ACT15P	real,
    PXX_EMPLT_SAL	real,
    PXX_EMPLT_FSAL	real,
    PXX_EMPLT_SALTP	real,
    PXX_EMPLT_NSAL	real,
    PXX_EMPLT_FNSAL	real,
    PXX_EMPLT_NSALTP	real,
    CXX_EMPLT	real,
    CXX_EMPLT_CS1	real,
    CXX_EMPLT_CS2	real,
    CXX_EMPLT_CS3	real,
    CXX_EMPLT_CS4	real,
    CXX_EMPLT_CS5	real,
    CXX_EMPLT_CS6	real,
    CXX_EMPLT_AGRI	real,
    CXX_EMPLT_INDUS	real,
    CXX_EMPLT_CONST	real,
    CXX_EMPLT_CTS	real,
    CXX_EMPLT_APESAS	real,
    CXX_EMPLT_F	real,
    CXX_AGRILT_F	real,
    CXX_INDUSLT_F	real,
    CXX_CONSTLT_F	real,
    CXX_CTSLT_F	real,
    CXX_APESASLT_F	real,
    CXX_EMPLT_SAL	real,
    CXX_AGRILT_SAL	real,
    CXX_INDUSLT_SAL	real,
    CXX_CONSTLT_SAL	real,
    CXX_CTSLT_SAL	real,
    CXX_APESASLT_SAL	real,
    CXX_AGRILT_FSAL	real,
    CXX_INDUSLT_FSAL	real,
    CXX_CONSTLT_FSAL	real,
    CXX_CTSLT_FSAL	real,
    CXX_APESASLT_FSAL	real,
    CXX_AGRILT_NSAL	real,
    CXX_INDUSLT_NSAL	real,
    CXX_CONSTLT_NSAL	real,
    CXX_CTSLT_NSAL	real,
    CXX_APESASLT_NSAL	real,
    CXX_AGRILT_FNSAL	real,
    CXX_INDUSLT_FNSAL	real,
    CXX_CONSTLT_FNSAL	real,
    CXX_CTSLT_FNSAL	real,
    CXX_APESASLT_FNSAL	real
);
COPY public.emploi_act_2015_2017
FROM 'C:\Users\salah\OneDrive\Bureau\TRAVAIL\GIT\scripts_sgevt\PROD\t0_cogugaison\4_Results_Step_n2_DATA_COGugaison_2019\Emploi\emploi-act-2015_2017.csv'
DELIMITER ',' CSV HEADER ENCODING 'UTF-8' NULL 'NA';

--2016
DROP TABLE IF EXISTS "public".emploi_act_2016_2019;
CREATE TABLE "public".emploi_act_2016_2019(
    insee varchar(6),
    nom_commune varchar,
    PXX_POP1564	real,
    PXX_POP1524	real,
    PXX_POP2554	real,
    PXX_POP5564	real,
    PXX_H1564	real,
    PXX_H1524	real,
    PXX_H2554	real,
    PXX_H5564	real,
    PXX_F1564	real,
    PXX_F1524	real,
    PXX_F2554	real,
    PXX_F5564	real,
    PXX_ACT1564	real,
    PXX_ACT1524	real,
    PXX_ACT2554	real,
    PXX_ACT5564	real,
    PXX_HACT1564	real,
    PXX_HACT1524	real,
    PXX_HACT2554	real,
    PXX_HACT5564	real,
    PXX_FACT1564	real,
    PXX_FACT1524	real,
    PXX_FACT2554	real,
    PXX_FACT5564	real,
    PXX_ACTOCC1564	real,
    PXX_ACTOCC1524	real,
    PXX_ACTOCC2554	real,
    PXX_ACTOCC5564	real,
    PXX_HACTOCC1564	real,
    PXX_HACTOCC1524	real,
    PXX_HACTOCC2554	real,
    PXX_HACTOCC5564	real,
    PXX_FACTOCC1564	real,
    PXX_FACTOCC1524	real,
    PXX_FACTOCC2554	real,
    PXX_FACTOCC5564	real,
    PXX_CHOM1564	real,
    PXX_HCHOM1564	real,
    PXX_HCHOM1524	real,
    PXX_HCHOM2554	real,
    PXX_HCHOM5564	real,
    PXX_FCHOM1564	real,
    PXX_FCHOM1524	real,
    PXX_FCHOM2554	real,
    PXX_FCHOM5564	real,
    PXX_INACT1564	real,
    PXX_ETUD1564	real,
    PXX_RETR1564	real,
    PXX_AINACT1564	real,
    CXX_ACT1564	real,
    CXX_ACT1564_CS1	real,
    CXX_ACT1564_CS2	real,
    CXX_ACT1564_CS3	real,
    CXX_ACT1564_CS4	real,
    CXX_ACT1564_CS5	real,
    CXX_ACT1564_CS6	real,
    CXX_ACTOCC1564	real,
    CXX_ACTOCC1564_CS1	real,
    CXX_ACTOCC1564_CS2	real,
    CXX_ACTOCC1564_CS3	real,
    CXX_ACTOCC1564_CS4	real,
    CXX_ACTOCC1564_CS5	real,
    CXX_ACTOCC1564_CS6	real,
    PXX_EMPLT	real,
    PXX_ACTOCC	real,
    PXX_POP15P	real,
    PXX_ACT15P	real,
    PXX_EMPLT_SAL	real,
    PXX_EMPLT_FSAL	real,
    PXX_EMPLT_SALTP	real,
    PXX_EMPLT_NSAL	real,
    PXX_EMPLT_FNSAL	real,
    PXX_EMPLT_NSALTP	real,
    CXX_EMPLT	real,
    CXX_EMPLT_CS1	real,
    CXX_EMPLT_CS2	real,
    CXX_EMPLT_CS3	real,
    CXX_EMPLT_CS4	real,
    CXX_EMPLT_CS5	real,
    CXX_EMPLT_CS6	real,
    CXX_EMPLT_AGRI	real,
    CXX_EMPLT_INDUS	real,
    CXX_EMPLT_CONST	real,
    CXX_EMPLT_CTS	real,
    CXX_EMPLT_APESAS	real,
    CXX_EMPLT_F	real,
    CXX_AGRILT_F	real,
    CXX_INDUSLT_F	real,
    CXX_CONSTLT_F	real,
    CXX_CTSLT_F	real,
    CXX_APESASLT_F	real,
    CXX_EMPLT_SAL	real,
    CXX_AGRILT_SAL	real,
    CXX_INDUSLT_SAL	real,
    CXX_CONSTLT_SAL	real,
    CXX_CTSLT_SAL	real,
    CXX_APESASLT_SAL	real,
    CXX_AGRILT_FSAL	real,
    CXX_INDUSLT_FSAL	real,
    CXX_CONSTLT_FSAL	real,
    CXX_CTSLT_FSAL	real,
    CXX_APESASLT_FSAL	real,
    CXX_AGRILT_NSAL	real,
    CXX_INDUSLT_NSAL	real,
    CXX_CONSTLT_NSAL	real,
    CXX_CTSLT_NSAL	real,
    CXX_APESASLT_NSAL	real,
    CXX_AGRILT_FNSAL	real,
    CXX_INDUSLT_FNSAL	real,
    CXX_CONSTLT_FNSAL	real,
    CXX_CTSLT_FNSAL	real,
    CXX_APESASLT_FNSAL	real
);
COPY public.emploi_act_2016_2019
FROM 'C:\Users\salah\OneDrive\Bureau\TRAVAIL\GIT\scripts_sgevt\PROD\t0_cogugaison\4_Results_Step_n2_DATA_COGugaison_2019\Emploi\emploi-act-2016_2019.csv'
DELIMITER ',' CSV HEADER ENCODING 'UTF-8' NULL 'NA';

--2017
DROP TABLE IF EXISTS "public".emploi_act_2017_2020;
CREATE TABLE "public".emploi_act_2017_2020(
    insee varchar(6),
    nom_commune varchar,
    PXX_POP1564	real,
    PXX_POP1524	real,
    PXX_POP2554	real,
    PXX_POP5564	real,
    PXX_H1564	real,
    PXX_H1524	real,
    PXX_H2554	real,
    PXX_H5564	real,
    PXX_F1564	real,
    PXX_F1524	real,
    PXX_F2554	real,
    PXX_F5564	real,
    PXX_ACT1564	real,
    PXX_ACT1524	real,
    PXX_ACT2554	real,
    PXX_ACT5564	real,
    PXX_HACT1564	real,
    PXX_HACT1524	real,
    PXX_HACT2554	real,
    PXX_HACT5564	real,
    PXX_FACT1564	real,
    PXX_FACT1524	real,
    PXX_FACT2554	real,
    PXX_FACT5564	real,
    PXX_ACTOCC1564	real,
    PXX_ACTOCC1524	real,
    PXX_ACTOCC2554	real,
    PXX_ACTOCC5564	real,
    PXX_HACTOCC1564	real,
    PXX_HACTOCC1524	real,
    PXX_HACTOCC2554	real,
    PXX_HACTOCC5564	real,
    PXX_FACTOCC1564	real,
    PXX_FACTOCC1524	real,
    PXX_FACTOCC2554	real,
    PXX_FACTOCC5564	real,
    PXX_CHOM1564	real,
    PXX_HCHOM1564	real,
    PXX_HCHOM1524	real,
    PXX_HCHOM2554	real,
    PXX_HCHOM5564	real,
    PXX_FCHOM1564	real,
    PXX_FCHOM1524	real,
    PXX_FCHOM2554	real,
    PXX_FCHOM5564	real,
    PXX_INACT1564	real,
    PXX_ETUD1564	real,
    PXX_RETR1564	real,
    PXX_AINACT1564	real,
    CXX_ACT1564	real,
    CXX_ACT1564_CS1	real,
    CXX_ACT1564_CS2	real,
    CXX_ACT1564_CS3	real,
    CXX_ACT1564_CS4	real,
    CXX_ACT1564_CS5	real,
    CXX_ACT1564_CS6	real,
    CXX_ACTOCC1564	real,
    CXX_ACTOCC1564_CS1	real,
    CXX_ACTOCC1564_CS2	real,
    CXX_ACTOCC1564_CS3	real,
    CXX_ACTOCC1564_CS4	real,
    CXX_ACTOCC1564_CS5	real,
    CXX_ACTOCC1564_CS6	real,
    PXX_EMPLT	real,
    PXX_ACTOCC	real,
    PXX_POP15P	real,
    PXX_ACT15P	real,
    PXX_EMPLT_SAL	real,
    PXX_EMPLT_FSAL	real,
    PXX_EMPLT_SALTP	real,
    PXX_EMPLT_NSAL	real,
    PXX_EMPLT_FNSAL	real,
    PXX_EMPLT_NSALTP	real,
    CXX_EMPLT	real,
    CXX_EMPLT_CS1	real,
    CXX_EMPLT_CS2	real,
    CXX_EMPLT_CS3	real,
    CXX_EMPLT_CS4	real,
    CXX_EMPLT_CS5	real,
    CXX_EMPLT_CS6	real,
    CXX_EMPLT_AGRI	real,
    CXX_EMPLT_INDUS	real,
    CXX_EMPLT_CONST	real,
    CXX_EMPLT_CTS	real,
    CXX_EMPLT_APESAS	real,
    CXX_EMPLT_F	real,
    CXX_AGRILT_F	real,
    CXX_INDUSLT_F	real,
    CXX_CONSTLT_F	real,
    CXX_CTSLT_F	real,
    CXX_APESASLT_F	real,
    CXX_EMPLT_SAL	real,
    CXX_AGRILT_SAL	real,
    CXX_INDUSLT_SAL	real,
    CXX_CONSTLT_SAL	real,
    CXX_CTSLT_SAL	real,
    CXX_APESASLT_SAL	real,
    CXX_AGRILT_FSAL	real,
    CXX_INDUSLT_FSAL	real,
    CXX_CONSTLT_FSAL	real,
    CXX_CTSLT_FSAL	real,
    CXX_APESASLT_FSAL	real,
    CXX_AGRILT_NSAL	real,
    CXX_INDUSLT_NSAL	real,
    CXX_CONSTLT_NSAL	real,
    CXX_CTSLT_NSAL	real,
    CXX_APESASLT_NSAL	real,
    CXX_AGRILT_FNSAL	real,
    CXX_INDUSLT_FNSAL	real,
    CXX_CONSTLT_FNSAL	real,
    CXX_CTSLT_FNSAL	real,
    CXX_APESASLT_FNSAL	real
);
COPY public.emploi_act_2017_2020
FROM 'C:\Users\salah\OneDrive\Bureau\TRAVAIL\GIT\scripts_sgevt\PROD\t0_cogugaison\4_Results_Step_n2_DATA_COGugaison_2019\Emploi\emploi-act-2017_2020.csv'
DELIMITER ',' CSV HEADER ENCODING 'UTF-8' NULL 'NA';


/* ADD year column for all tables */

-- ALTER TABLE "F4_EMP_EvolEmploi".emploi_act_20XX_20YY DROP COLUMN IF EXISTS year;
-- ALTER TABLE "F4_EMP_EvolEmploi".emploi_act_20XX_20YY ADD COLUMN year real;
-- UPDATE "F4_EMP_EvolEmploi".emploi_act_20XX_20YY SET year =20XX;


-- 2011
ALTER TABLE public.emploi_act_2011_2013 DROP COLUMN IF EXISTS year;
ALTER TABLE public.emploi_act_2011_2013 ADD COLUMN year real;
UPDATE public.emploi_act_2011_2013 SET year =2011;

-- 2012
ALTER TABLE public.emploi_act_2012_2014 DROP COLUMN IF EXISTS year;
ALTER TABLE public.emploi_act_2012_2014 ADD COLUMN year real;
UPDATE public.emploi_act_2012_2014 SET year =2012;

-- 2013
ALTER TABLE public.emploi_act_2013_2015 DROP COLUMN IF EXISTS year;
ALTER TABLE public.emploi_act_2013_2015 ADD COLUMN year real;
UPDATE public.emploi_act_2013_2015 SET year =2013;

-- 2014
ALTER TABLE public.emploi_act_2014_2016 DROP COLUMN IF EXISTS year;
ALTER TABLE public.emploi_act_2014_2016 ADD COLUMN year real;
UPDATE public.emploi_act_2014_2016 SET year =2014;

-- 2015
ALTER TABLE public.emploi_act_2015_2017 DROP COLUMN IF EXISTS year;
ALTER TABLE public.emploi_act_2015_2017 ADD COLUMN year real;
UPDATE public.emploi_act_2015_2017 SET year =2015;

-- 2016
ALTER TABLE public.emploi_act_2016_2019 DROP COLUMN IF EXISTS year;
ALTER TABLE public.emploi_act_2016_2019 ADD COLUMN year real;
UPDATE public.emploi_act_2016_2019 SET year =2016;

-- 2017
ALTER TABLE public.emploi_act_2017_2020 DROP COLUMN IF EXISTS year;
ALTER TABLE public.emploi_act_2017_2020 ADD COLUMN year real;
UPDATE public.emploi_act_2017_2020 SET year =2017;


/* */
/* UNION OF ALL TABLES*/

DROP TABLE IF EXISTS public.emploi_act_2011_2017;
CREATE TABLE public.emploi_act_2011_2017 AS (
    SELECT * FROM public.emploi_act_2011_2013
    UNION ALL
    SELECT * FROM public.emploi_act_2012_2014
    UNION ALL
    SELECT * FROM public.emploi_act_2013_2015
    UNION ALL
    SELECT * FROM public.emploi_act_2014_2016
    UNION ALL
    SELECT * FROM public.emploi_act_2015_2017
    UNION ALL
    SELECT * FROM public.emploi_act_2016_2019
    UNION ALL
    SELECT * FROM public.emploi_act_2017_2020
    ORDER BY insee,nom_commune
);


/* AGGREGATION */
DROP TABLE IF EXISTS public."F4_EMP_EvolEmploi2020";
CREATE TABLE public."F4_EMP_EvolEmploi2020" as
 (
-- Niv 1 : Commune
with t1 as  (
	select Table1.id_geom as insee, Table0.year,sum(CXX_EMPLT_CS1) as CXX_EMPLT_CS1,sum(CXX_EMPLT_CS2) as CXX_EMPLT_CS2,
	sum(CXX_EMPLT_CS3) as CXX_EMPLT_CS3,sum(CXX_EMPLT_CS4) as CXX_EMPLT_CS4, sum(CXX_EMPLT_CS5) as CXX_EMPLT_CS5, sum(CXX_EMPLT_CS6) as CXX_EMPLT_CS6,
	Table1.geom
	FROM ( -- Données territoire
				SELECT label AS ColMaj, label, id_geom, geom
				FROM public."TerritoryTable_PV_BDTopo_2020" 
				GROUP BY ColMaj, label, id_geom, geom
			) AS Table1
	left join (
			select * from public.emploi_act_2011_2017 ea  where substring(insee,1,2) like '35' 
	) as Table0
	on Table0.insee like Table1.id_geom
	where Table1.id_geom is not null
	group by Table1.id_geom, Table0.year,Table1.geom
	order by Table1.id_geom,Table0.year
),
-- Géométries niveau 2 de la table territoire
rank2 as (
	SELECT id_geom, ST_Union(geom) geom
		FROM public."TerritoryTable_PV_BDTopo_2020"
		WHERE rank = 2
		GROUP BY id_geom
),
-- Niv 2 : Polarités
t2 as (
	select rank2.id_geom as insee,t1.year,sum(CXX_EMPLT_CS1) as CXX_EMPLT_CS1,sum(CXX_EMPLT_CS2) as CXX_EMPLT_CS2,
	sum(CXX_EMPLT_CS3) as CXX_EMPLT_CS3,sum(CXX_EMPLT_CS4) as CXX_EMPLT_CS4, sum(CXX_EMPLT_CS5) as CXX_EMPLT_CS5, 
	sum(CXX_EMPLT_CS6) as CXX_EMPLT_CS6,rank2.geom
	from rank2
	LEFT JOIN t1
	ON ST_Intersects(ST_PointOnSurface(t1.geom),rank2.geom)
	GROUP BY rank2.id_geom, t1."year", rank2.geom
),
-- Géométries niveau 3 de la table territoire
rank3 as (
	SELECT id_geom, ST_Union(geom) geom
		FROM public."TerritoryTable_PV_BDTopo_2020"
		WHERE rank = 3
		GROUP BY id_geom
),
-- Données à l'EPCI
t3 as (
	select rank3.id_geom as insee,t1.year,sum(CXX_EMPLT_CS1) as CXX_EMPLT_CS1,sum(CXX_EMPLT_CS2) as CXX_EMPLT_CS2,
	sum(CXX_EMPLT_CS3) as CXX_EMPLT_CS3,sum(CXX_EMPLT_CS4) as CXX_EMPLT_CS4, sum(CXX_EMPLT_CS5) as CXX_EMPLT_CS5, 
	sum(CXX_EMPLT_CS6) as CXX_EMPLT_CS6, rank3.geom
	from rank3
	LEFT JOIN t1
	ON ST_Intersects(ST_PointOnSurface(t1.geom),rank3.geom)
	GROUP BY rank3.id_geom, t1."year", rank3.geom
),
-- Géométries niveau 4 de la table territoire
rank4 as (
	SELECT id_geom, ST_Union(geom) geom
		FROM public."TerritoryTable_PV_BDTopo_2020"
		WHERE rank = 4
		GROUP BY id_geom
),
-- Données au territoire (bon il suffirait de faire un SUM de tout dans l'absolu)
t4 as (
	select rank4.id_geom as insee,t1.year,sum(CXX_EMPLT_CS1) as CXX_EMPLT_CS1,sum(CXX_EMPLT_CS2) as CXX_EMPLT_CS2,
	sum(CXX_EMPLT_CS3) as CXX_EMPLT_CS3,sum(CXX_EMPLT_CS4) as CXX_EMPLT_CS4, sum(CXX_EMPLT_CS5) as CXX_EMPLT_CS5, 
	sum(CXX_EMPLT_CS6) as CXX_EMPLT_CS6,rank4.geom
	from t1,rank4
	WHERE t1.insee IN (
			SELECT terr1.id_geom
			FROM public."TerritoryTable_PV_BDTopo_2020" terr1, rank4
			WHERE ST_Intersects(ST_PointOnSurface(terr1.geom),rank4.geom)
				AND terr1.rank = 1
	)
	GROUP BY rank4.id_geom, t1."year", rank4.geom
)
SELECT * FROM t1 where year is not null
UNION
SELECT * FROM t2 where year is not null
UNION 
SELECT * FROM t3 where year is not null
UNION 
SELECT * FROM t4 where year is not null
ORDER BY insee, "year"
)
 
