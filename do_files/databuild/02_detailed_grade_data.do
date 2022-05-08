/*  Project: grading bias 
    File:  02_detailed_grade_data.do - clean and setup course level grading data
	Last edit: 2022-02-19 by hhs
*/
// load settings
do "D:\Data\workdata\704998\xdrev\704998\GradingBias\do_files\settings.do"
// load data
u "$rf\udgk2015.dta",clear
// select cohorts
destring bevisaar, gen(g_graduation_cohort)
keep if g_graduation_cohort>2002& g_graduation_cohort<2008
// select STX, HHX, and HTX only
keep if inlist(udd,1199,1179,1189,5080,5090)
rename udd g_udd
// identify assessment type
encode FAG_TXT,gen(g_subject)
g int g_oral=strpos(testtype,"mundtl")!=0
replace g_oral=1 if strpos(testtype,"samlet")!=0  
g int g_writ=strpos(testtype,"skrift")!=0
g int g_exam=strpos(testtype,"Eksa")!=0
g int g_studyproject=strpos(testtype,"opga")!=0
// subject level
g int g_level=1 	if  niveau=="A"
replace  g_level=2 	if  niveau=="B"
replace  g_level=3 	if  niveau=="C"
replace g_level=3 if g_level==.
gen int g_levelA=g_level==1
gen int g_levelB=g_level==2
gen int g_levelC=g_level==3
// remove lower levels in same unit (these are not included in GPA)
bys pnr g_subject g_graduation_cohort: egen maxlevel=min(g_level)
drop if g_level>maxlevel
// how many marks given in the unit?
gen a=g_studyproject!=1
bys pnr g_oral g_subject: egen g_marks=sum(a)
// how many marks to impute for the unit?
g g_markstoimpute=2-g_marks if g_studyproject==0
replace g_markstoimpute=0 if inlist(FAG_TXT,"Musik","Billedkunst","Idræt") & g_level==3 
replace g_markstoimpute=0 if g_studyproject==1
drop if g_markstoimpute<0
// use teacher mark if not exam assessed
replace g_markstoimpute=0 if g_exam==1
g b=g_markstoimpute+1
expand b,gen(g_imputed)
replace g_exam=1 if g_imputed==1
// rename variables
rename karakter g_mark
rename instnr g_instnr
// make wide
g g_mark_ta=g_mark if g_exam==0 & g_studyproject==0
g g_mark_ex=g_mark if g_exam==1 & g_imputed==0
rename g_subject sub
rename g_writ writ
rename g_graduation_cohort coh
rename g_imputed imp
rename g_oral oral
drop g_studyproject
// collapse to one obs
collapse (mean) g_*  (max) g_imputed=imp (count) n=g_mark,by( pnr  sub coh writ oral)   fast
// cleaning
drop if oral==0 & writ==0 								/* Projects */
drop if !inlist(g_mark_ta,0,3,5,6,7,8,9,10,11,13,.)   /* Marks that shouldn't exist; 44 obs out of 1.4 mio*/
drop if !inlist(g_mark_ex,0,3,5,6,7,8,9,10,11,13,.)   /* Marks that shouldn't exist; 289 obs out of 1.4 mio. */
rename  sub g_subject
rename  writ g_writ
rename  oral g_oral
rename  coh g_graduation_cohort
// difference betweent eacher asessement and exam mark
g g_difference=g_mark_ta-g_mark_ex if g_imputed==0
* keep and clean 
drop g_exam g_mark
keep pnr g_*
* labels *
label var g_graduation_cohort 	"Graduation Year"
label var g_subject 			"Subject"
label var g_writ  				"Written"
label var g_instnr  			"Institution id"
label var g_udd 				"Degree"
label var g_oral 				"Oral"
label var g_level 				"Level"
label var g_levelA				"A level"
label var g_levelB				"B level"
label var g_levelC				"C level"
label var g_imputed 			"Exam mark is imputed by TA"
label var g_mark_ta  			"Teacher assessment"
label var g_mark_ex 			"Exam assessment"
label var g_difference  		"Difference: TA-EX"
compress
// reverse the difference  to EX-TA measure (make it more intuitive) 
replace g_difference=g_difference*(-1)
gen g_dif_oral=g_difference if g_oral==0
replace g_difference=. if g_imputed==1
// save detailed data
drop if g_udd==.
compress
save "$tf\grading_data_detailed.dta",replace
// collapse
gen g_mark_ta_wr=g_mark_ta if g_writ==1
gen g_mark_ta_or=g_mark_ta if g_writ!=1
gen g_mark_ex_wr=g_mark_ex if g_writ==1
gen g_mark_ex_or=g_mark_ex if g_writ!=1
decode g_subject, gen(sub)
gen g_mark_math=g_mark_ta if g_mark_ex==. & sub=="Matematik"
replace  g_mark_math=(g_mark_ta+g_mark_ex)/2 if g_mark_ex!=. & sub=="Matematik"
gen g_mark_ex_wr_math=g_mark_ex_wr if g_writ==1 &   g_level==1 & sub=="Matematik"
collapse (mean)  g_mark_math g_mark_ex_wr_math g_dif_oral g_difference g_mark_ta g_mark_ex_wr g_mark_ex_or g_mark_ex g_mark_ta_wr g_mark_ta_or,by(pnr g_graduation_cohort) fast
save "$tf\grading_data_detailed_collapsed.dta",replace
