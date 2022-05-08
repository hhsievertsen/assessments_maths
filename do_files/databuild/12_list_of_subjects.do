/*  Project: grading bias 
    File:  12_list_of_subjects
	Last edit: 2022-02-19 by hhs
*/
* load globals etc
do "D:\Data\workdata\704998\xdrev\704998\GradingBias\do_files\settings.do"
// load data
* load raw data
use  "$tf\grading_data_detailed.dta",clear
// sample selection 
merge m:1 pnr using "$tf\analysisdata.dta",nogen keep(3) keepusing(pnr)
// Number of students
egen tag=tag(pnr)
egen Nstudents=sum(tag)
// decode subject
decode g_subject, gen(sj)
// sort by subject and level
sort sj g_level
// indicators
g int oral_ta=g_mark_ta!=.&g_oral>0 & g_oral!=.
g int oral_ex=g_mark_ex!=.&g_oral>0 & g_oral!=.
g int writ_ta=g_mark_ta!=.&g_writ==1
g int writ_ex=g_mark_ex!=.&g_writ==1
// aggregate
foreach v1 in oral writ{
	foreach v2 in ta ex{
		by sj g_level: egen count_`v1'_`v2'=sum(`v1'_`v2')
		gen share_`v1'_`v2'=round(100*count_`v1'_`v2'/Nstudents,.1)
		}
}
// keep 1 obs 
by sj g_level: keep if _n==1
// replace small groups with NA (-1)
gen a=.
foreach v1 in oral writ{
	foreach v2 in ta ex{
			replace share_`v1'_`v2'=-1 if count_`v1'_`v2'<5
		}
}
// keep variables
keep sj g_level share_*  g_subject
order sj g_level share_*
gsort -share_oral_ta
// Save data
save "$tf\unit_frequency.dta",replace
// export
cap file close mf
file open mf using "$df\tab_listofsubjects.tex",replace  write

local N=_N
forval i=1/`N'{
	// Write number
	file write mf "`i'&"
	// Write name
	qui: levelsof sj if _n==`i', local(a)
	foreach v in `a'{
		file write mf "`v';"
	}
	// Write level
	qui: sum g_level if _n==`i'
	local max=r(max)
	file write mf "`max'"
	// write shares
	foreach v1 in oral writ{
		foreach v2 in ta ex{
			qui: sum  share_`v1'_`v2' if _n==`i'
			local share: disp %4.1f r(mean)
				file write  mf  ";`share'"
			}
	}
	// End line
	file write mf  "\\"_n
}
// Close
file close mf
