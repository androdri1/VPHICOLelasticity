* Author: Susana Otálvaro-Ramírez
* Date: 2019.02.25
* Goal: Estimate the selection model in two stages with boostrapping 
	
////////////////////////////////////////////////////////////////////////////////
*glo data 	"C:\Users\juanmg\Documents\Archivos Compartidos\Elasticidad_Precio e Ingreso\Base datos Colmedica y Aliansalud\BasesOriginales_corregidas\Limpieza"
*glo data_tarif "C:\Users\juanmg\Documents\Archivos Compartidos\Elasticidad_Precio e Ingreso\Tarifas"
*glo derived "C:\Users\juanmg\Documents\Archivos Compartidos\Elasticidad_Precio e Ingreso\derived"

glo data "C:\Users\susana.otalvaro\Dropbox\tabacoDrive\Seguros\Data"
glo derived "C:\Users\susana.otalvaro\Dropbox\tabacoDrive\Seguros\Derived"
glo data_tarif "C:\Users\susana.otalvaro\Dropbox\tabacoDrive\Seguros\Data"


cd 		"$derived"

*********** BASE 2012 - 2013 
	clear all
	import excel "$data_tarif\Tarifas Colmedica 2012-2013 Familiares - Individuales.xlsx", sheet("Hoja1") firstrow

	gen id=_n
	
	** Expansion de grupo etario para merge
	gen 	grupo_etario_init = substr(GrupoEtareo, 1, strpos(GrupoEtareo, "-") - 1) 
	replace grupo_etario_init = substr(GrupoEtareo, 1, strpos(GrupoEtareo, "y") - 1) if grupo_etario_init==""
	replace grupo_etario_init = "0" if GrupoEtareo=="Menores de 1" | GrupoEtareo=="enores de 1"

	gen 	grupo_etario_fin = substr(GrupoEtareo, strpos(GrupoEtareo, "-") + 1, .) 
	replace grupo_etario_fin = substr(GrupoEtareo, strpos(GrupoEtareo, "y") + 1, .) if grupo_etario_fin=="70 y más" | grupo_etario_fin=="65 y más" | grupo_etario_fin=="60 y más" | grupo_etario_fin=="75 y ás" 
	replace grupo_etario_fin = "0" if grupo_etario_fin=="Menores de 1" 	| grupo_etario_fin=="enores de 1"
	replace grupo_etario_fin = "106" if grupo_etario_fin==" más" | grupo_etario_fin==" ás"

	destring grupo_etario_init grupo_etario_fin, replace

	gen expansion = (grupo_etario_fin-grupo_etario_init)+1
	expand expansion
	sort id
	gen id2 = _n
	tsset id2
	replace  grupo_etario_init=l.grupo_etario_init+1 if l.expansion==expansion
	
	drop id grupo_etario_fin expansion
	**


	reshape long tarif_ , i(id2) j(year)

	drop if tarif==.

	gen name_plan = substr(Código, 1,2)
	gen _plan = substr(Plan, 1,5)
	
	gen grupo_etario_init = substr(GrupoEtareo, 1, strpos(GrupoEtareo, "-") - 1) 
	gen grupo_etario_init = trim(demo1) 

	encode IndividualFamiliar, g(individual_familiar)
	rename Código CódigoPlan
	encode name_plan, g(nam_plan)
	encode Plan , g(plan_)
	encode _plan, g(plan1_)
	encode Sexo , g(gend)
	encode GrupoEtareo , g(grupo_etario)
	encode ConSinPOS, g(pos)

	recode gend (1=0 "Hombre")(2=1 "Mujer"), g(gender)

	drop IndividualFamiliar Plan Sexo GrupoEtareo ConSinPOS gend name_plan
	
	gen demo1 = substr(somemarvinstuff, 1, strpos(somemarvinstuff, "-") - 1) 
	gen demo2 = trim(demo1) 
	
	tempfile tarif2012_2013
	save `tarif2012_2013'
	
*********** BASE 2014 - 2015
	clear all
	import excel "$data_tarif\Tarifas Colmedica 2014-2015 Familiares - Individuales.xlsx", sheet("Hoja1") firstrow

	gen id=_n
	
	** Expansion de grupo etario para merge
	gen 	grupo_etario_init = substr(GrupoEtareo, 1, strpos(GrupoEtareo, "-") - 1) 
	replace grupo_etario_init = substr(GrupoEtareo, 1, strpos(GrupoEtareo, "y") - 1) if grupo_etario_init==""
	replace grupo_etario_init = "0" if GrupoEtareo=="Menores de 1" | GrupoEtareo=="enores de 1"

	gen 	grupo_etario_fin = substr(GrupoEtareo, strpos(GrupoEtareo, "-") + 1, .) 
	replace grupo_etario_fin = substr(GrupoEtareo, strpos(GrupoEtareo, "y") + 1, .) if grupo_etario_fin=="70 y más" | grupo_etario_fin=="65 y más" | grupo_etario_fin=="60 y más" | grupo_etario_fin=="75 y ás" 
	replace grupo_etario_fin = "0" if grupo_etario_fin=="Menores de 1" 	| grupo_etario_fin=="enores de 1"
	replace grupo_etario_fin = "106" if grupo_etario_fin==" más" | grupo_etario_fin==" ás"

	destring grupo_etario_init grupo_etario_fin, replace

	gen expansion = (grupo_etario_fin-grupo_etario_init)+1
	expand expansion
	sort id
	gen id2 = _n
	tsset id2
	replace  grupo_etario_init=l.grupo_etario_init+1 if l.expansion==expansion
	
	drop id grupo_etario_fin expansion
	**


	reshape long tarif_ , i(id2) j(year)

	drop if tarif==.

	gen name_plan = substr(Código, 1,2)
	gen _plan = substr(Plan, 1,5)
	
	gen grupo_etario_init = substr(GrupoEtareo, 1, strpos(GrupoEtareo, "-") - 1) 
	gen grupo_etario_init = trim(demo1) 

	encode IndividualFamiliar, g(individual_familiar)
	rename Código CódigoPlan
	encode name_plan, g(nam_plan)
	encode Plan , g(plan_)
	encode _plan, g(plan1_)
	encode Sexo , g(gend)
	encode GrupoEtareo , g(grupo_etario)
	encode ConSinPOS, g(pos)

	recode gend (1=0 "Hombre")(2=1 "Mujer"), g(gender)

	drop IndividualFamiliar Plan Sexo GrupoEtareo ConSinPOS gend name_plan
	
	gen demo1 = substr(somemarvinstuff, 1, strpos(somemarvinstuff, "-") - 1) 
	gen demo2 = trim(demo1) 
	
	tempfile tarif2014_2015
	save `tarif2014_2015'

*********** BASE 2016 - 2017
	clear all
	import excel "$data_tarif\Tarifas Colmedica 2016-2017 Familiares - Individuales.xlsx", sheet("Hoja1") firstrow

	drop if tarif_2016==.
	
	gen id=_n
	
	** Expansion de grupo etario para merge
	gen 	grupo_etario_init = substr(GrupoEtareo, 1, strpos(GrupoEtareo, "-") - 1) 
	replace grupo_etario_init = substr(GrupoEtareo, 1, strpos(GrupoEtareo, "y") - 1) if grupo_etario_init==""
	replace grupo_etario_init = "0" if GrupoEtareo=="Menores de 1" | GrupoEtareo=="enores de 1"

	gen 	grupo_etario_fin = substr(GrupoEtareo, strpos(GrupoEtareo, "-") + 1, .) 
	replace grupo_etario_fin = substr(GrupoEtareo, strpos(GrupoEtareo, "y") + 1, .) if grupo_etario_fin=="70 y más" | grupo_etario_fin=="65 y más" | grupo_etario_fin=="60 y más" | grupo_etario_fin=="75 y ás" 
	replace grupo_etario_fin = "0" if grupo_etario_fin=="Menores de 1" 	| grupo_etario_fin=="enores de 1"
	replace grupo_etario_fin = "106" if grupo_etario_fin==" más" | grupo_etario_fin==" ás"

	destring grupo_etario_init grupo_etario_fin, replace

	gen expansion = (grupo_etario_fin-grupo_etario_init)+1
	expand expansion
	sort id
	gen id2 = _n
	tsset id2
	replace  grupo_etario_init=l.grupo_etario_init+1 if l.expansion==expansion
	
	drop id grupo_etario_fin expansion
	**
	
	reshape long tarif_ , i(id2) j(year)

	gen name_plan = substr(CódigoPlan, 1,2)
	gen _plan = substr(Plan, 1,5)
	
	

	encode IndividualFamiliar, g(individual_familiar)
	encode name_plan, g(nam_plan)
	encode Plan , g(plan_)
	encode _plan, g(plan1_)
	encode Sexo , g(gend)
	encode GrupoEtareo , g(grupo_etario)
	encode ConSinPOS, g(pos)

	recode gend (1=0 "Hombre")(2=1 "Mujer"), g(gender)

	drop IndividualFamiliar Plan Sexo GrupoEtareo ConSinPOS gend name_plan _plan
	append using `tarif2012_2013'
	append using `tarif2014_2015'
	
	rename CódigoPlan códigoplanprincipal
	rename pos aliansalud
	rename gender género
	rename grupo_etario grupoetarioprepagada
	rename year año
	
	recode individual_familiar (1=3 "Familiar")(2=4 "Individual"), g(tipocarátulaprincipal)
	sort códigoplanprincipal año
	
	encode códigoplanprincipal, g(cod_plan)
	drop códigoplanprincipal
	
	recode cod_plan (5/6=50)(7=5 "D07")(8=6 "ES08")(9=7 "ES09")(10=8 "ES10")(11=50)(12=9 "ES12")(13=10 "ES13")(14=11 "ES14")(15=12 "ES15")(16=13 "MA15")(17=15 "NO16")(18=16 "NO17")(19=17 "NO18")(20=18 "OP38")(21=19 "PL01")(22=23 "PVT004")(23=24 "PVT005")(24=25 "PVT009")(25=26 "PVT010")(26=27 "PVT011")(27=28 "RO19")(28/29=50)(30=29 "RU22")(31=30 "RU23")(32=31 "RU24")(33=32 "RU25")(34=33 "RU26")(35=34 "RU27")(36=36 "VE28")(37=50)(38=37 "ZA30")(39=38 "ZA31")(40=39 "ZA32")(41=40 "ZA33")(42=41 "ZA34")(43=42 "ZA38")(44=43 "ZA39"), g(códigoplanprincipal)
	
	save "$derived\base_tarifas.dta", replace
