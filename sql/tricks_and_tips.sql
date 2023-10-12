
-- reload PG conf file after changing settings (settings must be uncommented -
-- IDK why, but it seems that there's default parameters somewhere else)
select pg_reload_conf();
-- see the values of max_parrel_workers params
SELECT name, setting FROM pg_settings WHERE name LIKE 'max_parallel%';
 --pour voir les requetes qui tournent encore
SELECT * FROM pg_stat_activity WHERE state = 'active';  
-- si on veut faire sauter toutes les requetes :: (attention ne pas utiliser sur le serveur)
--SELECT pg_cancel_backend(pid) FROM pg_stat_activity WHERE state = 'active';   
-- pour stoper la requete (le PID) voulue 
-- en mode "soft"
SELECT pg_cancel_backend(2364);                                 
-- en mode moins soft
SELECT pg_terminate_backend(2364); 
