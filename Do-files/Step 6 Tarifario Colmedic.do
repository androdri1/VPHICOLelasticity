* Author: Paul Andrés Rodríguez-Lesmes
* Date: 2019.02.25
* Goal: Estimate the selection model in two stages with boostrapping 
	
////////////////////////////////////////////////////////////////////////////////
// Here we construct Finkelstain's permanent income procedure
glo data "C:\Users\\`c(username)'\Dropbox\tabacoDrive\Seguros\Data" 
glo derived "C:\Users\\`c(username)'\Dropbox\tabacoDrive\Seguros\Derived" 


*glo data "F:\paul.rodriguez\Dropbox\tabaco\tabacoDrive\Seguros\Data" 
*glo derived "F:\paul.rodriguez\Dropbox\tabaco\tabacoDrive\Seguros\Derived" 
*glo data "C:\Users\andro\Dropbox\tabaco\tabacoDrive\Seguros\Data"
*glo derived "C:\Users\andro\Dropbox\tabaco\tabacoDrive\Seguros\Derived"

cd 		"$derived"

clear all
import excel "$data\Tarifas Colmedica 2016-2017 Familiares - Individuales.xlsx", sheet("Hoja1") firstrow

rename G tarif2016
rename H tarif2017

gen id=_n

reshape long tarif , i(id) j(year)

drop if tarif==.

gen name_plan = substr(CódigoPlan, 1,2)
gen _plan = substr(Plan, 1,5)

encode IndividualFamiliar, g(individual_familiar)
encode CódigoPlan, g(cod_plan)
encode name_plan, g(nam_plan)
encode Plan , g(plan_)
encode _plan, g(plan1_)
encode Sexo , g(gend)
encode GrupoEtareo , g(grupo_etario)
encode ConSinPOS, g(pos)

recode gend (1=0 "Hombre")(2=1 "Mujer"), g(gender)

drop IndividualFamiliar CódigoPlan Plan Sexo GrupoEtareo ConSinPOS gend name_plan


preserve
collapse (mean) tarif , by(year individual_familiar nam_plan plan1_ gender grupo_etario pos)
reshape wide tarif, i(individual_familiar nam_plan plan1_ gender grupo_etario pos) j(year)
save "$derived\Tarifario1.dta", replace 
restore

preserve
collapse (mean) tarif , by(year individual_familiar nam_plan gender grupo_etario pos)
reshape wide tarif, i(individual_familiar nam_plan gender grupo_etario pos) j(year)
save "$derived\Tarifario2.dta", replace 
restore

preserve
collapse (mean) tarif , by(individual_familiar nam_plan gender grupo_etario pos)
save "$derived\Tarifario3.dta", replace 
restore

