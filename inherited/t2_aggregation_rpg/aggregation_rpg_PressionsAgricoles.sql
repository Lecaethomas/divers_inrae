Case 
when  "CODE_GROUP" in ('0','1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','24','25','26', '28') then '2111' --cultures annuelles

when  "CODE_GROUP" in ('16','19','18','17') then '2310' --prairies

when  "CODE_GROUP" in ('20','23','22') then '2112' --maraichage

when  "CODE_GROUP" in ('27','20','21') then '2220' -- Verger


end