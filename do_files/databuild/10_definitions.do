/*  Project: grading bias 
    File:  10_definitions
	Last edit: 2022-02-19 by hhs
*/
// load globals etc
do "D:\Data\workdata\704998\xdrev\704998\GradingBias\do_files\settings.do"
// maths degrees
use "$tf\tf9.dta",clear
keep  o_cont_audd_grad* hs_s_mat1  g_mark_ex_wr_math
// find first degrees
gen firstdegree=.
forval i=1/10{
	replace firstdegree=o_cont_audd_grad`i' if firstdegree==.
}
// collapse maths characteristics of degree
collapse (mean) hs_s_mat1  g_mark_ex_wr_math (count) n=hs_s_mat1,by( firstdegree) fast
sum g_mark,d
gen s_math_high=g_mark>r(p90) & g_mark!=.
gen s_math_req=hs_s_mat1==1 
rename first audd
// save
keep audd s_math_high s_math_req
compress
drop if audd==.
save "$tf\mathdegrees.dta",replace 
// Load the data
use "$tf\tf9.dta",clear
// Merge the math degrees on
forval i=1/10{
	/* Graduate */
	cap drop audd
	gen audd = o_cont_audd_grad`i'
	merge m:1 audd using "$tf\mathdegrees.dta", keep(1 3)nogen 
	rename s_math_req o_s_gr_math_req_`i'
	rename s_math_high o_s_gr_math_high_`i'
	drop audd
	
}
// Create parental vars
replace c_edu_d_mother=0 if c_edu_d_mother==.
replace c_edu_d_father=0 if c_edu_d_father==.
tab c_edu_d_father,gen(c_father_edu_g)
tab c_edu_d_mother,gen(c_mother_edu_g)
tab c_par_eo,gen(c_parental_edu_obs_g)
tab c_par_io,gen(c_parental_inc_obs_g)
gen i=c_par_inc if c_par_io!=0
bys g_graduation_cohort: egen c_par_iq=xtile(i), nq(10)
replace c_par_iq=1 if c_par_io==0
drop i
tab c_par_iq,gen(c_par_inc_g)
// Math heavy degrees in year 10
gen o_s_math_req_10=0
gen o_s_math_high_10=0
forval i=1/10{
	/* Graduate */
	replace o_s_math_req_10=1 if o_s_gr_math_req_`i'==1
	replace o_s_math_high_10=1 if o_s_gr_math_high_`i'==1
}
// Treatment
gen hs_e_mat_A=hs_e_mat1
gen hs_s_mat_A=hs_s_mat1
label var hs_e_mat_A "A-level math exam"
// Interaction terms
gen hs_e_mat_AXf=hs_e_mat_A*c_female
label var hs_e_mat_AXf "A-level math exam $\times$ female"
// Hetero
egen c_gpagroup=xtile(g_mark_ta_or),nq(4)
gen c_lowgpa=c_gpagroup==1
// Program fe
egen hs_program_fe=group(g_hs_program )
// cleaning
keep pnr c_* g_* hs_* o_*
order pnr  c_* g_* hs_* o_*
save "$tf\tf10.dta",replace

