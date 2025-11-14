cd "C:\Users\wb545671\OneDrive - WBG\AFE_work\Mission\5.UGA_Nov2025\UGA_training\01.dofiles\Day2\data"

spshape2dta "gha_admbnda_adm2_gss_20210308.shp", replace saving(gha_admin) 

use gha_admin, clear

gen district = substr( ADM2_PCODE,3,.)
destring district, replace
merge 1:1 district using FH_sae_poverty
drop if _m == 2
save gha_pov_data.dta, replace 

geoframe create admin using gha_pov_data.dta, coord(_CX _CY) shp(gha_admin_shp.dta) replace

geoplot (area admin fh_fgt0, level(9) color(carto RedOr) lc(white)) ///
/*(label admin ADM2_EN, color(black) pos(12))*/, clegend(title("Poverty rate",size(small)) pos(5) form(%2.2f)) zlabel(0 "0%" .1 "10%" .2 "20%" .3 "30%" .4 "40%" .5 "50%" .6 "60%" .7 "70%" .8 "80%") xsize(6) ysize(8)

//////////////////////////////////// map for MOZ ///////////////////////////////
use "C:\Users\wb545671\OneDrive - WBG\AFE_work\007.QER\MOZ2022\Output\hh_poverty_v4_M_May.dta", clear
ren weight_pop wgt
gen cons = rcons_tot_pc/cpi2017/ppp2017
gen year = 2022
gen poor = cons<2.15
collapse (mean) poor [aw=wgt], by(provincia)
gen _ID = 8	if provincia == 1
replace _ID = 1	if provincia == 2
replace _ID = 7	if provincia == 3
replace _ID = 11 if provincia == 4
replace _ID = 10 if provincia == 5
replace _ID = 4	if provincia == 6
replace _ID = 9	if provincia == 7
replace _ID = 3	if provincia == 8
replace _ID = 2	if provincia == 9
replace _ID = 5	if provincia == 10
replace _ID = 6	if provincia == 11
tempfile data
save `data', replace

cd "C:\Users\wb545671\OneDrive - WBG\AFE_work\007.QER\MOZ2022\report\ch2_update\data\gadm41_MOZ_shp"
spshape2dta "gadm41_MOZ_1.shp", replace saving("MOZ")
use "MOZ", clear
ren (_CX _CY) (_X _Y)
merge 1:1 _ID using `data'
keep if _m==3
drop _m
gen label_pov = string(round(poor*100,0.1))+"%"
save, replace

geoframe create admin using "MOZ", replace

geoplot (area admin poor, level(9) color(carto RedOr) lc(white)) ///
(label admin label_pov if _ID !=6, color(black) pos(6) size(vsmall)) ///
(label admin NAME_1 if _ID !=6, color(black) pos(12)) ///
(area admin poor if _ID ==6, level(9) color(carto RedOr) lc(white)), ///
clegend(title("Poverty rate ($2.15)",size(small)) pos(5) form(%2.2f)) zlabel(0 "0%" .1 "10%" .2 "20%" .3 "30%" .4 "40%" .5 "50%" .6 "60%" .7 "70%" .8 "80%") ///
zoom(4: 4.5 350 20, circle connect(lp(dash)) lcolor(black) title("Maputo City" "23.4%", size(2.5))) xsize(6) ysize(8)
graph export "$path\F2.10.svg", as(svg) name("Graph") replace	
