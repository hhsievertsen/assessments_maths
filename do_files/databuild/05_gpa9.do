/*  Project: grading bias 
    File:  05_gpa9.do - 9th grade GPA
	Last edit: 2022-02-19 by hhs
*/
// load settings
do "D:\Data\workdata\704998\xdrev\704998\GradingBias\do_files\settings.do"
// Load data
use "$rf\udfk2014.dta", clear
keep if kltrin=="09"
// collapse
collapse (mean) c_gpa9=grundskolekarakter  ,by( skala  pnr skoleaar) fast
sort pnr skoleaar
by pnr: keep if _n==1
// keep vars
keep c_gpa9  pnr   
// save 
compress
save "$tf\gpa9data.dta",replace
