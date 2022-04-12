* Author: Susana Otálvaro-Ramírez
* Date: 2019.01.27
* Goal: Construct database of household and individuals (Cuadernillo 1)

if "`c(username)'"=="paul.rodriguez" {
	glo data "F:\paul.rodriguez\Dropbox\tabaco\tabacoDrive\Seguros\Data" 
	glo derived "F:\paul.rodriguez\Dropbox\tabaco\tabacoDrive\Seguros\Derived" 
}
else {
	glo data "C:\Users\\`c(username)'\Dropbox\tabacoDrive\Seguros\Data" 
	glo derived "C:\Users\\`c(username)'\Dropbox\tabacoDrive\Seguros\Derived" 
}

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
* Hogar
*------------------------------------------------------------------------------*
if 1==0{
use 	"$data\Viviendas y hogares.dta", clear 
encode DOMINIO, generate(DOM_) label(l_dominio)
encode REGION,  generate(REG_) label(l_REGION)
drop DOMINIO REGION
rename DOM_ DOMINIO
rename REG_ REGION

order VIVIENDA DIRECTORIO SECUENCIA_ENCUESTA SECUENCIA_P ORDEN REGION DOMINIO
la var P8520S1A1 "Estrato tarifa energía"

destring P8520S1 P8520S1A1 P8520S2 P8520S3 P8520S4 P8520S4A1 P8520S5 ///
			P4040 P1647 P5010 P814 P449 P5050 P5070 P5080 P5160 ///
			P5161S1 P5161S1A1 P5161S1A2 P5161S1A3 P5161S1A4 P5161S2 ///
			P5161S2A1 P5161S2A2 P5161S2A3 P5161S2A4 P5090 P917 ///
			P5100S1 P5100S2 P5100S3 P5100S4 P5102 P5103 P5105 P1644M1 ///
			P1644M2 P1644M3 P1644M4 P1644M5 P1644M6 P1644M7 P1644S1 ///
			P1644S3 P1645 P5110 P5140 P5240 P5250 P5230 P1646S1 P1646S2 ///
			P1646S3 P1646S4 P1646S5 P1646S6 P1646S7 P1646S8 P1646S9 ///
			P1646S10 P1646S11 P1646S12 P1646S13 P1646S14 P1646S15 ///
			P1646S16 P1646S17 P1646S18 P1646S19 P1646S20 P1646S21 ///
			P1646S22 P1646S23 P1646S24 P1646S25 P1646S26 P1646S27 ///
			P1646S28 P1646S29 P1646S30 P1646S28A1 P1646S29A1 P6008 ///
			NC2R_CC_P5 NC2R_CC_P6, replace

cleanvars "P8520S1 P8520S2 P8520S3 P8520S4 P8520S5 P4040 P5160 P5161S1 P5161S1A1 P5161S1A2 P5161S1A3 P5161S2 P5161S2A1 P5161S2A2 P5161S2A3 P917 P5102 P5105 P1644M1 P1644M2 P1644M3 P1644M4 P1644M5 P1644M6 P1644M7 P5230 P1646S1 P1646S2 P1646S3 P1646S4 P1646S5 P1646S6 P1646S7 P1646S8 P1646S9 P1646S10 P1646S11 P1646S12 P1646S13 P1646S14 P1646S15 P1646S16 P1646S17 P1646S18 P1646S19 P1646S20 P1646S21 P1646S22 P1646S23 P1646S24 P1646S25 P1646S26 P1646S27 P1646S28 P1646S29 P1646S30 NC2R_CC_P5 NC2R_CC_P6"

tempfile Hogares
save `Hogares'


use 	"$data\Caracteristicas generales personas.dta", clear 
merge n:1 DIRECTORIO using `Hogares'

save "$derived\Hogar_persona.dta", replace
}
*

** Organizar las variables 
use "$derived\Hogar_persona.dta", clear

/*
keep DIRECTORIO SECUENCIA_ENCUESTA SECUENCIA_P FEX_C ORDEN P6020 P6040 P6050 P6090 P6100 P6110 P6120 P6210 ///
	P6210S2 P6210S1 P8520S1A1 REGION DOMINIO P3 P6008 P7050 P6430 P6240 P6250 P6260 ///
	P6270 P6280 P6300 P6310 P6320 P6330 P6340 P6350 P6440 P6500 P6510 P6510S1 ///
	P6510S2 P6590 P6590S1 P6600 P6600S1 P6610 P6610S1 P6620 P6620S1 P6630S1 ///
	P6630S1A1 P6630S2 P6630S2A1 P6630S3 P6630S3A1 P6630S4 P6630S4A1 P6630S5 ///
	P6630S5A1 P6630S6 P6630S6A1 P6640 P6640S1 P6585S1 P6585S1A1 ///
	P6585S1A2 P6585S2 P6585S2A1 P6585S2A2 P6585S3 P6585S3A1 P6585S3A2 P1653S1 ///
	P1653S1A1 P1653S1A2 P1653S2 P1653S2A1 P1653S2A2 P1653S3 P1653S3A1 P1653S3A2 ///
	P1653S4 P1653S4A1 P1653S4A2 P6750 P6760 P550 P6779 P6779S1 P9460 P9460S1 ///
	P7422 P7422S1 P7472 P7472S1 P7500S1 P7500S1A1 P7500S4 P7500S4A1 P7500S5 ///
	P7500S5A1 P7500S2 P7500S2A1 P7500S3 P7500S3A1 P7510S1 P7510S1A1 P7510S2 ///
	P7510S2A1 P7510S3 P7510S3A1 P7510S4 P7510S4A1 P7510S5 P7510S5A1 P7510S6 ///
	P7510S6A1 P7510S10 P7510S10A1 P7510S9 P7510S9A1 P1668S1 P1668S1A2 P1668S1A1 ///
	P1668S1A3 P1668S1A4 P1668S2 P1668S2A1 P1668S2A2 P1668S2A3 P1668S2A4 P1668S3 ///
	P1668S3A1 P1668S3A2 P1668S3A3 P1668S3A4 P1668S4 P1668S4A1 P1668S4A2 P1668S4A3 ///
	P1668S4A4 P1668S5 P1668S5A1 P1668S5A2 P1668S5A3 P1668S5A4 P1668S6 P7513S1 ///
	P7513S1A1 P7513S2 P7513S2A1 P7513S3 P7513S3A1 P7513S4 P7513S4A1 P7513S5 ///
	P7513S5A1 P7513S6 P7513S6A1 P7513S7 P7513S7A1 P7513S7A2 P7513S8 P7513S8A1 ///
	P7513S9 P7513S9A1 P7513S10 P7513S10A1 P7513S11 P7513S11A1 P7513S12 P7513S12A1 ///
	P6920 P6920S1 P6940 P9450S1 P6440 P6450
*/
cleanvars "P6020 P6250 P6260 P6270 P6280 P6300 P6320 P6330 P6340 P6350 P6440 P6510 P6590 P6600 P6610 P6620 P6630S1 P6630S2 P6630S3 P6630S4 P6630S5 P6630S6 P6640 P6585S1 P6585S1A2 P6585S2 P6585S2A2 P6585S3 P6585S3A2 P1653S1 P1653S1A2 P1653S2 P1653S2A2 P1653S3 P1653S3A2 P1653S4 P1653S4A2 P6779 P9460 P7422 P7472 P7500S1 P7500S4 P7500S5 P7500S2 P7500S3 P7510S1 P7510S2 P7510S3 P7510S4 P7510S5 P7510S6 P7510S10 P7510S9 P1668S1 P1668S1A2 P1668S1A3 P1668S2 P1668S2A3 P1668S3 P1668S3A1 P1668S3A3 P1668S4 P1668S4A1 P1668S4A3 P1668S5 P1668S5A1 P1668S5A3 P1668S6 P7513S1 P7513S2 P7513S3 P7513S4 P7513S5 P7513S6 P7513S7 P7513S8 P7513S9 P7513S10 P7513S11 P7513S12 P6090 P6440 P5170 P5180 P6060 P6081 P6083 P6071 P6160 P6170 P6175 P6180 P8610 P8612 P1664 P1652S1 P1652S2 P1651 P7040 P7310 P7516 P5240 P5180 P6060 P6071 P6160 P6170 P8520S1 P8520S2 P8520S3 P8520S4 P8520S5 P4040 P5160 P5161S1 P5161S1A1 P5161S1A3 P5161S2 P5161S2A1 P5161S2A3 P917 P5102 P5105 P5230 P1646S1 P1646S2 P1646S3 P1646S4 P1646S5 P1646S6 P1646S7 NC2R_CC_P6 P1646S8 P1646S9 P1646S10 P1646S11 P1646S12 P1646S13 P1646S14 P1646S15 P1646S16 P1646S17 NC2R_CC_P5 P1646S18 P1646S19 P1646S20 P1646S21 P1646S22 P1646S23 P1646S24 P1646S25 P1646S26 P1646S27 P1646S28 P1646S29 P1646S30 P1652S1 P1652S2 P1651 P7040 P7310 P6990 P9450 P7514 P7516 "
cleanvars1 "P6210 P6210S1 P6210S2 P8520S1A1 P7050 P6430 P6500 P6510S1 P6510S2 P6590S1 P6600S1 P6610S1 P6620S1 P6630S1A1 P6630S2A1 P6630S3A1 P6630S4A1 P6630S5A1 P6630S6A1 P6640S1 P6585S1A1 P6585S2A1 P6585S3A1 P1653S1A1 P1653S2A1 P1653S3A1 P1653S4A1 P6750 P550 P6779S1 P9460S1 P7422S1 P7472S1 P7500S1A1 P7500S4A1 P7500S5A1 P7500S2A1 P7500S3A1 P7510S1A1 P7510S2A1 P7510S3A1 P7510S4A1 P7510S5A1 P7510S6A1 P7510S10A1 P7510S9A1 P1668S1A1 P1668S1A4 P1668S2A1 P1668S2A2 P1668S2A4 P1668S3A2 P1668S3A4 P1668S4A2 P1668S4A4 P1668S5A2 P1668S5A4 P7513S1A1 P7513S2A1  P7513S3A1 P7513S4A1 P7513S5A1 P7513S6A1 P7513S7A1 P7513S7A2 P7513S8A1 P7513S9A1 P7513S10A1 P7513S11A1 P7513S12A1 P6120 P6990 P9450 P7514 "

** Características generales - vivienda
/* *P6080 P6081 P6083 P5747 P448 P811 P8520S4A1 P1647 P5010 P814 P449 P5050 P5070 
* P5080 P5090  P5240 P1646S28A1 P1646S29A1 // Categoricas
* P5170 P5180 P6060 P6071 P6160 P6170 P8520S1 P8520S2 P8520S3 P8520S4 P8520S5 P4040 P5160 P5161S1 P5161S1A1 P5161S1A3 P5161S2 P5161S2A1 P5161S2A3 P917 P5102 P5105 P5230 P1646S1 P1646S2 P1646S3 P1646S4 P1646S5 P1646S6 P1646S7 NC2R_CC_P6 P1646S8 P1646S9 P1646S10 P1646S11 P1646S12 P1646S13 P1646S14 P1646S15 P1646S16 P1646S17 NC2R_CC_P5 P1646S18 P1646S19 P1646S20 P1646S21 P1646S22 P1646S23 P1646S24 P1646S25 P1646S26 P1646S27 P1646S28 P1646S29 P1646S30 // Binarias
P1645 P5110 P5140 P5250 P5161S1A2 P5161S2A2 // Continuas (valores) */

** Educación
/* P6236 // Categoricas
P6175 P6180 P8610 P8612 P1664 // Binarias */


** Ocupados
/* P1652S1 P1652S2 P1651 P7040 P7310 P6990 P9450 P7514 P7516  // Binarias
P6426 P6790 P6800 P6850 P7045 // Continuas (Meses, días, horas de trabajo)
P6765 P549 P6830 P6871 P6880 P9450S2 // Categoricas */

foreach variable in P6080 P6081 P6083 P5747 P448 P811 P8520S4A1 P1647 P5010 P814 P449 P5050 P5070 P5080 P5090  P5240 P1646S28A1 P1646S29A1 P6236 P6765 P549 P6830 P6871 P6880 P9450S2 {
qui tab `variable', g(`variable'_)
}
*

** Variables socioeconómicas básicas 
* Numero de personas en el hogar
recode P6008 (1/2=1 "1-2") (3=2 "3")(4=3 "4")(5/25=4 "5+"), g(personas_hogarS)

* Rural - Urbano 
gen sector=P3==1 
la var sector "Urbano - Rural"

* Estrato (energía)
rename P8520S1A1 estrato

* Edad (jefe)
gen edad=P6040

* Ocupacion (jefe)
gen 	ocupacion=P6430 if P6430!=. 
replace ocupacion=P7050 if P6430==. & P7050!=. 


* Contrato Laboral
egen contratoJ = sum(P6440==1 & ORDEN==1) , by(DIRECTORIO)

egen contratoC = sum(P6440==1) , by(DIRECTORIO)
gen contratoQ = (contratoC>0)
drop contratoC 


* Cotizantes de pension 
replace P6920=0 if P6920==2
egen pensionJ = sum(P6920==1 & ORDEN==1) , by(DIRECTORIO)

egen pensionC = sum(P6920==1) , by(DIRECTORIO)
gen pensionQ = (pensionC>0)
drop pensionC 


* Genero 
rename P6020 genero 

*Empleo 
gen PET_dummy =((edad>=10 & sector==0) | (edad>=12 & sector==1))

gen ocupados  = 1 if P6240==1 | P6250==1 | P6260==1 | P6270==1
gen inactivos = 1 if P6240==5 | P6300==0 | P6310==9 | P6310==10 | P6310==11 | P6310==12 | P6330==0 | P6340==0 | P6350==0
gen desocupados = 1 if P6350==1

count if PET_dummy==1 & ocupados!=1 & inactivos!=1 & desocupados==. 


* Afiliacion a salud & regimen de salud
rename P6090 afiliacion 
egen av_afiliacion=mean(afiliacion), by(DIRECTORIO) // Hay cosas raras aquí, hay personas dentro del hogar sin afiliación a salud
egen n_afiliacion=sum(afiliacion), by(DIRECTORIO) // Miembros afiliados a salud

gen afili1_hogar=(n_afiliacion>0) // Al menos un individuo esta afiliado en seguridad social salud
gen afiliT_hogar=(n_afiliacion==P6008) // Todos los miembros del hogar estan afiliados a salud


* Regimen de salud
recode P6100 (1=1 "Contributivo")(2=3 "Especial")(3=2 "Subsidiado"), g(regimen_salud)
replace regimen_salud=. if regimen_salud==9 | regimen_salud==3

egen av_regimen=mean(regimen_salud), by(DIRECTORIO) // No todos los miembros del hogar pertenecen al mismo regimen de salud

tab regimen_salud, g(reg_)

egen contr_hogar=sum(reg_1), by(DIRECTORIO)
egen subsi_hogar=sum(reg_2), by(DIRECTORIO)

gen contr1_hogar=(contr_hogar>0) // Al menos un individuo esta en regimen contributivo
gen contrT_hogar=(contr_hogar==P6008) // Todos los miembros del hogar estan en contributivo

gen subsi1_hogar=(subsi_hogar>0) // Al menos un individuo esta en regimen subsiibutivo
gen subsiT_hogar=(subsi_hogar==P6008) // Todos los miembros del hogar estan en subsiibutivo


* Informalidad 
*********** DEFINICION  FUERTE *************

// Asalariados: 
* pertenecen al regimen contributivo o especial de salud como cotizntes y no como beneficiarios
* estan cotizando a un fondo de pensiones oestan pensionados
* tienen contrato escrito de trabajo

// Cuenta propia: 
* pertenecen al regimen contributivo o especial de salud como cotizantrs y no como beneficiarios 
* Estan cotizando a un fondo de pensiones o estan pensionados

gen informal = (reg_1==0 & P6920==0 & P6440==0 & ocupados==1)   // Individuo informal incluyendo definicion de afiliacion a salud

egen infor_hogar=sum(informal), by(DIRECTORIO)  // Numero de miembros informales en el hogar

gen infor1_hogar=(infor_hogar>0) // Al menos un individuo es informal
gen inforJ_hogar=(infor_hogar==1 & ORDEN==1) // Jefe de hogar es informal
gen inforT_hogar=(infor_hogar==P6008) // Todos los miembros del hogar son informales

* Pago de la seguridad social en salud
recode P6110 (1=1 "Mixto")(2/3=2 "Descontado")(4=3 "Beneficiario")(5=4 "Empresa"), g(qpago_salud)
replace qpago_salud=. if qpago_salud==9

rename P6120 vpago_salud

egen vTpago_salud= sum(vpago_salud), by(DIRECTORIO)

* Numero de niños y adultos
egen numnin = sum(edad < 18), by(DIRECTORIO)
egen numadu = sum(edad > 17), by(DIRECTORIO)
egen men5 	= sum(edad < 5), by(DIRECTORIO)
egen may65 	= sum(edad > 65), by(DIRECTORIO)
gen hheq = 1 + (0.5*(numadu-1)) + (0.3*numnin)
replace hheq = 1 if hheq<1

recode numnin (0=0 "0")(1=1 "1")(2=2 "2")(3=3 "3")(4/12=4 "4+"), gen(menores)

* Nivel educativo (jefe)
la def educ 1 "Ninguno" 2 "Preescolar" 3 "Primaria" 4 "Secundaria" 5 "Media" 6 "Superior/Universitaria"
la val P6210 educ

gen educ_none = P6210==1 | P6210S1==100 | P6210S2==1
gen educ_pree = P6210==2 | P6210S1==200 | P6210S1==201  
gen educ_prim = P6210==3 | P6210S1==300 | P6210S1==301 | P6210S1==302 | P6210S1==303 | P6210S1==304 | P6210S1==305 | P6210S1==400 
gen educ_secu = P6210==4 | P6210S2==2 | P6210S1==406 | P6210S1==407 | P6210S1==408 | P6210S1==409 | P6210S1==500 
gen educ_medi = P6210==5 | P6210S1==510 | P6210S1==511 | P6210S1==512 | P6210S1==600 | P6210S2==3
gen educ_supe = P6210==6 | P6210S1==601 | P6210S1==602 | P6210S1==603 | P6210S1==604 | P6210S1==605 | P6210S1==606 | P6210S1==607 | P6210S1==608 | P6210S1==609 | P6210S1==610  | P6210S1==611 | P6210S1==612 | P6210S1==613 | P6210S1==614 | P6210S1==615 | P6210S2==4 | P6210S2==5


* Ingresos (mensualizacion)
* Descripcion ingresos
if 1==0{
/*
	// Ingresos mensuales 
	P6510 P6510S1 P6510S2 		// Horas extra
	P6590 P6590S1 				// Alimentos (especie)
	P6600 P6600S1 				// Vivienda (especie)
	P6610 P6610S1 				// Transporte (especie)
	P6620 P6620S1 				// Otros (especie)
	P6585S1 P6585S1A1 P6585S1A2 // Auxilio alimentos
	P6585S2 P6585S2A1 P6585S2A2 // Auxilio transporte
	P6585S3 P6585S3A1 P6585S3A2 // Auxilio familiar
	P1653S1 P1653S1A1 P1653S1A2	// Prima técnica o antiguedad
	P1653S2 P1653S2A1 P1653S2A2 // Bonificacion mensual
	P1653S3 P1653S3A1 P1653S3A2 // Viaticos no permanentes
	P1653S4 P1653S4A1 P1653S4A2 // Gastos de representacion
	P6779 P6779S1 				// Viaticos
	P9460 P9460S1 				// Subsidio desempleo
	P7422 P7422S1 				// Ingresos por trabajo
	P7472 P7472S1 
	P7500S1 P7500S1A1 			// Arriendos 
	P7500S4 P7500S4A1 			// Arriendos lotes
	P7500S5 P7500S5A1 			// Arriendos vehiculos
	P7500S2 P7500S2A1 			// Pension invalidez
	P7500S3 P7500S3A1 			// Pension alimentos
	
	
	// Ingresos 12 meses 
	P6630S1 P6630S1A1 		// Prima servicios
	P6630S2 P6630S2A1 		// Prima navidad
	P6630S3 P6630S3A1 		// Prima vacaciones
	P6630S4 P6630S4A1 		// Viaticos permanentes
	P6630S5 P6630S5A1 		// Bonificaciones anuales
	P6630S6 P6630S6A1 		// Accidentes
	P550 					// Ganancia cosecha
	P7510S1 P7510S1A1 		// Dinero otros hogares
	P7510S2 P7510S2A1 		// Fuera del país
	P7510S3 P7510S3A1 		// Entidades nacionales
	P7510S4 P7510S4A1 		// Instituciones extranjeras
	P7510S5 P7510S5A1 		// CDT
	P7510S6	P7510S6A1 		// Cesantías
	P7510S10 P7510S10A1 	// Dividendos
	P7510S9 P7510S9A1 		// Titulos valor
	P1668S1 P1668S1A2 P1668S1A1 P1668S1A3 P1668S1A4 // Más familias en acción
	P1668S2 P1668S2A1 P1668S2A2 P1668S2A3 P1668S2A4 // Adultos mayores
	P1668S3	P1668S3A1 P1668S3A2 P1668S3A3 P1668S3A4 // Familias en su tierra
	P1668S4 P1668S4A1 P1668S4A2 P1668S4A3 P1668S4A4 // Jovenes en accion
	P1668S5 P1668S5A1 P1668S5A2 P1668S5A3 P1668S5A4 // Victimizacion
	P7513S1 P7513S1A1 		// Venta de casas
	P7513S2 P7513S2A1 		// Venta vehiculos
	P7513S3 P7513S3A1 		// Venta semiovientes
	P7513S4 P7513S4A1 		// Venta acciones
	P7513S5	P7513S5A1 		// Reembolso por prestamo
	P7513S6 P7513S6A1 		// Préstamo
	P7513S7 P7513S7A1 	 	// Préstamo particular
	P7513S8 P7513S8A1 		// Indemnizaciones
	P7513S9 P7513S9A1 		// Loterias
	P7513S10 P7513S10A1 	// Herencias
	P7513S11 P7513S11A1 	// Devolucion impuestos
	P7513S12 P7513S12A1		// Reembolso seguros
	
	// Otra frec 
	P6750 P6760 				// Ganancia neta
	
*/
}
*
foreach variable in P6630S1 P6630S2 P6630S3 P6630S4  P6630S5 ///
					P6630S6 P7510S1 P7510S2 P7510S3 P7510S4 ///
					P7510S5 P7510S6	P7510S10 P7510S9 P7513S1 ///
					P7513S2 P7513S3 P7513S4 P7513S5	P7513S6 ///
					P7513S7 P7513S8 P7513S9 P7513S10 P7513S11  ///
					P7513S12 {
		replace `variable'A1=`variable'A1/12 if `variable'A1!=. & `variable'==1
					
					}

		replace P550 = P550/12 if P550!=. // Ganancia cosecha
	
egen 	familias_accion=rowtotal(P1668S1A2 P1668S1A4) if (P1668S1==1 & P1668S1A1==1 )| (P1668S1==1 & P1668S1A3==1)
replace familias_accion=familias_accion/12 if familias_accion!=.
		
egen 	adultos_mayores=rowtotal(P1668S2A2 P1668S2A4) if (P1668S2==1 & P1668S2A1==1) | (P1668S2==1 & P1668S2A3==1)
replace adultos_mayores=adultos_mayores/12 if adultos_mayores!=. 
		
egen 	familias_tierra=rowtotal(P1668S3A2 P1668S3A4) if (P1668S3==1 & P1668S3A1==1) | (P1668S3==1 & P1668S3A3==1)
replace familias_tierra=familias_tierra/12 if familias_tierra!=. 

egen 	jovenes_accion=rowtotal(P1668S4A2 P1668S4A4) if (P1668S4==1 & P1668S4A1==1)| (P1668S4==1 & P1668S4A3==1)
replace jovenes_accion=jovenes_accion/12 if jovenes_accion!=.

egen 	victimizacion=rowtotal(P1668S5A2 P1668S5A4) if (P1668S5==1 & P1668S5A1==1)| (P1668S5==1 & P1668S5A3==1)
replace victimizacion=victimizacion/12 if victimizacion!=.

replace P6750 =  P6750/P6760 if P6750!=. & P6760!=.	// Ganancia neta

egen ingresos= rowtotal(P6510S1 P6630S1A1 P6630S2A1 P6630S3A1 P6630S4A1 P6630S5A1 P6630S6A1 P7510S1A1 P7510S2A1 P7510S3A1 P7510S4A1 P7510S5A1 P7510S6A1 P7510S10A1 P7510S9A1 P7513S1A1 P7513S2A1 P7513S3A1 P7513S4A1 P7513S5A1 P7513S6A1 P7513S7A1 P7513S8A1 P7513S9A1 P7513S10A1 P7513S11A1 P7513S12A1 P550 familias_accion adultos_mayores familias_tierra jovenes_accion victimizacion P6750 P6590S1 P6600S1 P6610S1 P6620S1 P6585S1A1 P6585S2A1 P6585S3A1 P1653S1A1 P1653S2A1 P1653S3A1 P1653S4A1 P6779S1 P9460S1 P7422S1 P7472S1 P7500S1A1 P7500S2A1 P7500S3A1 P7500S4A1 P7500S5A1), missing
		
egen perceptores = sum(edad >= 12 & ingresos!=.), by(DIRECTORIO)



/*
Mercado laboral 
P6240 Actividad semana pasada (Trabajando, buscando, estudiando, oficios del hogar, incapacitado, otro)
P6250 Actividad paga por una hora
P6260 Tenia trabajo por el cual recibe ingresos (no trabajó)
P6270 Actividad no paga por una hora
P6280 Busco trabajo (4 semanas)
P6300 Desea conseguir trabajo
P6310 Razón no busco (4 semanas)
P6320 Busco trabajo por 2 semanas (12 meses)
P6330 Busca trabajo desde ultimo empleo
P6340 usca trabajo (12 meses)
P6350 Disponible
*/

 	
*------------------------------------------------------------------------------*
* Base final para pegar con gastos
*------------------------------------------------------------------------------*
	
sort DIRECTORIO ORDEN 

collapse (first) REGION sector DOMINIO FEX_C ORDEN estrato P6050 edad ///
				genero personas_hogarS perceptores numnin men5 may65 ///
				numadu hheq educ_none educ_pree educ_prim ///
				educ_secu educ_medi educ_supe ocupacion ///
				contratoJ contratoQ pensionJ pensionQ qpago_salud vTpago_salud ///
				afili1_hogar afiliT_hogar contr_hogar subsi_hogar ///
				contr1_hogar contrT_hogar subsi1_hogar subsiT_hogar ///
				ocupados desocupados inactivos infor1_hogar inforJ_hogar inforT_hogar ///
		 (sum) P6630S1A1 P6630S2A1 P6630S3A1 P6630S4A1 P6630S5A1 ///
				P6630S6A1 P7510S1A1 P7510S2A1 P7510S3A1 P7510S4A1 ///
				P7510S5A1 P7510S6A1 P7510S10A1 P7510S9A1 P7513S1A1 ///
				P7513S2A1 P7513S3A1 P7513S4A1 P7513S5A1	P7513S6A1 ///
				P7513S7A1 P7513S8A1 P7513S9A1 P7513S10A1 P7513S11A1 ///
				P7513S12A1 P550 familias_accion jovenes_accion ///
				adultos_mayores familias_tierra victimizacion P6750 ///
				P6510S1 P6590S1 P6600S1 P6610S1 P6620S1 P6585S1A1 ///
				P6585S2A1 P6585S3A1 P1653S1A1 P1653S2A1 P1653S3A1 ///
				P1653S4A1 P6779S1 P9460S1 P7422S1 P7472S1 P7500S1A1 ///
				P7500S2A1 P7500S3A1 P7500S4A1 P7500S5A1 ingresos ///
				P1645 P5110 P5140 P5250 P5161S1A2 P5161S2A2 ///
		  (mean) P5170 P5180 P6060 P6071 P6160 P6170 P8520S1 P8520S2 ///
				P8520S3 P8520S4 P8520S5 P4040 P5160 P5161S1 P5161S1A1 ///
				P5161S1A3 P5161S2 P5161S2A1 P5161S2A3 P917 P5102 P5105 ///
				P5230 P1646S1 P1646S2 P1646S3 P1646S4 P1646S5 P1646S6 ///
				P1646S7 NC2R_CC_P6 P1646S8 P1646S9 P1646S10 P1646S11 P1646S12 ///
				P1646S13 P1646S14 P1646S15 P1646S16 P1646S17 NC2R_CC_P5 P1646S18 ///
				P1646S19 P1646S20 P1646S21 P1646S22 P1646S23 P1646S24 P1646S25 ///
				P1646S26 P1646S27 P1646S28 P1646S29 P1646S30 P6175 P6180 P8610 ///
				P6426 P6790 P6800 P6850 P7045 P8612 P1664 P1652S1 P1652S2 ///
				P6080_* P6081_* P6083_* P5747_* P448_* P811_* P8520S4A1_* ///
				P1647_* P5010_* P814_* P449_* P5050_* P5070_* P5080_* P5090_* ///
				P5240_* P1646S28A1_* P1646S29A1_* P6236_* P6765_* P549_* P6830_* ///
				P6871_* P6880_* P9450S2_* P1651 P7040 P7310 P6990 P9450 P7514 P7516, by(DIRECTORIO)
				
la def REGION 1 "Atlántica" 2 "Bogotá" 3 "Central" 4 "Nuevos Departamentos" 5 "Oriental" 6 "Pacífica" 7 "San Andrés"				
la val REGION REGION
la def DOMINIO 1 "Arauca" 2 "Armenia" 3 "Barrancabermeja" 4 "Barranquilla" 5 "Bogotá" 6 "Bucaramanga y A.M." 7 "Buenaventura" 8 "Cali" 9 "Cartagena" 10 "Centro Poblado" 11 "Cúcuta y A.M." 12 "Florencia" 13 "Ibagué" 14 "Inírida" 15 "Leticia" 16 "Manizales y A.M." 17 "Medellín y A.M." 18 "Mitú" 19 "Mocoa" 20 "Montería" 21 "Neiva" 22 "Otras cabeceras" 23 "Pasto" 24 "Pereira y A.M." 25 "Popayán" 26 "Puerto Carreño" 27 "Quibdó" 28 "Riohacha" 29 "Rionegro" 30 "Rural disperso" 31 "San Andrés"32 "San José del Guaviare" 33 "Santa Marta" 34 "Sincelejo" 35 "Soledad" 36 "Tumaco" 37 "Tunja" 38 "Valledupar" 39 "Villavicencio" 40 "Yopal" 41 "Yumbo" 
la val DOMINIO DOMINIO
la def sector 0 "Rural" 1 "Urbano"
la val sector sector
la def genero 1 "Hombre" 0 "Mujer"
la val genero genero 
la def ocupados 1 "Ocupado" 0 "No ocupado"
la val ocupados ocupados
la def inactivos 1 "Inactivo" 0 "Activo o no PET"
la val inactivos inactivos
la def desocupados 1 "Desocupado" 0 "Ocupado o inactivo"
la val desocupados desocupados
la var contratoQ "Algun miembro del hogar tiene un contrato de trabajo (verbal o escrito)"
la var pensionQ "Algun miembro del hogar cotiza actualmente a pension"
la var contratoJ "El jefe de hogar tiene un contrato de trabajo (verbal o escrito)"
la var pensionJ "El jefe de hogar cotiza actualmente a pension"
la var numnin "Número de niños en el hogar"
la var numadu "Número de adultos en el hogar"
la var hheq "Equivalente del hogar"
la def ocupacion 1 "Obrero o empleado de empresa particular" 2 "Obrero o empleado del gobierno" ///
				3 "Empleado doméstico" 4 "Trabajador por cuenta propia" 5 "Patrón o empleador" ///
				6 "Trabajador familiar son remuneración" 7 "Trabajador sin remuneración en empresas" ///
				8 "Jornalero o peón" 9 "Otra ocupación"
la val ocupacion ocupacion
la var contr1_hogar "Al menos un miembro del hogar está en régimen contributivo"
la var contrT_hogar "Todos los miembros del hogar están en régimen contributivo"

la var subsi1_hogar "Al menos un miembro del hogar está en régimen subsidiado"
la var subsiT_hogar "Todos los miembros del hogar están en régimen subsidiado"
la var afili1_hogar "Al menos un miembro del hogar está afiliado a salud"
la var afiliT_hogar "Todos los miembros del hogar están afiliados a salud"
*la def genero 1 "Hombre" 0 "Mujer"
la val genero genero
la var infor1_hogar "Al menos un individuo del hogar es informal" 
la var inforJ_hogar "El jefe del hogar es informal" 
la var inforT_hogar "Todos los miembros del hogar son informales"


save "$derived\Hogar_jefe.dta", replace
