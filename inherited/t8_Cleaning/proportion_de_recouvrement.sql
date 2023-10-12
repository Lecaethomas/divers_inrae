--Cette requête prend deux couches en entrée et permet d'écrire une couche rassemblant les géométries des deux avec d'une part chancune des géométries d'une des couches (t1) et d'autre part, pour chancune d'entre elles,
-- toute les géométries qui les intersectent et le taux de recouvrement correspondant

drop table if exists proportions_cover_scot;
create table proportions_cover_scot as(
select  t1.geom,t1.title , t1.siren sirenGpu,(st_area(st_intersection(st_makevalid(t2.geom), st_makevalid(t1.geom)))/st_area(t2.geom))*100 as proportion,t2.scot, t2.siren sirenFede  
from "SCOT_GPU_ExtractEric_20210427" t1, "SCoT_fedescot_2021" t2 
where st_intersects(t1.geom, t2.geom)
--group by scot, t.siren, b.title , b.siren, proportion
order by t1.id, proportion desc)