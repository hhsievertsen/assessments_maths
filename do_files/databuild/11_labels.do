/*  Project: grading bias 
    File:  11_labels.do
	Last edit: 2022-02-19 by hhs
*/
// load globals etc
do "D:\Data\workdata\704998\xdrev\704998\GradingBias\do_files\settings.do"
// Load the data
use "$tf\tf10.dta",clear
// Parental backbround
label var c_par_inc "Parental income (1,000 EUR 2015 level)"
label var c_par_io "Parental income observed"
label var c_par_eo "Parental education observed"
label var c_par_ud "At least one parent with a university degree"
label var c_father_edu_g1 "Father education: unknown"
label var c_father_edu_g2 "Father education: compulsory"
label var c_father_edu_g3 "Father education: prepatory"
label var c_father_edu_g4 "Father education: academic high school"
label var c_father_edu_g5 "Father education: vocational high school"
label var c_father_edu_g6 "Father education: vocational training"
label var c_father_edu_g7 "Father education: adv. prepatory"
label var c_father_edu_g8 "Father education: short professional"
label var c_father_edu_g9 "Father education: vocational college"
label var c_father_edu_g10 "Father education: university (Bachelor)"
label var c_father_edu_g11 "Father education: university (Master)"
label var c_father_edu_g12 "Father education: university (PhD)"
label var c_mother_edu_g1 "Mother education: unknown"
label var c_mother_edu_g2 "Mother education: compulsory"
label var c_mother_edu_g3 "Mother education: prepatory"
label var c_mother_edu_g4 "Mother education: academic high school"
label var c_mother_edu_g5 "Mother education: vocational high school"
label var c_mother_edu_g6 "Mother education: vocational training"
label var c_mother_edu_g7 "Mother education: adv. prepatory"
label var c_mother_edu_g8 "Mother education: short professional"
label var c_mother_edu_g9 "Mother education: vocational college"
label var c_mother_edu_g10 "Mother education: university (Bachelor)"
label var c_mother_edu_g11 "Mother education: university (Master)"
label var c_mother_edu_g12 "Mother education: university (PhD)"
label var c_parental_edu_obs_g1 "Parental education observed: none"
label var c_parental_edu_obs_g2 "Parental education observed: one"
label var c_parental_edu_obs_g3 "Parental education observed: both"
label var c_parental_inc_obs_g1 "Parental income observed: none"
label var c_parental_inc_obs_g2 "Parental income observed: one"
label var c_parental_inc_obs_g3 "Parental income observed: both"
forval i=1/10{
	label var c_par_inc_g`i' "Parental income decile: `i'" 
}

// Individual stuff
label var g_obs "Observations per individual"
label var g_obs_ex "Exams per individual"
label var g_mark_ta_or "Teacher assessment: oral"
label var g_mark_ta_wr "Teacher assessment: written"
label var c_female "Female"
label var  c_gpa9 "GPA, 9th grade"
label var c_female 					"Female"
label var g_graduation_cohort 	"Graduation Year"
label var g_gpa_actual 			"GPA (actual)"
label var o_enrolled_he_y10 "Enrolled within 10y"
label var o_graduated_he_y10 "Graduated within 10y"
label var o_s_math_req_10 "Graduated from maths req. degree within 10y"
label var o_s_math_high_10 "Graduated from maths dem. degree within 10y"
label var  g_obs_ex   "Number of assessments"
label var hs_e_mat_A "Maths exam" 
label var g_gpa_actual "GPA"
// cleaning
compress
order c_* g_* o_* 
save "$tf\analysisdata.dta",replace

