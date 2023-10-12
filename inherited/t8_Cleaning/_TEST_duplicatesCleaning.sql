-------- Tentative de nettoyage des doublons-----------------
drop table if exists carroyage_pv_centralite_full__;
create table carroyage_pv_centralite_full__ as (
select geom,"ID_CAR",id,"NbrLog" from (
SELECT geom,"ID_CAR",id,"NbrLog", ROW_NUMBER() OVER(PARTITION BY geom ORDER BY id asc) AS Row,
geom FROM ONLY carroyage_pv_centralite_full_ 
group by id, geom,"ID_CAR"
) dups )--where dups.Row > 1