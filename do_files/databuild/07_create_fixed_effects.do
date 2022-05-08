/*  Project: grading bias 
    File:  07_create_fixed_effects
	Last edit: 2022-02-19 by hhs
*/
// load globals etc
do "D:\Data\workdata\704998\xdrev\704998\GradingBias\do_files\settings.do"
// Load raw data
use  pnr g_level g_subject g_udd  g_difference g_oral pnr g_graduation_cohort ///
 g_mark_ex      g_imputed g_dif_oral using "$tf\grading_data_detailed.dta",clear
// decode subject
decode g_subject,gen(sub)
// Create fixed effects for subjects
gen byte s_dan1 = sub=="Dansk"& g_level==1
gen byte s_his1 = sub=="Historie"& g_level==1
gen byte s_old3 = sub=="Oldtidskundskab"& g_level==3
gen byte s_rel3 = sub=="Religion"& g_level==3
gen byte s_geo3 = sub=="Geografi"& g_level==3
gen byte s_bil3 = sub=="Billedkunst"& g_level==3
gen byte s_bio3 = sub=="Biologi"& g_level==3
gen byte s_mus3 = sub=="Musik"& g_level==3
gen byte s_idr3 = sub=="Idræt"& g_level==3
gen byte s_tys2 = sub=="Tysk"& g_level==2
gen byte s_eng1 = sub=="Engelsk"& g_level==1
gen byte s_eng2 = sub=="Engelsk"& g_level==2
gen byte s_mat1 = sub=="Matematik"& g_level==1
gen byte s_fys2 = sub=="Fysik"& g_level==2
gen byte s_kem3 = sub=="Kemi"& g_level==3
gen byte s_mat2 = sub=="Matematik"& g_level==2
gen byte s_psy3 = sub=="Psykologi"& g_level==3
gen byte s_nat3 = sub=="Naturfag"& g_level==3
gen byte s_lat3 = sub=="Latin"& g_level==3
gen byte s_spa3 = sub=="Spansk"& g_level==3
// Create fixed effects for exams
gen byte e_mat1 = sub=="Matematik"& g_level==1 & g_oral==1 & g_difference!=. & g_imputed==0
// Number of assessments
sort pnr g_graduation_cohort
by pnr g_graduation_cohort: gen g_obs=_N
by pnr g_graduation_cohort: egen g_obs_ex=count(g_mark_ex)
// Collapse to pnr level
collapse (max) s_* e_*  (firstnm) g_obs_ex g_obs g_udd, by(g_graduation_cohort pnr) fast
// Create fixed effect
egen g_hs_program=group(s_*)
sort g_hs_program
by  g_hs_program: gen  g_hs_program_N=_N
// Count objects
gen byte g_hs_program_s=0
foreach v in  s_dan1 s_his1 s_old3 s_rel3 s_geo3 s_bil3 s_bio3 s_mus3 s_idr3 s_tys2 s_eng1 s_eng2 s_mat1 s_fys2 s_kem3 s_mat2 s_psy3 s_nat3 s_lat3 s_spa3 s_erh3b s_int2 s_sam2b s_sam1 s_inf2 s_erh3c s_idr2 s_afs1 s_sam2 s_erh2 s_fra3 s_fra2 s_tys1 s_bio1 s_erh1 s_spa2 s_afs2 s_fil3 s_kem2 s_fys1 s_mus1 s_med3 s_erh3d s_kem1 s_tek2 s_bio2 s_bil2 s_erh3e s_sam3 s_tys3 {
	cap replace g_hs_program_s=g_hs_program_s+1 if `v'==1
	cap  rename  `v' hs_`v'
}
// drop unknown degree
drop if g_udd==.
// save
compress
rename e_mat1 hs_e_mat1
save "$tf\fe_raw_sub.dta",replace

