/*  Project: grading bias 
    File:  04_child_covariates.do - clean and setup grading data
	Last edit: 2022-02-19 by hhs
*/
// load globals etc
do "D:\Data\workdata\704998\xdrev\704998\GradingBias\do_files\settings.do"
// loop over calendar years (variables are fixed over time, by assumption)
forval i=2003/2015{
		use "$rf\grundvive`i'.dta", clear
		cap rename FOED_DAG c_dateofbirth
		cap rename foed_dag c_dateofbirth
		cap rename mor_id MOR_ID
		cap rename far_id FAR_ID
		keep pnr  IE_TYPE koen c_dateofbirth FAR_ID MOR_ID OPR_LAND
		* define
		gen byte c_female=koen==2				/* Gender*/
		rename FAR_ID c_father_id				/* Father id */
		rename MOR_ID c_mother_id				/* Mother id */
		rename OPR_LAND c_country_of_origin_dst
		rename IE_TYPE c_immigrationstatus
		* keep
		keep pnr   c_fem* c_dateofbirth c_father_id c_mother_id c_country_of_origin_dst c_immigrationstatus
		save "$tf\childdata`i'.dta",replace
	}
// append and save
clear
forval i=2003/2008{
		append using "$tf\childdata`i'.dta"
	}
// Keep one obs per child  (assuming all variables are constant over time)
bys pnr: keep if _n==1
compress
save "$tf\childdata.dta",replace

