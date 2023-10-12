alter table scot_fede_allyears add column origin text
update scot_fede_allyears set origin = 'FEDE'


alter table "SCOT_GPU_ExtractEric_20210427" add column origin text
update "SCOT_GPU_ExtractEric_20210427" set origin = 'GPU'

update "scot_date_GPU" set "year" =
case 
	when "except" is null then left("date"::text,4)::int
	else "except"::int
	end;

select * from "scot_date_GPU"

drop table if exists scot_gpu_fede_allyears;
create table scot_gpu_fede_allyears as (
--la table du gpu à laquelle on ajoute l'année d'approb
with temp1 as (
select t1.geom,coalesce(t1.siren::int,0) id, t1.title "name" , t2."year",t1.origin from "SCOT_GPU_ExtractEric_20210427" t1 
	left join "scot_date_GPU" t2 
	on t1.siren::text = t2.siren::text
	),
--formatage de la table de la fede
temp2 as(
select geom,coalesce(siren_epci::int,0) id,scot as "name",annee "year", 'FEDE'::text origin from scot_fede_allyears  
),
-- on set le champ id de la table fede à null pour les géométries qui existent déjà dans la couche GPU selon leur siren et date d'appro
temp21 as(
select geom, 0::int id, "name", "year", origin, id siren 
	from(
		select t1.geom,t1.id::int,t1."name",t1."year",t1.origin
		from temp2 t1 , temp1 t2 
		--on  t1.id::int=t2.id::int and t1."year"::int=t2."year"::int
		where t1.id::int=t2.id::int and t1."year"::int=t2."year"::int
		group by t1.geom, t1.id, t1."name", t1."year", t1.origin
		) temp211),
--on extrait normalement le reste de la fede qui ne correspond pas ni par le siren ni par la date aux géoms du GPU
temp3 as(
select t1.geom,  t1.id::int, t1."name", t1."year", t1.origin 
	from temp2 t1, temp21 t2
	where t1.id <> t2.siren and t1."year"<>t2."year"
	group by t1.geom,  t1.id::int, t1."name", t1."year", t1.origin 
	)

-- union des geom du gpu (114), des geom de la fede avec siren null (58) et du reste des geom de la fede normalement constituées (normalement ~4350) 
select * from temp3
union all
select geom,  id::int, "name", "year", origin  from temp21
union all
select * from temp1
);

--// !! ensuite dans qgis on selectionne avec ça count("concat","concat")>1 and "id">'0' and"origin" ='FEDE'





drop index  if exists scot_gpu_fede_allyears_idx;
create index scot_gpu_fede_allyears_idx on scot_gpu_fede_allyears using gist(geom)

drop table if exists scot_gpu_fede_allyears_final ;
create table scot_gpu_fede_allyears_final as(
select t1.id,"name",t1."year",origin from scot_gpu_fede_allyears t1, "scot_date_GPU" t2
where t1.id <> t2.siren and t1.year <> t2.year and not origin = 'GPU'
and lower("name") like '%pays de vitr%'
group by t1.id,"name",t1."year",origin
)

create table "GPU_DATE" as(
select t1.geom,coalesce(t1.siren::int,0) id, t1.title "name" , t2."year",t1.origin from "SCOT_GPU_ExtractEric_20210427" t1 
	left join "scot_date_GPU" t2 
	on t1.siren::text = t2.siren::text )