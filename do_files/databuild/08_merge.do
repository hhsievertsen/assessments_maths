/*  Project: grading bias 
    File:  08_merge.do - Merge all data
	Last edit: 2022-02-19 by hhs
*/
// load globals etc
do "D:\Data\workdata\704998\xdrev\704998\GradingBias\do_files\settings.do"
// load overall gpa data
use  "$tf\gpa_overall.dta",clear
rename instnr g_instnr
// merge time invariant characteristics on
merge m:1 pnr using "$tf\childdata.dta",nogen keep(1 3)
// merge with parent data
gen holder=pnr
foreach l in `l' father mother {
	replace pnr=c_`l'_id
	merge m:1 pnr g_graduation_cohort using "$tf\parental_covars.dta", keep(1 3) nogen
	rename p_edu_y p_edu_y_`l'
	rename p_edu_d p_edu_d_`l'
	rename p_inc p_inc_`l'
	label var p_edu_y_`l' "Parental education (years) [`l']"
	label var p_edu_d_`l' "Parental education (degree) [`l']"
	label var p_inc_`l'  "Parental income (1000 EUR, 2015 level) [`l']"
}
replace pnr=holder
drop holder
* adjust levels edu
gen c_par_ud=inlist(p_edu_d_mother,65,70)
replace c_par_ud= 1 if inlist(p_edu_d_father,65,70)
gen c_par_eo=0
replace c_par_eo=1 if p_edu_d_father!=.
replace c_par_eo=c_par_eo+1  if p_edu_d_mother!=.
rename p_edu_d_father c_edu_d_father
rename p_edu_d_mother c_edu_d_mother
* adjust  income levels
gen i=0
replace i=i+p_inc_father if p_inc_father!=.
replace i=i+p_inc_mother if p_inc_mother!=.
gen c_par_io=0
replace c_par_io=1 if p_inc_father!=.
replace c_par_io=c_par_io+1  if p_inc_mother!=.
replace i=i/c_par_io
rename i c_par_inc
drop p_* 
// merge 9th grade GPA on
merge m:1 pnr using "$tf\gpa9data.dta",nogen keep(1 3)
// merge cont education on
forval i=0/10{
// enroll
	gen o_year_enr=g_graduation_cohort +`i'
	merge m:1 pnr o_year_enr using  "$tf\contedudata_enr.dta", nogen keep(1 3) keepusing(o_enr_field* o_cont_degreetype_enr o_cont_udd_enr)
	gen o_enrolled_he_y`i'=inlist( o_cont_degreetype_enr,60,65,50,40)
	rename o_cont_degreetype_enr o_cont_degreetype_enr_y`i'
	drop o_cont_degreetype_enr o_year_enr o_enr_field_hum o_enr_field_nat o_enr_field_tech o_enr_field_soc o_enr_field_health
	rename o_cont_udd_enr o_cont_udd_enr`i'
	// graduate
	gen o_year_grad=g_graduation_cohort +`i'
	merge m:1 pnr o_year_grad using  "$tf\contedudata_grad.dta", nogen keep(1 3) keepusing(o_grad_fiel* o_cont_degreetype_grad o_cont_audd_grad)
	gen o_graduated_he_y`i'=inlist( o_cont_degreetype_grad,60,65,50,40)
	drop o_grad_field_health o_grad_field_soc o_grad_field_hum o_grad_field_nat o_grad_field_tech
	rename o_cont_degreetype_grad o_cont_degreetype_grad_y`i' 
	rename o_cont_audd_grad o_cont_audd_grad`i'
	drop  o_year_grad
}
forval i=1/10{
	forval j=0/`i'{
		replace o_enrolled_he_y`i'=1 if o_enrolled_he_y`j'==1
		replace o_graduated_he_y`i'=1  if o_graduated_he_y`j'==1
		}
}
// merge fixed effects on
merge 1:1 pnr g_graduation_cohort using "$tf\fe_raw_sub.dta ",nogen keep(3)
// merge exam results on
merge 1:1 pnr g_graduation_cohort using "$tf\grading_data_detailed_collapsed.dta ",nogen keep(3)
* clean
keep pnr  c_* g_* o_* hs_*	
order pnr c_* g_* o_* hs_*
compress
* save
save "$tf\tf8.dta",replace
	
