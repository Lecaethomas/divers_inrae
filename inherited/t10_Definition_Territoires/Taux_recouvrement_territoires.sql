-- Un script pour calculer un taux de recouvrement entre des géométries T1 et T2
-- pour chaque geom de t1 on a autant de ligne qu'il y a d'intersection avec une autre géométrie de t2 
drop table if exists proportions_cover_scot;
create table proportions_cover_scot as(
select  t1.geom,t1.title , t1.siren sirenGpu,(st_area(st_intersection(st_makevalid(t2.geom), st_makevalid(t1.geom)))/st_area(t2.geom))*100 as proportion,t2.scot, t2.siren sirenFede  
	from "SCOT_GPU_ExtractEric_20210427" t1, "SCoT_fedescot_2021" t2 
	where st_intersects(t1.geom, t2.geom)
	order by t1.id, proportion desc)




