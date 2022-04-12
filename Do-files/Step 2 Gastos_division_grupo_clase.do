* Author: Susana Otálvaro-Ramírez
* Date: 2019.01.27
* Goal: Construct database of household and individuals (Cuadernillo 1)


glo data "C:\Users\\`c(username)'\Dropbox\tabacoDrive\Seguros\Data" 
glo derived "C:\Users\\`c(username)'\Dropbox\tabacoDrive\Seguros\Derived" 


*glo data "F:\paul.rodriguez\Dropbox\tabaco\tabacoDrive\Seguros\Data" 
*glo derived "F:\paul.rodriguez\Dropbox\tabaco\tabacoDrive\Seguros\Derived" 

cd 		"$derived"

cap program drop cleanvars
program define cleanvars , rclass
	args lista
	disp "Cleaning! `lista'"
	foreach varDep in `lista'	{
		destring `varDep', replace
		* For yes and no questions, set the "no"s as 0s
		cap recode `varDep' (2=0) ( 9 99 98 =.), g(_`varDep')
		cap drop `varDep'
		cap rename _`varDep' `varDep'
	}
end


cap program drop cleanvars1
program define cleanvars1 , rclass
	args lista
	disp "Cleaning! `lista'"
	foreach varDep in `lista'	{
		destring `varDep', replace
		* For yes and no questions, set the "no"s as 0s
		cap recode `varDep' (9 99 98 999=.), g(_`varDep')
		cap drop `varDep'
		cap rename _`varDep' `varDep'
	}
end


*------------------------------------------------------------------------------*
* Gastos del Hogar
*------------------------------------------------------------------------------*

use 	"$data\Gastos_ENPH.dta", clear 
gen 	division 	= substr(articulo,1,2)
gen 	grupo 		= substr(articulo,1,3)
gen 	clase 		= substr(articulo,1,4)
gen 	subclase 	= substr(articulo,1,6)

/* 1. Gasto en alimentos */

forval j=1(1)2{
egen 	g_alimentos`j' = sum(valor_mensual) if grupo=="01`j'", by(directorio)
egen 	g_alimentos`j'M = max(g_alimentos`j'), by(directorio)
drop 	g_alimentos`j'
rename 	g_alimentos`j'M g_alimentos`j'
}

egen g_alimentos = rowtotal(g_alimentos1 g_alimentos2), missing 

/* 2. Gasto en bebidas alcoholicas, tabaco y estupefacientes */

forval j=1(1)3{
egen 	g_BTE`j' = sum(valor_mensual) if grupo=="02`j'", by(directorio)
egen 	g_BTE`j'M = max(g_BTE`j'), by(directorio)
drop 	g_BTE`j'
rename 	g_BTE`j'M g_BTE`j'
}

egen g_BTE = rowtotal(g_BTE1 g_BTE2 g_BTE3), missing

/* 3. Gasto en vestido y calzado */

forval j=1(1)2{
egen 	g_vestido`j' = sum(valor_mensual) if grupo=="03`j'", by(directorio)
egen 	g_vestido`j'M = max(g_vestido`j'), by(directorio)
drop 	g_vestido`j'
rename 	g_vestido`j'M g_vestido`j'
}

egen g_vestido = rowtotal(g_vestido1 g_vestido2), missing

/* 4. Gasto en servicios del hogar */

forval j=1(1)5{
egen 	g_servicios`j' = sum(valor_mensual) if grupo=="04`j'", by(directorio)
egen 	g_servicios`j'M = max(g_servicios`j'), by(directorio)
drop 	g_servicios`j'
rename 	g_servicios`j'M g_servicios`j'
}


egen g_servicios = rowtotal(g_servicios1 g_servicios2 g_servicios3 g_servicios4 g_servicios5), missing

/* 5. Gasto en muebles */

egen 	g_muebles = sum(valor_mensual) if division=="05", by(directorio)
egen 	g_mueblesM = max(g_muebles), by(directorio)

drop 	g_muebles 
rename 	g_mueblesM g_muebles

/* 6. Gasto en salud */

** Productos farmacéuticos
egen 	g_salud1101 = sum(valor_mensual) if subclase=="061101", by(directorio)
egen 	g_salud1101M = max(g_salud1101), by(directorio)

egen 	g_salud1102 = sum(valor_mensual) if subclase=="061102", by(directorio)
egen 	g_salud1102M = max(g_salud1102), by(directorio)

egen 	g_salud1104 = sum(valor_mensual) if subclase=="061104", by(directorio)
egen 	g_salud1104M = max(g_salud1104), by(directorio)

egen 	g_salud1199 = sum(valor_mensual) if subclase=="061199", by(directorio)
egen 	g_salud1199M = max(g_salud1199), by(directorio)

egen 	g_salud1201 = sum(valor_mensual) if subclase=="061201", by(directorio)
egen 	g_salud1201M = max(g_salud1201), by(directorio)

egen 	g_salud1202 = sum(valor_mensual) if subclase=="061202", by(directorio)
egen 	g_salud1202M = max(g_salud1202), by(directorio)

egen 	g_salud1301 = sum(valor_mensual) if subclase=="061301", by(directorio)
egen 	g_salud1301M = max(g_salud1301), by(directorio)

drop 	g_salud1101 g_salud1102 g_salud1104 g_salud1199 g_salud1201 g_salud1202 g_salud1301
rename 	g_salud1101M g_salud1101
rename 	g_salud1102M g_salud1102
rename 	g_salud1104M g_salud1104
rename 	g_salud1199M g_salud1199
rename 	g_salud1201M g_salud1201
rename 	g_salud1202M g_salud1202
rename 	g_salud1301M g_salud1301

** Servicios a pacientes externos
egen 	g_salud2101 = sum(valor_mensual) if subclase=="062101", by(directorio)
egen 	g_salud2101M = max(g_salud2101), by(directorio)

egen 	g_salud2102 = sum(valor_mensual) if subclase=="062102", by(directorio)
egen 	g_salud2102M = max(g_salud2102), by(directorio)

egen 	g_salud2103 = sum(valor_mensual) if subclase=="062103", by(directorio)
egen 	g_salud2103M = max(g_salud2103), by(directorio)

egen 	g_salud2104 = sum(valor_mensual) if subclase=="062104", by(directorio)
egen 	g_salud2104M = max(g_salud2104), by(directorio)

egen 	g_salud2201 = sum(valor_mensual) if subclase=="062201", by(directorio)
egen 	g_salud2201M = max(g_salud2201), by(directorio)

egen 	g_salud2301 = sum(valor_mensual) if subclase=="062301", by(directorio)
egen 	g_salud2301M = max(g_salud2301), by(directorio)

egen 	g_salud2302 = sum(valor_mensual) if subclase=="062302", by(directorio)
egen 	g_salud2302M = max(g_salud2302), by(directorio)

egen 	g_salud2303 = sum(valor_mensual) if subclase=="062303", by(directorio)
egen 	g_salud2303M = max(g_salud2303), by(directorio)

egen 	g_salud2304 = sum(valor_mensual) if subclase=="062304", by(directorio)
egen 	g_salud2304M = max(g_salud2304), by(directorio)

egen 	g_salud2401 = sum(valor_mensual) if subclase=="062401", by(directorio)
egen 	g_salud2401M = max(g_salud2401), by(directorio)

egen 	g_salud2402 = sum(valor_mensual) if subclase=="062402", by(directorio)
egen 	g_salud2402M = max(g_salud2402), by(directorio)

drop 	g_salud2101 g_salud2102 g_salud2103 g_salud2104 g_salud2201 g_salud2301 g_salud2302 g_salud2303 g_salud2304 g_salud2401 g_salud2402
rename 	g_salud2101M g_salud2101
rename 	g_salud2102M g_salud2102
rename 	g_salud2103M g_salud2103
rename 	g_salud2104M g_salud2104
rename 	g_salud2201M g_salud2201
rename 	g_salud2301M g_salud2301
rename 	g_salud2302M g_salud2302
rename 	g_salud2303M g_salud2303
rename 	g_salud2304M g_salud2304
rename 	g_salud2401M g_salud2401
rename 	g_salud2402M g_salud2402

** Servicios de hospital
egen 	g_salud3001 = sum(valor_mensual) if subclase=="063001", by(directorio)
egen 	g_salud3001M = max(g_salud3001), by(directorio)

egen 	g_salud3002 = sum(valor_mensual) if subclase=="063002", by(directorio)
egen 	g_salud3002M = max(g_salud3002), by(directorio)

egen 	g_salud3003 = sum(valor_mensual) if subclase=="063003", by(directorio)
egen 	g_salud3003M = max(g_salud3003), by(directorio)

egen 	g_salud3004 = sum(valor_mensual) if subclase=="063004", by(directorio)
egen 	g_salud3004M = max(g_salud3004), by(directorio)

drop 	g_salud3001 g_salud3002 g_salud3003 g_salud3004 
rename 	g_salud3001M g_salud3001
rename 	g_salud3002M g_salud3002
rename 	g_salud3003M g_salud3003
rename 	g_salud3004M g_salud3004
		
egen 	g_salud1 = rowtotal(g_salud1101 g_salud1102 g_salud1104 g_salud1199 g_salud1201 g_salud1202 g_salud1301), missing
egen 	g_salud2 = rowtotal(g_salud2101 g_salud2102 g_salud2103 g_salud2104 g_salud2201 g_salud2301 g_salud2302 g_salud2303 g_salud2304 g_salud2401 g_salud2402), missing
egen 	g_salud3 = rowtotal(g_salud3001 g_salud3002 g_salud3003 g_salud3004), missing

egen 	g_prepagada_pagos = rowtotal(g_salud2402 g_salud3004), missing
egen 	g_salud = rowtotal(g_salud1 g_salud2 g_salud3), missing


/* 7. Gasto en transporte */

forval j=1(1)3{
egen 	g_transporte`j' = sum(valor_mensual) if grupo=="07`j'", by(directorio)
egen 	g_transporte`j'M = max(g_transporte`j'), by(directorio)
drop 	g_transporte`j'
rename 	g_transporte`j'M g_transporte`j'
}


egen g_transporte = rowtotal(g_transporte1 g_transporte2 g_transporte3), missing

/* 8. Gasto en comunicaciones */

forval j=1(1)3{
egen 	g_comunicacion`j' = sum(valor_mensual) if grupo=="08`j'", by(directorio)
egen 	g_comunicacion`j'M = max(g_comunicacion`j'), by(directorio)
drop 	g_comunicacion`j'
rename 	g_comunicacion`j'M g_comunicacion`j'
}

egen g_comunicacion = rowtotal(g_comunicacion1 g_comunicacion2 g_comunicacion3), missing

/* 9. Gasto en recreación */

egen 	g_recreacion = sum(valor_mensual) if division=="09", by(directorio)
egen 	g_recreacionM = max(g_recreacion), by(directorio)

drop 	g_recreacion 
rename 	g_recreacionM g_recreacion

/* 10. Gasto en educación */

forval j=1(1)2{
egen 	g_educacion`j' = sum(valor_mensual) if grupo=="10`j'", by(directorio)
egen 	g_educacion`j'M = max(g_educacion`j'), by(directorio)
drop 	g_educacion`j'
rename 	g_educacion`j'M g_educacion`j'
}

forval j=4(1)5{
egen 	g_educacion`j' = sum(valor_mensual) if grupo=="10`j'", by(directorio)
egen 	g_educacion`j'M = max(g_educacion`j'), by(directorio)
drop 	g_educacion`j'
rename 	g_educacion`j'M g_educacion`j'
}


egen g_educacion = rowtotal(g_educacion1 g_educacion2 g_educacion4 g_educacion5), missing

/* 11. Gasto en restaurantes y hoteles */

forval j=1(1)2{
egen 	g_hoteles`j' = sum(valor_mensual) if grupo=="11`j'", by(directorio)
egen 	g_hoteles`j'M = max(g_hoteles`j'), by(directorio)
drop 	g_hoteles`j'
rename 	g_hoteles`j'M g_hoteles`j'
}

egen g_hoteles = rowtotal(g_hoteles1 g_hoteles2), missing 


/* 12. Gasto en bienes y servicios diversos */

** Cuidado personal
egen 	g_diversos1101 = sum(valor_mensual) if subclase=="121101", by(directorio)
egen 	g_diversos1101M = max(g_diversos1101), by(directorio)

egen 	g_diversos1201 = sum(valor_mensual) if subclase=="121201", by(directorio)
egen 	g_diversos1201M = max(g_diversos1201), by(directorio)

egen 	g_diversos1301 = sum(valor_mensual) if subclase=="121301", by(directorio)
egen 	g_diversos1301M = max(g_diversos1301), by(directorio)

egen 	g_diversos1302 = sum(valor_mensual) if subclase=="121302", by(directorio)
egen 	g_diversos1302M = max(g_diversos1302), by(directorio)

egen 	g_diversos1303 = sum(valor_mensual) if subclase=="121303", by(directorio)
egen 	g_diversos1303M = max(g_diversos1303), by(directorio)

egen 	g_diversos1304 = sum(valor_mensual) if subclase=="121304", by(directorio)
egen 	g_diversos1304M = max(g_diversos1304), by(directorio)

egen 	g_diversos1399 = sum(valor_mensual) if subclase=="121399", by(directorio)
egen 	g_diversos1399M = max(g_diversos1399), by(directorio)

drop 	g_diversos1101 g_diversos1201 g_diversos1301 g_diversos1302 g_diversos1303 g_diversos1304 g_diversos1399
rename 	g_diversos1101M g_diversos1101
rename 	g_diversos1201M g_diversos1201
rename 	g_diversos1301M g_diversos1301
rename 	g_diversos1302M g_diversos1302
rename 	g_diversos1303M g_diversos1303
rename 	g_diversos1304M g_diversos1304
rename 	g_diversos1399M g_diversos1399

** Prostitución
egen 	g_diversos2001 = sum(valor_mensual) if subclase=="122001", by(directorio)
egen 	g_diversos2001M = max(g_diversos2001), by(directorio)

drop 	g_diversos2001 
rename 	g_diversos2001M g_diversos2001

** Efectos personales
egen 	g_diversos3101 = sum(valor_mensual) if subclase=="123101", by(directorio)
egen 	g_diversos3101M = max(g_diversos3101), by(directorio)

egen 	g_diversos3102 = sum(valor_mensual) if subclase=="123102", by(directorio)
egen 	g_diversos3102M = max(g_diversos3102), by(directorio)

egen 	g_diversos3103 = sum(valor_mensual) if subclase=="123103", by(directorio)
egen 	g_diversos3103M = max(g_diversos3103), by(directorio)

egen 	g_diversos3201 = sum(valor_mensual) if subclase=="123201", by(directorio)
egen 	g_diversos3201M = max(g_diversos3201), by(directorio)

egen 	g_diversos3202 = sum(valor_mensual) if subclase=="123202", by(directorio)
egen 	g_diversos3202M = max(g_diversos3202), by(directorio)

egen 	g_diversos3203 = sum(valor_mensual) if subclase=="123203", by(directorio)	// Artículos de fumador
egen 	g_diversos3203M = max(g_diversos3203), by(directorio)

egen 	g_diversos3204 = sum(valor_mensual) if subclase=="123204", by(directorio)
egen 	g_diversos3204M = max(g_diversos3204), by(directorio)

egen 	g_diversos3205 = sum(valor_mensual) if subclase=="123205", by(directorio)
egen 	g_diversos3205M = max(g_diversos3205), by(directorio)

drop 	g_diversos3101 g_diversos3102 g_diversos3103 g_diversos3201 g_diversos3202 g_diversos3203 g_diversos3204 g_diversos3205 
rename 	g_diversos3101M g_diversos3101
rename 	g_diversos3102M g_diversos3102
rename 	g_diversos3103M g_diversos3103
rename 	g_diversos3201M g_diversos3201
rename 	g_diversos3202M g_diversos3202
rename 	g_diversos3203M g_diversos3203
rename 	g_diversos3204M g_diversos3204
rename 	g_diversos3205M g_diversos3205

** Protección Social
egen 	g_diversos4001 = sum(valor_mensual) if subclase=="124001", by(directorio)
egen 	g_diversos4001M = max(g_diversos4001), by(directorio)

egen 	g_diversos4002 = sum(valor_mensual) if subclase=="124002", by(directorio)
egen 	g_diversos4002M = max(g_diversos4002), by(directorio)

egen 	g_diversos4003 = sum(valor_mensual) if subclase=="124003", by(directorio)
egen 	g_diversos4003M = max(g_diversos4003), by(directorio)

egen 	g_diversos4004 = sum(valor_mensual) if subclase=="124004", by(directorio)
egen 	g_diversos4004M = max(g_diversos4004), by(directorio)

egen 	g_diversos4005 = sum(valor_mensual) if subclase=="124005", by(directorio)
egen 	g_diversos4005M = max(g_diversos4005), by(directorio)

drop 	g_diversos4001 g_diversos4002 g_diversos4003 g_diversos4004 g_diversos4005
rename 	g_diversos4001M g_diversos4001
rename 	g_diversos4002M g_diversos4002
rename 	g_diversos4003M g_diversos4003
rename 	g_diversos4004M g_diversos4004
rename 	g_diversos4005M g_diversos4005

** Seguros
egen 	g_diversos5101 = sum(valor_mensual) if subclase=="125101", by(directorio)
egen 	g_diversos5101M = max(g_diversos5101), by(directorio)

egen 	g_diversos5201 = sum(valor_mensual) if subclase=="125201", by(directorio)
egen 	g_diversos5201M = max(g_diversos5201), by(directorio)

egen 	g_diversos5301 = sum(valor_mensual) if subclase=="125301", by(directorio)
egen 	g_diversos5301M = max(g_diversos5301), by(directorio)

egen 	g_diversos5401 = sum(valor_mensual) if subclase=="125401", by(directorio)
egen 	g_diversos5401M = max(g_diversos5401), by(directorio)

egen 	g_diversos5599 = sum(valor_mensual) if subclase=="125599", by(directorio)
egen 	g_diversos5599M = max(g_diversos5599), by(directorio)

egen 	g_diversos530101 = sum(valor_mensual) if articulo=="12530101", by(directorio)
egen 	g_diversos530101M = max(g_diversos530101), by(directorio)

egen 	g_diversos530103 = sum(valor_mensual) if articulo=="12530103", by(directorio)
egen 	g_diversos530103M = max(g_diversos530103), by(directorio)

egen seguros_salud1=rowtotal(g_diversos530101 g_diversos530103), missing

drop 	g_diversos5101 g_diversos5201 g_diversos5301 g_diversos5401 g_diversos5599 g_diversos530101 g_diversos530103
rename 	g_diversos5101M g_diversos5101
rename 	g_diversos5201M g_diversos5201
rename 	g_diversos5301M g_diversos5301
rename 	g_diversos5401M g_diversos5401
rename 	g_diversos5599M g_diversos5599
rename 	g_diversos530101M g_diversos530101
rename 	g_diversos530103M g_diversos530103

** Servicios financieros
egen 	g_diversos6101 = sum(valor_mensual) if subclase=="126101", by(directorio)
egen 	g_diversos6101M = max(g_diversos6101), by(directorio)

egen 	g_diversos6201 = sum(valor_mensual) if subclase=="126201", by(directorio)
egen 	g_diversos6201M = max(g_diversos6201), by(directorio)

egen 	g_diversos6202 = sum(valor_mensual) if subclase=="126202", by(directorio)
egen 	g_diversos6202M = max(g_diversos6202), by(directorio)

egen 	g_diversos6203 = sum(valor_mensual) if subclase=="126203", by(directorio)
egen 	g_diversos6203M = max(g_diversos6203), by(directorio)

drop 	g_diversos6101 g_diversos6201 g_diversos6202 g_diversos6203 
rename 	g_diversos6101M g_diversos6101
rename 	g_diversos6201M g_diversos6201
rename 	g_diversos6202M g_diversos6202
rename 	g_diversos6203M g_diversos6203

** Otros servicios
egen 	g_diversos7001 = sum(valor_mensual) if subclase=="127001", by(directorio)
egen 	g_diversos7001M = max(g_diversos7001), by(directorio)

egen 	g_diversos7002 = sum(valor_mensual) if subclase=="127002", by(directorio)
egen 	g_diversos7002M = max(g_diversos7002), by(directorio)

egen 	g_diversos7003 = sum(valor_mensual) if subclase=="127003", by(directorio)
egen 	g_diversos7003M = max(g_diversos7003), by(directorio)

egen 	g_diversos7004 = sum(valor_mensual) if subclase=="127004", by(directorio)
egen 	g_diversos7004M = max(g_diversos7004), by(directorio)

egen 	g_diversos7006 = sum(valor_mensual) if subclase=="127006", by(directorio)
egen 	g_diversos7006M = max(g_diversos7006), by(directorio)

egen 	g_diversos7007 = sum(valor_mensual) if subclase=="127007", by(directorio)	// Artículos de fumador
egen 	g_diversos7007M = max(g_diversos7007), by(directorio)

egen 	g_diversos7009 = sum(valor_mensual) if subclase=="127009", by(directorio)
egen 	g_diversos7009M = max(g_diversos7009), by(directorio)

egen 	g_diversos7099 = sum(valor_mensual) if subclase=="127099", by(directorio)
egen 	g_diversos7099M = max(g_diversos7099), by(directorio)

drop 	g_diversos7001 g_diversos7002 g_diversos7003 g_diversos7004 g_diversos7006 g_diversos7007 g_diversos7009 g_diversos7099 
rename 	g_diversos7001M g_diversos7001
rename 	g_diversos7002M g_diversos7002
rename 	g_diversos7003M g_diversos7003
rename 	g_diversos7004M g_diversos7004
rename 	g_diversos7006M g_diversos7006
rename 	g_diversos7007M g_diversos7007
rename 	g_diversos7009M g_diversos7009
rename 	g_diversos7099M g_diversos7099


egen 	g_diversos1 = rowtotal(g_diversos1101 g_diversos1201 g_diversos1301 g_diversos1302 g_diversos1303 g_diversos1304 g_diversos1399), missing
egen 	g_diversos2 = rowtotal(g_diversos2001), missing
egen 	g_diversos3 = rowtotal(g_diversos3101 g_diversos3102 g_diversos3103 g_diversos3201 g_diversos3202 g_diversos3203 g_diversos3204 g_diversos3205), missing
egen 	g_diversos3a = rowtotal(g_diversos3101 g_diversos3102 g_diversos3103 g_diversos3201 g_diversos3202 g_diversos3204 g_diversos3205), missing 
egen 	g_diversos4 = rowtotal(g_diversos4001 g_diversos4002 g_diversos4003 g_diversos4004 g_diversos4005), missing
egen 	g_diversos5 = rowtotal(g_diversos5101 g_diversos5201 g_diversos5301 g_diversos5401 g_diversos5599), missing
egen 	g_diversos5a = rowtotal(g_diversos5101 g_diversos5201 g_diversos5401 g_diversos5599), missing
egen 	g_diversos6 = rowtotal(g_diversos6101 g_diversos6201 g_diversos6202 g_diversos6203), missing
egen 	g_diversos7 = rowtotal(g_diversos7001 g_diversos7002 g_diversos7003 g_diversos7004 g_diversos7006 g_diversos7007 g_diversos7009 g_diversos7099), missing

egen 	g_diversos = rowtotal(g_diversos1 g_diversos2 g_diversos3 g_diversos4 g_diversos5 g_diversos6 g_diversos7), missing

egen 	g_tabacoT = rowtotal(g_diversos3203 g_BTE2), missing

egen 	g_seguros_salud = rowtotal(g_diversos5301 g_prepagada_pagos), missing
save "$derived\PreHogar_gasto.dta", replace 

*------------------------------------------------------------------------------*
* Gastos del Hogar - completa
*------------------------------------------------------------------------------*
collapse (first) g_* seguros_salud1, by(directorio)

rename directorio DIRECTORIO

save "$derived\Hogar_gasto.dta", replace 

use "$derived\Hogar_gasto.dta", clear
merge 1:1 DIRECTORIO using "$derived\Hogar_jefe.dta", nogen

la var g_alimentos1 "Alimentos"
la var g_alimentos2 "Bebidas no alcohólicas"
la var g_alimentos "Alimentos"
la var g_BTE1 "Bebidas alcohólicas"
la var g_BTE2 "Tabaco"
la var g_BTE3 "Estupefacientes"
la var g_BTE "Bebidas alcohólicas, tabaco y estupefacientes" 
la var g_vestido1 "Vestido"
la var g_vestido2 "Calzado"
la var g_vestido "Vestido y calzado"
la var g_servicios1 "Alquiler efectivo"
la var g_servicios2 "Alquiler imputado"
la var g_servicios3 "Conservación y reparación"
la var g_servicios4 "Agua y servicios diversos"
la var g_servicios5 "Electricidad, gas y otros comustibles"
la var g_servicios "Servicios del hogar"
la var g_muebles "Muebles y artículos para el hogar"
la var g_salud1 "Productos y equipos médicos"
la var g_salud1101 "Productos farmacéuticos"
la var g_salud1101 "Productos dermatológicos"
la var g_salud1104 "Fórmula médica completa"
la var g_salud1199 "Otros farmacéuticos"
la var g_salud1201 "Implementos médicos"
la var g_salud1202 "Anticonceptivos de bloqueo"
la var g_salud1301 "Equipo terapéutico"
la var g_salud2 "Servicios pacientes externos"
la var g_salud2101 "Consulta médica general"
la var g_salud2102 "Consulta médica especialista"
la var g_salud2103 "Especialistas ortodoncia"
la var g_salud2104 "Consulta médica bioenergética"
la var g_salud2201 "Servicios odontológicos"
la var g_salud2301 "Rayos X"
la var g_salud2302 "Exámenes de laboratorio"
la var g_salud2303 "Servicios médicos auxiliares"
la var g_salud2304 "Alquiler equipo terapéutico"
la var g_salud2401 "Cuotas moderadoras EPS"
la var g_salud2402 "Bonos medicina prepagada"
la var g_salud3 "Servicios de hospital"
la var g_salud3001 "Atención pacientes internos"
la var g_salud3002 "Atención pacientes particulares"
la var g_salud3003 "Servicios médicos menores"
la var g_salud3004 "Pagos hospitalarios complementarios"
la var g_salud "Salud"
la var g_transporte1 "Adquisición vehículos"
la var g_transporte2 "Funcionamiento transporte"
la var g_transporte3 "Servicios de transporte"
la var g_transporte "Transporte"
la var g_comunicacion1 "Servicios postales"
la var g_comunicacion2 "Equipo telefónico"
la var g_comunicacion3 "Servicios telefónicos"
la var g_comunicacion "Comunicaciones"
la var g_recreacion "Recreación y cultura"
la var g_educacion1 "Preescolar y básica"
la var g_educacion2 "Secundaria"
la var g_educacion4 "Superior"
la var g_educacion5 "No atribuible a ningun nivel"
la var g_educacion "Educacion"
la var g_hoteles1 "Comidas por contrato"
la var g_hoteles2 "Servicios de alojamiento"
la var g_hoteles "Hoteles y restaurantes"
la var g_diversos1 "Cuidado personal"
la var g_diversos1101 "Peluquería y cuidado personal"
la var g_diversos1201 "Electrónicos para cuidado personal"
la var g_diversos1301 "Cuidado y atención personal"
la var g_diversos1302 "Higiene corporal"
la var g_diversos1303 "Higiene oral"
la var g_diversos1304 "Productos de belleza"
la var g_diversos1399 "Otros aseo personal"
la var g_diversos2 "Prostitución"
la var g_diversos2001 "Entretenimiento privado de adultos"
la var g_diversos3 "Efectos personales"
la var g_diversos3a "Efectos personales sin artículos fumador"
la var g_diversos3101 "Artículos piedras preciosas"
la var g_diversos3102 "Relojes, cronómetros, termómetros, etc."
la var g_diversos3103 "Artículos de fantasía"
la var g_diversos3201 "Artículos de viaje"
la var g_diversos3202 "Artículos para bebés"
la var g_diversos3203 "Artículos fumador"
la var g_diversos3204 "Artículos personales"
la var g_diversos3205 "Artículos funerarios"
la var g_diversos4 "Protección social"
la var g_diversos4001 "Protección social dentro y fuera del hogar"
la var g_diversos4002 "Guarderías"
la var g_diversos4003 "Pagos a EPS"
la var g_diversos4004 "Pagos de pensiones y cesantías"
la var g_diversos4005 "Comedores comunitarios"
la var g_diversos5 "Seguros"
la var g_diversos5a "Seguros sin seg. salud"
la var g_diversos5101 "Seguro de vida y educación"
la var g_diversos5201 "Seguro de vivienda"
la var g_diversos5301 "Seguro médico, de accidentes y medicina prepagada"
la var g_diversos5401 "Seguro de vehículos o transporte"
la var g_diversos5599 "Otros seguros"
la var g_diversos530101  "Pago anual medicina prepagada o complementaria"
la var g_diversos530103 "Seguros específicos de salud (maternidad, etc.)"
la var seguros_salud1 "Seguros de salud (Prepagada y seguros específicos)"
la var g_diversos6 "Servicios financieros"
la var g_diversos6101 "Pago de intereses sobre prestamos"
la var g_diversos6201 "Comisión explícita"
la var g_diversos6202 "Adquisición en mercados financieros"
la var g_diversos6203 "Servicios financieros auxiliares"
la var g_diversos7 "Otros servicios"
la var g_diversos7001 "Honorarios"
la var g_diversos7002 "Documentos administrativos"
la var g_diversos7003 "Cuotas a organizaciones"
la var g_diversos7004 "Servicios religiosos"
la var g_diversos7006 "Impuestos"
la var g_diversos7007 "Mesadas a no perceptores de ingreso"
la var g_diversos7009 "Planes protección social externos"
la var g_diversos7099 "Otros pagos por servicios"
la var g_diversos "Bienes y Servicios diversos"

save "$derived\Hogar_gasto_completo.dta", replace 
