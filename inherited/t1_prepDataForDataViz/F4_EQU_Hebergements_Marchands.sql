-- Ce script prend la table en sortie de cogugaison et preprocessing effectu�s sous python pour calculer les valeurs � diff�rentes �chelles territoriales. 
-- On r�introduit des noms de champs complets afin de pouvoir les r�utiliser directement en dataviz.


drop table if exists "F4_EQU_EvolCapaciteHebMarchands"."capacite_hbgmnt_ccles";
create table "F4_EQU_EvolCapaciteHebMarchands"."capacite_hbgmnt_ccles" as (
	with t1 as (
		select Table1.id_geom as insee, Table0.year,sum(htch) as htch  ,sum(cpgel) as cpgel  ,sum(cpgeo) as cpgeo,sum(vvlit) as vvlit,sum(rtlit) as rtlit ,sum(ajcslit) as ajcslit,sum((2*htch)+(3.5*cpgel)+(3.5*cpgeo)+vvlit+rtlit+ajcslit) as total,
		Table1.geom
		from ( select label as ColMaj,label,id_geom,geom from "public"."territory_table_CAP20" ) as Table1
		left join (
			select "codgeo", year,cpgel,htch,cpgeo,vvlit,rtlit,ajcslit,total from "F4_EQU_EvolCapaciteHebMarchands"."capacite_hbgmnt" heb,"public"."territory_table_CAP20" tt  where heb."codgeo"= tt.id_geom
		) as Table0
		on Table0."codgeo" = Table1.id_geom
		where Table1.id_geom is not null and year is not null 
		group by Table1.id_geom,Table0.year,Table1.geom
		order by Table1.id_geom,Table0.year
		),
		--select * from t1
		

	rank2 as (
		SELECT id_geom, ST_Union(geom) geom
			FROM public."territory_table_CAP20"
			WHERE rank = 2
			GROUP BY id_geom
	),
	t2 as (
		select rank2.id_geom as insee,t1.year,sum(htch) as htch  ,sum("cpgel")  as cpgel   ,sum("cpgeo")as cpgeo,sum("vvlit") as vvlit,sum("rtlit")as rtlit ,sum("ajcslit") as "ajcslit",sum((2*htch)+(3.5*cpgel)+(3.5*cpgeo)+vvlit+rtlit+ajcslit) as total,
		rank2.geom
		from rank2
		LEFT JOIN t1
		ON ST_Intersects(ST_PointOnSurface(t1.geom),rank2.geom)
		GROUP BY rank2.id_geom, t1."year", rank2.geom
	),

	rank3 as (
		SELECT id_geom, ST_Union(geom) geom
			FROM public."territory_table_CAP20"
			WHERE rank = 3
			GROUP BY id_geom
	),
	t3 as (
		select rank3.id_geom as insee,t1.year,sum(htch) as htch ,sum("cpgel") as cpgel   ,sum("cpgeo")as cpgeo,sum("vvlit") as vvlit ,sum("rtlit")as rtlit ,sum("ajcslit")as "ajcslit",sum((2*htch)+(3.5*cpgel)+(3.5*cpgeo)+vvlit+rtlit+ajcslit) as total,
		rank3.geom
		from rank3
		LEFT JOIN t1
		ON ST_Intersects(ST_PointOnSurface(t1.geom),rank3.geom)
		GROUP BY rank3.id_geom, t1."year", rank3.geom
	),
	rank4 as (
		SELECT id_geom, ST_Union(geom) geom
			FROM public."territory_table_CAP20"
			WHERE rank = 4
			GROUP BY id_geom
	),
	t4 as (
		select rank4.id_geom as insee,t1.year,sum(htch) as htch ,sum("cpgel") as cpgel   ,sum("cpgeo")as cpgeo,sum("vvlit") as vvlit,sum("rtlit")as rtlit ,sum("ajcslit")as "ajcslit",sum((2*htch)+(3.5*cpgel)+(3.5*cpgeo)+vvlit+rtlit+ajcslit) as total,
		rank4.geom
		from t1,rank4
		WHERE t1.insee IN (
				SELECT terr1.id_geom
				FROM public."territory_table_CAP20" terr1, rank4
				WHERE ST_Intersects(ST_PointOnSurface(terr1.geom),rank4.geom)
					AND terr1.rank = 1
		)
		GROUP BY rank4.id_geom, t1."year", rank4.geom
	)
	
	select insee,"year",2*htch "Lits dans des hôtels",3.5*cpgel "Capacité des campings (loués à l'année)",3.5*cpgeo "Capacité des campings (clientèle de passage)",vvlit"Lits dans des villages vacances",rtlit "Lits dans des résidences de tourisme",ajcslit "Lits dans des auberges de jeunesse", total FROM t1 where year is not null
	UNION
	SELECT insee,"year",2*htch "Lits dans des hôtels",3.5*cpgel "Capacité des campings (loués à l'année)",3.5*cpgeo "Capacité des campings (clientèle de passage)",vvlit"Lits dans des villages vacances",rtlit "Lits dans des résidences de tourisme",ajcslit "Lits dans des auberges de jeunesse",total FROM t2 where year is not null
	UNION 
	SELECT insee,"year",2*htch "Lits dans des hôtels",3.5*cpgel "Capacité des campings (loués à l'année)",3.5*cpgeo "Capacité des campings (clientèle de passage)",vvlit"Lits dans des villages vacances",rtlit "Lits dans des résidences de tourisme",ajcslit "Lits dans des auberges de jeunesse",total FROM t3 where year is not null
	UNION 
	SELECT insee,"year",2*htch "Lits dans des hôtels",3.5*cpgel "Capacité des campings (loués à l'année)",3.5*cpgeo  "Capacité des campings (clientèle de passage)",vvlit"Lits dans des villages vacances",rtlit "Lits dans des résidences de tourisme",ajcslit "Lits dans des auberges de jeunesse",total FROM t4 where year is not null
	ORDER BY insee, "year"
);
select * from "F4_EQU_EvolCapaciteHebMarchands".capacite_hbgmnt_ccles
order by insee, year

