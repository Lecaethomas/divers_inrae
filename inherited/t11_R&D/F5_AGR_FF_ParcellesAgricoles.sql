drop table if exists "F5_AGR_PressionsEspacesAgricoles".parcelles_agricoles_ff;
create table "F5_AGR_PressionsEspacesAgricoles".parcelles_agricoles_ff as(
with t01 as(
select idprocpte, idprodroit, idpersonne , dnuper, dnupro
	from ff_2019.fftp_2019_proprietaire_droit fpd 
	--where dnatprtxt = 'PERSONNE MORALE - COLLECTIVITE LOCALE' 
	--and dsiren is not null and typedroit ='P'
),
t02 as(
select t01.idprocpte idprot01,t01.idpersonne, t01.idprodroit , dnuper ,t1.idpar,t1.idsec,t1.idprocpte,t1.idparref,t1.idsecref,t1.idvoie,t1.idcom,t1.idcomtxt,t1.ccodep,t1.ccodir,t1.ccocom,t1.ccopre,t1.ccosec,t1.dnupla,t1.dcntpa,t1.dnupro,t1.jdatat,t1.jdatatv,t1.dreflf,t1.gpdl,t1.cprsecr,t1.ccosecr,t1.dnuplar,t1.dnupdl,t1.gurbpa,t1.dparpi,t1.ccoarp,t1.gparnf,t1.gparbat,t1.dnuvoi,t1.dindic,t1.ccovoi,t1.ccoriv,t1.ccocif,t1.ccpper,t1.cconvo,t1.dvoilib,t1.idparm,t1.ccocomm,t1.ccoprem,t1.ccosecm,t1.dnuplam,t1."type",t1.typetxt,t1.ccoifp,t1.jdatatan,t1.jannatmin,t1.jannatmax,t1.jannatminh,t1.jannatmaxh,t1.janbilmin,t1.nsuf,t1.ssuf,t1.cgrnumd,t1.cgrnumdtxt,t1.dcntsfd,t1.dcntarti,t1.dcntnaf,t1.dcnt01,t1.dcnt02,t1.dcnt03,t1.dcnt04,t1.dcnt05,t1.dcnt06,t1.dcnt07,t1.dcnt08,t1.dcnt09,t1.dcnt10,t1.dcnt11,t1.dcnt12,t1.dcnt13,t1.schemrem,t1.nlocal,t1.nlocmaison,t1.nlocappt,t1.nloclog,t1.nloccom,t1.nloccomrdc,t1.nloccomter,t1.ncomtersd,t1.ncomterdep,t1.nloccomsec,t1.nlocdep,t1.nlocburx,t1.tlocdomin,t1.nbat,t1.nlochab,t1.nlogh,t1.npevph,t1.stoth,t1.stotdsueic,t1.nloghvac,t1.nloghmeu,t1.nloghloue,t1.nloghpp,t1.nloghautre,t1.nloghnonh,t1.nactvacant,t1.nloghvac2a,t1.nactvac2a,t1.nloghvac5a,t1.nactvac5a,t1.nmediocre,t1.nloghlm,t1.nloghlls,t1.npevd,t1.stotd,t1.npevp,t1.sprincp,t1.ssecp,t1.ssecncp,t1.sparkp,t1.sparkncp,t1.slocal,t1.tpevdom_s,t1.nlot,t1.pdlmp,t1.ctpdl,t1.typecopro2,t1.ncp,t1.ndroit,t1.ndroitindi,t1.ndroitpro,t1.ndroitges,t1.catpro2,t1.catpro2txt,t1.catpro3,t1.catpropro2,t1.catproges2,t1.locprop,t1.locproptxt,t1.geompar,t1.geomloc,t1.source_geo,t1.vecteur,t1.contour,t1.idpk

	from ff_2019.fftp_2019_pnb10_parcelle t1 right join t01 on t1.dnupro= t01.dnupro
	where cgrnumd in ('01','02','03')
	--where t01.dsiren is not null
)
select * from t02
--where dsiren is not null
);


drop table if exists "F5_AGR_PressionsEspacesAgricoles".parcelles_agricoles_ff_proprietaire_dnupro;
create table "F5_AGR_PressionsEspacesAgricoles".parcelles_agricoles_ff_proprietaire_dnupro as (
select  geompar, dnupro from "F5_AGR_PressionsEspacesAgricoles".parcelles_agricoles_ff t1
--where st_intersects(ttpd.geom,t1.geomloc) and ttpd.rank='3'
--where dsiren is not null

group by geompar , dnupro-- , dsiren
)

drop table if exists "F5_AGR_PressionsEspacesAgricoles".parcelles_agricoles_ff_proprietaire_dnuper;
create table "F5_AGR_PressionsEspacesAgricoles".parcelles_agricoles_ff_proprietaire_dnuper as (
select  count(distinct(dnuper))  from "F5_AGR_PressionsEspacesAgricoles".parcelles_agricoles_ff t1
--where st_intersects(ttpd.geom,t1.geomloc) and ttpd.rank='3'
--where dsiren is not null

group by geompar , dnuper-- , dsiren
)


drop table if exists "F5_AGR_PressionsEspacesAgricoles".parcelles_agricoles_ff_proprietaire_siren;
create table "F5_AGR_PressionsEspacesAgricoles".parcelles_agricoles_ff_proprietaire_siren as (
select  geompar ,geomloc, dnuper from "F5_AGR_PressionsEspacesAgricoles".parcelles_agricoles_ff t1, public."TerritoryTable_PSB_dec.2019" ttpd 
--where st_intersects(ttpd.geom,t1.geomloc) and ttpd.rank='3'
--where dsiren is not null
group by geompar , dnuper, geomloc, dsiren
)



create table parcelles_PSB_2019 as(
select * from  ff_2019.fftp_2019_pnb10_parcelle t1, public."TerritoryTable_PSB_dec.2019" t2 where st_intersects (t1.geomloc, t2.geom)
)
select * from parcelles_privees_ff ppf 