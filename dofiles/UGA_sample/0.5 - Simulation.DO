
/*===============================================================================
unit-model (SAE training)
	- Real world data application
	- author Haoyu Wu (hw4@worldbank.org) 
*==============================================================================*/

	global main "C:\Users\wb545671\OneDrive - WBG\AFE_work\Mission\5.UGA_Nov2025\UGA_training\UGA_example"
	global mdata  "$main\data_in"
	global log    "$main\results"
	global survey "$mdata\UNHS2023_hh.dta"
	global census "$mdata\NPHC2024_hh.dta"
	global temp   "$main\temp"

	log close _all
	log using "$log\Simulation", replace

	version 15
	global seed 648743

*===============================================================================
// End of preamble
*===============================================================================
	use "$temp\mysvy.dta", clear
	char list

	global hhmodel : char _dta[rhs]
	global alpha   : char _dta[alpha]
	global sel     : char _dta[sel]

	//Add lnhhsize
	use "$census", clear
	*gen lnhhsize = ln(hhsize)
	egen hhid = group(HH_DISTRICT HH_COUNTY HH_SUBCOUNTY HH_SEGMENT HH_STRUCTURE HH_NUMBER HH_CASEUID)
	destring subcouty, replace

	loc var dwell_tenure roof wall floor dwell_type stove light kitchen water_drink toilet_type hand_wash bathroom waste water_dis
	foreach v of loc var{
		tab `v', gen(`v')
		drop `v'
	}
	gen hhsize = 1

	tempfile census1
	save `census1'

	// Create data ready for SAE - optimized dataset
	sae data import, datain(`census1') varlist($hhmodel $alpha hhsize) ///
	area(subcouty) uniqid(hhid) dataout("$mdata\census_mata")

*===============================================================================
// Simulation -> Obtain point estimates
*===============================================================================	
	use "$temp\mysvy.dta", clear
	replace hhid = substr(hhid,2,.)
	destring hhid, replace

	sae sim h3 welfare $hhmodel [aw=rmult], area(subcouty) zvar($alpha) mcrep(100) bsrep(0) ///
	lnskew matin("$mdata\census_mata") lnskew_w seed($seed) pwcensus(hhsize) ///
	indicators(fgt0) aggids(0) uniqid(hhid) plines(11.361597)

	save "$temp\mySAE_point.dta", replace 

/*==============================================================================
// Simulation -> Obtain MSE estimates
*===============================================================================	

	use "$mdata\mysvy.dta", clear
	replace hhid = substr(hhid,2,.)
	destring hhid, replace

	sae sim h3 welfare $hhmodel [aw=rmult], area(subcouty) zvar($alpha) mcrep(100) bsrep(200) ///
	lnskew matin("$mdata\census_mata") lnskew_w seed($seed) pwcensus(hhsize) ///
	indicators(fgt0) aggids(0) uniqid(hhid) plines(11.361597)

	save "$temp\mySAE.dta", replace 
	*/
