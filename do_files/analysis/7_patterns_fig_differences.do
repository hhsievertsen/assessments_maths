/*  Project: grading bias 
    File:  7_patterns_fig_differences
	Last edit: 2022-02-18 by Hans. 
*/
// load globals etc
do "D:\Data\workdata\704998\xdrev\704998\GradingBias\do_files\settings.do"
// empty dataset for saving estimates
clear 
gen beta=.
gen g_sub_en=""
gen g_level=.
gen up95=.
gen lo95=.
save "$tf\estimatesgender.dta",replace
// load data
* load raw data
use  "$tf\grading_data_detailed.dta",clear
// sample selection 
merge m:1 pnr using "$tf\analysisdata.dta",nogen keep(3) keepusing(pnr c_female)
// drop if exam mark is imputed
drop if g_imputed==1
gen constant=1
// Gen subject
decode g_subject,gen(sub)
gen g_sub_en=""
replace g_sub_en="Danish" if sub=="Dansk"
replace g_sub_en="English" if sub=="Engelsk"
replace g_sub_en="Mathematics" if sub=="Matematik"
replace g_sub_en="German" if sub=="Tysk"
replace g_sub_en="History" if sub=="Historie"
replace g_sub_en="Science" if sub=="Naturfag"
replace g_sub_en="Physics" if sub=="Fysik"
replace g_sub_en="Chemistry" if sub=="Kemi"
replace g_sub_en="Biology" if sub=="Biologi"
replace g_sub_en="Spanish" if sub=="Spansk"
replace g_sub_en="French" if sub=="Fransk"
replace g_sub_en="Geography" if sub=="Geografi"
replace g_sub_en="Religion" if sub=="Religion"
replace g_sub_en="Social studies" if sub=="Samfundsfag"
replace g_sub_en="Classics" if sub=="Oldtidskundskab"
keep if g_oral==1
// loop over subject
foreach sub in    Danish Classics English French Geography German History Mathematics Spanish Physics Religion Chemistry	    {
	forval level=1/3{
		// Check whether there are sufficient obs
		qui: sum g_difference if g_sub_en=="`sub'" & g_level==`level'  
		if r(N)>1000{
			reg g_difference c_female if g_sub_en=="`sub'" & g_level==`level',robust
			preserve
					use "$tf\estimatesgender.dta",clear
						local a=_N +1
						set obs `a'
						replace up95=_b[c_female]+ invt(e(df_r),0.975)*_se[c_female] if beta==.
						replace lo95=_b[c_female]- invt(e(df_r),0.975)*_se[c_female] if beta==.
						replace g_sub_en="`sub'" if  beta==.
						replace g_level=`level' if  beta==.
						replace beta=_b[c_female] if beta==.
						save "$tf\estimatesgender.dta",replace
			restore
		}
	}
}	
// Chart
use "$tf\estimatesgender.dta",clear
sort beta
gen rank=_n
// Label
gen lab=g_sub_en
replace lab=lab+" " +"A-level" if g_level==1
replace lab=lab+" " +"B-level" if g_level==2
replace lab=lab+" " +"C-level" if g_level==3
encode lab,gen(x)
labmask(rank),val(lab)
// Chart 
sort beta
tw (bar beta rank, horizontal fcolor(ebblue%70) lcolor(ebblue%70)  ) ///
	(rcap u lo95 rank, horizontal lcolor(gs8)  ) ///
 ,  ylab(1(1)24,valuelabel angle(horizontal) labsize(small) noticks nogrid) ///
 graphregion(lcolor(white) fcolor(white)) ///
 plotregion(lcolor(white) fcolor(white)) ///
 xlab(,noticks format(%4.2f) labsize(small)) xtitle("{&Delta}Mark{sub:Girls}-{&Delta}Mark{sub:Boys} ",size(small)) ///
 ytitle("") yscale(noline) legend(order(1 "Difference" 2 "95%CI") pos(12) region(lcolor(white)) size(small))
	graph export "$df\fig_differences_by_sub_difference_gender.png",replace width(2000)
	
