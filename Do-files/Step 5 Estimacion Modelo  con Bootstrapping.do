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
    * **************************************************************************
    * Define the Finkelstain procedure withint a program in order to produce valid
    * SE via Bootstrapping as this is a 2-stage procedure
    * REQS: a variable called "wave" that can be either 1 or 2
    *       The "If" only applies to the second
    * ARGS: varlist of controls
    *        iv : Heckman selection variable
	*		 W : Participation variable
	*		 P : Premium variable 
	*		 Y : Income variable
    *        Matchweights: If the sample is being reweighted via matching, those
    *                      weights are included here

use "$derived\Hogar_gasto_completo2.dta", clear

cap recode edad_g (1 2 = 1) ( 3=2) (4=3) (5=4), gen(edad_g2)
tab edad_g2, gen(edad_g2_)

cap recode educacion1 (1 2=1) (3=2) (4=3) , gen(educacion2)
tab educacion2, gen(educ2_)
    
	glo controls_ind "genero edad_g2_* educ2_*"
	glo controls_hou " may65 strata_2 strata_3 strata_4" //
	glo controls_hou2 " percep_2 percep_3 percep_4 "
	glo controls_reg  "region_1 region_2 region_3 region_4 region_5 region_6 sector_1"
	glo controls_reg2  " quintil_1 quintil_2 quintil_3 quintil_4"


    cap program drop Finkel
    program define Finkel , eclass
       	syntax [varlist(numeric)] [if] [in] [aw] , iv(varlist) W(varlist) P(varlist) Y(varlist) [grupo(varname)]
                
        tempvar xbres
		cap drop  _lnpPre
        tempvar mills 
		tempname beta // temporary matrices        
        
        
        * ......................................................................
        * First stage: Heckman selection model 
        
		probit `w' `iv' `y' `varlist'  `if' `aw'
		predict `xbres' , xb
		gen `mills' = normalden(-`xbres')/(1-normal(-`xbres'))
		loc beta1 = _b[`iv']	
		
		su `mills'
				
		* ......................................................................
        * Second stage: Predicting the premium for all households (imputation)
		reg `p' `y' `varlist' `mills' `if' `aw'
		predict _lnpPre , xb
			
		
        * ......................................................................
        * Third stage: The effect of the premium on participation
		reg `w' _lnpPre `y' `varlist' `if' `aw', r	
		loc beta2 = _b[_lnpPre]
		loc beta3 = _b[`y']
		
		la var _lnpPre "Imputated Premium"
		
		loc yvar = "`w'"
		loc nobs = e(N)
		loc dof = e(df_m)
       
        
        mat `beta' = [`beta1' , `beta2' , `beta3' ]
        mat colnames `beta' = "`iv'" "`_lnpPre'" "`y'" 
        
        ereturn post `beta', dep("`yvar'") obs(`nobs') dof(`dof')
        
    end
    
	glo NBs=50
    bs , reps($NBs) seed(123): Finkel $controls_ind $controls_hou $controls_reg $controls_reg2, iv(hhsize) w(ssp) p(lnp) y(lny) 
		
    bs , reps($NBs) seed(123): Finkel $controls_ind $controls_hou $controls_hou2 $controls_reg $controls_reg2, iv(hhsize) w(ssp) p(lnp) y(lny) 
	
	/*tempvar e
        predict `e', e

        su `e' if e(sample) == 1
        loc sse = r(Var)
        loc depvar = e(depvar)
        su `depvar' if e(sample) == 1
        loc sst = r(Var)
        loc rSq = 1 - `sse'/`sst'    
    */
