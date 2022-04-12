* Author: Susana Otálvaro-Ramírez, Paul Rodriguez-Lesmes, Sofia Casabianca
* Date: 2019.02.01
* Goal: Estimate the selection model 


if "`c(username)'"=="paul.rodriguez" {
	glo data "D:\Paul.Rodriguez\Dropbox\Salud Colombia\Seguros\Data" 
	glo derived "$data\..\Derived" 
} 
else if "`c(username)'"=="andro" {
	glo data "C:\Users\\`c(username)'\Dropbox\tabaco\tabacoDrive\Seguros\Data" 
	glo derived "C:\Users\\`c(username)'\Dropbox\tabaco\tabacoDrive\Derived" 
}
else if "`c(username)'"=="msofi" {
	glo data "C:\Users\msofi\Dropbox\Seguros\Derived" 
	glo derived "C:\Users\msofi\Dropbox\Seguros\Derived" 
}

else {
	glo data "C:\Users\\`c(username)'\Dropbox\tabacoDrive\ENPH\Data" 
	glo derived "C:\Users\\`c(username)'\Dropbox\tabacoDrive\Seguros\Derived" 
}

if 1==0 {
	cd 		"$derived"
	use "$derived\Hogar_gasto_completo1.dta", clear

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


	cap recode edad_g (1 2 = 1) ( 3=2) (4=3) (5=4), gen(edad_g2)
	tab edad_g2, gen(edad_g2_)

	cap recode educacion1 (1 2=1) (3=2) (4=3) , gen(educacion2)
	tab educacion2, gen(educ2_)


	replace region_1=1 if  region_7==1 // Incluimos San Andres en la region Atlántica
	drop region_7
	recode REGION (7=1)

	gen white_collar = ((educacion2>2 & (ocupacion!=3 | ocupacion!=6 | ocupacion!=7)) | (educacion2>1 & (ocupacion!=1 | ocupacion!=3 | ocupacion!=6 | ocupacion!=7)))


	rename numind hhsize
	
	* No está siendo utilizado; no sabemos realmente cuál es la demanda a nivel 
	* individual así que puede ser confuso .................................
	cap drop lnp_pc
	gen 	lnp_pc 	= g_diversos530101/hhsize if g_diversos530101!=. & hhsize!=. 
	replace lnp_pc 	= ln(lnp_pc)
	

	//hheq = max{1 + (0.5*(numadu-1)) + (0.3*numnin)
	*gen persingr = ingresos/hheq
	*label var persingr "Ingreso por persona equivalente"
	*drop lny
	*gen lny=ln(persingr)	
	* .....................................................................
	

	save "$derived\Hogar_gasto_completo2.dta", replace
}

********************************************************************************
** VERSION
********************************************************************************
use "$derived\Hogar_gasto_completo2.dta", clear

label var genero "Male-Head of Household (HH)"
label var edad_g2_1 "HH age: Less than 30 y/o"
label var edad_g2_2 "HH age: 30 to 39 y/o"
label var edad_g2_3 "HH age: 40 to 49 y/o"
label var edad_g2_4 "HH age: 50 y/o or more"
label var educ2_1 "HH Education: Less high school"
label var educ2_2 "HH Education: High school"
label var educ2_3 "HH Education: Tertiary education" //Comentar el término correcto con Pamela y Paul
label var may65 "At least one member over 65 y/o"
label var strata_2 "Low income" //"Estrato 2"
label var strata_3 "Middle income" //"Estrato 3"
label var strata_4 "Middle-to-High income" //"Estrato 4,5 o 6"
lab var lny "Log ingreso del hogar pp eq."
label var estado_L1 "HH is in the work force"
gen ocupOt= !(ocup_1==1 | ocup_2==1 | ocup_5==1) if ocup_5!=.
label var ocupOt "ocupacion==Otra"


keep if ocupacion!=8 & sector_1!=1 // Quitamos todo lo rural

glo controls_ind "genero edad_g2_* educ2_*"
glo controls_hou "may65 strata_2 strata_3 strata_4" //
*glo controls_hou2 "percep_1 percep_3 percep_4 "
glo controls_reg  "region_1  region_2 region_4 region_5 region_6 " // Base es 3: central
*glo controls_reg2  "quintil_1 quintil_2 quintil_3 quintil_4" // Este es un ordenamiento de las ciudades según su quintil de gasto



********************************************************************************
** Grafico gasto en primas 
gen expp=exp(lnp)

gen expprely = expp/y

gen exppc = expp/hhsize

gen sspX = expp>=90000 if expp!=.

label def hhsize2 1 "1" 2 "2" 3 "3" 4 "4" 5 "5+"
label val hhsize hhsize2


tw (kdensity exppc if hhsize==1) (kdensity exppc if hhsize==2) (kdensity exppc if hhsize==3) (kdensity exppc if hhsize==4) (kdensity exppc if hhsize==5) if expp>90000 ///
	, legend(order(1 "1 member" 2 "2 members" 3 "3 members" 4 "members" 5 "5 or more members"  )) xtitle(Expenditure in VPHI per HH memeber) ytitle(Density)


tw (kdensity expp if hhsize==1) (kdensity expp if hhsize==2) (kdensity expp if hhsize==3) (kdensity expp if hhsize==4) (kdensity expp if hhsize==5) if expp>90000 ///
	, legend(order(1 "1 member" 2 "2 members" 3 "3 members" 4 "members" 5 "5 or more members"  )) xtitle(Expenditure in VPHI) ytitle(Density)

scatter expprely hhsize
graph box expprely if expp>90000 , over(hhsize) ytitle("Expenditure on VPHI's premium as a proportion of HH income")

graph bar (mean) sspX, over(hhsize) ytitle("Affiliate to a VPHI")

* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
* Este programa realiza el Heckman y luego la estiamción de los parámetros 
* estructurales de la ecuación 1
cap program drop calculoE
program define calculoE , eclass
	syntax [varlist(numeric)] [if] [aw] , iv(varname) price(varname) [grupo(varname) bst(integer 0) ]

	tempvar touse
	mark `touse' `if'
	marksample touse // Temporal variable with the sample
	markout `touse' `iv' `varlist'   // Remove from the sample the missings in the main variables 
			
	tempvar xbres2
	tempvar mills2
	tempname beta 
	tempname cov
	
	cap drop _lnpPre2 
	cap drop _lnp2
	cap drop _ssp
	
	gen _ssp = `price'!=.

	// Paso 1: El heckman selection
	probit _ssp `iv'  `varlist'  if `touse'  `aw' ,  iterate(1000)	
	predict `xbres2' , xb
	gen `mills2'= normalden(-`xbres2')/(1-normal(-`xbres2'))

	reg `price' `varlist' `mills2' if `touse' `aw'
	predict _lnp2 , xb // Paso 2: La imputación del "precio" a los que no compran seguro
	label var _lnp2 "Log del gasto en primas" // Este es el estándar de una estimación estructural, es como un 2SLS
	
	// Paso 3: Efecto de la tarifa sobre la compra	
	if "`grupo'"=="" { // Si no se especifican interacciones
		probit _ssp  _lnp2  `varlist' if `touse' `aw', r iterate(1000)	
		margins , dydx(_lnp2 lny) post
	}
	else {  // Con interacciones por grupo
		//probit _ssp c._lnp2 c._lnp2#i.`grupo'  `varlist' if `touse' `aw' , r iterate(1000)	
		//margins , dydx(_lnp2 lny) post by(`grupo')
	
		probit _ssp c._lnp2#i.`grupo'  `varlist' if `touse' `aw' , r iterate(1000)	
		margins , dydx(_lnp2 lny) post by(`grupo') 

	}		

	if `bst'==1 {
		loc nobs = e(N)
		mat `beta' = e(b)
		mat `cov' = e(V)
		*mat colnames `beta' = "`iv'" "`_lnpPre'" "`y'" 	
		ereturn post `beta' `cov', dep("_ssp") obs(`nobs') esample(`touse') 	

	}

end
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

** RESULTADO PRINCIPAL, no importan los pesos de la encuesta
cap drop lnp2
gen lnp2 = lnp if g_diversos530101>	90000 // Limitar la muestra a los gastos mayores 90000 COP
calculoE lny $controls_ind $controls_hou $controls_reg  [aw=FEX_C] , iv(hhsize) price(lnp2) bst(0)
calculoE lny $controls_ind $controls_hou $controls_reg             , iv(hhsize) price(lnp2) bst(0)
bs , reps(200) seed(123): calculoE lny $controls_ind $controls_hou $controls_reg  , iv(hhsize) price(lnp2) bst(1)


** TABLA RESULTADOS PRINCIPALES
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

matrix limitLow=[0,90000, 120000]

cd "$derived\tables"
log using mylog, text replace
forval kk=1(1)3 {
	cap drop lnp2
	gen lnp2 = lnp if g_diversos530101>	limitLow[1,`kk']

	est drop _all
	* Modelo 1: Jefes trabajadores y no trabajadores (N=48601)
	calculoE lny $controls_ind $controls_hou $controls_reg  , iv(hhsize) price(lnp2) bst(0)
		qui sum _ssp  if e(sample)==1
		local mean = r(mean)
		estadd scalar spp = r(mean)	
		lincom _lnp2/`mean'
		estadd scalar Price_Elasticity = r(estimate)
		estadd scalar Price_Elasticity_p = r(p)
		lincom lny/`mean'
		estadd scalar Income_Elasticity = r(estimate)
		estadd scalar Income_Elasticity_p = r(p)	
		
		est sto m1
		
	* Modelo 2: Jefes trabajadores (N=31592) 
	calculoE lny $controls_ind $controls_hou $controls_reg ocup_1 ocup_2 ocup_5  , iv(hhsize) price(lnp2)  bst(0)
		qui sum _ssp  if e(sample)==1
		local mean = r(mean)
		estadd scalar spp = r(mean)	
		lincom _lnp2/`mean'
		estadd scalar Price_Elasticity = r(estimate)
		estadd scalar Price_Elasticity_p = r(p)
		lincom lny/`mean'
		estadd scalar Income_Elasticity = r(estimate)
		estadd scalar Income_Elasticity_p = r(p)
		
		est sto m2

	* Modelo 3: Jefes trabajadores no informales, con alguien en el régimen contributivo (N=14384) 
	calculoE lny $controls_ind $controls_hou $controls_reg ocup_1 ocup_2 ocup_5   if inforJ_hogar==0 & estado_lab==1 & contr1_hogar==1  , iv(hhsize) price(lnp2) bst(0) 
		qui sum _ssp  if e(sample)==1
		local mean = r(mean)
		estadd scalar spp = r(mean)	
		lincom _lnp2/`mean'
		estadd scalar Price_Elasticity = r(estimate)
		estadd scalar Price_Elasticity_p = r(p)
		lincom lny/`mean'
		estadd scalar Income_Elasticity = r(estimate)
		estadd scalar Income_Elasticity_p = r(p)		
			
		est sto m3
		
	* Modelo 4: Jefes trabajadores y no trabajadores, estrato 3 en adelante (N=8320) 
	calculoE lny $controls_ind $controls_hou $controls_reg ocup_1 ocup_2 ocup_5   if estrato>=3 , iv(hhsize) price(lnp2) bst(0)
		qui sum _ssp  if e(sample)==1
		local mean = r(mean)
		estadd scalar spp = r(mean)	
		lincom _lnp2/`mean'
		estadd scalar Price_Elasticity = r(estimate)
		estadd scalar Price_Elasticity_p = r(p)	
		lincom lny/`mean'
		estadd scalar Income_Elasticity = r(estimate)
		estadd scalar Income_Elasticity_p = r(p)
		
		est sto m4	
		
	disp in red "Limite con " as result  limitLow[1,2]
	esttab m1 m2 m3 m4                          , scalars("N Observaciones" "spp Participación" "Price_Elasticity" "Price_Elasticity_p" "Income_Elasticity" "Income_Elasticity_p") star(* .1 ** .05 *** 0.001) se
	esttab m1 m2 m3 m4 using "elasticitiesC`kk'", scalars("N Observaciones" "spp Participación" "Price_Elasticity" "Price_Elasticity_p" "Income_Elasticity" "Income_Elasticity_p") star(* .1 ** .05 *** 0.001) se booktabs fragment nolines label nonumbers replace  
}
log close		

* BS version ................................
cap log close
log using BSversion , replace  text

cap drop lnp2
gen lnp2 = lnp if g_diversos530101>	90000
bs , reps(1000) seed(123): calculoE lny $controls_ind $controls_hou $controls_reg  , iv(hhsize) price(lnp2) bst(1)
bs , reps(1000) seed(123): calculoE lny $controls_ind $controls_hou $controls_reg ocup_1 ocup_2 ocup_5  , iv(hhsize) price(lnp2)  bst(1)
bs , reps(1000) seed(123): calculoE lny $controls_ind $controls_hou $controls_reg ocup_1 ocup_2 ocup_5   if inforJ_hogar==0 & estado_lab==1 & contr1_hogar==1  , iv(hhsize) price(lnp2) bst(1)
bs , reps(1000) seed(123): calculoE lny $controls_ind $controls_hou $controls_reg ocup_1 ocup_2 ocup_5   if estrato>=3 , iv(hhsize) price(lnp2) bst(1)
log close
		
	
** TABLA DESCRIPTIVA
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

gen inc1000=ingresos/1000
label var inc1000 "Ingresos del hogar (miles COP)"
gen prima1000=g_diversos530101/1000
label var prima1000 "Gasto en primas (miles COP)"

histogram prima1000, scheme(plotplain) xline(90) percent ytitle(Porcentaje observaciones)

cd "$derived\tables"
eststo clear
 
estpost sum inc1000 prima1000 $controls_ind $controls_hou $controls_reg estado_L1 contr1_hogar inforJ_hogar ocup_1 ocup_2 ocup_5 ocupOt if g_diversos530101==.
est store a
estpost sum inc1000 prima1000 $controls_ind $controls_hou $controls_reg estado_L1 contr1_hogar inforJ_hogar ocup_1 ocup_2 ocup_5 ocupOt if g_diversos530101>0 & g_diversos530101!=.
est store b
estpost sum inc1000 prima1000 $controls_ind $controls_hou $controls_reg estado_L1 contr1_hogar inforJ_hogar ocup_1 ocup_2 ocup_5 ocupOt if g_diversos530101>90000 & g_diversos530101!=.
est store c
 
esttab a b c using desc.tex, replace ///
	mtitles("\textbf{\emph{No participante}}" "\textbf{\emph{Participante}}" "\textbf{\emph{Participante 90k}}") ///
	collabels(\multicolumn{1}{c}{{Mean}} \multicolumn{1}{c}{{Std.Dev.}} ) ///
	cells("mean(fmt(2)) sd(fmt(2))") label nonumber f noobs alignment(S) booktabs //  count(fmt(0))
			
			
texdoc init desc , append force
tex \cmidrule(l){2-3} \cmidrule(l){4-5} \cmidrule(l){6-7}
tex Número de observaciones
foreach caso in a b c {
	est restore `caso'
	loc ene=e(N) 
	tex & \multicolumn{2}{c}{`ene'}
}
tex \\
texdoc close
		
** EJERCICIOS DE HETEROGENEIDAD
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/* De acuerdo con el modelo de la sección de Resultados Principales (Limitado a 
   gastos mayores de 90000 COP) con Jefes de hogar no informales, se realizan 
   los ejercicios.

	* Modelo 3: Jefes trabajadores no informales, con alguien en el régimen contributivo (N=14384) 
	calculoE lny $controls_ind $controls_hou $controls_reg ocup_1 ocup_2 ocup_5   if inforJ_hogar==0 & estado_lab==1 & contr1_hogar==1  , iv(hhsize) price(lnp2) bst(0)
		qui sum _ssp  if e(sample)==1
		estadd scalar spp = r(mean)
		est sto m3
 */
 
** Creación o Reodificación a Dummies de Variables para el ejercicio

cap drop lnp2
	gen lnp2 = lnp if g_diversos530101>90000
	
recode may65_a (0=1 "None")(1/2=2 "At least one"), g(may65_b)
label var may65_b "At least one member over 65 y/o"

recode men5_a (0=1 "None")(1/2=2 "At least one"), g(men5_b)
label var men5_b "At least one child under 5 y/o"
**FALTA

* Modelo 3: Jefes trabajadores no informales, con alguien en el régimen contributivo (N=14384) 
calculoE lny $controls_ind $controls_hou $controls_reg ocup_1 ocup_2 ocup_5   if inforJ_hogar==0 & estado_lab==1 & contr1_hogar==1  , iv(hhsize) price(lnp2) bst(0) grupo(edad_g2)
qui sum _ssp  if e(sample)==1 & edad_g2 == 1
local mean_1 = r(mean)
	estadd scalar mean_1 = `mean_1'
	
qui sum _ssp  if e(sample)==1 & edad_g2 == 2
local mean_2 = r(mean)
	estadd scalar mean_2 = `mean_2'
qui sum _ssp  if e(sample)==1 & edad_g2 == 3
local mean_3 = r(mean)
	estadd scalar mean_3 = `mean_3'
qui sum _ssp  if e(sample)==1 & edad_g2 == 4
local mean_4 = r(mean)
	estadd scalar mean_4 = `mean_4'



lincom [_lnp2]1.edad_g2/`mean_1' - [_lnp2]2.edad_g2/`mean_2'
	estadd scalar d1 = r(p)
lincom [_lnp2]1.edad_g2/`mean_1' - [_lnp2]3.edad_g2/`mean_3'
	estadd scalar d2 = r(p)
lincom [_lnp2]1.edad_g2/`mean_1' - [_lnp2]4.edad_g2/`mean_4'
	estadd scalar d3 = r(p)
lincom [lny]1.edad_g2/`mean_1' - [lny]2.edad_g2/`mean_2'
	estadd scalar d4 = r(p)
lincom [lny]1.edad_g2/`mean_1' - [lny]3.edad_g2/`mean_3'
	estadd scalar d5 = r(p)
lincom [lny]1.edad_g2/`mean_1' - [lny]4.edad_g2/`mean_4'
	estadd scalar d6 = r(p)
		
lincom [_lnp2]1.edad_g2/`mean_1'
	estadd scalar Price_Elasticity_1 = r(estimate)
	estadd scalar Price_Elasticity_1_se = r(se)
lincom [_lnp2]2.edad_g2/`mean_2'
	estadd scalar Price_Elasticity_2 = r(estimate)
	estadd scalar Price_Elasticity_2_se = r(se)
lincom [_lnp2]3.edad_g2/`mean_3'
	estadd scalar Price_Elasticity_3 = r(estimate)
	estadd scalar Price_Elasticity_3_se = r(se)
lincom [_lnp2]4.edad_g2/`mean_4'
	estadd scalar Price_Elasticity_4 = r(estimate)
	estadd scalar Price_Elasticity_4_se = r(se)

lincom [lny]1.edad_g2/`mean_1'
	estadd scalar Income_Elasticity_1 = r(estimate)
	estadd scalar Income_Elasticity_1_se = r(se)
lincom [lny]2.edad_g2/`mean_2'
	estadd scalar Income_Elasticity_2 = r(estimate)
	estadd scalar Income_Elasticity_2_se = r(se)
lincom [lny]3.edad_g2/`mean_3'
	estadd scalar Income_Elasticity_3 = r(estimate)
	estadd scalar Income_Elasticity_3_se = r(se)
lincom [lny]4.edad_g2/`mean_4'
	estadd scalar Income_Elasticity_4 = r(estimate)
	estadd scalar Income_Elasticity_4_se = r(se)	
	
	
	est sto m3_1
	
calculoE lny $controls_ind $controls_hou $controls_reg ocup_1 ocup_2 ocup_5   if inforJ_hogar==0 & estado_lab==1 & contr1_hogar==1  , iv(hhsize) price(lnp2) bst(0) grupo(may65_b)
qui sum _ssp  if e(sample)==1 & may65_b == 1
local mean_1 = r(mean)
	estadd scalar mean_1 = `mean_1'
qui sum _ssp  if e(sample)==1 & may65_b == 2
local mean_2 = r(mean)
	estadd scalar mean_2 = `mean_2'

lincom [_lnp2]1.may65_b/`mean_1' - [_lnp2]2.may65_b/`mean_2'
	estadd scalar d7 = r(p)
lincom [lny]1.may65_b/`mean_1' - [lny]2.may65_b/`mean_2'
	estadd scalar d8 = r(p)
	
lincom [_lnp2]1.may65_b/`mean_1'
	estadd scalar Price_Elasticity_1 = r(estimate)
	estadd scalar Price_Elasticity_1_se = r(se)
lincom [_lnp2]2.may65_b/`mean_2'
	estadd scalar Price_Elasticity_2 = r(estimate)
	estadd scalar Price_Elasticity_2_se = r(se)

lincom [lny]1.may65_b/`mean_1'
	estadd scalar Income_Elasticity_1 = r(estimate)
	estadd scalar Income_Elasticity_1_se = r(se)
lincom [lny]2.may65_b/`mean_2'
	estadd scalar Income_Elasticity_2 = r(estimate)
	estadd scalar Income_Elasticity_2_se = r(se)

	est sto m3_5
	
calculoE lny $controls_ind $controls_hou $controls_reg ocup_1 ocup_2 ocup_5   if inforJ_hogar==0 & estado_lab==1 & contr1_hogar==1  , iv(hhsize) price(lnp2) bst(0) grupo(men5_b)
qui sum _ssp  if e(sample)==1 & men5_b == 1
local mean_1 = r(mean)
	estadd scalar mean_1 = `mean_1'
qui sum _ssp  if e(sample)==1 & men5_b == 2
local mean_2 = r(mean)
	estadd scalar mean_2 = `mean_2'

lincom [_lnp2]1.men5_b/`mean_1' - [_lnp2]2.men5_b/`mean_2'
	estadd scalar d9 = r(p)
lincom [lny]1.men5_b/`mean_1' - [lny]2.men5_b/`mean_2'
	estadd scalar d10 = r(p)
	
lincom [_lnp2]1.men5_b/`mean_1'
	estadd scalar Price_Elasticity_1 = r(estimate)
	estadd scalar Price_Elasticity_1_se = r(se)
lincom [_lnp2]2.men5_b/`mean_2'
	estadd scalar Price_Elasticity_2 = r(estimate)
	estadd scalar Price_Elasticity_2_se = r(se)

lincom [lny]1.men5_b/`mean_1'
	estadd scalar Income_Elasticity_1 = r(estimate)
	estadd scalar Income_Elasticity_1_se = r(se)
lincom [lny]2.men5_b/`mean_2'
	estadd scalar Income_Elasticity_2 = r(estimate)
	estadd scalar Income_Elasticity_2_se = r(se)
	
	est sto m3_6

	
disp in red "Limite con " as result  limitLow[1,2]
	esttab  m3_1 m3_5 m3_6                          , scalars("N Observaciones" "d1 Tests Ln(p) 1-2" "d2 Tests Ln(p) 1-3" "d3 Tests Ln(p) 1-4" "d4 Tests Ln(y) 1-2" "d5 Tests Ln(y) 1-3" "d6 Tests Ln(y) 1-4" "d7 Test Ln(p) Over 65" "d8 Test Ln(y) Over 65" "d9 Test Ln(p) Under 5" "d10 Test Ln(y) Under 5" "Price_Elasticity_1 Price Elasticity 1"  "Price_Elasticity_1_se Price Elasticity 1 se " "Price_Elasticity_2 Price Elasticity 2" "Price_Elasticity_2_se Price Elasticity 2 se" "Price_Elasticity_3 Price Elasticity 3"  "Price_Elasticity_3_se Price Elasticity 3 se" "Price_Elasticity_4 Price Elasticity 4" "Price_Elasticity_4_se Price Elasticity 4 se" "Income_Elasticity_1 Income Elasticity 1" "Income_Elasticity_1_se Income Elasticity 1 se" "Income_Elasticity_2 Income Elasticity 2" "Income_Elasticity_2_se Income Elasticity 2 se" "Income_Elasticity_3 Income Elasticity 3" "Income_Elasticity_3_se Income Elasticity 3 se" "Income_Elasticity_4 Income Elasticity 4" "Income_Elasticity_4_se Income Elasticity 4 se" "mean_1 Mean group 1" "mean_2 Mean group 2" "mean_3 Mean group 3" "mean_4 Mean group 4" ) star(* .1 ** .05 *** 0.001) se
	esttab m3_1 m3_5 m3_6 using "elasticities_interactions", scalars("N Observaciones" "d1 Tests Ln(p) 1-2" "d2 Tests Ln(p) 1-3" "d3 Tests Ln(p) 1-4" "d4 Tests Ln(y) 1-2" "d5 Tests Ln(y) 1-3" "d6 Tests Ln(y) 1-4" "d7 Test Ln(p) Over 65" "d8 Test Ln(y) Over 65" "d9 Test Ln(p) Under 5" "d10 Test Ln(y) Under 5" "Price_Elasticity_1 Price Elasticity 1"  "Price_Elasticity_1_se Price Elasticity 1 se " "Price_Elasticity_2 Price Elasticity 2" "Price_Elasticity_2_se Price Elasticity 2 se" "Price_Elasticity_3 Price Elasticity 3"  "Price_Elasticity_3_se Price Elasticity 3 se" "Price_Elasticity_4 Price Elasticity 4" "Price_Elasticity_4_se Price Elasticity 4 se" "Income_Elasticity_1 Income Elasticity 1" "Income_Elasticity_1_se Income Elasticity 1 se" "Income_Elasticity_2 Income Elasticity 2" "Income_Elasticity_2_se Income Elasticity 2 se" "Income_Elasticity_3 Income Elasticity 3" "Income_Elasticity_3_se Income Elasticity 3 se" "Income_Elasticity_4 Income Elasticity 4" "Income_Elasticity_4_se Income Elasticity 4 se" "mean_1 Mean group 1" "mean_2 Mean group 2" "mean_3 Mean group 3" "mean_4 Mean group 4" ) star(* .1 ** .05 *** 0.001) se booktabs fragment nolines label nonumbers replace
	
tabstat g_diversos530101  if inforJ_hogar==0 & estado_lab==1 & contr1_hogar==1 & g_diversos530101 > 90000, by(edad_g2) stat(mean) c(s)
tabstat g_diversos530101  if inforJ_hogar==0 & estado_lab==1 & contr1_hogar==1 & g_diversos530101 > 90000, by(may65_b) stat(mean) c(s)
tabstat g_diversos530101  if inforJ_hogar==0 & estado_lab==1 & contr1_hogar==1 & g_diversos530101 > 90000, by(men5_b) stat(mean) c(s)


*Ejercicio de Heterogeneidad de Jefe de Hogar por Género
preserve
recode genero (0=1 "Mujer")(1/2=2 "Hombre"), g(genero_a)
label var genero_a "Género RECODED"


calculoE lny $controls_ind $controls_hou $controls_reg ocup_1 ocup_2 ocup_5   if inforJ_hogar==0 & estado_lab==1 & contr1_hogar==1  , iv(hhsize) price(lnp2) bst(0) grupo(genero_a)
qui sum _ssp  if e(sample)==1 & genero_a == 1
local mean_1 = r(mean)
	estadd scalar mean_1 = `mean_1'
qui sum _ssp  if e(sample)==1 & genero_a == 2
local mean_2 = r(mean)
	estadd scalar mean_2 = `mean_2'
	
lincom [_lnp2]1.genero_a/`mean_1' - [_lnp2]2.genero_a/`mean_2'
	estadd scalar d11 = r(p)
lincom [lny]1.genero_a/`mean_1' - [lny]2.genero_a/`mean_2'
	estadd scalar d12 = r(p)
	
lincom [_lnp2]1.genero_a/`mean_1'
	estadd scalar Price_Elasticity_1 = r(estimate)
	estadd scalar Price_Elasticity_1_se = r(se)
lincom [_lnp2]2.genero_a/`mean_2'
	estadd scalar Price_Elasticity_2 = r(estimate)
	estadd scalar Price_Elasticity_2_se = r(se)

lincom [lny]1.genero_a/`mean_1'
	estadd scalar Income_Elasticity_1 = r(estimate)
	estadd scalar Income_Elasticity_1_se = r(se)
lincom [lny]2.genero_a/`mean_2'
	estadd scalar Income_Elasticity_2 = r(estimate)
	estadd scalar Income_Elasticity_2_se = r(se)

	est sto m4_1
	
disp in red "Limite con " as result  limitLow[1,2]
	esttab  m4_1                         , scalars("N Observaciones" "d11 Test Ln(p) Male HH" "d12 Test Ln(y) Male HH" "Price_Elasticity_1 Price Elasticity 1"  "Price_Elasticity_1_se Price Elasticity 1 se " "Price_Elasticity_2 Price Elasticity 2" "Price_Elasticity_2_se Price Elasticity 2 se" "Income_Elasticity_1 Income Elasticity 1" "Income_Elasticity_1_se Income Elasticity 1 se" "Income_Elasticity_2 Income Elasticity 2" "Income_Elasticity_2_se Income Elasticity 2 se" "mean_1 Mean group 1" "mean_2 Mean group 2"  ) star(* .1 ** .05 *** 0.001) se
	esttab m4_1 using "elasticities_gender", scalars("N Observaciones" "d11 Test Ln(p) Male HH" "d10 Test Ln(y) Male HH" "Price_Elasticity_1 Price Elasticity 1"  "Price_Elasticity_1_se Price Elasticity 1 se " "Price_Elasticity_2 Price Elasticity 2" "Price_Elasticity_2_se Price Elasticity 2 se" "Income_Elasticity_1 Income Elasticity 1" "Income_Elasticity_1_se Income Elasticity 1 se" "Income_Elasticity_2 Income Elasticity 2" "Income_Elasticity_2_se Income Elasticity 2 se" "mean_1 Mean group 1" "mean_2 Mean group 2" ) star(* .1 ** .05 *** 0.001) se booktabs fragment nolines label nonumbers replace

restore
********************************************************************************
** Figura de los coeficientes de Ln(p2) con multiples Umbrales.
********************************************************************************
//Model 3 Estimation 

cd "$derived\tables\tables_figureCutoff"
matrix limitLow=[0, 10000, 20000, 30000, 40000, 50000, 60000, 70000, 80000, 90000, 100000, 110000, 120000, 130000, 140000]
log using mylog_figure_m3, text replace
forval kk=1(1)15 {
	cap drop lnp2
	gen lnp2 = lnp if g_diversos530101>	limitLow[1,`kk']

// 	est drop _all
	
	* Modelo 3: Jefes trabajadores no informales, con alguien en el régimen contributivo (N=14384) 
	calculoE lny $controls_ind $controls_hou $controls_reg ocup_1 ocup_2 ocup_5   if inforJ_hogar==0 & estado_lab==1 & contr1_hogar==1  , iv(hhsize) price(lnp2) bst(0) 
		qui sum _ssp  if e(sample)==1
		local mean = r(mean)
		estadd scalar spp = r(mean)	
		lincom _lnp2/`mean'
		estadd scalar Price_Elasticity = r(estimate)
		estadd scalar Price_Elasticity_p = r(p)
		lincom lny/`mean'
		estadd scalar Income_Elasticity = r(estimate)
		estadd scalar Income_Elasticity_p = r(p)		
			
		est sto m3_`kk'
			
	disp in red "Limite con " as result  limitLow[1,`kk']
	esttab m3_`kk'                          , scalars("N Observaciones" "spp Participación" "Price_Elasticity" "Price_Elasticity_p" "Income_Elasticity" "Income_Elasticity_p") star(* .1 ** .05 *** 0.001) se
	esttab m3_`kk' using "elasticitiesC`kk'", scalars("N Observaciones" "spp Participación" "Price_Elasticity" "Price_Elasticity_p" "Income_Elasticity" "Income_Elasticity_p") star(* .1 ** .05 *** 0.001) se booktabs fragment nolines label nonumbers replace
	
}
log close

// Semi-Elasticity of Demand

// // Complete Graph
coefplot (m3_1, offset(-0.7)) (m3_2, offset(-0.6)) (m3_3, offset(-0.5)) (m3_4, offset(-0.4)) (m3_5, offset(-0.3)) (m3_6, offset(-0.2)) (m3_7, offset(-0.1)) m3_8 (m3_9, offset(0.1)) (m3_10, offset(0.2)) (m3_11, offset(0.3)) (m3_12, offset(0.4))  (m3_13, offset(0.5)) (m3_14, offset(0.6)) (m3_15, offset(0.7)), ///
title("Cut-off Sensibility Test", size(*0.9)) subtitle("Semi-elasticity of demand", size(*0.9)) keep(_lnp2) xline(0) nokey graphregion(col(white)) xlabel() legend(order(2 "0" 4 "10" 6 "20" 8 "30" 10 "40" 12 "50" 14 "60" 16 "70" 18 "80" 20 "90" 22 "100" 24 "110" 26 "120" 28 "130" 30 "140")  cols(5) position(6))  ///
ytitle("Cut-off in Thousands of COP") plotregion(col(white)) bgcol(white) ylabel(0.3 "140" 0.4 "130" 0.5 "120" 0.6 "110" 0.7 "100" 0.8 "90" 0.9 "80" 1 "70" 1.1 "60" 1.2 "50" 1.3 "40" 1.4 "30" 1.5 "20" 1.6 "10" 1.7 "0") xsize(8) ysize(8) 
graph export "Sensibility_Cutoff_Complete_Demand.png", replace

// // Over 50.000
coefplot (m3_7, offset(-0.4)) (m3_8, offset(-0.3)) (m3_9, offset(-0.2)) (m3_10, offset(-0.1)) (m3_11, offset(0)) (m3_12, offset(0.1))  (m3_13, offset(0.2)) (m3_14, offset(0.3)) (m3_15, offset(0.4)), ///
title("Cut-off Sensibility Test", size(*0.9)) subtitle("Semi-elasticity of demand over 50.000COP Cut-off", size(*0.9)) keep(_lnp2) xline(0) nokey graphregion(col(white)) xlabel() legend(order(2 "0" 4 "10" 6 "20" 8 "30" 10 "40" 12 "50" 14 "60" 16 "70" 18 "80" 20 "90" 22 "100" 24 "110" 26 "120" 28 "130" 30 "140")  cols(5) position(6))  ///
ytitle("Cut-off in Thousands of COP") plotregion(col(white)) bgcol(white) ylabel(0.6 "140" 0.7 "130" 0.8 "120" 0.9 "110" 1 "100" 1.1 "90" 1.2 "80" 1.3 "70" 1.4 "60") xsize(8) ysize(8) 
graph export "Sensibility_Cutoff_Over50_Demand.png", replace

// Income Semi-Elasticity

// // Complete Graph
coefplot (m3_1, offset(-0.7)) (m3_2, offset(-0.6)) (m3_3, offset(-0.5)) (m3_4, offset(-0.4)) (m3_5, offset(-0.3)) (m3_6, offset(-0.2)) (m3_7, offset(-0.1)) m3_8 (m3_9, offset(0.1)) (m3_10, offset(0.2)) (m3_11, offset(0.3)) (m3_12, offset(0.4))  (m3_13, offset(0.5)) (m3_14, offset(0.6)) (m3_15, offset(0.7)), ///
title("Cut-off Sensibility Test", size(*0.9)) subtitle("Income Semi-elasticity", size(*0.9)) keep(lny) xline(0) nokey graphregion(col(white)) xlabel() legend(order(2 "0" 4 "10" 6 "20" 8 "30" 10 "40" 12 "50" 14 "60" 16 "70" 18 "80" 20 "90" 22 "100" 24 "110" 26 "120" 28 "130" 30 "140")  cols(5) position(6))  ///
ytitle("Cut-off in Thousands of COP") plotregion(col(white)) bgcol(white) ylabel(0.3 "140" 0.4 "130" 0.5 "120" 0.6 "110" 0.7 "100" 0.8 "90" 0.9 "80" 1 "70" 1.1 "60" 1.2 "50" 1.3 "40" 1.4 "30" 1.5 "20" 1.6 "10" 1.7 "0") xsize(8) ysize(8) 
graph export "Sensibility_Cutoff_Complete_Income.png", replace




cd "$derived\tables\tables_figureCutoff"
log using mylog_figure_Tau, text replace
cap matrix drop miMat
forval kk=-0.2(0.1)0.2 {
	cap drop lnp2
	cap drop exp2
	
	gen lnp2 = lnp if g_diversos530101>90000
	replace lnp2 = ln(exp(lnp2)*(1 +`kk'*educacion2))
	gen exp2     = exp(lnp2)  
		
// 	est drop _all

	if `kk' == -0.2 {
		local i = 1
	}
	else if `kk' == -0.1 {
		local i = 2
	} 
	else if `kk' == 0 {
		local i = 3
	} 
	else if `kk' == 0.1 {
		local i = 4
	}
	else if `kk' == 0.2 {
		local i = 5
	}
		
	* Modelo 3: Jefes trabajadores no informales, con alguien en el régimen contributivo (N=14384) 
	sum exp2
	loc meanExp = r(mean)
	
	calculoE lny $controls_ind $controls_hou $controls_reg ocup_1 ocup_2 ocup_5   if inforJ_hogar==0 & estado_lab==1 & contr1_hogar==1  , iv(hhsize) price(lnp2) bst(0) 
		qui sum _ssp  if e(sample)==1
		local mean = r(mean)
		estadd scalar spp = r(mean)	
		lincom _lnp2/`mean'
		estadd scalar Price_Elasticity = r(estimate)
		estadd scalar Price_Elasticity_p = r(p)
		estadd scalar lb_d = r(lb)
		estadd scalar ub_d = r(ub)
		lincom lny/`mean'
		estadd scalar Income_Elasticity = r(estimate)
		estadd scalar Income_Elasticity_p = r(p)		
		estadd scalar lb_i = r(lb)
		estadd scalar ub_i = r(ub)			
		est sto m3Tau_`i'
			
		matrix miMat = nullmat(miMat) \ [ `kk', `meanExp', e(spp) , _b[_lnp2] , e(Price_Elasticity) , e(Price_Elasticity_p)  ]
	
}
log close
matrix list miMat // No cambia... as expected, porque lo que interesa es el entrar o no; cualquier movimiento sistemático del gasto es capturado por la pendiente
