--Complete processus for OSM data import into PostGIS DB, from an .osm file to routable graph for isochrones
--Before executing SQL you needs to extract the .osm file with osm2pgsql (for example), and default.style file which contains DB structure
--CMD avec version décrite par les étudiants: 
	--osm2pgsql -v -d Test -U postgres -H localhost -P 5432 -S "D:\Data\Isochrones\default.style" D:\Data\Isochrones\midi-pyrenees-latest.osm
--CMD avec version actuelle: 
	--osm2pgsql -s -v -d Test -U postgres -H localhost -W -P 5432 --flat-nodes D:\Data\Isochrones\flat-nodes.bin -S "D:\Data\Isochrones\default.style" D:\Data\Isochrones\france-latest.osm.pbf
	--"Osm2pgsql took 573792s overall" (6.64j)

--Pour installer le nécessaire sur la nouvelle base:
--CREATE EXTENSION postgis;
--CREATE EXTENSION postgis_raster;
--CREATE EXTENSION postgis_sfcgal;
--CREATE EXTENSION address_standardizer;
--CREATE EXTENSION fuzzystrmatch;
--CREATE EXTENSION postgis_topology;
--CREATE EXTENSION postgis_tiger_geocoder;
--CREATE EXTENSION pgrouting;

--Variables à remplacer (selon le territoire):
	-- route_st_pf
	-- psb_emprise
	-- route_ST_pf_topo
	-- idx_route_st_pf_geom



DROP TABLE IF EXISTS osm_line_pf_20220425;
CREATE TABLE osm_line_pf_20220425 AS (
SELECT osm_id,"access","addr:housename","addr:housenumber","addr:interpolation",admin_level,aerialway,aeroway,amenity,area,barrier,bicycle,brand,bridge,boundary,building,construction,covered,culvert,cutting,denomination,disused,embankment,foot,"generator:source",harbour,highway,historic,horse,intermittent,junction,landuse,layer,leisure,"lock",man_made,military,motorcar,"name","natural",office,oneway,"operator",place,population,power,power_source,public_transport,railway,"ref",religion,route,service,shop,sport,surface,toll,tourism,"tower:type",tracktype,tunnel,water,waterway,wetland,width,wood,z_order,way_area,way 
FROM "planet_osm_line_BN" t, public."emprise_PF" p
WHERE st_intersects( t.way, st_transform(p.geom,3857))
UNION
SELECT osm_id,"access","addr:housename","addr:housenumber","addr:interpolation",admin_level,aerialway,aeroway,amenity,area,barrier,bicycle,brand,bridge,boundary,building,construction,covered,culvert,cutting,denomination,disused,embankment,foot,"generator:source",harbour,highway,historic,horse,intermittent,junction,landuse,layer,leisure,"lock",man_made,military,motorcar,"name","natural",office,oneway,"operator",place,population,power,power_source,public_transport,railway,"ref",religion,route,service,shop,sport,surface,toll,tourism,"tower:type",tracktype,tunnel,water,waterway,wetland,width,wood,z_order,way_area,way 
FROM "planet_osm_line_Br"t, public."emprise_PF" p
WHERE st_intersects( t.way, st_transform(p.geom,3857))
UNION 
SELECT osm_id,"access","addr:housename","addr:housenumber","addr:interpolation",admin_level,aerialway,aeroway,amenity,area,barrier,bicycle,brand,bridge,boundary,building,construction,covered,culvert,cutting,denomination,disused,embankment,foot,"generator:source",harbour,highway,historic,horse,intermittent,junction,landuse,layer,leisure,"lock",man_made,military,motorcar,"name","natural",office,oneway,"operator",place,population,power,power_source,public_transport,railway,"ref",religion,route,service,shop,sport,surface,toll,tourism,"tower:type",tracktype,tunnel,water,waterway,wetland,width,wood,z_order,way_area,way 
FROM "planet_osm_line_PdL"t, public."emprise_PF" p
WHERE st_intersects( t.way, st_transform(p.geom,3857))
);

--Conversion to EPSG:2154 (ajout d'une colonne en 2154, "way" reste en 3857) (104 min 17 secs)
--À executer uniqument la première fois.

ALTER TABLE public.osm_line_pf_20220425 ADD COLUMN geom geometry
(LINESTRING,2154);
UPDATE public.osm_line_pf_20220425 SET geom=st_transform(way,2154);


SELECT count(*) FROM public.osm_line_pf_20220425 WHERE ST_IsSimple(geom) = FALSE;

--Use an "empriseST" named file with your project perimeter (21 min 42 secs)
/*DROP TABLE IF EXISTS route_st_pf;
CREATE TABLE route_st_pf
AS SELECT osm_id, access, "addr:housename", "addr:housenumber",
"addr:interpolation",admin_level, aerialway, aeroway, amenity, area, barrier,
bicycle, brand, bridge, boundary, building, construction, covered, culvert,
cutting, denomination, disused, embankment, foot, "generator:source",
harbour, highway, historic, horse, intermittent, junction, landuse, layer,
leisure, LOCK, man_made, military, motorcar, name, office, oneway,
operator, place, a.population, POWER, power_source, public_transport,
railway, REF, religion, route, service, shop, sport, surface, toll, tourism,
"tower:type", tracktype, tunnel, water, waterway, wetland, width, wood,
z_order, ST_Segmentize(st_intersection(a.geom,b.geom),200) AS geom
FROM public.planet_osm_line_pf_20220425 a, public."empriseST_Paris" b
WHERE a.geom && b.geom AND ST_intersects(a.geom,b.geom) AND highway IS NOT NULL;*/

-- If needed, cut long roads here: load "route_ST", split it, then replace the DB layer with your new route_ST, 
-- OR, run this instead to split every 100m:

/*(From https://gis.stackexchange.com/questions/199395/qgis-or-postgis-auto-split-long-line-features/199465#199465)*/
-- (~ 4-5mn)



DROP TABLE IF EXISTS route_st_pf;
CREATE TABLE route_st_pf AS (
	WITH temp_route_st_pf AS (
		SELECT osm_id, access, admin_level, aerialway, aeroway,
		bicycle, bridge, highway, horse, motorcar, oneway, public_transport,
		railway, route, service, tracktype, tunnel, waterway, 
		ST_Segmentize(st_intersection(a.geom,b.geom),200) AS geom
		FROM public.osm_line_pf_20220425 a, public."emprise_PF" b
		WHERE a.geom && b.geom AND ST_intersects(a.geom,b.geom) AND highway IS NOT NULL AND  ST_IsSimple(a.geom) <> FALSE
	)
	SELECT b.osm_id, b.access, b.admin_level, b.aerialway, b.aeroway,
		b.bicycle, b.bridge, b.highway, b.horse, b.motorcar, b.oneway, b.public_transport,
		b.railway, b.route, b.service, b.tracktype, b.tunnel, b.waterway, 
		row_number() OVER() new_id,
	ST_LineSubstring(temp_route_st_pf.geom, b.dist_from/ST_Length(temp_route_st_pf.geom), LEAST(b.dist_to/ST_Length(temp_route_st_pf.geom), 1)) geom
	FROM (
	  SELECT osm_id, access, admin_level, aerialway, aeroway,
		bicycle, bridge, highway, horse, motorcar, oneway, public_transport,
		railway, route, service, tracktype, tunnel, waterway, 
		dist dist_from, LEAD(dist) OVER (PARTITION BY osm_id ORDER BY dist) dist_to
	  FROM (
	    SELECT osm_id, access, admin_level, aerialway, aeroway,
		bicycle, bridge, highway, horse, motorcar, oneway, public_transport,
		railway, route, service, tracktype, tunnel, waterway, 
		generate_series(0, ceil(ST_Length(temp_route_st_pf.geom)/100.0)::int*100, 100) dist
	    FROM temp_route_st_pf
	    ) a
	  ) b
	JOIN temp_route_st_pf ON b.osm_id = temp_route_st_pf.osm_id
	WHERE b.dist_to IS NOT NULL
);

--Create spatial index
drop index if exists idx_route_st_pf_geom ;
CREATE INDEX idx_route_st_pf_geom ON route_st_pf USING gist (geom);

--Add primariy key (36 min 58 secs.)
ALTER TABLE route_st_pf ADD COLUMN id_route SERIAL PRIMARY KEY; 

--Create topology
--If you need to drop topology: SELECT topology.DropTopology('route_ST_pf_topo');

drop schema if exists "route_ST_pf_topo" cascade;
SELECT topology.CreateTopology('route_ST_pf_topo', 2154);

--Add field for relations
SELECT topology.AddTopoGeometryColumn('route_ST_pf_topo', 'public', 'route_st_pf', 'topo_geom', 'LINESTRING');



--Get relations infos, may be a long step (~48h sur PSB)
-- ! la fonction opology.toTopoGeom() génère les relations de topologie mais permet aussi, grace au 4e paramètre de modifier à la marge la géométrie, soit de "snapper" les end et start point des lignes entre eux selon une tolérance 
DO $$DECLARE r record;
BEGIN
FOR r IN SELECT * FROM route_st_pf LOOP
BEGIN
UPDATE route_st_pf SET topo_geom = topology.toTopoGeom(geom,'route_ST_pf_topo', 1, 0.001)
WHERE id_route = r.id_route;
EXCEPTION
WHEN OTHERS THEN
RAISE WARNING 'Loading of record % failed: %', r.id_route, SQLERRM;
END;
END LOOP;
END$$;


--Get attribute infos (~50mn)
ALTER TABLE "route_ST_pf_topo".edge_data add COLUMN type character varying;
ALTER TABLE "route_ST_pf_topo".edge_data add COLUMN nom character varying;
ALTER TABLE "route_ST_pf_topo".edge_data add COLUMN tunnel character varying;
ALTER TABLE "route_ST_pf_topo".edge_data add COLUMN bridge character varying;
ALTER TABLE "route_ST_pf_topo".edge_data add COLUMN id_route integer;
ALTER TABLE "route_ST_pf_topo".edge_data add COLUMN oneway character varying;

DROP TABLE IF EXISTS "route_ST_pf_topo".route_edge_data;
create table "route_ST_pf_topo".route_edge_data as
SELECT e.edge_id,r.highway as type , r.oneway as oneway, r.tunnel as
tunnel, r.bridge as bridge, r.id_route as id_route
FROM "route_ST_pf_topo".edge e, "route_ST_pf_topo".relation rel, public.route_st_pf r
WHERE e.edge_id = rel.element_id AND rel.topogeo_id = (r.topo_geom).id;

--Get rid of bridges and tunnels issues
UPDATE "route_ST_pf_topo".edge_data a SET (type,tunnel,bridge,id_route,oneway) =
(r.type,r.tunnel,r.bridge,r.id_route,r.oneway)
FROM "route_ST_pf_topo".route_edge_data r WHERE a.edge_id=r.edge_id;

DROP TABLE IF EXISTS "route_ST_pf_topo".bridge_segments;
Create table "route_ST_pf_topo".bridge_segments as
SELECT a.type,a.nom,a.bridge, ST_LineMerge(st_union(a.geom)) as geom
from "route_ST_pf_topo".edge_data a, "route_ST_pf_topo".edge_data b
where a.id_route = b.id_route and a.bridge='yes' group by
a.id_route,a.type,a.nom,a.bridge;

DROP TABLE IF EXISTS "route_ST_pf_topo".tunnel_segments;
Create table "route_ST_pf_topo".tunnel_segments as
SELECT a.type,a.nom,a.tunnel, ST_LineMerge(st_union(a.geom)) as geom
from "route_ST_pf_topo".edge_data a, "route_ST_pf_topo".edge_data b
where a.id_route = b.id_route and a.tunnel='yes' group by
a.id_route,a.type,a.nom,a.tunnel;

--New table
DROP TABLE IF EXISTS "route_ST_pf_topo".new_edge_data;
Create table "route_ST_pf_topo".new_edge_data as
select a.type,a.nom,a.bridge,a.tunnel,a.geom,a.oneway from "route_ST_pf_topo".edge_data a;

--Delete bridges and tunnels parts
DELETE FROM "route_ST_pf_topo".new_edge_data a WHERE a.bridge='yes';
DELETE FROM "route_ST_pf_topo".new_edge_data a WHERE a.tunnel='yes';

--Replace bridges and tunnels parts by thoses freshly created
--If an error about multi linestrings pops at this step, try this before:
	--ALTER TABLE "route_ST_pf_topo".bridge_segments
	--ALTER COLUMN geom TYPE geometry(linestring,2154) USING ST_GeometryN(geom, 1);
	--ALTER TABLE "route_ST_pf_topo".tunnel_segments
	--ALTER COLUMN geom TYPE geometry(linestring,2154) USING ST_GeometryN(geom, 1);
INSERT INTO "route_ST_pf_topo".new_edge_data (type,bridge,geom)
SELECT type,bridge,geom
FROM "route_ST_pf_topo".bridge_segments;
INSERT INTO "route_ST_pf_topo".new_edge_data (type,tunnel,geom)
SELECT type,tunnel,geom
FROM "route_ST_pf_topo".tunnel_segments;


ALTER TABLE "route_ST_pf_topo".new_edge_data ADD COLUMN edge_id SERIAL PRIMARY KEY;
ALTER TABLE "route_ST_pf_topo".new_edge_data ADD COLUMN "source" integer;
ALTER TABLE "route_ST_pf_topo".new_edge_data ADD COLUMN "target" integer;
select pgr_createTopology('route_ST_pf_topo.new_edge_data', 0.001,'geom',
'edge_id');


ALTER TABLE "route_ST_pf_topo".new_edge_data add COLUMN tps_distance double precision;
UPDATE "route_ST_pf_topo".new_edge_data a SET
tps_distance=st_length(st_transform(geom,2154))/1000;


--Assign pedestrian speed
ALTER Table "route_ST_pf_topo".new_edge_data ADD COLUMN tps_pieton double precision;
UPDATE "route_ST_pf_topo".new_edge_data SET tps_pieton = -1 ;
UPDATE "route_ST_pf_topo".new_edge_data SET tps_pieton = tps_distance /5 WHERE
type IN
('primary','primary_link','secondary','secondary_link','tertiary','tertiary_link',
'residential','living_street','pedestrian','track','road','footway','path',
'cycleway','crossing','unclassified') ;
UPDATE "route_ST_pf_topo".new_edge_data SET tps_pieton = tps_distance /2 WHERE
type ='steps';


--Assign bike speed
ALTER TABLE "route_ST_pf_topo".new_edge_data ADD COLUMN tps_velo double precision;
UPDATE "route_ST_pf_topo".new_edge_data SET tps_velo = -1 ;
UPDATE "route_ST_pf_topo".new_edge_data SET tps_velo = tps_distance /17 WHERE
type
IN('primary','primary_link','secondary','secondary_link','tertiary','tertiary_link',
'residential','living_street','pedestrian','road','unclassified') ;
UPDATE "route_ST_pf_topo".new_edge_data SET tps_velo =tps_distance /19.55 WHERE
type ='cycleway' ;
UPDATE "route_ST_pf_topo".new_edge_data SET tps_velo =tps_distance /13 WHERE
type IN ('path','track','footway') ;
UPDATE "route_ST_pf_topo".new_edge_data SET tps_velo = tps_distance /2 WHERE
type ='steps';


--Assign car speed
ALTER TABLE "route_ST_pf_topo".new_edge_data ADD COLUMN tps_voiture double precision;
UPDATE "route_ST_pf_topo".new_edge_data SET tps_voiture = -1 ;
update "route_ST_pf_topo".new_edge_data set tps_voiture = tps_distance /100 where type =  'trunk';
update "route_ST_pf_topo".new_edge_data set tps_voiture = tps_distance /30 where type = 'trunk_link';  
update "route_ST_pf_topo".new_edge_data set tps_voiture = tps_distance /120 where type ='motorway';
update "route_ST_pf_topo".new_edge_data set tps_voiture = tps_distance /30 where type = 'motorway_link';
update "route_ST_pf_topo".new_edge_data set tps_voiture = tps_distance /80 where type ='primary';
update "route_ST_pf_topo".new_edge_data set tps_voiture = tps_distance /30 where type = 'primary_link';
update "route_ST_pf_topo".new_edge_data set tps_voiture = tps_distance /70 where type = 'secondary';
update "route_ST_pf_topo".new_edge_data set tps_voiture = tps_distance /30 where type = 'secondary_link';
update "route_ST_pf_topo".new_edge_data set tps_voiture = tps_distance /50 where type = 'tertiary';
update "route_ST_pf_topo".new_edge_data set tps_voiture = tps_distance /30 where type = 'tertiary_link';
update "route_ST_pf_topo".new_edge_data set tps_voiture = tps_distance /50 where type = 'residential' ;
update "route_ST_pf_topo".new_edge_data set tps_voiture = tps_distance /50 where type = 'road';
update "route_ST_pf_topo".new_edge_data set tps_voiture = tps_distance /50 where type = 'unclassified';
update "route_ST_pf_topo".new_edge_data set tps_voiture = tps_distance /20 where type = 'living_street';

--Assign reverse_cost, here only for cars
ALTER TABLE "route_ST_pf_topo".new_edge_data ADD COLUMN reverse_cost double precision;
UPDATE "route_ST_pf_topo".new_edge_data SET reverse_cost = tps_voiture;
update "route_ST_pf_topo".new_edge_data set reverse_cost = -1 where oneway = 'yes';










--AUTRES COMMANDES UTILES-- ----- A ne pas utiliser a priori

--Ajout et update d'une colonne d'aléa:
ALTER TABLE "route_ST_Paris_topo".new_edge_data_vertices_pgr ADD COLUMN alea double precision;
update "route_ST_Paris_topo".new_edge_data_vertices_pgr set alea = -1;
update "route_ST_Paris_topo".new_edge_data_vertices_pgr set alea = 5
FROM (
	SELECT a.id, a.alea
	from "route_ST_Paris_topo".new_edge_data_vertices_pgr a, public."Crues_2" b
	where ST_Within(a.the_geom, b.geom)
)
where "route_ST_Paris_topo".new_edge_data_vertices_pgr.id=z.id;

--Points hors d'eau
WITH alealines AS (
	WITH aleapoints AS (
		SELECT * 
		FROM "route_ST_Paris_topo".new_edge_data_vertices_pgr
		WHERE alea != -1
	)
	SELECT e.geom
	FROM "route_ST_Paris_topo".new_edge_data e, aleapoints
	WHERE ST_Intersects(e.geom,aleapoints.the_geom)
)
SELECT v.the_geom
FROM "route_ST_Paris_topo".new_edge_data_vertices_pgr v, alealines
WHERE ST_Intersects(v.the_geom,alealines.geom)
AND v.alea = -1

--gare, arrêts de bus, espaces verts, medecins, pharmacies, lieux de cultes, mairies bureaux de postes 