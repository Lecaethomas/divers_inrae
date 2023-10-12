DO $$
DECLARE
    tables CURSOR FOR
        SELECT tablename
        FROM pg_tables
        where schemaname = 'TA_DATA_INTEGRATION'
        and length(tablename) = 14
        ORDER BY tablename;
    --nbRow geometry;
BEGIN
    FOR table_record IN tables LOOP
        EXECUTE 'drop table if exists '||table_record.tablename||'_processed;
				create table '||table_record.tablename||'_processed as (
				select t1.*, 2*htchxx::real "lits_ds_htls",3.5*cpgelxx::real "cpcite_cpgs_(a_l_annee)",3.5*cpgeoxx::real "cpcite_cpgs_(cltl_de_pssge)" 
					from "TA_DATA_INTEGRATION".'||table_record.tablename||' t1
						)';
    END LOOP;
END$$;