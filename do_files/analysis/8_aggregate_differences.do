/*  Project: grading bias 
    File:  8_aggregate_differences.do 
	Last edit: 2022-02-19 by Hans. 
*/
* load globals etc
do "D:\Data\workdata\704998\xdrev\704998\GradingBias\do_files\settings.do"
* load raw data
use  "$tf\grading_data_detailed.dta",clear
merge m:1 pnr g_graduation_cohort using "$tf\analysisdata.dta", keep(3) keepusing(c_female)
* drop if exam mark is imputed
drop if g_imputed==1

cap program drop mywrite
program mywrite
	syntax ,[cond(string) name(string) end(str)]
	sum g_difference `cond'
	local a: disp %4.2f r(mean)
	local b: disp %4.2f r(sd)
	local c: disp %10.0fc r(N)
	file write mf "`name';`a';`b';`c'"`end'
end

cap file close mf
file open mf using "$df\tab_aggdifferences_A.tex",replace write
// Overall
	mywrite,name(Overall)
// Danish
	mywrite, cond(if g_subject==14 )
//  Math (A level)
	mywrite, cond(if g_subject==70 & g_level==1 ) end(_n)
// Overall + Oral
	mywrite,name(Oral) cond(if g_oral==1)
// Danish + Oral
	mywrite, cond(if g_subject==14 & g_oral==1)
// Math (A level) + Oral
	mywrite, cond(if g_subject==70 & g_oral==1 & g_level==1) end(_n)
// Overall + Written
	mywrite,name(Written) cond(if g_writ==1)
// Danish + Written
	mywrite, cond(if g_subject==14 & g_writ==1)
// Math (A level) + Written
	mywrite, cond(if g_subject==70 & g_writ==1 & g_level==1) end(_n)
file close mf
	
// Girls only
preserve
	keep if c_female==1
	cap file close mf
	file open mf using "$df\tab_aggdifferences_A_girls.tex",replace write
	// Overall
		mywrite,name(Overall)
	// Danish
		mywrite, cond(if g_subject==14 )
	//  Math (A level)
		mywrite, cond(if g_subject==70 & g_level==1 ) end(_n)
	// Overall + Oral
		mywrite,name(Oral) cond(if g_oral==1)
	// Danish + Oral
		mywrite, cond(if g_subject==14 & g_oral==1)
	// Math (A level) + Oral
		mywrite, cond(if g_subject==70 & g_oral==1 & g_level==1) end(_n)
	// Overall + Written
		mywrite,name(Written) cond(if g_writ==1)
	// Danish + Written
		mywrite, cond(if g_subject==14 & g_writ==1)
	// Math (A level) + Written
		mywrite, cond(if g_subject==70 & g_writ==1 & g_level==1) end(_n)
	file close mf
restore	
// Boys only
preserve
	keep if c_female==0
	cap file close mf
	file open mf using "$df\tab_aggdifferences_A_boys.tex",replace write
	// Overall
		mywrite,name(Overall)
	// Danish
		mywrite, cond(if g_subject==14 )
	//  Math (A level)
		mywrite, cond(if g_subject==70 & g_level==1 ) end(_n)
	// Overall + Oral
		mywrite,name(Oral) cond(if g_oral==1)
	// Danish + Oral
		mywrite, cond(if g_subject==14 & g_oral==1)
	// Math (A level) + Oral
		mywrite, cond(if g_subject==70 & g_oral==1 & g_level==1) end(_n)
	// Overall + Written
		mywrite,name(Written) cond(if g_writ==1)
	// Danish + Written
		mywrite, cond(if g_subject==14 & g_writ==1)
	// Math (A level) + Written
		mywrite, cond(if g_subject==70 & g_writ==1 & g_level==1) end(_n)
	file close mf
restore	
	
