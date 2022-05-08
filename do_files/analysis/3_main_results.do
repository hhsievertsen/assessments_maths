/*  Project: grading bias 
    File:  3_main_results. Main results
	Last edit: 2022-02-19 by hhs
*/
* load globals etc
do "D:\Data\workdata\704998\xdrev\704998\GradingBias\do_files\settings.do"
// load
use "$tf\analysisdata.dta",clear
keep if hs_s_mat_A==1
// Run regressions
eststo clear
foreach v in g_gpa_actual o_enrolled_he_y10 o_graduated_he_y10 o_s_math_req_10 o_s_math_high_10  {
	qui: eststo: reg   	`v'	  i.hs_program_fe i.g_graduation_cohort i.g_instnr 	 $vars  c_female hs_e_mat_A     hs_e_mat_AXf  	,  cluster( hs_program_fe)
// Test joint hypothesis
	test  hs_e_mat_A  +   hs_e_mat_AXf =0
	// Save scalars
	estadd scalar pval=r(p)
	estadd scalar msum=_b[hs_e_mat_A]+_b[hs_e_mat_AXf]
	sum   	`v' if c_female==1 & hs_e_mat_A==0
	estadd scalar mdvf=r(mean)
	sum  	`v'  if c_female==0 & hs_e_mat_A==0
	estadd scalar mdvm=r(mean)
	
}
// Create table
esttab using "$df\tab_main_results.rtf",replace label se b(%4.3f)  star(* 0.1 ** 0.05 *** 0.01)  nomtitles ///
			nonumbers keep( hs_e_mat_A     hs_e_mat_AXf  	 c_female  ) noobs  stats(msum pval mdvf mdvm N, labels("Sum" "P-val" "MDV Fem"  "MDV Mal" "Observations") fmt( %5.3f %5.3f %5.3f %5.3f  %10.0f))

/*-------------------------- By attainment -------------------------------------*/			
cap drop _*
sum g_mark_ex_wr_math,d
gen _Z=g_mark_ex_wr_math>r(p50) 
replace _Z=. if g_mark_ex_wr_math==.
gen _ZXfemale=_Z*c_female
gen _ZXmath=_Z*hs_e_mat_A
gen _ZXmathXfemale=_ZXmath*c_female
eststo clear
foreach v in g_gpa_actual  o_enrolled_he_y10 o_graduated_he_y10 o_s_math_req_10 o_s_math_high_10 {
	// For main
	qui: eststo m_low_`v': reg   	`v'	 i.hs_program_fe i.g_graduation_cohort i.g_instnr 	 $vars c_female hs_e_mat_A     hs_e_mat_AXf  	_Z _ZXfemale _ZXmath _ZXmathXfemale,  cluster( hs_program_fe)
// Test joint hypothesis
	test  hs_e_mat_A  +   hs_e_mat_AXf =0
	// Save scalars
	estadd scalar pval=r(p)
	// sum for girls below median
	estadd scalar msum=_b[hs_e_mat_A]+_b[hs_e_mat_AXf] 
	sum   	`v' if c_female==1 & hs_e_mat_A==0 & _Z==0
	estadd scalar mdvf=r(mean)
	sum  	`v'  if c_female==0 & hs_e_mat_A==0  & _Z==0
	estadd scalar mdvm=r(mean)
	// sum for girls below median
	estadd scalar msumA=_b[hs_e_mat_A]+_b[hs_e_mat_AXf]+_b[_ZXmathXfemale]+_b[_ZXmath]
	test  hs_e_mat_A  +   hs_e_mat_AXf +_ZXmath+_ZXmathXfemale=0
	estadd scalar pvalA=r(p)
	sum   	`v' if c_female==1 & hs_e_mat_A==0  & _Z==1
	estadd scalar mdvfA=r(mean)
	sum  	`v'  if c_female==0 & hs_e_mat_A==0  & _Z==1
	estadd scalar mdvmA=r(mean)
	
}

// Create table
esttab m_low_g_gpa_actual m_low_o_enrolled_he_y10 m_low_o_graduated_he_y10 m_low_o_s_math_req_10 m_low_o_s_math_high_10 ///
	using "$df\tab_main_resultsbyattainment.rtf",replace label se b(%4.3f)  star(* 0.1 ** 0.05 *** 0.01)  nomtitles ///
			nonumbers keep( hs_e_mat_A     hs_e_mat_AXf  	 c_female  _Z _ZXfemale _ZXmath _ZXmathXfemale ) noobs  stats(msum pval mdvf mdvm  msumA pvalA mdvfA mdvmA N, fmt( %5.3f %5.3f %5.3f %5.3f %5.3f %5.3f %5.3f %5.3f  %10.0f)) 
			
/*-------------------------- By income  -------------------------------------*/			
cap drop _*
gen _Z=c_par_iq>=6
replace _Z=. if c_par_io==0
gen _ZXfemale=_Z*c_female
gen _ZXmath=_Z*hs_e_mat_A
gen _ZXmathXfemale=_ZXmath*c_female
eststo clear
foreach v in g_gpa_actual  o_enrolled_he_y10 o_graduated_he_y10 o_s_math_req_10 o_s_math_high_10 {
	// For main
	qui: eststo m_low_`v': reg   	`v'	 i.hs_program_fe i.g_graduation_cohort i.g_instnr 	 $vars c_female hs_e_mat_A     hs_e_mat_AXf  	_Z _ZXfemale _ZXmath _ZXmathXfemale,  cluster( hs_program_fe)
// Test joint hypothesis
	test  hs_e_mat_A  +   hs_e_mat_AXf =0
	// Save scalars
	estadd scalar pval=r(p)
	// sum for girls below median
	estadd scalar msum=_b[hs_e_mat_A]+_b[hs_e_mat_AXf] 
	sum   	`v' if c_female==1 & hs_e_mat_A==0 & _Z==0
	estadd scalar mdvf=r(mean)
	sum  	`v'  if c_female==0 & hs_e_mat_A==0  & _Z==0
	estadd scalar mdvm=r(mean)
	// sum for girls below median
	estadd scalar msumA=_b[hs_e_mat_A]+_b[hs_e_mat_AXf]+_b[_ZXmathXfemale]+_b[_ZXmath]
	test  hs_e_mat_A  +   hs_e_mat_AXf +_ZXmath+_ZXmathXfemale=0
	estadd scalar pvalA=r(p)
	sum   	`v' if c_female==1 & hs_e_mat_A==0  & _Z==1
	estadd scalar mdvfA=r(mean)
	sum  	`v'  if c_female==0 & hs_e_mat_A==0  & _Z==1
	estadd scalar mdvmA=r(mean)
	
}



// Create table
esttab m_low_g_gpa_actual m_low_o_enrolled_he_y10 m_low_o_graduated_he_y10 m_low_o_s_math_req_10 m_low_o_s_math_high_10 ///
	using "$df\tab_main_resultsbyinc.rtf",replace label se b(%4.3f)  star(* 0.1 ** 0.05 *** 0.01)  nomtitles ///
			nonumbers keep( hs_e_mat_A     hs_e_mat_AXf  	 c_female  _Z _ZXfemale _ZXmath _ZXmathXfemale ) noobs  stats(msum pval mdvf mdvm  msumA pvalA mdvfA mdvmA N, fmt( %5.3f %5.3f %5.3f %5.3f %5.3f %5.3f %5.3f %5.3f  %10.0f)) 		
			
/*-------------------------- By educaton  -------------------------------------*/					
cap drop _*
gen _Z=c_par_ud==1
replace _Z=. if c_par_eo==0
gen _ZXfemale=_Z*c_female
gen _ZXmath=_Z*hs_e_mat_A
gen _ZXmathXfemale=_ZXmath*c_female
eststo clear
foreach v in g_gpa_actual  o_enrolled_he_y10 o_graduated_he_y10 o_s_math_req_10 o_s_math_high_10 {
	// For main
	qui: eststo m_low_`v': reg   	`v'	 i.hs_program_fe i.g_graduation_cohort i.g_instnr 	 $vars c_female hs_e_mat_A     hs_e_mat_AXf  	_Z _ZXfemale _ZXmath _ZXmathXfemale,  cluster( hs_program_fe)
// Test joint hypothesis
	test  hs_e_mat_A  +   hs_e_mat_AXf =0
	// Save scalars
	estadd scalar pval=r(p)
	// sum for girls below median
	estadd scalar msum=_b[hs_e_mat_A]+_b[hs_e_mat_AXf] 
	sum   	`v' if c_female==1 & hs_e_mat_A==0 & _Z==0
	estadd scalar mdvf=r(mean)
	sum  	`v'  if c_female==0 & hs_e_mat_A==0  & _Z==0
	estadd scalar mdvm=r(mean)
	// sum for girls below median
	estadd scalar msumA=_b[hs_e_mat_A]+_b[hs_e_mat_AXf]+_b[_ZXmathXfemale]+_b[_ZXmath]
	test  hs_e_mat_A  +   hs_e_mat_AXf +_ZXmath+_ZXmathXfemale=0
	estadd scalar pvalA=r(p)
	sum   	`v' if c_female==1 & hs_e_mat_A==0  & _Z==1
	estadd scalar mdvfA=r(mean)
	sum  	`v'  if c_female==0 & hs_e_mat_A==0  & _Z==1
	estadd scalar mdvmA=r(mean)
	
}



// Create table
esttab m_low_g_gpa_actual m_low_o_enrolled_he_y10 m_low_o_graduated_he_y10 m_low_o_s_math_req_10 m_low_o_s_math_high_10 ///
	using "$df\tab_main_resultsbyedu.rtf",replace label se b(%4.3f)  star(* 0.1 ** 0.05 *** 0.01)  nomtitles ///
			nonumbers keep( hs_e_mat_A     hs_e_mat_AXf  	 c_female  _Z _ZXfemale _ZXmath _ZXmathXfemale ) noobs  stats(msum pval mdvf mdvm  msumA pvalA mdvfA mdvmA N, fmt( %5.3f %5.3f %5.3f %5.3f %5.3f %5.3f %5.3f %5.3f  %10.0f)) 	
			
/*-------------------------- By type  -------------------------------------*/					
cap drop _*
gen _Z=inlist(g_udd,1179,1189,1199)
replace _Z=. if g_udd==.
gen _ZXfemale=_Z*c_female
gen _ZXmath=_Z*hs_e_mat_A
gen _ZXmathXfemale=_ZXmath*c_female
eststo clear
foreach v in g_gpa_actual  o_enrolled_he_y10 o_graduated_he_y10 o_s_math_req_10 o_s_math_high_10 {
	// For main
	qui: eststo m_low_`v': reg   	`v'	 i.hs_program_fe i.g_graduation_cohort i.g_instnr 	 $vars c_female hs_e_mat_A     hs_e_mat_AXf  	_Z _ZXfemale _ZXmath _ZXmathXfemale,  cluster( hs_program_fe)
// Test joint hypothesis
	test  hs_e_mat_A  +   hs_e_mat_AXf =0
	// Save scalars
	estadd scalar pval=r(p)
	// sum for girls below median
	estadd scalar msum=_b[hs_e_mat_A]+_b[hs_e_mat_AXf] 
	sum   	`v' if c_female==1 & hs_e_mat_A==0 & _Z==0
	estadd scalar mdvf=r(mean)
	sum  	`v'  if c_female==0 & hs_e_mat_A==0  & _Z==0
	estadd scalar mdvm=r(mean)
	// sum for girls below median
	estadd scalar msumA=_b[hs_e_mat_A]+_b[hs_e_mat_AXf]+_b[_ZXmathXfemale]+_b[_ZXmath]
	test  hs_e_mat_A  +   hs_e_mat_AXf +_ZXmath+_ZXmathXfemale=0
	estadd scalar pvalA=r(p)
	sum   	`v' if c_female==1 & hs_e_mat_A==0  & _Z==1
	estadd scalar mdvfA=r(mean)
	sum  	`v'  if c_female==0 & hs_e_mat_A==0  & _Z==1
	estadd scalar mdvmA=r(mean)
	
}



// Create table
esttab m_low_g_gpa_actual m_low_o_enrolled_he_y10 m_low_o_graduated_he_y10 m_low_o_s_math_req_10 m_low_o_s_math_high_10 ///
	using "$df\tab_main_resultsbytype.rtf",replace label se b(%4.3f)  star(* 0.1 ** 0.05 *** 0.01)  nomtitles ///
			nonumbers keep( hs_e_mat_A     hs_e_mat_AXf  	 c_female  _Z _ZXfemale _ZXmath _ZXmathXfemale ) noobs  stats(msum pval mdvf mdvm  msumA pvalA mdvfA mdvmA N, fmt( %5.3f %5.3f %5.3f %5.3f %5.3f %5.3f %5.3f %5.3f  %10.0f)) 
