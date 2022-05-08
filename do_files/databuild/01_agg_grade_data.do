/*  Project: grading bias 
    File:  1_agg_grade_data.do - clean overall HS GPA data
	Last edit: 2022-02-19 by hhs
*/
// load settings
do "D:\Data\workdata\704998\xdrev\704998\GradingBias\do_files\settings.do"
// load data
u "$rf\udg2019.dta",clear
// rename variables
rename KARAKTER_UDD g_gpa_actual
// adjust GPA to regular scale
replace g_gpa_actual=g_gpa_actual/10
// extract graduation year
gen g_graduation_cohort=year(KARAKTER_UDD_VTIL)
// select cohorts
keep if g_graduation_cohort>2002& g_graduation_cohort<2008
// select high school degrees
keep if inlist(audd, 1199,5090,5080, 1539,1145,1146)
// keep only first observation per individual
sort pnr  g_graduation_cohort KARAKTER_UDD_VTIL
by pnr g_graduation_cohort (KARAKTER_UDD_VTIL): keep if _n==1
// select variables to keep
keep pnr g_graduation_cohort  g_gpa_actual audd instnr
// save data
compress
save "$tf\gpa_overall.dta",replace




