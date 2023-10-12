
drop table if exists test;
create table test as (
	
	with t1 as (
	Select  depcom, construct,
	COUNT(DISTINCT id) FROM "F1_MIX_lgt_soc_res_princ"."RPLS2019_detail_PV" where construct > 2005 group by construct, depcom
	order by  depcom asc
	),
	--select * from t1;

	t2 as (
	select * from "F1_MIX_lgt_soc_res_princ".res_princ_full_csv
	--where nom_commune is null
	order by  codgeo asc
	)
	--select * from t2;

	SELECT *
    FROM t1 LEFT OUTER JOIN t2 ON (t1.depcom::varchar = t2.codgeo and t1.construct<year::int )order by codgeo

	--WHERE t2.codgeo = t1.depcom::varchar
	--and t1.construct::varchar=t2.year
	--order by codgeo, construct asc
);
select * from test

Select  depcom,
	COUNT(DISTINCT depcom) from test group by depcom

	
	