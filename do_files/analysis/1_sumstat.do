/*  Project: grading bias 
    File:  1_sumstat.do -summary stats
	Last edit: 2022-02-19 by hhs
*/
// load globals etc
do "D:\Data\workdata\704998\xdrev\704998\GradingBias\do_files\settings.do"
// load analysisdata
use  "$tf\analysisdata.dta",clear
// Program for sumstat
cap program drop mysumstat
program mysumstat
	syntax varlist,  title(string) [last option(string)] 
	cap file close myfile
	file open myfile using "$df\\tab_sumstat.tex",write `option'
	file write myfile "`title'" _n
	foreach v in `varlist'{
		qui: sum `v'
		local a: disp %4.2f r(mean)
		local b: disp %4.2f r(sd)
		qui: sum `v' if hs_s_mat_A==1
		local c: disp %4.2f r(mean)
		local d: disp %4.2f r(sd)
		
		local label: variable label `v'
		file write myfile ";`label';`a';`b';`c';`d'"_n
	}
	
	if "`last'"!=""{
	qui: sum c_female 
	local a: disp %9.0f r(N)
	qui: sum c_female if hs_s_mat_A==1
	local b: disp %9.0f r(N)
	file write myfile "Observations;;`a';;`b'"_n
	}
	file close myfile
end
// Create tables
replace c_par_ud=. if c_par_eo==0
replace c_par_inc=. if c_par_io==0
mysumstat c_female   c_par_ud c_par_inc    ,title("A. Background") option(replace)
mysumstat  g_obs_ex hs_e_mat_A g_gpa_actual , option(append) title("B. Assessments")
mysumstat o_enrolled_he_y10 o_graduated_he_y10 o_s_math_req_10 o_s_math_high_10 ,last option(append)  title("B. Post-secondary schooling") 

