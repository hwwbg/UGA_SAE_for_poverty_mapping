cd "C:\Users\wb545671\OneDrive - WBG\AFE_work\Mission\5.UGA_Nov2025\UGA_training\UGA_example\map"

use "C:\Users\wb545671\OneDrive - WBG\AFE_work\Mission\5.UGA_Nov2025\UGA_training\UGA_example\data_in\UNHS2023_hh.dta", clear
 decode subreg, gen(REGNAME)
collapse poor_new [aw = hmult],by(REGNAME)
tempfile data
save `data', replace

*spshape2dta "uga_admbnda_adm4_ubos_20200824", replace saving(uga_admin4) 
*spshape2dta "uga_admbnda_adm3_ubos_20200824", replace saving(uga_admin3) 
*spshape2dta "uga_admbnda_adm2_ubos_20200824", replace saving(uga_admin2)
*spshape2dta "admin1_combined", replace saving(uga_admin1)

use uga_admin4, clear
merge 1:1 REGNAME using  `data'
save uga_admin1.dta, replace 

geoframe create uga_admin1 using uga_admin1.dta, coord(_CX _CY) shp(uga_admin1_shp.dta) replace

geoplot (area uga_admin1 poor_new, level(9) color(carto RedOr) lc(white)) (label uga_admin1 REGNAME, color(black) pos(12)), clegend(title("Poverty rate",size(small)) pos(5) form(%2.2f)) zlabel(0 "0%" .1 "10%" .2 "20%" .3 "30%" .4 "40%" .5 "50%" .6 "60%" .7 "70%" .8 "80%") xsize(6) ysize(8)