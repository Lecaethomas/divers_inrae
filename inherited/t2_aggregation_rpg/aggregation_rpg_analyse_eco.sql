Case 
when  "CODE_GROUP" in ('0','1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','24','25','26', '28') then 'Cultures annuelles'

when  "CODE_GROUP" in ('16','19') then 'Prairies temporaires'

when  "CODE_GROUP" in ('18','17') then 'Prairies permanentes'

when  "CODE_GROUP" in ('23','22') then 'Maraichage - Cultures légumières'

when  "CODE_GROUP" in ('27') then 'Arboriculture'

when  "CODE_GROUP" in ('20') then 'Verger'

when  "CODE_GROUP" in ('21') then 'Vignes'

end


--/////--- sans maraichage -- pcq j'arrivais pas à l'isoler ---//////---
Case 
when  "CODE_GROUP" in ('0','1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','24','25','26', '28') then 'Cultures annuelles'

when  "CODE_GROUP" in ('16','19') then 'Prairies temporaires'

when  "CODE_GROUP" in ('18','17') then 'Prairies permanentes'

--when  "CODE_GROUP" in ('23','22') then 'Maraichage'

when  "CODE_GROUP" in ('27', '23','22') then 'Arboriculture'

when  "CODE_GROUP" in ('20') then 'Verger'

when  "CODE_GROUP" in ('21') then 'Vignes'

end

