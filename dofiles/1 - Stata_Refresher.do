
/*===============================================================================
 Stata Refresh
 author: hwu4@worldbank.org
*=============================================================================*/
global path "C:\Users\wb545671\OneDrive - WBG\AFE_work\Mission\5.UGA_Nov2025\UGA_training"
global  out  "$path\05.output\Day1"

sysuse auto, clear //stata buildin data auto

***  Local vs Global 

// The command local tells Stata to keep everything in the command line in memory only until the program or do-file ends.

local  varlist "mpg rep78 headroom trunk weight length"

dis  "`varlist'"
macro list

//  The command global tells Stata to store everything in the command line in its memory until you exit Stata. The global macro will still be in memory even if you open another data set before exiting.

global  varlist  "mpg rep78 headroom trunk weight length"
dis   "$varlist"
 
***  A global variable can be constructed from a local variable 

local  lvarlist  "mpg rep78 headroom trunk weight length"
global gvarlist  "`lvarlist'"
dis   "$gvarlist"   


***   Two local variables can be combined

local   lvars1  "mpg rep78"
local   lvars2  "headroom trunk weight length "
local   lvars3  " `lvars1'  `lvars2'"
dis   "`lvars3'"



***   Two global variables  can be combined 

global lvars1  "mpg rep78"
global lvars2  "headroom trunk weight length "
global lvars3  $lvars1   $lvars2
dis  "$lvars3" 


****  A local variable can be appended 

local   lvars1  "headroom trunk weight length "
local   lvars2  "`lvars1' mpg  "
dis     "`lvars2'"



****  A global variable can be appened

global   lvars1  "headroom trunk weight length "
global   lvars2  $lvars1 mpg  
dis     "$lvars2"


****   Elements contained in a local variable can be removed if they are present in another list 

local   lvars1  "rep78"
local   lvars2  "mpg rep78 headroom trunk weight length"
local   lvars3 :  list    lvars2 -  lvars1 
dis   "`lvars3'"



****  Creates a local list from unique elements contained in variables

tab  make
levelsof make, local(varlist_make) clean 
*dis  "`varlist_make'"
foreach x of local varlist_make{
	di "`x'"
}
 
***    Using a local/global  as a list 

local  varlist "mpg rep78 headroom trunk weight length"
reg  price  `varlist'


global  varlist  "mpg rep78 headroom trunk weight length"
reg  price  $varlist



***  Create log shift transformation to approximate normality ;  zero-skewness log 

gen  lny=ln(mpg)
lnskew0 double bcy = mpg
	
sum lny, d
sum bcy, d	

tw kdensity lny || kdensity bcy, graphregion(style(none) color(gs16)) ///
ylab(, angle(0) nogrid) ytitle("kdensity")  , legend(label(1 "mpg, ln") label(2 "mpg, ln shift transformation"))

tw (kdensity lny) (kdensity bcy), normal

kdensity bcy ,normal
kdensity lny ,normal

graph export  "$out\logShift_transformation.png", replace



***  Loops/Foreach :  Using elements of  local  variable   

local varlist  "mpg rep78 headroom trunk weight length"

foreach x of local varlist {
	sum  `x'
	gen     nor_`x'= (`x'-r(mean))/r(sd)
}
summ nor*
drop nor* 


***  Loops/Foreach :  Using elements of global  variable   

global varlist  "mpg rep78 headroom trunk weight length"

foreach x of global varlist {
	sum  `x'
	gen     nor_`x'= (`x'-r(mean))/r(sd)
}
summ nor*
drop nor* 



***   Loop/Forvalues 
set seed 1234
forvalues i = 1(1)5 {
	generate x`i' = runiform()
}


* Removal of non-significant vars  
* We iterate over different significance levels (e.g., 0.9, 0.8, …, 0.1).
* For each variable, we test its significance using test.
* If the p-value is greater than the threshold, we remove that variable from the hhvars list.
* Finally, we store the remaining significant variables in the global macro postsign.



local  hhvars  "rep78 headroom trunk price"

reg mpg `hhvars' , r 
  
forvalues  z= 0.9(-0.1)0.1{
	foreach x of varlist `hhvars'{
		local hhvars1
		qui: reg mpg `hhvars' , r 
		qui: test `x'

		if (r(p)>`z'){
			local hhvars1
			foreach yy of local hhvars{
				if ("`yy'"=="`x'") dis ""
				else local hhvars1 `hhvars1' `yy'
			}
		}
		else local hhvars1 `hhvars'
		local hhvars `hhvars1'
	}
}
global postsign `hhvars'


dis "$postsign"

reg mpg $postsign , r 



** Lasso Technique 
** LASSO stands for Least Absolute Shrinkage and Selection Operator.
**  It's a technique used in statistical modeling and machine learning.
** The main goal of LASSO is to find a balance between simplicity and accuracy in our models.
** LASSO adds a penalty term based on the absolute values of the coefficients.
** LASSO encourages sparsity (fewer non-zero coefficients) in the model.
** Why is this useful? It helps with variable selection by automatically identifying and discarding irrelevant or redundant variables.
**  LASSO helps us find a good balance between having enough features for accurate predictions and keeping the model simple.
set seed  1234

reg   mpg i.foreign i.rep78 headroom weight turn gear_ratio
lasso linear mpg i.foreign i.rep78 headroom weight turn gear_ratio

lassoknots

lassocoef, display(coef, postselection)

	
global beforelasso  "`e(allvars)'"
global postlasso "`e(allvars_sel)'"	


dis  "Before lasso:  $beforelasso"

dis  "Post lasso:   $postlasso"
	