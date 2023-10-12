-- un script pour tracer les lignes entre toutes les O-D théoriques
-- elles ont vocation à être appelées par la dataviz en cours de test pour être tranformées en arc et jointes avec les CClés
drop table if exists ;
create table "F1_MOB_Flux_DomTrav_lines as(
select  (st_dump(st_makeline(t1.geom, t2.geom))).geom geom, t1."NOM_COM_M" nom_dep,t1."INSEE_COM" insee_dep,t2."NOM_COM_M" nom_dest,t2."INSEE_COM" insee_dest 
from "centroids_communes_PSB_depart" t1, "centroids_communes_PSB_dest" t2
where t1."INSEE_COM" <> t2."INSEE_COM"
)
