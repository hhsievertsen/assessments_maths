/*  Project: grading bias 
    File:  7_cont_education.do
	Last edit: 2022-02-19 by hhs
*/
// load settings
do "D:\Data\workdata\704998\xdrev\704998\GradingBias\do_files\settings.do"
// enrollment - load education registry
use "$rf\KOTRE2019.dta", clear
// merge with formats
merge m:1 udd using "$ff\uddan_2014_udd.dta", keep(1 3) nogen
// year of enrollment
gen o_year_enr=year(ELEV3_VFRA)
// field of study
destring h1, replace
gen o_enr_field_hum=inlist(M1TEKST,"Humanistisk","Humanistisk og teologisk") 
gen o_enr_field_nat=inlist(M1TEKST,"Naturvidenskabelig") 
gen o_enr_field_tech=inlist(M1TEKST,"Teknisk") 
gen o_enr_field_soc=inlist(M1TEKST,"Samfundsvidenskabelig") 
gen o_enr_field_health=inlist(M1TEKST,"Sundhed") 
keep pnr h1 o_year_enr pnr udd o_enr_field_*
// remove duplicates (allow 1 enrollment per year)
gsort pnr o_year -h1
by pnr o_year_enr: keep if _n==1
rename udd o_cont_udd_enr
rename h1 o_cont_degreetype_enr
// labels 
label var o_year_enr "Year enrolled"
label var o_cont_udd_enr "Educational program enrolled in"
label var o_cont_degreetype_enr "Educational program type enrolled in "
// save 
keep pnr o_*
compress
save "$tf\contedudata_enr.dta",replace
// graduation - load education registry
use "$rf\KOTRE2019.dta", clear
// drop non completed programs
drop if audd==0
drop if audd==9999
// merge with formats
merge m:1 audd using "$ff\uddan_2014_audd.dta", keep(1 3) nogen
destring h1, replace
// field of study
gen o_year_grad=year(ELEV3_VTIL)
gen o_grad_field_hum=inlist(M1TEKST,"Humanistisk","Humanistisk og teologisk") 
gen o_grad_field_nat=inlist(M1TEKST,"Naturvidenskabelig") 
gen o_grad_field_agr=inlist(M1TEKST,"Jordbrugsvidenskabelig") 
gen o_grad_field_tech=inlist(M1TEKST,"Teknisk") 
gen o_grad_field_soc=inlist(M1TEKST,"Samfundsvidenskabelig") 
gen o_grad_field_health=inlist(M1TEKST,"Sundhed") 
keep pnr h1 o_year_grad pnr audd   o_grad_field*
// remove duplicates
gsort pnr o_year -h1
by pnr o_year: keep if _n==1
rename audd o_cont_audd_grad
rename h1 o_cont_degreetype_grad
// labels 
label var o_year_grad "Year graduated"
label var o_cont_audd_grad "Educational program graduated from"
label var o_cont_degreetype_grad "Educational program type graduated from"
/* Save */
keep pnr o_*
compress
save "$tf\contedudata_grad.dta",replace
