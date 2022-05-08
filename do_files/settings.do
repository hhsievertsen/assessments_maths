/*  Project: grading bias 
    File:  settings.do - define globals and paths
	Last edit: 2022-02-19 by hhs
*/
// Settings
clear all

cd "D:\Data\workdata\704998\xdrev\704998\"
set max_memory 15g, permanently
set maxvar 10000
// Global paths
global df "GradingBias\output_files" 		/* Files to download 		*/
global rf "raw"  							/* Raw data files 			*/
global tf "GradingBias\temporary_files" 	/* Temporary analysis files	*/
global ff "GradingBias\format_files" 		/* Education formats etc	*/

// Global model specifications
gl controls="par_inc2-par_inc10   parental_inc_observed3 father_edu_g2-father_edu_g12 mother_edu_g2-mother_edu_g12   parental_edu_g_observed3"

* model
gl vars =" c_par_inc_g2 c_par_inc_g3 c_par_inc_g4 c_par_inc_g5 c_par_inc_g6 c_par_inc_g7 c_par_inc_g8 c_par_inc_g9 c_par_inc_g10  c_parental_inc_obs_g2 c_parental_inc_obs_g3 c_mother_edu_g2 c_mother_edu_g3 c_mother_edu_g4 c_mother_edu_g5 c_mother_edu_g6 c_mother_edu_g7 c_mother_edu_g8 c_mother_edu_g9 c_mother_edu_g10 c_mother_edu_g11 c_mother_edu_g12 c_father_edu_g2 c_father_edu_g3 c_father_edu_g4 c_father_edu_g5 c_father_edu_g6 c_father_edu_g7 c_father_edu_g8 c_father_edu_g9 c_father_edu_g10 c_father_edu_g11 c_father_edu_g12   c_parental_edu_obs_g2"
	