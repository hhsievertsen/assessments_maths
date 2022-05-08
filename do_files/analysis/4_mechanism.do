/*  Project: grading bias 
    File:  4_mechanism
	Last edit: 2022-02-18 by Hans. 
*/

// load globals etc
do "D:\Data\workdata\704998\xdrev\704998\GradingBias\do_files\settings.do"

// Load data
use "$tf\analysisdata.dta",clear  
// For reviewer
						
eststo clear
foreach v in  g_mark_math  g_mark_ex_wr_math  {
	qui: eststo: reghdfe   	`v'	$vars c_female hs_e_mat_A     hs_e_mat_AXf  	if hs_s_mat_A==1, absorb( hs_program_fe  g_graduation_cohort g_instnr  ) cluster( hs_program_fe)
		test  hs_e_mat_A  +   hs_e_mat_AXf =0
	// Save scalars
	estadd scalar pval=r(p)
	estadd scalar msum=_b[hs_e_mat_A]+_b[hs_e_mat_AXf]
	sum   	`v' if c_female==1 & hs_e_mat_A==0
	estadd scalar mdvf=r(mean)
	sum  	`v'  if c_female==0 & hs_e_mat_A==0
	estadd scalar mdvm=r(mean)
}


				
esttab using "$df\tab_mechanism_REFEREE.rtf",replace label se b(%4.3f) nogaps star(* 0.1 ** 0.05 *** 0.01)  nomtitles ///
			nonumbers keep( hs_e_mat_A     hs_e_mat_AXf  	 c_female  ) noobs  stats(msum pval mdvf mdvm N, labels("Sum" "P-val" "MDV Fem"  "MDV Mal" "Obs") fmt( %5.3f %5.3f %5.3f %5.3f %6.0f))
						
