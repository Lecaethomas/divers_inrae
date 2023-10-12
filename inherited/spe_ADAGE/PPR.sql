select distinct(cod_commune) from "Communes_PPRN_HorsInondation" t1 , communes_admin_e_2020 t2
where t1.cod_commune <> t2.insee_com 


alter table "Communes_PPRT_valides"
alter column cod_commune type varchar;

update "Communes_PPRT_valides" set cod_commune =
	case 
	when length(cod_commune::varchar)::int< 5 then concat('0',cod_commune::varchar)::varchar
	else cod_commune::varchar end 

--ppnr_hi 
	
drop table if exists "ADAGE_communes_pprn_hi_20211209";
create table "ADAGE_communes_pprn_hi_20211209" as (
with ppr_uniq as( 
select distinct on (cod_commune) cod_commune, lib_pprn , lib_risque from "Communes_PPRN_HorsInondation" t1 -- 
where cod_commune is not null
)
select t01.cod_commune,  t02.geom, t02.nom_com , lib_pprn , lib_risque from ppr_uniq t01 --, geomc  ,  lib_pprn , lib_risque
left join communes_admin_e_2020 t02
on t01.cod_commune::varchar = t02.insee_com::varchar
where geom is not null)

-- pprt

drop table if exists "ADAGE_communes_pprt_20211209";
create table "ADAGE_communes_pprt_20211209" as (
with ppr_uniq as( 
select distinct on (cod_commune) cod_commune, lib_pprt , lib_risque from "Communes_PPRT_valides" t1 -- 
where cod_commune is not null
)
select t01.cod_commune,  t02.geom, t02.nom_com , lib_pprt , lib_risque from ppr_uniq t01 --, geomc  ,  lib_pprn , lib_risque
left join communes_admin_e_2020 t02
on t01.cod_commune::varchar = t02.insee_com::varchar
where geom is not null)

-- pprm 

drop table if exists "ADAGE_communes_pprm_20211209";
create table "ADAGE_communes_pprm_20211209" as (
with ppr_uniq as( 
select distinct on (cod_commune) cod_commune, lib_pprm , lib_risque from "Communes_PPRMiniers_valides"   t1 -- 
where cod_commune is not null
)
select t01.cod_commune,  t02.geom, t02.nom_com , lib_pprm , lib_risque from ppr_uniq t01 --, geomc  ,  lib_pprn , lib_risque
left join communes_admin_e_2020 t02
on t01.cod_commune::varchar = t02.insee_com::varchar
where geom is not null)

