/*  Project: grading bias 
    File:  6_specification curve.
	Last edit: 2022-02-18 by Hans. 
*/


// load globals etc
do "D:\Data\workdata\704998\xdrev\704998\GradingBias\do_files\settings.do"
// Load data
use "$tf\estimates_sensitivity.dta",clear

keep if depvar=="o_s_math_req_10"
replace depvar="g_gpa_actual"
drop if probit==0
replace beta=.
replace ul=.
replace ll=.
append using  "$tf\estimates_sensitivity.dta",
save "$tf\estimates_sensitivityfull.dta",replace

foreach depvar in g_gpa_actual o_s_math_high_10  o_enrolled_he_y10 o_graduated_he_y10 o_s_math_req_10 {
use "$tf\estimates_sensitivityfull.dta",clear
keep if depvar=="`depvar'"
drop if fe==0
replace beta=-9999 if beta==.
sort beta
gen rank=_n
replace beta=. if beta==-9999
rename probit logit 
// Indicators 
forval i=1/10{
	gen y`i'=-0.005-(0.0025*`i')
	}
	gen main=logit==0 & gpa9==0 & exw==0 & controls==1 & fe==1 
// Chart
tw (rspike ul ll rank,lcolor(black) lwidth(medthick))  ///
   (scatter beta rank if main!=1, msymbol(O) mcolor(black) msize(large)) ///
    (rspike ul ll rank if logit==0 & gpa9==0 & exw==0 & controls==1 & fe==1  , msymbol(Sh)  lcolor(ebblue) lwidth(medthick))  ///
   (scatter beta rank if logit==0 & gpa9==0 & exw==0 & controls==1 & fe==1 ,msymbol(Oh)  mcolor(ebblue) msize(large)) ///
   (scatter y1 rank, mcolor(gs15) msize(large) msymbol(S)) ///
   (scatter y1 rank if controls==1, mcolor(black) msize(large) msymbol(S))  ///
   (scatter y2 rank, mcolor(gs15) msize(large) msymbol(S)) ///
   (scatter y2 rank if gpa9==1, mcolor(black) msize(large) msymbol(S))  ///
   (scatter y3 rank, mcolor(gs15) msize(large) msymbol(S)) ///
   (scatter y3 rank if exw==1, mcolor(black) msize(large) msymbol(S))  ///
   (scatter y4 rank, mcolor(gs15) msize(large) msymbol(S)) ///
   (scatter y4 rank if fe==1, mcolor(black) msize(large) msymbol(S))  ///
   (scatter y5 rank, mcolor(gs15) msize(large) msymbol(S)) ///
   (scatter y5 rank if logit==1, mcolor(black) msize(large) msymbol(S))  ///
    ,graphregion(lcolor(white) fcolor(white)) ///
	plotregion(lcolor(white) fcolor(white)) ///
	xscale(noline) yscale(noline) xlab( 0 " ",noticks) xtitle(" ") /// 
	ylab(0 "0.00" 0.01 "0.01" 0.02 "0.02" 0.03 "0.03" 0.035 "Coefficient ",noticks nogrid angle(horizontal)) ///
	yline(0) legend(order(2 "Point estimate" 1 "95%CI" 4 "Main specfication") size(small) symysize(small) symxsize(small) region(lcolor(white)) pos(12) rows(1))
	
 // Add labels
gr_edit yaxis1.add_ticks -0.0075 `"Parental controls"',custom tickset(major) editstyle(tickstyle(textstyle(size(small))))
gr_edit yaxis1.add_ticks -0.01   `"Control for GPA 9"',custom tickset(major) editstyle(tickstyle(textstyle(size(small))))
gr_edit yaxis1.add_ticks -0.0125 `"Control for written TA"',custom tickset(major) editstyle(tickstyle(textstyle(size(small))))
gr_edit yaxis1.add_ticks -0.015  `"Fixed effects"',custom tickset(major) editstyle(tickstyle(textstyle(size(small))))
gr_edit yaxis1.add_ticks -0.0175  `"Probit"',custom tickset(major) editstyle(tickstyle(textstyle(size(small))))
       graph export "$df\FIGUREA1_`depvar'.tif", replace width(4000)
	          graph export "$df\FIGUREA1_`depvar'.pdf", replace
}
