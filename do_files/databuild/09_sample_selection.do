/*  Project: grading bias 
    File:  09_sample_selection
	Last edit: 2022-02-19 by hhs
*/
// load globals etc
do "D:\Data\workdata\704998\xdrev\704998\GradingBias\do_files\settings.do"
// Load the data
use "$tf\tf8.dta",clear
// drop gender missing (19 obs)
drop if c_female==.
// drop no variation within fixed effects (545 obs)
preserve
	keep if hs_s_mat1==1
	egen hs_program_fe=group(g_hs_program g_udd)
	keep pnr  g_graduation_cohort hs_program_fe  g_instnr
	bys  g_graduation_cohort : gen a=_N
	bys  hs_program_fe : gen b=_N
	bys  g_instnr : gen c=_N
	gen novariation=a==1|b==1|c==1
	keep pnr g_graduation_cohort novariation
	save "$tf\ss.dta",replace
restore
merge 1:1 pnr g_graduation_cohort using  "$tf\ss.dta",nogen
drop if novariation==1
// cleaning
order pnr c_*  g_* hs_* o*
keep  pnr  c_*     g_* hs_* o*
compress
save "$tf\tf9.dta",replace
