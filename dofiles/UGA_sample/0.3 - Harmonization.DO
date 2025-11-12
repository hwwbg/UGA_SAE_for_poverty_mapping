global path "C:\Users\wb545671\OneDrive - WBG\AFE_work\Mission\5.UGA_Nov2025\UGA_training"
global datain "C:\Users\wb545671\OneDrive - WBG\Kristina Noelle Vaughan's files - UNHS 2023_24\UNHS2024Data"

/////////////////////////////// survey /////////////////////////////////////////

use "$datain\HSEC11A_2.dta", clear
keep if  Stove4c__id == 0 //main stove
recode HC3 (3 96 = 10) (4 = 3) (5 = 4)(6 =5) (7 = 6) (8 = 7) (9=8) ( 10= 9) (. .a = .), gen (stove)
keep hhid stove
tempfile D11A
save `D11A', replace

/*use "$datain\HSEC11B_2.dta", clear
gen HG3 = (HG3a*60+HG3b)*HG4 if HG3a <= 24 & HG3b <= 60 & HG4 != 98
replace HG3 = 0 if HG3 == .
label var HG3 "enegy collection time for 30 days"
keep hhid HG3
collapse (sum) HG3, by(hhid)
replace HG3 = . if HG3 == 0
drop if HG3 == .
tempfile D11B2
save `D11B2', replace*/

use "$datain\HSEC11C_2.dta", clear
keep if Lighting4f__id == 0
recode HL2 (96 = 13) (. .a = .), gen (light)
keep hhid light
tempfile D11C2
save `D11C2', replace

use "$datain\HSEC12.dta", clear
keep if HA03 == 1 | HA03 == 4 | HA03 == 5
ren (HA05 HA06 HH_Assets__id) (num value asset)
keep hhid asset num value
gen a = 1
reshape wide a num value, i(hhid) j(asset)
ren a* assets*
foreach v of var asset*{
	replace `v' = 0 if mi(`v')
}
ren num* assets_num*
ren value* assets_value*

tempfile D12
save `D12', replace

/*use "$datain\HSEC13.dta", clear
keep hhid Income_source__id
ren Income_source__id a
gen income = 1
reshape wide income, i(hhid) j(a)
tempfile D13
save `D13', replace*/

use "$datain\HSEC14A.dta", clear
duplicates drop hhid, force
tempfile D14a
save `D14a', replace


use "$path\UGA_example\data_in\POV_2024.dta", clear
merge 1:1 hhid using "$datain\HSEC10.dta", nogen
merge 1:1 hhid using `D11A', nogen
*merge 1:1 hhid using `D11B2', nogen
merge 1:1 hhid using `D11C2', nogen
merge 1:1 hhid using "$datain\HSEC11B_1.dta", nogen
merge 1:1 hhid using "$datain\HSEC11C_1.dta", nogen
merge 1:1 hhid using "$datain\HSEC11D.dta", nogen
merge 1:1 hhid using `D12', nogen
*merge 1:1 hhid using `D13', nogen
merge 1:1 hhid using `D14a', nogen

*save "$path\UGA_example\data_in\UNHS2023_hh_temp.dta", replace
//dweling tenure
recode HC01 (96 = 8) (. .a = .), gen(dwell_tenure)

//dwelling type
recode HC02 (96 = 11) (. .a = .), gen(dwell_type)

//rooms
gen room = HC03
recode room (.a = .)

//roof
recode HC04 (96 = 7) (. .a = .), gen(roof)

//wall
recode HC05 (96 = 9) (. .a = .), gen(wall)

//floor 
recode HC06 (1 96 = 8) (. .a = .), gen(floor)

//ran out of food
recode FIE06 (2 = 0) (98 99 . .a = .), gen(nofood)

//skip meal
recode FIE04 (2 = 0) (98 99 . .a = .), gen(skip_meal)

//stove (asset)
*recode HC3 (3 96 = 11), gen(stove)

//light
*recode HL2 (96 = 12), gen(light)

//solar power
gen solar = inlist(HE1,3,4,5)
forv i = 1/7{
	replace HE2__`i' = 0 if solar == 0 & HE2__`i' !=1
}

recode HE2__1 (1 = 1), gen(solar_phone_charger)
recode HE2__2 (1 = 1), gen(solar_radio)
recode HE2__3 (1 = 1), gen(solar_tv)
recode HE2__4 (1 = 1), gen(solar_fan)
recode HE2__5 (1 = 1), gen(solar_refrig)
recode HE2__6 (1 = 1), gen(solar_iron)
recode HE2__7 (1 = 1), gen(solar_cook)

//kitchen
recode HC26 (. .a = .), gen(kitchen)

//drink water
recode HC07 (96 = 14) (. .a = .), gen(water_drink)

//distance to water 
recode HC09 (1 2 = 1)(3 4 = 2) (. .a = .), gen(water_dis)
replace water_dis = 1 if inlist(HC07,1,2,4,9,12)
//toilet
recode HC14 (96 = 9 )(. .a = .), gen(toilet_type)


//shared toilet
recode HC15 (2 = 0) (97 . .a = .), gen(toilet_share)

//hand wash
gen hand_wash = HC17

//bathroom
recode HC28 (96 = 7)(. .a = .), gen(bathroom)

//solid waste
recode HC27 (1 6 = 1) (3 = 2) (2 = 3) (5 = 4) (4 = 5) (7 96 = 6) (.a = .), gen(waste)

/*
1 "Collected/Supervised" ///
2 "Unsupervised dump/heap" ///
3 "Pit (burn/bury)" ///
4 "Burning (open air)" ///
5 "Garden/compost" ///
6 "Other/unspecified"*/


//assets
* 1. Motor vehicle
gen asset_vehicle = assets16

* 2. Motorcycle
gen asset_motorcycle = assets17

* 3. Bicycle
gen asset_bicycle = assets18

* 4. Television
gen asset_tv = assets8

* 5. Radio
gen asset_radio = assets9

* 6. Computer / Laptop
gen asset_computer = assets13

* 7. Generator
gen asset_generator = assets14

* 8. Solar panel / inverter
gen asset_solar = assets15
replace asset_solar = 1 if solar == 1
drop solar

* 9. Refrigerator
gen asset_refrigerator = assets7

* Label variables
label var asset_vehicle      "Owns motor vehicle (any type)"
label var asset_motorcycle   "Owns motorcycle"
label var asset_bicycle      "Owns bicycle"
label var asset_tv           "Owns television"
label var asset_radio        "Owns radio"
label var asset_computer     "Owns computer/laptop"
label var asset_generator    "Owns generator"
label var asset_solar        "Owns solar panel/inverter"
label var asset_refrigerator "Owns refrigerator"


//two set of cloth
recode W02 (2 = 0)(. .a = .) , gen(cloth)

//one pair of shoes
recode W04 (2 = 0)(. .a = .), gen(shoes)

keep hhid - poor_new dwell_tenure - shoes stove* light*

//subcounty
gen hid = substr(hhid,2,.)
gen subcouty = substr(hid,1,6)
gen couty = substr(hid,1,4)

//poverty line
sum poor_new [aw= hmult]
_pctile welfare [aw= hmult ], p(`=`r(mean)'*100')
gen pline = r(r1)

save "$path\UGA_example\data_in\UNHS2023_hh.dta", replace

/////////////////////////////// Census /////////////////////////////////////////
use "$path\UGA_example\data_in\census_raw\NPHC 2024-Users  File using cpro_extract_Household_data.dta", clear

recode HH_H1 (11 = 1) (12 = 2) (13 = 3) (14 = 4) (15 = 5) (16 = 6) (17 = 7) (. .a = .), gen(dwell_tenure)

recode HH_H2 (11 = 1) (12 = 2) (13 = 3) (14 = 4) (15 = 5) (16 = 6) ///
(17 = 10) (18=7) (19 = 8) (20 = 9) (21 22 96 = 11) (. .a = .), gen(dwell_type)


recode HH_H5 (11 = 1) (12 = 2) (13 = 3) (14 = 4) (15 = 5) (16 = 6) ( 17 18 96 = 7) (. .a = .), gen(roof)

recode HH_H6 (11 = 1) (12 = 2) (13 = 3) (14 = 4) (15 = 5) (16 = 6) ( 17 = 7) (18 19 = 8) (nonmiss = 9), gen(wall)

recode HH_H7 (11 = 4) (12 = 6) (13 = 7) (14 = 3) (15 = 2) (16 = 8) ( 17 = 5) (nonmiss = 8), gen(floor)

recode HH_H13 (8 9 . .a= .) (2=0), gen(nofood)

recode HH_H11 (8 9 . .a= .)(2=0), gen(skip_meal)

recode HH_H16 (0 = 11) (96 = 10) (. .a = .), gen(stove)

recode HH_H18 (96 = 13) (. .a = .), gen(light)

recode HH_H20 (1 = 2) (2 = 1) (4 = 5) (5 = 4)(. .a = .), gen(kitchen)

recode HH_H22 (10 = 1) (11 = 2)(12 = 14) (13 = 3) (14 = 4) (15 = 5) (16 = 6) (17 = 7) (18 = 8) (19 = 9) (20 = 10) (21 = 11) (22 = 12) (23 = 13) (. .a = .), gen(water_drink)

recode HH_H23 (2 3 4 = 1) (5 = 2), gen(water_dis)
replace water_dis = 1 if inlist(HH_H22,10,11,14,19,22)

recode HH_H24 (10 = 1) (11 = 2)(12 =3)(13 = 4)(14 = 5)(15 = 6)(16 = 7)(17 = 8), gen(toilet_type)

recode HH_H25 (2 = 0), gen(toilet_share)

gen hand_wash = HH_H26

replace HH_H27 = HH_H27 - 10
gen bathroom = HH_H27

recode HH_H18A (2 =0)(. .a = .), gen(solar_phone_charger)
recode HH_H18B (2 =0)(. .a = .), gen(solar_radio)
recode HH_H18C (2 =0)(. .a = .), gen(solar_tv)
recode HH_H18D (2 =0)(. .a = .), gen(solar_fan)
recode HH_H18E (2 =0)(. .a = .), gen(solar_refrig)
recode HH_H18F (2 =0)(. .a = .), gen(solar_iron)
recode HH_H18G (2 =0)(. .a = .), gen(solar_cook)

foreach v of var solar_*{
	replace `v' = 0 if !inlist(HH_H18,2,3)
}

recode HH_H28A (14 16 = 1) (15 = 2) (13 = 3) (12 = 4) (11 = 5) (18 17 96 = 6), gen(waste)

/*
1 "Collected/Supervised" ///
2 "Unsupervised dump/heap" ///
3 "Pit (burn/bury)" ///
4 "Burning (open air)" ///
5 "Garden/compost" ///
6 "Other/unspecified"*/

//asssets
* 1. Motor vehicle (any type)
gen asset_vehicle = HH_H31A

* 2. Motorcyc
gen asset_motorcycle = HH_H31B

* 3. Bicycle
gen asset_bicycle = HH_H31C

* 4. Television
gen asset_tv = HH_H31F

* 5. Radio
gen asset_radio = HH_H31G

* 6. Computer / Laptop
gen asset_computer = HH_H31I

* 7. Generator
gen asset_generator = HH_H31J

* 8. Solar panel / inverter
gen asset_solar = HH_H18 // adjust if categorical (e.g. == "Solar")

* 9. Refrigerator
gen asset_refrigerator = HH_H18E

* Label variables
label var asset_vehicle      "Owns motor vehicle (any type)"
label var asset_motorcycle   "Owns motorcycle"
label var asset_bicycle      "Owns bicycle"
label var asset_tv           "Owns television"
label var asset_radio        "Owns radio"
label var asset_computer     "Owns computer/laptop"
label var asset_generator    "Owns generator"
label var asset_solar        "Owns solar panel/inverter"
label var asset_refrigerator "Owns refrigerator"

recode HH_H36 (8 = .) (2=0), gen(cloth)

recode HH_H37 (7 8 = .)(2=0), gen(shoes)

keep HH_DISTRICT HH_SUBCOUNTY HH_COUNTYN HH_COUNTY HH_SUBCOUNTYN HH_PARISHN HH_SEGMENT HH_STRUCTURE HH_NUMBER HH_CASEUID dwell_tenure - shoes

//subcounty
tostring HH_SUBCOUNTY, gen(a)
replace a = "0" + a if length(a)<2
gen subcouty = string(HH_DISTRICT) + string(HH_COUNTY) + a

save "$path\UGA_example\data_in\NPHC2024_hh.dta", replace

////////////////////////////// summary compare /////////////////////////////////
use "$path\UGA_example\data_in\UNHS2023_hh.dta", clear

loc var dwell_tenure roof wall floor dwell_type stove light kitchen water_drink toilet_type hand_wash bathroom waste 
foreach v of loc var{
	tab `v', gen(`v')
}

collapse (mean) nofood skip_meal solar* water_dis toilet_share asset* cloth shoes dwell_tenure* roof* wall* floor* dwell_type* stove* light* kitchen* water_drink* toilet_type* hand_wash* bathroom* waste* [aw=mult]

ren * surv_mean*
gen a = 1
reshape long surv_mean, i(a) j(variable) s
drop a
tempfile data
save `data', replace



use "$path\UGA_example\data_in\NPHC2024_hh.dta",clear

loc var dwell_tenure roof wall floor dwell_type stove light kitchen water_drink toilet_type hand_wash bathroom waste 
foreach v of loc var{
	tab `v', gen(`v')
}

collapse (mean) nofood skip_meal solar* water_dis toilet_share asset* cloth shoes dwell_tenure* roof* wall* floor* dwell_type* stove* light* kitchen* water_drink* toilet_type* hand_wash* bathroom* waste* 

ren * census_mean*
gen a = 1
reshape long census_mean, i(a) j(variable) s
drop a
merge 1:1 variable using `data', nogen

gen diff = (census_mean/surv_mean) - 1
s
drop if strpos( variable, "waste")
drop if strpos( variable, "solar_")

sum diff
export excel using "$path\UGA_example\results\summary_statistics.xlsx", sheet("mean_compare") sheetreplace firstrow(variables)


