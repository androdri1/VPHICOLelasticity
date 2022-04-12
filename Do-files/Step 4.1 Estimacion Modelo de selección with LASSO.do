********************************************************************************
* Author: Susana Otálvaro-Ramírez
* Date: 2019.03.20
* Goal: Estimate the selection model using LASSO selected controls
********************************************************************************


if "`c(username)'"=="paul.rodriguez" {
	glo data "F:\paul.rodriguez\Dropbox\tabaco\tabacoDrive\Seguros\Data" 
	glo derived "F:\paul.rodriguez\Dropbox\tabaco\tabacoDrive\Seguros\Derived" 
}
else {
	glo data "C:\Users\\`c(username)'\Dropbox\tabacoDrive\Seguros\Data" 
	glo derived "C:\Users\\`c(username)'\Dropbox\tabacoDrive\Seguros\Derived" 
}

cd 		"$derived"

use "$derived\LASSO_selection.dta", replace

recode edad (10/19=1 "10-19")(20/29=2 "20-29")(30/39=3 "30-39")(40/49=4 "40-49")(50/110=5 "50+"), g(edad_g)
tab edad_g, g(ag_)
recode educacion (0=0 "None")(1/2=1 "Primary or less")(3=2 "Secondary")(4=3 "High School")(5=4 "Tertiary"), g(educ)

glo controls_ind "edad genero" //i.educacion
glo controls_indx "ag_1 ag_2 ag_3 ag_4 ag_5 genero"
glo controls_hou "men5 may65"

tab educ, g(ed_)
tab ocupacion, g(ocup_)
tab REGION, g(region_)
tab sector, g(sector_)
tab strata, g(strata_)
tab perceptoresI, g(percep_)
tab quintil_ciudadMed, g(quintil_)



gen 	estado_lab=1 if ocupados==1 & inactivos!=1 & desocupados!=1
replace estado_lab=2 if ocupados!=1 & inactivos==1 & desocupados!=1
replace estado_lab=3 if ocupados!=1 & inactivos!=1 & desocupados==1

tab ocupacion estado_lab , row mi
tab estado_lab , gen(estado_L) 


..
glo controls_ind2 " ed_2 ed_3 ed_4 ed_5 ocup_1 ocup_2 ocup_3 ocup_4 ocup_5 ocup_6 ocup_7"
glo controls_hou2 "strata_2 strata_3 strata_4 percep_2 percep_3 percep_4 quintil_1 quintil_2 quintil_3 quintil_4"
glo controls_reg  "region_1 region_2 region_3 region_4 region_5 region_6 sector_1"

rename numind hhsize

local pDS : list xSelh | xSeled
local pDS1 : list pDS | xSellf
local pDS2 : list pDS1 | xSeloth

save "$derived\Hogar_gasto_completo2_LASSO.dta", replace

********************************************************************************
** Comparación de modelos
********************************************************************************

keep if ocupacion!=8 & sector_1!=1 // Quitamos todo lo rural

cap recode edad_g (1 2 = 1) ( 3=2) (4=3) (5=4), gen(edad_g2)
tab edad_g2, gen(edad_g2_)

cap recode educacion1 (1 2=1) (3=2) (4=3) , gen(educacion2)
tab educacion2, gen(educ2_)


replace region_1=1 if  region_7==1 // Incluimos San Andres en la region Atlántica
drop region_7
recode REGION (7=1)

gen white_collar = ((educacion2>2 & (ocupacion!=3 | ocupacion!=6 | ocupacion!=7)) | (educacion2>1 & (ocupacion!=1 | ocupacion!=3 | ocupacion!=6 | ocupacion!=7)))

glo controls_ind "genero edad_g2_* educ2_*"
glo controls_hou "may65 strata_2 strata_3 strata_4" //
glo controls_hou2 "percep_1 percep_3 percep_4 "
glo controls_reg  "region_1  region_2 region_4 region_5 region_6 " // Base es 3: central
glo controls_reg2  "quintil_1 quintil_2 quintil_3 quintil_4" // Este es un ordenamiento de las ciudades según su quintil de gasto

** PROBIT
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
cap program drop calculoPr
program define calculoPr , eclass
	syntax [varlist(numeric)] [if] [in] [aw] , iv(varlist) price(varlist) [grupo(varname)]

	tempvar xbres2
	tempvar mills2
	cap drop _lnpPre2 
	cap drop _lnp2
	cap drop _ssp
	
	gen _ssp=lnp!=.
*qui {	
	// Paso 1: El heckman selection
	probit _ssp `iv'  `varlist'  `if' `aw'
	predict `xbres2' , xb
	gen `mills2'= normalden(-`xbres2')/(1-normal(-`xbres2'))

	reg `price' `varlist' `mills2' `if' `aw'
	predict _lnpPre2 , xb // Paso 2: La imputación del "precio" a los que no compran seguro
	label var _lnpPre2 "Imputed price of HI"
	gen _lnp2= `price'
	replace _lnp2=_lnpPre2 if _lnp2==.
	*replace _lnp2=_lnpPre2
	
*}
	// Paso 3: Efecto de la tarifa sobre la compra	
	if "`grupo'"=="" { // Si no se especifican interacciones
		logit _ssp  _lnp2  `varlist' `if' `aw', r
		*reg ssp  _lnp2  `varlist' `if' `aw', r
		margins , dydx(_lnp2 lny) 
	}
	else {  // Con interacciones por grupo
		logit _ssp  c._lnp2 c._lnp2#i.`grupo'  `varlist' `if' `aw' , r			
		margins , dydx(_lnp2 lny) 
	}		

end
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

** OLS
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
cap program drop calculoOLS
program define calculoOLS , eclass
	syntax [varlist(numeric)] [if] [in] [aw] , iv(varlist) price(varlist) [grupo(varname)]

	tempvar xbres2
	tempvar mills2
	cap drop _lnpPre2 
	cap drop _lnp2
	cap drop _ssp
	
	gen _ssp=lnp!=.
*qui {	
	// Paso 1: El heckman selection
	probit _ssp `iv'  `varlist'  `if' `aw'
	predict `xbres2' , xb
	gen `mills2'= normalden(-`xbres2')/(1-normal(-`xbres2'))

	reg `price' `varlist' `mills2' `if' `aw'
	predict _lnpPre2 , xb // Paso 2: La imputación del "precio" a los que no compran seguro
	label var _lnpPre2 "Imputed price of HI"
	gen _lnp2= `price'
	replace _lnp2=_lnpPre2 if _lnp2==.
	*replace _lnp2=_lnpPre2
	
*}
	// Paso 3: Efecto de la tarifa sobre la compra	
	if "`grupo'"=="" { // Si no se especifican interacciones
		reg _ssp  _lnp2  `varlist' `if' `aw', r
		*reg ssp  _lnp2  `varlist' `if' `aw', r
		*margins , dydx(_lnp2 lny) 
	}
	else {  // Con interacciones por grupo
		reg _ssp  c._lnp2 c._lnp2#i.`grupo'  `varlist' `if' `aw' , r			
		margins , dydx(_lnp2 lny) 
	}		

end
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



texdoc init "$dir/compare_models3.tex", force

tex \begin{table}[h]
tex \caption{\textit{Comparing models}}\label{tab:compare_models}
tex \resizebox{\textwidth}{
tex \begin{tabular}{lcccccc} \hline
tex & Prob. Lineal & Probit & cvlasso & lasso2 & lasso2(EBIC) & rlasso \\
tex & (1) & (2) & (3) & (4) & (5) & (6) \\ \hline
tex & & & & & & \\

*Linear probability
calculoOLS lny $controls_ind $controls_hou  $controls_reg  `pDS2' [aw=FEX_C] , iv(hhsize)
*outreg2 using ResultsT1.doc, keep(_lnpPre2 lny) ctitle(1) replace 
local rmse_ols : di %5.3f `e(rmse)'
predict y_ols, xb


*Probit
calculoPr lny $controls_ind $controls_hou  $controls_reg  `pDS2' [aw=FEX_C] , iv(hhsize)
*outreg2 using ResultsT1.doc, keep(_lnpPre2 lny) ctitle(2) append 

XX
estat classification 
predict phat
local rmse_prob = sqrt((prepagada - phat)^2)
local rmse_prob : di %5.3f `rmse_prob'
predict y

*Compare and selection models - Machine Learning

*Cross-validation
cvlasso prepagada `pDS2', lopt seed(123) postest
*outreg2 using "$dir\compare_models.xls", append ctitle(cvlasso) addtext(Errores Estandar, Robustos) addstat(RMSE, `e(rmse)')  dec(3)
cap drop xbhat2
cap drop resid2
predict double xbhat2, xb
predict double resid2, resid

local rmse_cv = sqrt(resid2^2)
local rmse_cv : di %5.3f `rmse_cv'


*Lasso2
lasso2 prepagada `pDS2'
lasso2, lic(aic) postresults
*outreg2 using "$dir\compare_models.xls", append ctitle(lasso2(BIC/AIC)) addtext(Errores Estandar, Cluster) addstat(RMSE, `e(rmse)')  dec(3)
local rmse_aicbic : di %5.3f `e(rmse)'
cap drop xbhat3
predict double xbhat3, xb lambda(39)

*EBIC
lasso2 prepagada `pDS2'
lasso2, lic(ebic) postresults
local rmse_ebic : di %5.3f `e(rmse)'
cap drop xbhat4
predict double xbhat4, xb lambda(39)
*outreg2 using "$dir\compare_models.xls", append ctitle(lasso2(EBIC)) addtext(Errores Estandar, Cluster) addstat(RMSE, `e(rmse)')  dec(3)

*Rigorous Lasso
rlasso prepagada `pDS2', cluster(cod_upz)
*outreg2 using "$dir\compare_models.xls", append ctitle(rlasso) addtext(Errores Estandar, Cluster) addstat(RMSE, `e(rmse)')  dec(3)
local rmse_rlasso : di %5.3f `e(rmse)'
cap drop xbhat5
predict double xbhat5, xb

tex RMSE &  `rmse_ols' & `rmse_prob' & `rmse_cv' & `rmse_aicbic' & `rmse_ebic' & `rmse_rlasso' \\
tex & & & & & & \\ \hline

tex \end{tabular}
tex }
tex \end{table}

global pred y_ols y xbhat2 xbhat3 xbhat4 xbhat5

foreach x in $pred{
	graph twoway (histogram `x') (kdensity `x'), title(`x') legend(off) name(g`x', replace) nodraw
}
graph combine gy_ols gy gxbhat2 gxbhat3 gxbhat4 gxbhat5, col(2) xcommon

save "$dir\Data\geo_colmedica_final.dta", replace
