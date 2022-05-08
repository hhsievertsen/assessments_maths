/*  Project: grading bias 
    File:  5_sensitivity_graduation
	Last edit: 2022-02-19 by Hans. 
*/
// load globals etc
do "D:\Data\workdata\704998\xdrev\704998\GradingBias\do_files\settings.do"



// Empty dataset
clear
gen beta=.	
gen ll=.
gen ul=.	
gen controls=.
gen probit=.	
gen gpa9=.
gen fe=.
gen exw=.
gen recorded=.
gen depvar=" "
save "$tf\estimates_sensitivity.dta",replace

cap program drop mystore
program mystore
	syntax, gpa9(string) exw(string) controls(string) fe(string) adepvar(string)
	// marginal effects 
	mat results=r(table)
	preserve
		use "$tf\estimates_sensitivity.dta",clear
		qui: local obs=_N +1
		set obs `obs'
		qui: replace beta=results[1,1]		if recorded==.
		qui: replace ll=results[5,1]		if recorded==.
		qui: replace ul=results[6,1]		if recorded==.
		qui: replace controls=`controls'		if recorded==.
		qui: replace probit=0		if recorded==.
		qui: replace gpa9=`gpa9'		if recorded==.
		qui: replace fe=`fe'		if recorded==.
		qui: replace exw=`exw' 		if recorded==.
			qui: replace depvar="`adepvar'"	if recorded==.
		qui: replace recorded=1
		di "OLS, FE:`fe' Controls:`controls' GPA9:`gpa9' Ex written:`exw' completed"
		qui: save "$tf\estimates_sensitivity.dta",replace
	restore
end

// Program to store results
cap program drop mystoreprobit
program mystoreprobit
	syntax, gpa9(string) exw(string) controls(string) fe(string) adepvar(string)
	// marginal effects 
	qui: margins  ,dydx( hs_e_mat_AXf)
	mat results=r(table)
	preserve
		use "$tf\estimates_sensitivity.dta",clear
		local obs=_N +1
			set obs `obs'
		qui: replace beta=results[1,1]		if recorded==.
		qui: replace ll=results[5,1]		if recorded==.
		qui: replace ul=results[6,1]		if recorded==.
		qui: replace controls=`controls'		if recorded==.
		qui: replace probit=1		if recorded==.
		qui: replace gpa9=`gpa9'		if recorded==.
		qui: replace fe=`fe'		if recorded==.
		qui: replace exw=`exw' 		if recorded==.
		qui: replace depvar="`adepvar'"	if recorded==.
		qui: replace recorded=1
		di "probit, FE:`fe' Controls:`controls' GPA9:`gpa9' Ex written:`exw' completed"
		qui: save "$tf\estimates_sensitivity.dta",replace
	restore
end


foreach depvar in g_gpa_actual o_s_math_high_10  o_enrolled_he_y10 o_graduated_he_y10 o_s_math_req_10 {
	
// Load data
use "$tf\analysisdata.dta",clear  




gen c_gpa9m=c_gpa9==.
replace c_gpa9=0 if c_gpa9==.
// With FE
	// Main	
	qui: reghdfe   	`depvar' hs_e_mat_AXf $vars c_female hs_e_mat_A       	if hs_s_mat_A==1, absorb( hs_program_fe g_udd g_graduation_cohort g_instnr  ) cluster( hs_program_fe)		
	mystore,controls(1) gpa9(0) exw(0)  fe(1) adepvar("`depvar'")
	// + 9th gpa
	qui: reghdfe   	`depvar' hs_e_mat_AXf $vars c_gpa9 c_gpa9m   c_female hs_e_mat_A       	if hs_s_mat_A==1, absorb( hs_program_fe g_udd g_graduation_cohort g_instnr  ) cluster( hs_program_fe)		
	mystore,controls(1) gpa9(1) exw(0)  fe(1) adepvar("`depvar'")
	// + 9th gpa + Ex written
	qui: reghdfe   	`depvar' hs_e_mat_AXf $vars c_gpa9 c_gpa9m  g_mark_ta_wr  c_female hs_e_mat_A       	if hs_s_mat_A==1, absorb( hs_program_fe g_udd g_graduation_cohort g_instnr  ) cluster( hs_program_fe)		
	mystore,controls(1) gpa9(1) exw(1)  fe(1) adepvar("`depvar'")
	// +  TA written
	qui: reghdfe   	`depvar' hs_e_mat_AXf $vars g_mark_ta_wr  c_female hs_e_mat_A       	if hs_s_mat_A==1, absorb( hs_program_fe g_udd g_graduation_cohort g_instnr  ) cluster( hs_program_fe)		
	mystore,controls(1) gpa9(0) exw(1)  fe(1) adepvar("`depvar'")
	// No controls
	qui: reghdfe   	`depvar'  hs_e_mat_AXf c_female hs_e_mat_A       	if hs_s_mat_A==1, absorb( hs_program_fe g_udd g_graduation_cohort g_instnr  ) cluster( hs_program_fe)		
	mystore,controls(0) gpa9(0) exw(0)  fe(1) adepvar("`depvar'")
	// + 9th gpa
	qui: reghdfe   	`depvar'  hs_e_mat_AXf c_gpa9 c_gpa9m   c_female hs_e_mat_A       	if hs_s_mat_A==1, absorb( hs_program_fe g_udd g_graduation_cohort g_instnr  ) cluster( hs_program_fe)		
	mystore,controls(0) gpa9(1) exw(0)  fe(1) adepvar("`depvar'")
	// + 9th gpa + Ex written
	qui: reghdfe   	`depvar'  hs_e_mat_AXf c_gpa9 c_gpa9m  g_mark_ta_wr  c_female hs_e_mat_A       	if hs_s_mat_A==1, absorb( hs_program_fe g_udd g_graduation_cohort g_instnr  ) cluster( hs_program_fe)		
	mystore,controls(0) gpa9(1) exw(1)  fe(1) adepvar("`depvar'")
	// +  TA written
	qui: reghdfe   	`depvar'  hs_e_mat_AXf g_mark_ta_wr  c_female hs_e_mat_A       	if hs_s_mat_A==1, absorb( hs_program_fe g_udd g_graduation_cohort g_instnr  ) cluster( hs_program_fe)		
	mystore,controls(0) gpa9(0) exw(1)  fe(1) adepvar("`depvar'")
// Without FE
	// Main	
	qui: reg   	`depvar' hs_e_mat_AXf $vars c_female hs_e_mat_A       	if hs_s_mat_A==1, cluster( hs_program_fe)		
	mystore,controls(1) gpa9(0) exw(0)  fe(0) adepvar("`depvar'")
	// + 9th gpa
	qui: reg   	`depvar' hs_e_mat_AXf $vars c_gpa9 c_gpa9m   c_female hs_e_mat_A       	if hs_s_mat_A==1, cluster( hs_program_fe)		
	mystore,controls(1) gpa9(1) exw(0)  fe(0) adepvar("`depvar'")
	// + 9th gpa + Ex written
	qui: reg   	`depvar' hs_e_mat_AXf $vars c_gpa9 c_gpa9m  g_mark_ta_wr  c_female hs_e_mat_A       	if hs_s_mat_A==1, cluster( hs_program_fe)		
	mystore,controls(1) gpa9(1) exw(1)  fe(0) adepvar("`depvar'")
	// +  TA written
	qui: reg   	`depvar' hs_e_mat_AXf $vars g_mark_ta_wr  c_female hs_e_mat_A       	if hs_s_mat_A==1,  cluster( hs_program_fe)		
	mystore,controls(1) gpa9(0) exw(1)  fe(0) adepvar("`depvar'")
	
	// No controls
	qui: reg   	`depvar' hs_e_mat_AXf  c_female hs_e_mat_A       	if hs_s_mat_A==1, cluster( hs_program_fe)		
	mystore,controls(0) gpa9(0) exw(0)  fe(0) adepvar("`depvar'")
	// + 9th gpa
	qui: reg   	`depvar' hs_e_mat_AXf  c_gpa9 c_gpa9m   c_female hs_e_mat_A       	if hs_s_mat_A==1, cluster( hs_program_fe)		
	mystore,controls(0) gpa9(1) exw(0)  fe(0) adepvar("`depvar'")
	// + 9th gpa + Ex written
	qui: reg   	`depvar' hs_e_mat_AXf  c_gpa9 c_gpa9m  g_mark_ta_wr  c_female hs_e_mat_A       	if hs_s_mat_A==1, cluster( hs_program_fe)		
	mystore,controls(0) gpa9(1) exw(1)  fe(0) adepvar("`depvar'")
	// +  TA written
	qui: reg   	`depvar' hs_e_mat_AXf  g_mark_ta_wr  c_female hs_e_mat_A       	if hs_s_mat_A==1,  cluster( hs_program_fe)		
	mystore,controls(0) gpa9(0) exw(1)  fe(0) adepvar("`depvar'")
// probit
gl FE="i.hs_program_fe i. g_graduation_cohort i.g_instnr"
*** probit
if "`depvar'"!="g_gpa_actual" {


// remove if no variation in FE
cap drop ignored
cap drop sd 
cap drop sd1
bys hs_program_fe: egen sd=sd(`depvar')
bys g_instnr: egen sd1=sd(`depvar')
gen ignored=sd==0
replace ignored=1 if sd1==0
// With FE
	// Main	
	qui: probit   `depvar'  $FE  $vars c_female hs_e_mat_A     hs_e_mat_AXf  	if hs_s_mat_A==1 & ignored==0, cluster( hs_program_fe)		
	mystoreprobit,controls(1) gpa9(0) exw(0)  fe(1) adepvar("`depvar'")
	// + 9th gpa
	qui: probit   	`depvar' $FE  $vars c_gpa9 c_gpa9m   c_female hs_e_mat_A     hs_e_mat_AXf  	if hs_s_mat_A==1 & ignored==0, cluster( hs_program_fe)		
	mystoreprobit,controls(1) gpa9(1) exw(0)  fe(1) adepvar("`depvar'")
	// + 9th gpa + Ex written
	qui: probit   	`depvar' $FE  $vars c_gpa9 c_gpa9m  g_mark_ta_wr  c_female hs_e_mat_A     hs_e_mat_AXf  	if hs_s_mat_A==1 & ignored==0, cluster( hs_program_fe)		
	mystoreprobit,controls(1) gpa9(1) exw(1)  fe(1) adepvar("`depvar'")
	// +  Ex written
	qui: probit   	`depvar' $FE  $vars g_mark_ta_wr  c_female hs_e_mat_A     hs_e_mat_AXf  	if hs_s_mat_A==1 & ignored==0, cluster( hs_program_fe)		
	mystoreprobit,controls(1) gpa9(0) exw(1)  fe(1) adepvar("`depvar'")
	// No controls
	qui: probit   	`depvar' $FE  c_female hs_e_mat_A     hs_e_mat_AXf  	if hs_s_mat_A==1 & ignored==0, cluster( hs_program_fe)		
	mystoreprobit,controls(0) gpa9(0) exw(0)  fe(1) adepvar("`depvar'")
	// + 9th gpa
	qui: probit   	`depvar' $FE  c_gpa9 c_gpa9m   c_female hs_e_mat_A     hs_e_mat_AXf  	if hs_s_mat_A==1 & ignored==0, cluster( hs_program_fe)		
	mystoreprobit,controls(0) gpa9(1) exw(0)  fe(1) adepvar("`depvar'")
	// + 9th gpa + Ex written
	qui: probit   	`depvar' $FE   c_gpa9 c_gpa9m  g_mark_ta_wr  c_female hs_e_mat_A     hs_e_mat_AXf  	if hs_s_mat_A==1 & ignored==0, cluster( hs_program_fe)		
	mystoreprobit,controls(0) gpa9(1) exw(1)  fe(1) adepvar("`depvar'")
	// +  Ex written
	qui: probit   	`depvar' $FE   g_mark_ta_wr  c_female hs_e_mat_A     hs_e_mat_AXf  	if hs_s_mat_A==1 & ignored==0, cluster( hs_program_fe)		
	mystoreprobit,controls(0) gpa9(2) exw(1)  fe(1) adepvar("`depvar'")
// Without FE
	// Main	
	qui: probit   	`depvar'   $vars c_female hs_e_mat_A     hs_e_mat_AXf  	if hs_s_mat_A==1 , cluster( hs_program_fe)		
	mystoreprobit,controls(1) gpa9(0) exw(0)  fe(0) adepvar("`depvar'")
	// + 9th gpa
	qui: probit   	`depvar'   $vars c_gpa9 c_gpa9m   c_female hs_e_mat_A     hs_e_mat_AXf  	if hs_s_mat_A==1, cluster( hs_program_fe)		
	mystoreprobit,controls(1) gpa9(1) exw(0)  fe(0) adepvar("`depvar'")
	// + 9th gpa + Ex written
	qui: probit   	`depvar'   $vars c_gpa9 c_gpa9m  g_mark_ta_wr  c_female hs_e_mat_A     hs_e_mat_AXf  	if hs_s_mat_A==1, cluster( hs_program_fe)		
	mystoreprobit,controls(1) gpa9(1) exw(1)  fe(0) adepvar("`depvar'")
	// +  TA written
	qui: probit   	`depvar'   $vars g_mark_ta_wr  c_female hs_e_mat_A     hs_e_mat_AXf  	if hs_s_mat_A==1, cluster( hs_program_fe)		
	mystoreprobit,controls(1) gpa9(0) exw(1)  fe(0) adepvar("`depvar'")
	// No controls
	qui: probit   	`depvar'   c_female hs_e_mat_A     hs_e_mat_AXf  	if hs_s_mat_A==1, cluster( hs_program_fe)		
	mystoreprobit,controls(0) gpa9(0) exw(0)  fe(0) adepvar("`depvar'")
	// + 9th gpa
	qui: probit   	`depvar'   c_gpa9 c_gpa9m   c_female hs_e_mat_A     hs_e_mat_AXf  	if hs_s_mat_A==1, cluster( hs_program_fe)		
	mystoreprobit,controls(0) gpa9(1) exw(0)  fe(0) adepvar("`depvar'")
	// + 9th gpa + Ex written
	qui: probit   	`depvar'    c_gpa9 c_gpa9m  g_mark_ta_wr  c_female hs_e_mat_A     hs_e_mat_AXf  	if hs_s_mat_A==1, cluster( hs_program_fe)		
	mystoreprobit,controls(0) gpa9(1) exw(1)  fe(0) adepvar("`depvar'")
	// +  Ex written
	qui: probit   	`depvar'    g_mark_ta_wr  c_female hs_e_mat_A     hs_e_mat_AXf  	if hs_s_mat_A==1, cluster( hs_program_fe)		
	mystoreprobit,controls(0) gpa9(2) exw(1)  fe(0) adepvar("`depvar'")
}
	
}
