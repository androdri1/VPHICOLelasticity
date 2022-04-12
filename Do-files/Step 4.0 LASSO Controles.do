* Author: Susana Otálvaro-Ramírez
* Date: 2019.03.20
* Goal: Select Controls by LASSO
set more off

clear all 
set maxvar 20000 
set matsize 11000 

if "`c(username)'"=="paul.rodriguez" {
	glo data "F:\paul.rodriguez\Dropbox\tabaco\tabacoDrive\Seguros\Data" 
	glo derived "F:\paul.rodriguez\Dropbox\tabaco\tabacoDrive\Seguros\Derived" 
}
else {
	glo data "C:\Users\\`c(username)'\Dropbox\tabacoDrive\Seguros\Data" 
	glo derived "C:\Users\\`c(username)'\Dropbox\tabacoDrive\Seguros\Derived" 
}

cd 		"$derived"


use "$derived\Hogar_gasto_completo1.dta", clear

*HOUSING
*Dummys
global dummysh P6080_1 P6080_2 P6080_3 P6080_4 P6080_5 P6080_6 ///
P6081_1 P6081_2 P6081_3 P6083_1 P6083_2 P6083_3 ///
P5747_1 P5747_2 P5747_3 P5747_4 P5747_5 P5747_6 ///
P448_1 P448_2 P448_3 P448_4 P448_5 P448_6 P448_7 P448_8 P448_9 ///
P811_1 P811_2 P811_3 P811_4 P811_5 P811_6 P811_7 ///
P8520S4A1_1 P8520S4A1_2 P8520S4A1_3 P8520S4A1_4 ///
P8520S4A1_5 P8520S4A1_6 P8520S4A1_7 P8520S4A1_8 P8520S4A1_9 ///
P1647_1 P1647_2 P1647_3 P1647_4 P1647_5 P1647_6 P1647_7 ///
P1647_8 P1647_9 P1647_10 P1647_11 P1647_12 P1647_13 P1647_14 ///
P1647_15 P1647_16 P1647_17 P1647_18 P1647_19 P1647_20 P1647_21 ///
P1647_22 P1647_23 P5010_1 P5010_2 P5010_3 P5010_4 P5010_5 P5010_6 ///
P5010_7 P5010_8 P5010_9 P5010_10 P5010_11 P5010_12 P814_1 P814_2 ///
P814_3 P814_4 P814_5 P814_6 P449_1 P449_2 P449_3 P449_4 P449_5 ///
P5050_1 P5050_2 P5050_3 P5050_4 P5050_5 P5050_6 P5050_7 P5050_8 ///
P5050_9 P5050_10 P5070_1 P5070_2 P5070_3 P5070_4 P5070_5 P5070_6 ///
P5080_1 P5080_2 P5080_3 P5080_4 P5080_5 P5080_6 P5080_7 ///
P5090_1 P5090_2 P5090_3 P5090_4 P5090_5 P5090_6 P5240_1 P5240_2 ///
P5240_3 P1646S28A1_1 P1646S28A1_2 P1646S28A1_3 P1646S28A1_4 ///
P1646S28A1_5 P1646S28A1_6 P1646S28A1_7 P1646S28A1_8 P1646S28A1_9 ///
P1646S28A1_10 P1646S29A1_1 P1646S29A1_2 P1646S29A1_3 P1646S29A1_4 ///
P1646S29A1_5 P1646S29A1_6 P1646S29A1_7 P5170 P5180 P6060 P6071 P6160 ///
P6170 P8520S1 P8520S2 P8520S3 P8520S4 P8520S5 P4040 P5160 P5161S1 ///
P5161S1A1 P5161S1A3 P5161S2 P5161S2A1 P5161S2A3 P917 P5102 P5105 ///
P5230 P1646S1 P1646S2 P1646S3 P1646S4 P1646S5 P1646S6 P1646S7 ///
NC2R_CC_P6 P1646S8 P1646S9 P1646S10 P1646S11 P1646S12 P1646S13 ///
P1646S14 P1646S15 P1646S16 P1646S17 NC2R_CC_P5 P1646S18 P1646S19 ///
P1646S20 P1646S21 P1646S22 P1646S23 P1646S24 P1646S25 P1646S26 ///
P1646S27 P1646S28 P1646S29 P1646S30 
 
*    
foreach i in $dummysh{
	quietly gen dhousing_`i'= (`i'==1)
}

global new_dummysh dhousing_*

*Continous variables 

global continuh P1645 P5110 P5140 P5250 P5161S1A2 P5161S2A2 

drop $dummysh

* EDUCATION
*Dummys
global dummysed P6175 P6180 P8610 P8612 P1664 P6236_1 P6236_2 ///
P6236_3 P6236_4 P6236_5 P6236_6 P6236_7 P6236_8 P6236_9 ///
P6236_10 P6236_11 P6236_12 P6236_13 P6236_14 P6236_15 P6236_16 ///
P6236_17 P6236_18 P6236_19 P6236_20 P6236_21 P6236_22 P6236_23


foreach i in $dummysed{
	quietly gen deducat_`i'= (`i'==1)
}
global new_dummyshe deducat_*
drop $dummysed

*LABOR FORCE
*Dummys
global dummyslf P1652S1 P1652S2 P1651 P7040 P7310 P6990 P9450 ///
P7514 P7516 P6765_1 P6765_2 P6765_3 P6765_4 P6765_5 P6765_6 ///
P6765_7 P6765_8 P549_1 P549_2 P549_3 P549_4 P6830_1 P6830_2 ///
P6830_3 P6830_4 P6830_5 P6830_6 P6830_7 P6871_1 P6871_2 P6871_3 ///
P6871_4 P6871_5 P6880_1 P6880_2 P6880_3 P6880_4 P6880_5 P6880_6 ///
P6880_7 P6880_8 P6880_9 P6880_10 P6880_11 P9450S2_2 P9450S2_1 
     

foreach i in $dummyslf{
	quietly gen dlabor_`i'= (`i'==1)
}
global new_dummyslf dlabor_*

*Continue variables

global contnulf P6426 P6790 P6800 P6850 P7045 
drop $dummyslf

* OTHERS
* Categorical 
foreach var in personas_hogarS estrato ocupacion{
	qui tab `var', g(`var'_)
}
*

* Dummies 
glo dummyoth personas_hogarS_1 personas_hogarS_2 personas_hogarS_3 ///
personas_hogarS_4 estrato_1 estrato_2 estrato_3 estrato_4 estrato_5 ///
estrato_6 estrato_7 sector contratoJ contratoQ pensionJ pensionQ ///
genero ocupados ocupacion_1 ocupacion_2 ocupacion_3 ocupacion_4 ///
ocupacion_5 ocupacion_6 ocupacion_7 ocupacion_8 ///
afili1_hogar afiliT_hogar contr_hogar subsi_hogar contr1_hogar ///
contrT_hogar subsi1_hogar subsiT_hogar infor1_hogar ///
inforJ_hogar inforT_hogar educ_none educ_pree educ_prim educ_secu ///
educ_medi educ_supe 


foreach i in $dummyoth{
	quietly gen dother_`i'= (`i'==1)
}
global new_dummysoth dother_*

* Continuous
glo contnuoth edad n_afiliacion infor_hogar qpago_salud vpago_salud vTpago_salud ///
numnin numadu men5 may65 hheq perceptores


*Selection Controls housing
lassoShooting ssp $new_dummysh $continuh, lasiter(100) verbose(0) fdisplay(0)
local xSelh `r(selected)'
di "`xSelh'"
********************************************************************************


*Selection Controls education
lassoShooting ssp $new_dummysed, lasiter(100) verbose(0) fdisplay(0)
local xSeled `r(selected)'
di "`xSeled'"

*Selection Controls labor force
lassoShooting ssp $new_dummyslf $continulf, lasiter(100) verbose(0) fdisplay(0) 
local xSellf `r(selected)'
di "`xSellf'"

*Selection Controls add_vars
lassoShooting ssp $new_dummysoth $contnuoth, lasiter(100) verbose(0) fdisplay(0) 
local xSeloth `r(selected)'
di "`xSeloth'"

local pDS : list xSelh | xSeled
local pDS1 : list pDS | xSellf
local pDS2 : list pDS1 | xSeloth

save "$derived\LASSO_selection.dta", replace
