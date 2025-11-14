
/*===============================================================================
unit-model (SAE training)
	- Real world data application
	- author Haoyu Wu (hw4@worldbank.org) 
*==============================================================================*/

global main	  "C:\Users\wb545671\OneDrive - WBG\AFE_work\Mission\5.UGA_Nov2025\UGA_training\MEX_example"
global mdata  "$main\input"
global log    "$main\log"
global survey "$mdata\survey_public.dta"
global census "$mdata\census_public.dta"
global temp   "$main\temp"

*log close _all
*log using "$log\Simulation", replace

version 15
local seed 648743

*===============================================================================
// End of preamble
*===============================================================================
use "$mdata\mysvy.dta", clear
char list

global hhmodel : char _dta[rhs]
global alpha   : char _dta[alpha]
global sel     : char _dta[sel]

//Add lnhhsize
use "$census"
gen lnhhsize = ln(hhsize)

tempfile census1
save `census1'

// Create data ready for SAE - optimized dataset
sae data import, datain(`census1') varlist($hhmodel $alpha hhsize) ///
area(HID_mun) uniqid(hhid) dataout("$mdata\census_mata")

*===============================================================================
// Simulation -> Obtain point estimates
*===============================================================================	
use "$mdata\mysvy.dta", clear
	drop if e_y<1
	drop if $sel==1
	rename MUN HID_mun
sae sim h3 e_y $hhmodel [aw=Whh], area(HID_mun) zvar($alpha) mcrep(100) bsrep(0) ///
lnskew matin("$mdata\census_mata") seed(`seed') pwcensus(hhsize) ///
indicators(fgt0 fgt1 fgt2) aggids(0) uniqid(hhid) plines(715)

save "$temp\mySAE_point.dta", replace 

/*===============================================================================
// Simulation -> Obtain MSE estimates
*===============================================================================	

use "$mdata\mysvy.dta", clear
	drop if e_y<1
	drop if $sel==1
	rename MUN HID_mun
sae sim h3 e_y $hhmodel, area(HID_mun) zvar($alpha) mcrep(100) bsrep(200) ///
lnskew matin("$mdata\census_mata") seed(`seed') pwcensus(hhsize) ///
indicators(fgt0 fgt1 fgt2) aggids(0 4) uniqid(hhid) plines(715)

save "$temp\mySAE.dta", replace 
*/
