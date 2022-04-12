* Author: Susana Otálvaro-Ramírez
* Date: 2019.01.29
* Goal: Calculate descriptive statistics of Health insurance programs

// glo data "C:\Users\\`c(username)'\Dropbox\tabacoDrive\Seguros\Data" 
// glo derived "C:\Users\\`c(username)'\Dropbox\tabacoDrive\Seguros\Derived" 

glo data "C:\Users\msofi\Dropbox\Seguros\Derived" 
glo derived "C:\Users\msofi\Dropbox\Seguros\Derived" 

*glo data "F:\paul.rodriguez\Dropbox\tabaco\tabacoDrive\Seguros\Data" 
*glo derived "F:\paul.rodriguez\Dropbox\tabaco\tabacoDrive\Seguros\Derived" 
*glo data "C:\Users\andro\Dropbox\tabaco\tabacoDrive\Seguros\Data"
*glo derived "C:\Users\andro\Dropbox\tabaco\tabacoDrive\Seguros\Derived"

cd 		"$derived"

use "$derived\Hogar_gasto_completo.dta", replace 

gen 	educacion=0 if educ_none==1 & educ_pree!=1 & educ_prim!=1 & educ_secu!=1 & educ_medi!=1 & educ_supe!=1 
replace educacion=1 if educ_none!=1 & educ_pree==1 & educ_prim!=1 & educ_secu!=1 & educ_medi!=1 & educ_supe!=1 
replace educacion=2 if educ_none!=1 & educ_pree!=1 & educ_prim==1 & educ_secu!=1 & educ_medi!=1 & educ_supe!=1 
replace educacion=3 if educ_none!=1 & educ_pree!=1 & educ_prim!=1 & educ_secu==1 & educ_medi!=1 & educ_supe!=1 
replace educacion=4 if educ_none!=1 & educ_pree!=1 & educ_prim!=1 & educ_secu!=1 & educ_medi==1 & educ_supe!=1 
replace educacion=5 if educ_none!=1 & educ_pree!=1 & educ_prim!=1 & educ_secu!=1 & educ_medi!=1 & educ_supe==1 

la def educacion 0 "Ninguna" 1 "Preescolar" 2 "Primaria" 3 "Secundaria" 4 "Media" 5 "Superior"
la val educacion educacion
recode educacion (0/1=1 "Preescolar")(2=2 "Primaria")(3/4=3 "Bachillerato")(5=4 "Superior"), g(educacion1)

recode perceptores (0=0 "Cero")(1=1 "Uno")(2=2 "Dos")(3/10=3 "Tres o más"), g(perceptoresI)	
recode numnin (0=0 "Cero")(1=1 "Uno")(2=2 "Dos")(3=3 "Tres")(4/12=4 "Cuatro o más"), g(menores)

gen 	tot_indiv = .
replace tot_indiv = numnin + numadu if numnin!=. & numadu!=.
recode tot_indiv (1=1 "Uno")(2=2 "Dos")(3=3 "Tres")(4=4 "Cuatro")(5/22=5 "Cinco +"), g(numind)

la def ocupacion1 1 "Obrero particular" 2 "Obrero gobierno" 3 "Empleado doméstico" 4 "Trabajador cuenta propia"  5 "Patrón"  6 "Familiar sin remuneración"  7 "Sin remuneración de negocio" 8 "Jornalero o peón"
la val ocupacion ocupacion1

recode men5 (0=0 "0")(1=1 "1")(2/5=2 "2+"), g(men5_a)
recode may65 (0=0 "0")(1=1 "1")(2/5=2 "2+"), g(may65_a)

gen 	estado_laboral=.
replace estado_laboral=1 if ocupados==1 & desocupados==0 & inactivos==0
replace estado_laboral=2 if desocupados==1 & ocupados==0 & inactivos==0
replace estado_laboral=3 if inactivos==1 & ocupados==0 & desocupados==0

la def estado_laboral 1 "Ocupados" 2 "Desocupados" 3 "Inactivos"
la val estado_laboral estado_laboral 
la def personas_hogar 1 "Una o dos" 2 "Tres" 3 "Cuatro" 4 "Cinco o más"
la val personas_hogarS personas_hogar

la var numnin "Número de niños en el hogar (<18)"
la var numadu "Número de adultos en el hogar"
la var hheq "Equivalente del hogar"
la var ocupacion "Ocupacion del jefe del hogar"
la var menores "Número de niños hogar (categorías)"

recode estrato (0/1=1 "0-1")(2=2 "2")(3=3 "3")(4/6=4 "4+"), g(strata)

preserve
collapse (mean) m_ingresos = ingresos (median) p50_ingresos = ingresos, by(DOMINIO)
xtile quintil_ciudad = m_ingresos, n(5)
xtile quintil_ciudadMed = p50_ingresos, n(5) 
keep  DOMINIO quintil_ciudad quintil_ciudadMed
tempfile cuartil
save `cuartil'
restore 

merge n:1 DOMINIO using `cuartil', nogen 

replace g_diversos530101=. if g_diversos530101==0 // Sólo 35
gen lnp=ln(g_diversos530101)
gen ssp=g_diversos530101!=.

sum ssp [ aw=FEX_C]

egen y = rowtotal(g_alimentos g_BTE g_vestido g_servicios g_muebles g_salud g_transporte g_comunicacion g_recreacion g_educacion g_hoteles g_diversos), missing
gen lny = ln(y)

recode DOMINIO 	(1=1 "Arauca")(2=2 "Armenia")(3=3 "Barrancabermeja")(4=4 "Barranquilla")(5=5 "Bogotá") ///
				(6=6 "Bucaramanga y A.M")(7=7 "Buenaventura")(8=8 "Cali")(9=9 "Cartagena")(11=10 "Cúcuta") ///
				(12=11 "Florencia")(13=12 "Ibagué")(14=13 "Inírida")(15=14 "Leticia")(16=15 "Manizales y A.M") ///
				(17=16 "Medellín y A.M")(18=17 "Mitú")(19=18 "Mocoa")(20=19 "Montería")(21=20 "Neiva")(23=21 "Pasto") ///
				(24=22 "Pereira y A.M")(25=23 "Popayán")(26=24 "Puerto Carreño")(27=25 "Quibdó")(28=26 "Riohacha") ///
				(29=27 "Rionegro")(31=28 "San Andrés")(32=29 "San José del Guaviare")(33=30 "Santa Marta")(34=31 "Sincelejo") ///
				(35=32 "Soledad")(36=33 "Tumaco")(37=34 "Tunja")(38=35 "Valledupar")(39=36 "Villavicencio")(40=37 "Yopal")(41=38 "Yumbo"), gen(ciudad)

save "$derived\Hogar_gasto_completo1.dta", replace

	
*------------------------------------------------------------------------------*
* SEGUROS EN SALUD 
*------------------------------------------------------------------------------*
use "$derived\Hogar_gasto_completo1.dta", replace
hist lnp  , xscale(log) scheme(plotplain) xtitle(Premium (log))
graph export "$derived\images\Hist_PremLog.pdf", as(pdf) replace

hist g_diversos530101, scheme(plotplain) xtitle(Premium) 
graph export "$derived\images\Hist_Prem.pdf", as(pdf) replace

//Nuevas
 
hist lnp  , xscale(log) scheme(plotplain) xtitle(Premium (log))
graph export "$derived\images\Hist_PremLog2.pdf", as(pdf) replace

preserve
replace g_diversos530101 = g_diversos530101/1000
hist g_diversos530101, scheme(plotplain) xtitle(Premium expense (thousands COP)) percent
graph export "$derived\images\Hist_Prem2.pdf", as(pdf) replace
restore

cd 		"$derived\tables"

if 1==0{
// Por ciudad, region y sector
preserve
drop if DOMINIO==10 | DOMINIO==22 | DOMINIO==30

collapse (mean) mean=g_diversos530101 (sd) sd=g_diversos530101 (p25) p25=g_diversos530101 (p50) p50=g_diversos530101 (p75) p75=g_diversos530101 (count) count=g_diversos530101 [aw=FEX_C], by(ciudad)
list 
export excel ciudad mean sd p25 p50 p75 count using "$derived\tables\descriptivas.xlsx", sheet("ciudades") firstrow(variables) replace
restore 

preserve
drop if DOMINIO==10 | DOMINIO==22 | DOMINIO==30
tabstat g_diversos530101 [aw=FEX_C], by(ciudad) stat(mean sd min p25 median p75 max count) columns(statistics) save
*tabstat g_seguros_salud [aw=FEX_C], by(ciudad) stat(mean sd min p25 median p75 max count)


		twoway (kdensity g_diversos530101 if ciudad==30 [aw=FEX_C], range(0 200000)), ///
		xtitle("Gasto", size(small)) ytitle("Densidad", size(vsmall)) legend(label(1 "Arauca") label(2 "Barrancabermeja") label(3 "Puerto Inírida") label(4 "Leticia") label(5 "Mitú") label(6 "Montería") label(7 "Quibdó") label(8 "San Andrés") label(9 "Santa Marta") label(10 "Soledad") rows(3) pos(6) size(vsmall)) title("Cuartil 1") ///
		name(ciudades_1CGT, replace) 

		twoway (kdensity g_diversos530101 if ciudad==22 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if ciudad==26 [aw=FEX_C], range(0 200000)), ///
		xtitle("Gasto", size(small)) ytitle(" ", size(vsmall)) legend(label(1 "Florencia") label(2 "Pereira") label(3 "Riohacha") label(4 "Tumaco") rows(3) pos(6) size(vsmall)) title("Cuartil 2") ///
		name(ciudades_2CGT, replace) 
		
		twoway (kdensity g_diversos530101 if ciudad==2 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if ciudad==4 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if ciudad==12 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if ciudad==23 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if ciudad==27 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if ciudad==31 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if ciudad==38 [aw=FEX_C], range(0 200000)), ///
		xtitle("Gasto", size(small)) ytitle(" ", size(vsmall)) legend(label(1 "Armenia") label(2 "Barranquilla") label(3 "Cartagena") label(4 "Cúcuta") label(5 "Ibagué") label(6 "Popayán") label(7 "Rionegro") label(8 "Sincelejo") label(9 "Yopal") label(10 "Yumbo") rows(3) pos(6) size(vsmall)) title("Cuartil 3") ///
		name(ciudades_3CGT, replace) 

		twoway (kdensity g_diversos530101 if ciudad==5 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if ciudad==6 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if ciudad==8 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if ciudad==15 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if ciudad==16 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if ciudad==20 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if ciudad==21 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if ciudad==34 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if ciudad==36 [aw=FEX_C], range(0 200000)), ///
		xtitle("Gasto", size(small)) ytitle("Densidad", size(vsmall)) legend(label(1 "Bogotá") label(2 "Bucaramanga") label(3 "Cali") label(4 "Manizales") label(5 "Medellín") label(6 "Neiva") label(7 "Pasto") label(8 "Tunja") label(9 "Villavicencio") rows(3) pos(6) size(vsmall)) title("Cuartil 4") ///
		name(ciudades_4CGT, replace) 

		graph combine ciudades_1CGT ciudades_2CGT ciudades_3CGT ciudades_4CGT , r(2) c(2) ///
		title("Distribución del gasto en Seguros relacionados con salud", size(small)) subtitle("Por ciudades", size(vsmall)) note("Fuente: ENPH - Cálculos propios.", size(vsmall)) scale(0.8) name(graphcomb, replace)   
		
				
		graph export "$derived\tables\images\ciudades_CG.pdf", as(pdf)replace
		graph close _all	
restore 

// Region
preserve
collapse (mean) mean=g_diversos530101 (sd) sd=g_diversos530101 (p25) p25=g_diversos530101 (p50) p50=g_diversos530101 (p75) p75=g_diversos530101 (count) count=g_diversos530101 [aw=FEX_C], by(REGION)
list 
export excel REGION mean sd p25 p50 p75 count using "$derived\tables\descriptivas.xlsx", sheet("regiones") firstrow(variables)
restore 

tabstat g_diversos530101 [aw=FEX_C], by(REGION) stat(mean sd min p25 median p75 max count)
*tabstat g_seguros_salud [aw=FEX_C], by(REGION) stat(mean sd min p25 median p75 max count)

		twoway (kdensity g_diversos530101 if REGION==1 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if REGION==2 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if REGION==3 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if REGION==4 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if REGION==5 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if REGION==6 [aw=FEX_C], range(0 200000)), ///
		xtitle("Gasto", size(small)) ytitle("Densidad", size(vsmall)) legend(label(1 "Atlántica") label(2 "Bogotá") label(3 "Central") label(4 "Nuevos Departamentos") label(5 "Oriental") label(6 "Pacífica") rows(1) pos(6) size(vsmall)) title("Distribución del Gasto en Seguros de salud - Regiones") ///
		name(region_CGT, replace) 
		graph export "$derived\tables\images\regiones_CG.pdf", as(pdf)replace

// Sector: Urbano - Rural
preserve
collapse (mean) mean=g_diversos530101 (sd) sd=g_diversos530101 (p25) p25=g_diversos530101 (p50) p50=g_diversos530101 (p75) p75=g_diversos530101 (count) count=g_diversos530101 [aw=FEX_C], by(sector)
list 
export excel sector mean sd p25 p50 p75 count using "$derived\tables\descriptivas.xlsx", sheet("sector") firstrow(variables) 
restore 

tabstat g_diversos530101 [aw=FEX_C], by(sector) stat(mean sd min p25 median p75 max count)
*tabstat g_seguros_salud [aw=FEX_C], by(sector) stat(mean sd min p25 median p75 max count)

		twoway (kdensity g_diversos530101 if sector==0 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if sector==1 [aw=FEX_C], range(0 200000)), ///
		xtitle("Gasto", size(small)) ytitle("Densidad", size(vsmall)) legend(label(1 "Rural") label(2 "Urbano") rows(1) pos(6) size(vsmall)) title("Distribución del Gasto en Seguros de salud - Sector") ///
		name(sector_CGT, replace) 
		graph export "$derived\tables\images\sectores_CG.pdf", as(pdf)replace


// Nivel educativo del jefe
preserve
collapse (mean) mean=g_diversos530101 (sd) sd=g_diversos530101 (p25) p25=g_diversos530101 (p50) p50=g_diversos530101 (p75) p75=g_diversos530101 (count) count=g_diversos530101 [aw=FEX_C], by(educacion1)
list 
export excel educacion1 mean sd p25 p50 p75 count using "$derived\tables\descriptivas.xlsx", sheet("educacion") firstrow(variables) 
restore 

tabstat g_diversos530101  [aw=FEX_C], by(educacion1) stat(mean sd min p25 median p75 max count)
*tabstat g_seguros_salud [aw=FEX_C], by(educacion1) stat(mean sd min p25 median p75 max count)


		twoway (kdensity g_diversos530101 if educacion1==1 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if educacion1==2 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if educacion1==3 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if educacion1==4 [aw=FEX_C], range(0 200000)), ///
		xtitle("Gasto", size(small)) ytitle("Densidad", size(vsmall)) legend(label(1 "Preescolar") label(2 "Primaria") label(3 "Bachillerato") label(4 "Superior") rows(1) pos(6) size(vsmall)) title("Distribución del Gasto en Seguros de salud - Educacion") ///
		name(educacion1_CGT, replace) 
		graph export "$derived\tables\images\educacion_CG.pdf", as(pdf)replace

// Género del jefe
preserve
collapse (mean) mean=g_diversos530101 (sd) sd=g_diversos530101 (p25) p25=g_diversos530101 (p50) p50=g_diversos530101 (p75) p75=g_diversos530101 (count) count=g_diversos530101 [aw=FEX_C], by(genero)
list 
export excel genero mean sd p25 p50 p75 count using "$derived\tables\descriptivas.xlsx", sheet("genero") firstrow(variables) 
restore 

tabstat g_diversos530101  [aw=FEX_C], by(genero) stat(mean sd min p25 median p75 max count)
*tabstat g_seguros_salud [aw=FEX_C], by(genero) stat(mean sd min p25 median p75 max count)

		twoway (kdensity g_diversos530101 if genero==0 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if genero==1 [aw=FEX_C], range(0 200000)), ///
		xtitle("Gasto", size(small)) ytitle("Densidad", size(vsmall)) legend(label(1 "Mujer") label(2 "Hombre") rows(1) pos(6) size(vsmall)) title("Distribución del Gasto en Seguros de salud - Genero") ///
		name(genero_CGT, replace) 
		graph export "$derived\tables\images\genero_CG.pdf", as(pdf)replace
		
// Ocupacion del jefe 
preserve
collapse (mean) mean=g_diversos530101 (sd) sd=g_diversos530101 (p25) p25=g_diversos530101 (p50) p50=g_diversos530101 (p75) p75=g_diversos530101 (count) count=g_diversos530101 [aw=FEX_C], by(ocupacion)
list 
export excel ocupacion mean sd p25 p50 p75 count using "$derived\tables\descriptivas.xlsx", sheet("ocupacion") firstrow(variables) 
restore 

tabstat g_diversos530101  [aw=FEX_C], by(ocupacion) stat(mean sd min p25 median p75 max count)
*tabstat g_seguros_salud [aw=FEX_C], by(ocupacion) stat(mean sd min p25 median p75 max count)


		twoway (kdensity g_diversos530101 if ocupacion==1 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if ocupacion==2 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if ocupacion==3 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if ocupacion==4 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if ocupacion==5 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if ocupacion==8 [aw=FEX_C], range(0 200000)), ///
		xtitle("Gasto", size(small)) ytitle("Densidad", size(vsmall)) legend(label(1 "Obrero particular") label(2 "Obrero gobierno") label(3 "Empleado doméstico") label(4 "Trabajador cuenta propia") label(5 "Patrón") label(6 "Jornalero o peón") rows(2) pos(6) size(vsmall)) title("Distribución del Gasto en Seguros de salud - Ocupacion") ///
		name(ocupacion_CGT, replace) 
		graph export "$derived\tables\images\ocupaciones_CG.pdf", as(pdf)replace

// Estado laboral del jefe
preserve
collapse (mean) mean=g_diversos530101 (sd) sd=g_diversos530101 (p25) p25=g_diversos530101 (p50) p50=g_diversos530101 (p75) p75=g_diversos530101 (count) count=g_diversos530101 [aw=FEX_C], by(estado_laboral)
list 
export excel estado_laboral mean sd p25 p50 p75 count using "$derived\tables\descriptivas.xlsx", sheet("estado_laboral") firstrow(variables)
restore 

tabstat g_diversos530101  [aw=FEX_C], by(estado_laboral) stat(mean sd min p25 median p75 max count)
*tabstat g_seguros_salud [aw=FEX_C], by(estado_laboral) stat(mean sd min p25 median p75 max count)

		twoway (kdensity g_diversos530101 if estado_laboral==1 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if estado_laboral==2 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if estado_laboral==3 [aw=FEX_C], range(0 200000)), ///
		xtitle("Gasto", size(small)) ytitle("Densidad", size(vsmall)) legend(label(1 "Ocupado") label(2 "Desocupado") label(3 "Inactivo") rows(1) pos(6) size(vsmall)) title("Distribución del Gasto en Seguros de salud - estado_laboral") ///
		name(estado_laboral_CGT, replace) 
		graph export "$derived\tables\images\estado_laboral_CG.pdf", as(pdf)replace


// Menores de edad
preserve
collapse (mean) mean=g_diversos530101 (sd) sd=g_diversos530101 (p25) p25=g_diversos530101 (p50) p50=g_diversos530101 (p75) p75=g_diversos530101 (count) count=g_diversos530101 [aw=FEX_C], by(menores)
list 
export excel menores mean sd p25 p50 p75 count using "$derived\tables\descriptivas.xlsx", sheet("menores") firstrow(variables)
restore 

tabstat g_diversos530101  [aw=FEX_C], by(menores) stat(mean sd min p25 median p75 max count)
*tabstat g_seguros_salud [aw=FEX_C], by(menores) stat(mean sd min p25 median p75 max count)

		twoway (kdensity g_diversos530101 if menores==0 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if menores==1 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if menores==2 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if menores==3 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if menores==4 [aw=FEX_C], range(0 200000)), ///
		xtitle("Gasto", size(small)) ytitle("Densidad", size(vsmall)) legend(label(1 "0") label(2 "1") label(3 "2") label(4 "3") label(5 "4+") rows(1) pos(6) size(vsmall)) title("Distribución del Gasto en Seguros de salud - Número de niños") ///
		name(menores_CGT, replace) 
		graph export "$derived\tables\images\menores_CG.pdf", as(pdf)replace


// Perceptores de ingreso 
preserve
collapse (mean) mean=g_diversos530101 (sd) sd=g_diversos530101 (p25) p25=g_diversos530101 (p50) p50=g_diversos530101 (p75) p75=g_diversos530101 (count) count=g_diversos530101 [aw=FEX_C], by(perceptoresI)
list 
export excel perceptoresI mean sd p25 p50 p75 count using "$derived\tables\descriptivas.xlsx", sheet("perceptoresI") firstrow(variables)
restore 

tabstat g_diversos530101  [aw=FEX_C], by(perceptoresI) stat(mean sd min p25 median p75 max count)
*tabstat g_seguros_salud [aw=FEX_C], by(perceptoresI) stat(mean sd min p25 median p75 max count)

		twoway (kdensity g_diversos530101 if perceptoresI==0 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if perceptoresI==1 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if perceptoresI==2 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if perceptoresI==3 [aw=FEX_C], range(0 200000)), ///
		xtitle("Gasto", size(small)) ytitle("Densidad", size(vsmall)) legend(label(1 "0") label(2 "1") label(3 "2") label(4 "3+") rows(1) pos(6) size(vsmall)) title("Distribución del Gasto en Seguros de salud - Perceptores de ingresos") ///
		name(perceptoresI_CGT, replace) 
		graph export "$derived\tables\images\perceptoresI_CG.pdf", as(pdf)replace
		
		
// Cantidad de personas en el hogar
preserve
collapse (mean) mean=g_diversos530101 (sd) sd=g_diversos530101 (p25) p25=g_diversos530101 (p50) p50=g_diversos530101 (p75) p75=g_diversos530101 (count) count=g_diversos530101 [aw=FEX_C], by(numind)
list 
export excel numind mean sd p25 p50 p75 count using "$derived\tables\descriptivas.xlsx", sheet("numind") firstrow(variables) 
restore 

tabstat g_diversos530101  [aw=FEX_C], by(numind) stat(mean sd min p25 median p75 max count)
*tabstat g_seguros_salud [aw=FEX_C], by(numind) stat(mean sd min p25 median p75 max count)

		twoway (kdensity g_diversos530101 if numind==1 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if numind==2 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if numind==3 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if numind==4 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if numind==5 [aw=FEX_C], range(0 200000)), ///
		xtitle("Gasto", size(small)) ytitle("Densidad", size(vsmall)) legend(label(1 "0") label(2 "1") label(3 "2") label(4 "3") label(5 "4+") rows(1) pos(6) size(vsmall)) title("Distribución del Gasto en Seguros de salud - Número de individuos en el hogar") ///
		name(numind_CGT, replace) 
		graph export "$derived\tables\images\numind_CG.pdf", as(pdf)replace


// Por quintil de ingreso
preserve
collapse (mean) mean=g_diversos530101 (sd) sd=g_diversos530101 (p25) p25=g_diversos530101 (p50) p50=g_diversos530101 (p75) p75=g_diversos530101 (count) count=g_diversos530101 [aw=FEX_C], by(quintil_ciudadMed)
list 
export excel quintil_ciudadMed mean sd p25 p50 p75 count using "$derived\tables\descriptivas.xlsx", sheet("quintil_ciudad") firstrow(variables) 
restore 

tabstat g_diversos530101  [aw=FEX_C], by(quintil_ciudadMed) stat(mean sd min p25 median p75 max count)
*tabstat g_seguros_salud [aw=FEX_C], by(quintil_ciudadMed) stat(mean sd min p25 median p75 max count)

		twoway (kdensity g_diversos530101 if quintil_ciudadMed==1 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if quintil_ciudadMed==2 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if quintil_ciudadMed==3 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if quintil_ciudadMed==4 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if quintil_ciudadMed==5 [aw=FEX_C], range(0 200000)), ///
		xtitle("Gasto", size(small)) ytitle("Densidad", size(vsmall)) legend(label(1 "1") label(2 "2") label(3 "3") label(4 "4") label(5 "5") rows(1) pos(6) size(vsmall)) title("Distribución del Gasto en Seguros de salud - Quintil de ingreso") ///
		name(quintil_ciudadMed_CGT, replace) 
		graph export "$derived\tables\images\quintil_ciudadMed_CG.pdf", as(pdf)replace

	
// Por estrato 
preserve
collapse (mean) mean=g_diversos530101 (sd) sd=g_diversos530101 (p25) p25=g_diversos530101 (p50) p50=g_diversos530101 (p75) p75=g_diversos530101 (count) count=g_diversos530101 [aw=FEX_C], by(strata)
list 
export excel strata mean sd p25 p50 p75 count using "$derived\tables\descriptivas.xlsx", sheet("strata") firstrow(variables) 
restore 

tabstat g_diversos530101  [aw=FEX_C], by(strata) stat(mean sd min p25 median p75 max count)
*tabstat g_seguros_salud [aw=FEX_C], by(strata) stat(mean sd min p25 median p75 max count)

		twoway (kdensity g_diversos530101 if strata==1 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if strata==2 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if strata==3 [aw=FEX_C], range(0 200000)) ///
		(kdensity g_diversos530101 if strata==4 [aw=FEX_C], range(0 200000)), ///
		xtitle("Gasto", size(small)) ytitle("Densidad", size(vsmall)) legend(label(1 "0-1") label(2 "2") label(3 "3") label(4 "4+") rows(1) pos(6) size(vsmall)) title("Distribución del Gasto en Seguros de salud - Estrato") ///
		name(strata_CGT, replace) 
		graph export "$derived\tables\images\strata_CG.pdf", as(pdf)replace

		graph close _all
}


*------------------------------------------------------------------------------*
* SEGUROS EN SALUD (MEDICINA PREPAGADA Y SEGUROS ESPECÍFICOS)
*------------------------------------------------------------------------------*
if 1==1{
// Por ciudad, region y sector
preserve
drop if DOMINIO==10 | DOMINIO==22 | DOMINIO==30

recode DOMINIO 	(1=1 "Arauca")(2=2 "Armenia")(3=3 "Barrancabermeja")(4=4 "Barranquilla")(5=5 "Bogotá") ///
				(6=6 "Bucaramanga y A.M")(7=7 "Buenaventura")(8=8 "Cali")(9=9 "Cartagena")(11=10 "Cúcuta") ///
				(12=11 "Florencia")(13=12 "Ibagué")(14=13 "Inírida")(15=14 "Leticia")(16=15 "Manizales y A.M") ///
				(17=16 "Medellín y A.M")(18=17 "Mitú")(19=18 "Mocoa")(20=19 "Montería")(21=20 "Neiva")(23=21 "Pasto") ///
				(24=22 "Pereira y A.M")(25=23 "Popayán")(26=24 "Puerto Carreño")(27=25 "Quibdó")(28=26 "Riohacha") ///
				(29=27 "Rionegro")(31=28 "San Andrés")(32=29 "San José del Guaviare")(33=30 "Santa Marta")(34=31 "Sincelejo") ///
				(35=32 "Soledad")(36=33 "Tumaco")(37=34 "Tunja")(38=35 "Valledupar")(39=36 "Villavicencio")(40=37 "Yopal")(41=38 "Yumbo"), gen(ciudad)


tabstat seguros_salud1 [aw=FEX_C], by(ciudad) stat(mean sd min p25 median p75 max count)
*tabstat g_seguros_salud [aw=FEX_C], by(ciudad) stat(mean sd min p25 median p75 max count)

		twoway (kdensity seguros_salud1 if ciudad==1 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if ciudad==3 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if ciudad==14 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if ciudad==17 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if ciudad==19 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if ciudad==30 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if ciudad==32 [aw=FEX_C], range(0 200000)), ///
		xtitle("Gasto", size(small)) ytitle("Densidad", size(vsmall)) legend(label(1 "Arauca") label(2 "Barrancabermeja") label(3 "Puerto Inírida") label(4 "Leticia") label(5 "Mitú") label(6 "Montería") label(7 "Quibdó") label(8 "San Andrés") label(9 "Santa Marta") label(10 "Soledad") rows(3) pos(6) size(vsmall)) title("Cuartil 1") ///
		name(ciudades_1CGT, replace) 

		twoway (kdensity seguros_salud1 if ciudad==11 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if ciudad==22 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if ciudad==26 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if ciudad==33 [aw=FEX_C], range(0 200000)), ///
		xtitle("Gasto", size(small)) ytitle(" ", size(vsmall)) legend(label(1 "Florencia") label(2 "Pereira") label(3 "Riohacha") label(4 "Tumaco") rows(3) pos(6) size(vsmall)) title("Cuartil 2") ///
		name(ciudades_2CGT, replace) 
		
		twoway (kdensity seguros_salud1 if ciudad==2 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if ciudad==4 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if ciudad==10 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if ciudad==12 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if ciudad==23 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if ciudad==27 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if ciudad==31 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if ciudad==37 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if ciudad==38 [aw=FEX_C], range(0 200000)), ///
		xtitle("Gasto", size(small)) ytitle(" ", size(vsmall)) legend(label(1 "Armenia") label(2 "Barranquilla") label(3 "Cartagena") label(4 "Cúcuta") label(5 "Ibagué") label(6 "Popayán") label(7 "Rionegro") label(8 "Sincelejo") label(9 "Yopal") label(10 "Yumbo") rows(3) pos(6) size(vsmall)) title("Cuartil 3") ///
		name(ciudades_3CGT, replace) 

		twoway (kdensity seguros_salud1 if ciudad==5 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if ciudad==6 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if ciudad==8 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if ciudad==15 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if ciudad==16 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if ciudad==20 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if ciudad==21 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if ciudad==34 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if ciudad==36 [aw=FEX_C], range(0 200000)), ///
		xtitle("Gasto", size(small)) ytitle("Densidad", size(vsmall)) legend(label(1 "Bogotá") label(2 "Bucaramanga") label(3 "Cali") label(4 "Manizales") label(5 "Medellín") label(6 "Neiva") label(7 "Pasto") label(8 "Tunja") label(9 "Villavicencio") rows(3) pos(6) size(vsmall)) title("Cuartil 4") ///
		name(ciudades_4CGT, replace) 

		graph combine ciudades_1CGT ciudades_2CGT ciudades_3CGT ciudades_4CGT , r(2) c(2) ///
		title("Distribución del gasto en Seguros relacionados con salud", size(small)) subtitle("Por ciudades", size(vsmall)) note("Fuente: ENPH - Cálculos propios.", size(vsmall)) scale(0.8) name(graphcomb, replace)   
		
				
		graph export "$derived\tables\images\ciudades_CG.pdf", as(pdf)replace
		graph close _all	
restore 

tabstat seguros_salud1 [aw=FEX_C], by(REGION) stat(mean sd min p25 median p75 max count)
*tabstat g_seguros_salud [aw=FEX_C], by(REGION) stat(mean sd min p25 median p75 max count)

		twoway (kdensity seguros_salud1 if REGION==1 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if REGION==2 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if REGION==3 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if REGION==4 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if REGION==5 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if REGION==6 [aw=FEX_C], range(0 200000)), ///
		xtitle("Gasto", size(small)) ytitle("Densidad", size(vsmall)) legend(label(1 "Atlántica") label(2 "Bogotá") label(3 "Central") label(4 "Nuevos Departamentos") label(5 "Oriental") label(6 "Pacífica") rows(1) pos(6) size(vsmall)) title("Distribución del Gasto en Seguros de salud - Regiones") ///
		name(region_CGT, replace) 
		graph export "$derived\tables\images\regiones_CG.pdf", as(pdf)replace

tabstat seguros_salud1 [aw=FEX_C], by(sector) stat(mean sd min p25 median p75 max count)
*tabstat g_seguros_salud [aw=FEX_C], by(sector) stat(mean sd min p25 median p75 max count)

		twoway (kdensity seguros_salud1 if sector==0 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if sector==1 [aw=FEX_C], range(0 200000)), ///
		xtitle("Gasto", size(small)) ytitle("Densidad", size(vsmall)) legend(label(1 "Rural") label(2 "Urbano") rows(1) pos(6) size(vsmall)) title("Distribución del Gasto en Seguros de salud - Sector") ///
		name(sector_CGT, replace) 
		graph export "$derived\tables\images\sectores_CG.pdf", as(pdf)replace


// Nivel educativo del jefe
tabstat seguros_salud1  [aw=FEX_C], by(educacion1) stat(mean sd min p25 median p75 max count)
*tabstat g_seguros_salud [aw=FEX_C], by(educacion1) stat(mean sd min p25 median p75 max count)


		twoway (kdensity seguros_salud1 if educacion1==1 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if educacion1==2 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if educacion1==3 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if educacion1==4 [aw=FEX_C], range(0 200000)), ///
		xtitle("Gasto", size(small)) ytitle("Densidad", size(vsmall)) legend(label(1 "Preescolar") label(2 "Primaria") label(3 "Bachillerato") label(4 "Superior") rows(1) pos(6) size(vsmall)) title("Distribución del Gasto en Seguros de salud - Educacion") ///
		name(educacion1_CGT, replace) 
		graph export "$derived\tables\images\educacion_CG.pdf", as(pdf)replace

// Género del jefe
tabstat seguros_salud1  [aw=FEX_C], by(genero) stat(mean sd min p25 median p75 max count)
*tabstat g_seguros_salud [aw=FEX_C], by(genero) stat(mean sd min p25 median p75 max count)

		twoway (kdensity seguros_salud1 if genero==0 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if genero==1 [aw=FEX_C], range(0 200000)), ///
		xtitle("Gasto", size(small)) ytitle("Densidad", size(vsmall)) legend(label(1 "Mujer") label(2 "Hombre") rows(1) pos(6) size(vsmall)) title("Distribución del Gasto en Seguros de salud - Genero") ///
		name(genero_CGT, replace) 
		graph export "$derived\tables\images\genero_CG.pdf", as(pdf)replace
		
// Ocupacion del jefe 
tabstat seguros_salud1  [aw=FEX_C], by(ocupacion) stat(mean sd min p25 median p75 max count)
*tabstat g_seguros_salud [aw=FEX_C], by(ocupacion) stat(mean sd min p25 median p75 max count)


		twoway (kdensity seguros_salud1 if ocupacion==1 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if ocupacion==2 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if ocupacion==3 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if ocupacion==4 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if ocupacion==5 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if ocupacion==8 [aw=FEX_C], range(0 200000)), ///
		xtitle("Gasto", size(small)) ytitle("Densidad", size(vsmall)) legend(label(1 "Obrero particular") label(2 "Obrero gobierno") label(3 "Empleado doméstico") label(4 "Trabajador cuenta propia") label(5 "Patrón") label(6 "Jornalero o peón") rows(2) pos(6) size(vsmall)) title("Distribución del Gasto en Seguros de salud - Ocupacion") ///
		name(ocupacion_CGT, replace) 
		graph export "$derived\tables\images\ocupaciones_CG.pdf", as(pdf)replace

// Estado laboral del jefe
tabstat seguros_salud1  [aw=FEX_C], by(estado_laboral) stat(mean sd min p25 median p75 max count)
*tabstat g_seguros_salud [aw=FEX_C], by(estado_laboral) stat(mean sd min p25 median p75 max count)

		twoway (kdensity seguros_salud1 if estado_laboral==1 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if estado_laboral==2 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if estado_laboral==3 [aw=FEX_C], range(0 200000)), ///
		xtitle("Gasto", size(small)) ytitle("Densidad", size(vsmall)) legend(label(1 "Ocupado") label(2 "Desocupado") label(3 "Inactivo") rows(1) pos(6) size(vsmall)) title("Distribución del Gasto en Seguros de salud - estado_laboral") ///
		name(estado_laboral_CGT, replace) 
		graph export "$derived\tables\images\estado_laboral_CG.pdf", as(pdf)replace


// Menores de edad
tabstat seguros_salud1  [aw=FEX_C], by(menores) stat(mean sd min p25 median p75 max count)
*tabstat g_seguros_salud [aw=FEX_C], by(menores) stat(mean sd min p25 median p75 max count)

		twoway (kdensity seguros_salud1 if menores==0 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if menores==1 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if menores==2 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if menores==3 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if menores==4 [aw=FEX_C], range(0 200000)), ///
		xtitle("Gasto", size(small)) ytitle("Densidad", size(vsmall)) legend(label(1 "0") label(2 "1") label(3 "2") label(4 "3") label(5 "4+") rows(1) pos(6) size(vsmall)) title("Distribución del Gasto en Seguros de salud - Número de niños") ///
		name(menores_CGT, replace) 
		graph export "$derived\tables\images\menores_CG.pdf", as(pdf)replace


// Perceptores de ingreso 
tabstat seguros_salud1  [aw=FEX_C], by(perceptoresI) stat(mean sd min p25 median p75 max count)
*tabstat g_seguros_salud [aw=FEX_C], by(perceptoresI) stat(mean sd min p25 median p75 max count)

		twoway (kdensity seguros_salud1 if perceptoresI==0 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if perceptoresI==1 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if perceptoresI==2 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if perceptoresI==3 [aw=FEX_C], range(0 200000)), ///
		xtitle("Gasto", size(small)) ytitle("Densidad", size(vsmall)) legend(label(1 "0") label(2 "1") label(3 "2") label(4 "3+") rows(1) pos(6) size(vsmall)) title("Distribución del Gasto en Seguros de salud - Perceptores de ingresos") ///
		name(perceptoresI_CGT, replace) 
		graph export "$derived\tables\images\perceptoresI_CG.pdf", as(pdf)replace
		
		
// Cantidad de personas en el hogar
tabstat seguros_salud1  [aw=FEX_C], by(numind) stat(mean sd min p25 median p75 max count)
*tabstat g_seguros_salud [aw=FEX_C], by(numind) stat(mean sd min p25 median p75 max count)

		twoway (kdensity seguros_salud1 if numind==1 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if numind==2 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if numind==3 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if numind==4 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if numind==5 [aw=FEX_C], range(0 200000)), ///
		xtitle("Gasto", size(small)) ytitle("Densidad", size(vsmall)) legend(label(1 "0") label(2 "1") label(3 "2") label(4 "3") label(5 "4+") rows(1) pos(6) size(vsmall)) title("Distribución del Gasto en Seguros de salud - Número de individuos en el hogar") ///
		name(numind_CGT, replace) 
		graph export "$derived\tables\images\numind_CG.pdf", as(pdf)replace


// Por quintil de ingreso
tabstat seguros_salud1  [aw=FEX_C], by(quintil_ciudadMed) stat(mean sd min p25 median p75 max count)
*tabstat g_seguros_salud [aw=FEX_C], by(quintil_ciudadMed) stat(mean sd min p25 median p75 max count)

		twoway (kdensity seguros_salud1 if quintil_ciudadMed==1 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if quintil_ciudadMed==2 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if quintil_ciudadMed==3 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if quintil_ciudadMed==4 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if quintil_ciudadMed==5 [aw=FEX_C], range(0 200000)), ///
		xtitle("Gasto", size(small)) ytitle("Densidad", size(vsmall)) legend(label(1 "1") label(2 "2") label(3 "3") label(4 "4") label(5 "5") rows(1) pos(6) size(vsmall)) title("Distribución del Gasto en Seguros de salud - Quintil de ingreso") ///
		name(quintil_ciudadMed_CGT, replace) 
		graph export "$derived\tables\images\quintil_ciudadMed_CG.pdf", as(pdf)replace

	
// Por estrato 
tabstat seguros_salud1  [aw=FEX_C], by(strata) stat(mean sd min p25 median p75 max count)
*tabstat g_seguros_salud [aw=FEX_C], by(strata) stat(mean sd min p25 median p75 max count)

		twoway (kdensity seguros_salud1 if strata==1 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if strata==2 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if strata==3 [aw=FEX_C], range(0 200000)) ///
		(kdensity seguros_salud1 if strata==4 [aw=FEX_C], range(0 200000)), ///
		xtitle("Gasto", size(small)) ytitle("Densidad", size(vsmall)) legend(label(1 "0-1") label(2 "2") label(3 "3") label(4 "4+") rows(1) pos(6) size(vsmall)) title("Distribución del Gasto en Seguros de salud - Estrato") ///
		name(strata_CGT, replace) 
		graph export "$derived\tables\images\strata_CG.pdf", as(pdf)replace

		graph close _all
}



