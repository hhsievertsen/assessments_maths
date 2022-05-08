/*  Project: grading bias 
    File:  3_parent_data.do - parent data
	Last edit: 2022-02-19 by hhs
*/
* load settings
do "D:\Data\workdata\704998\xdrev\704998\GradingBias\do_files\settings.do"
// loop over grund data and save income and date of birth
forval i=2003/2008{
		use "$rf\grundvive`i'.dta", clear
		keep pnr DISPON_13  
		gen int t=`i'
		save "$tf\gr`i'.dta",replace
}
// Append to one dataset
clear
forval i=2003/2008{
		append using "$tf\gr`i'.dta"
}
// price adjustment to 2015 level using CPI (1000 EURO)
rename DISPON_13 p_inc
replace p_inc=p_inc*(100/72.8)*.13*0.001 if t==1999
replace p_inc=p_inc*(100/75.1)*.13*0.001 if t==2000
replace p_inc=p_inc*(100/76.9)*.13*0.001 if t==2001
replace p_inc=p_inc*(100/78.8)*.13*0.001 if t==2002
replace p_inc=p_inc*(100/80.6)*.13*0.001 if t==2003
replace p_inc=p_inc*(100/81.7)*.13*0.001 if t==2004
replace p_inc=p_inc*(100/83.3)*.13*0.001 if t==2005
replace p_inc=p_inc*(100/85.0)*.13*0.001 if t==2006
replace p_inc=p_inc*(100/86.7)*.13*0.001 if t==2007
replace p_inc=p_inc*(100/89.9)*.13*0.001 if t==2008

// rename and save 
compress
bys pnr t: keep if _n==1 /* remove duplicates*/
save "$tf\parental_income.dta",replace
// load education register
use "$rf\KOTRE2019.dta", clear
// only consider completed degrees
drop if audd==9999 | audd==0
// merge with formats
tostring audd, replace
merge m:1 audd using "$ff\uddan_2014_audd_ext.dta", keep(1 3) nogen keepusing(pria h1)
destring h1,replace
// loop over years
forval i=2003/2008{
	preserve
		drop if year(ELEV3_VTIL)>`i'
		collapse (max) pria h1, by(pnr) fast
		replace pria=pria/12
		gen t=`i'
		compress
		save "$tf\parschooling`i'.dta", replace
	restore
}
// append
clear
forval i=2003/2008{
	append using "$tf\parschooling`i'.dta"
}
save "$tf\parental_schooling.dta",replace
// merge education and income
use "$tf\parental_schooling.dta",clear
merge 1:1 pnr t using "$tf\parental_income.dta", nogen
// renaming 
rename pria  p_edu_y
rename h1 p_edu_d
rename t g_graduation_cohort
// labels 
label var p_edu_y "Parental education (years)"
label var p_edu_d "Parental education (degree)"
label var p_inc "Parental income (1000 EUR, 2015 level)"
// drop and compress
compress
save "$tf\parental_covars.dta",replace
