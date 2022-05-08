/*  Project: grading bias 
    File:  2_validity.dos
	Last edit: 2022-02-19 by hhs
*/
 graph drop _all 
* load globals etc
do "D:\Data\workdata\704998\xdrev\704998\GradingBias\do_files\settings.do"
use "$tf\analysisdata.dta",clear 
// Predict A level exam
eststo clear
eststo f1: reghdfe hs_e_mat_A    $vars c_female   g_mark_ta_wr if hs_s_mat_A==1, ///
				absorb(  g_hs_program    g_instnr  g_graduation_cohort  ) ///
				cluster( hs_program_fe)
mat  modela=r(table)
// save F stat
estadd scalar Fpval=  Ftail(e(df_m),e(df_r),e(F))
gl F1p= Ftail(e(df_m),e(df_r),e(F))
gl F1=e(F)
// create table
esttab f1 using "$df\tab_balance_maths.rtf",replace label se b(%4.3f) nogaps star(* 0.1 ** 0.05 *** 0.01)  nomtitles ///
			nonumbers stats(N N_clust F Fpval, labels("Observations" " Clusters" " F-stat" " P-val") fmt(%10.0f %10.0f %5.2f %5.2f))
// create chart
// stats math
mat b=modela[3,1..36]'
svmat b
rename b tstats_math
// names
local name=""
local i=1
foreach v in $vars {
	local lab: variable label `v'
	di "`i' `lab'"
	local i=`i'+1
}
keep  tstats* $vars
drop if tstats_==.
gen order=_n
// helper lines
gen x1=-3 if _n==1
replace x1=3 if _n==2
gen x2=3.8 if _n==3
replace x2=8.2 if _n==4
gen yup=36.5 if _n<=4
gen ylo=0 if _n<=4
gen x3=0 if _n==1
replace x3=0.000001 if _n==2
gen x4=6 if _n==1
replace x4=6.000001 if _n==2
gen yline=36.5 if _n==1
replace yline=0 if _n==2
// dashed liness 
gen ydash=36 if _n==1
replace ydash=0 if _n==2
gen xdash1=-1.96
gen xdash2=1.96
// Fstat
gen Fx1=$F1 if _n<3
local F1: disp %4.2f $F1
local F1p: disp %4.2f $F1p
// create chart
  tw (rarea yup ylo x1 ,fcolor(gs12%33) lcolor(white)  ) ///
	(line yline x3  ,lcolor(gs4)) ///
   (scatter order tstats_ ,mcolor(black) msymbol(Oh)  msize(medsmall)) ///
   (line ydash xdash1, lpattern(dash) lwidth(medthin) lcolor(gs10)) ///
   (line ydash xdash2, lpattern(dash) lwidth(medthin) lcolor(gs10)) ///
   ,xlab(-3 "-3" -2.5 " "  -2 "-2" -1 "-1" 0 "0" 1 "1" 2 "2" ///
        2.5 " "  3 "3", noticks labsize(vsmall)) ///
		 graphregion(lcolor(white) fcolor(white)) ///
		 plotregion(lcolor(white) fcolor(white)) yscale(noline)		 ///
		 ylab( ///
		 1 " "  ///
		2 " "  ///
		3 " "  ///
		4 " "  ///
		5 " "  ///
		6 " "  ///
		7 " "  ///
		8 " "  ///
		9 " "  ///
		10 " "  ///
		11 " "  ///
		12 " "  ///
		13 " "  ///
		14 " "  ///
		15 " "  ///
		16 " "  ///
		17 " "  ///
		18 " "  ///
		19 " "  ///
		20 " "  ///
		21 " "  ///
		22 " "  ///
		23 " "  ///
		24 " "  ///
		25 " "  ///
		26 " "  ///
		27 " "  ///
		28 " "  ///
		29 " "  ///
		30 " "  ///
		31 " "  ///
		32 " "  ///
		33 " "  ///
		34 " "  ///
		35 " "  ///
		36 " "  ///
		37 "  " ///
		,nogrid noticks angle(horizontal) labsize(vsmall))		///
		 legend(off) xtitle("t-stat",size(vsmall)) ///
		 text(38.7 0 "With Teacher Assessment",size(small)) ///
		 text(37.4 0 "F stat: `F1' (pval=`F1p') ",size(vsmall)) ///
		 xscale(noline)  xsize(6) ysize(8)  name(fig1)  ///
		 title(" ")
		 graph export "$df\fig_balance_math.png",replace width(2000)
		 
	

		 
/* without teacher mark */
use "$tf\analysisdata.dta",clear 
// Predict A level exam
eststo f2: reghdfe hs_e_mat_A    $vars c_female    if hs_s_mat_A==1, ///
				absorb(  g_hs_program    g_instnr  g_graduation_cohort  ) ///
				cluster( hs_program_fe)
mat  modela=r(table)
// save F stat
estadd scalar Fpval=  Ftail(e(df_m),e(df_r),e(F))
gl F1p= Ftail(e(df_m),e(df_r),e(F))
gl F1=e(F)
// create table
esttab f2 f1  using "$df\tab_balance_maths_full.rtf",replace label se b(%4.3f) nogaps star(* 0.1 ** 0.05 *** 0.01)  nomtitles ///
			nonumbers stats(N N_clust F Fpval, labels("Observations" " Clusters" " F-stat" " P-val") fmt(%10.0f %10.0f %5.2f %5.2f))
// create chart
// stats math
mat b=modela[3,1..35]'
svmat b
rename b tstats_math
// names
local name=""
local i=1
foreach v in $vars {
	local lab: variable label `v'
	di "`i' `lab'"
	local i=`i'+1
}
keep  tstats* $vars
drop if tstats_==.
gen order=_n
// helper lines
gen x1=-3 if _n==1
replace x1=3 if _n==2
gen x2=3.8 if _n==3
replace x2=8.2 if _n==4
gen yup=36.5 if _n<=4
gen ylo=0 if _n<=4
gen x3=0 if _n==1
replace x3=0.000001 if _n==2
gen x4=6 if _n==1
replace x4=6.000001 if _n==2
gen yline=36.5 if _n==1
replace yline=0 if _n==2
// dashed liness 
gen ydash=36 if _n==1
replace ydash=0 if _n==2
gen xdash1=-1.96
gen xdash2=1.96
// Fstat
gen Fx1=$F1 if _n<3
local F1: disp %4.2f $F1
local F1p: disp %4.2f $F1p
// create chart
  tw (rarea yup ylo x1 ,fcolor(gs12%33) lcolor(white)  ) ///
	(line yline x3  ,lcolor(gs4)) ///
   (scatter order tstats_ ,mcolor(black) msymbol(Oh)  msize(medsmall)) ///
   (line ydash xdash1, lpattern(dash) lwidth(medthin) lcolor(gs10)) ///
   (line ydash xdash2, lpattern(dash) lwidth(medthin) lcolor(gs10)) ///
   ,xlab(-3 "-3" -2.5 " "  -2 "-2" -1 "-1" 0 "0" 1 "1" 2 "2" ///
        2.5 " "  3 "3", noticks labsize(vsmall)) ///
		 graphregion(lcolor(white) fcolor(white)) ///
		 plotregion(lcolor(white) fcolor(white)) yscale(noline)		 ///
		 ylab( ///
		1 " "  ///
		2 " "  ///
		3 " "  ///
		4 " "  ///
		5 " "  ///
		6 " "  ///
		7 " "  ///
		8 " "  ///
		9 " "  ///
		10 " "  ///
		11 " "  ///
		12 " "  ///
		13 " "  ///
		14 " "  ///
		15 " "  ///
		16 " "  ///
		17 " "  ///
		18 " "  ///
		19 " "  ///
		20 " "  ///
		21 " "  ///
		22 " "  ///
		23 " "  ///
		24 " "  ///
		25 " "  ///
		26 " "  ///
		27 " "  ///
		28 " "  ///
		29 " "  ///
		30 " "  ///
		31 " "  ///
		32 " "  ///
		33 " "  ///
		34 " "  ///
		35 " "  ///
		36 " "  ///
		37 "  " ///
		,nogrid noticks angle(horizontal) labsize(vsmall))		///
		 legend(off) xtitle("t-stat",size(vsmall)) ///
		 title("  ") ///
		 text(38.7 0 "Without Teacher Assessment",size(small)) ///
		 text(37.4 0 "F stat: `F1' (pval=`F1p') ",size(vsmall)) ///
		 xscale(noline)  xsize(16) ysize(8) name(fig2)  
		 graph export "$df\fig_balance_math_short.png",replace width(2000)

		 // create chart
  tw (rarea yup ylo x1 if x1==-999,fcolor(gs12%33) lcolor(white)  ) ///
   ,xlab(-3 "  ", noticks labsize(vsmall)) ///
		 graphregion(lcolor(white) fcolor(white)) ///
		 plotregion(lcolor(white) fcolor(white)) yscale(noline)		 ///
		 ylab( ///
		1 "Parental income decile: 2 " ///
		2 "Parental income decile: 3 " ///
		3 "Parental income decile: 4 " ///
		4 "Parental income decile: 5 " ///
		5 "Parental income decile: 6 " ///
		6 "Parental income decile: 7 " ///
		7 "Parental income decile: 8 " ///
		8 "Parental income decile: 9 " ///
		9 "Parental income decile: 10 " ///
		10 "Parental income observed: one " ///
		11 "Parental income observed: both " ///
		12 "Mother education: compulsory " ///
		13 "Mother education: prepatory " ///
		14 "Mother education: academic high school " ///
		15 "Mother education: vocational high school " ///
		16 "Mother education: vocational training " ///
		17 "Mother education: adv. prepatory " ///
		18 "Mother education: short professional " ///
		19 "Mother education: vocational college " ///
		20 "Mother education: university (Bachelor) " ///
		21 "Mother education: university (Master) " ///
		22 "Mother education: university (PhD) " ///
		23 "Father education: compulsory " ///
		24 "Father education: prepatory " ///
		25 "Father education: academic high school " ///
		26 "Father education: vocational high school " ///
		27 "Father education: vocational training " ///
		28 "Father education: adv. prepatory " ///
		29 "Father education: short professional " ///
		30 "Father education: vocational college " ///
		31 "Father education: university (Bachelor) " ///
		32 "Father education: university (Master) " ///
		33 "Father education: university (PhD) " ///
		34 "Parental education observed: both " ///
		35 "Female" ///
		36 "Teacher Assessment (written)" ///
		37 " "  ///
		,nogrid noticks angle(horizontal) labsize(vsmall))		///
		 legend(off) xtitle(" ",size(vsmall)) ///
		 title("  ") ytitle(" ") ///
		 text(38.7 0 " ",size(small)) ///
		 text(37.4 0 " ",size(vsmall)) ///
		 xscale(noline)  xsize(16) ysize(8) name(fig0)  ///
		 plotregion(margin(0 -50 5 2 ))
		
graph combine fig0 fig2 fig1, title("    Dep var: A-Level Math Exam") cols(3) graphregion(fcolor(white)) 

gr_edit .plotregion1.graph1.xoffset = 8

gr_edit .plotregion1.graph3.xoffset = -4

gr_edit .plotregion1.graph2.yaxis1.draw_view.setstyle, style(no)

gr_edit .plotregion1.graph3.yaxis1.draw_view.setstyle, style(no)
 graph export "$df\FIGURE1.tif",replace width(4000)
  graph export "$df\FIGURE1.pdf",replace 