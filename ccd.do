********************************************************************************
*							Instructions for use							                               *
*		1. Data can be found here: http://nces.ed.gov/ccd/pubschuniv.asp	         *
*			What you'll need to download is a ZIP Flat File (This should be          *
*			the first row of each year range. Once you download this file, 	         *
*			unzip the .txt file inside to your desired location. Next, rename        *
*			the file according to the convention that has been established in        *
*			this file. The name should be CCD[year]. The year used should be         *
*			the first in the school year range. For example, when the 		           *
*			2013-2014 dataset is ready, the file name should be CCD13.txt.	         *
*		2. There are only two things you will need to change in this file. Both    *
*			are located below this box and above the double lines of asterisks.      *
*			The first change is for the working directory. This is the filepath      *
*			for where the .txt file you just renamed is located. The second          *
*			thing you will need to change is the data year on the following          *
*			line. This two-digit number should mimic the number you used when        *
*			renaming the file. For example, when the 2013-2014 data are ready,       *
*			the 12 below should be changed to 13.							                       *
********************************************************************************

cd "C:\Users\Skurrum\Dropbox\ECS\Original Data\CCD" // sets working directory
local datayear = 12 //change data year here to change throughout
********************************************************************************
********************************************************************************


local lastyear = `datayear'-1
local twoyears = `datayear'-2
local dropyear = `datayear'-3



//	#0
//	program setup

version 13
set linesize 80
clear all
set more off

//	#1
//	import text file

import delimited "CCD`datayear'.txt"

//	#2
//	save imported file as .dta

save CCD`datayear', replace

//	#3
//	select variables to keep

use CCD`datayear'.dta, clear // CCD dataset for selected year

keep lstate type conum coname chartr g10 g11 g12
	

//	#4
//	save new dataset

save CCD`datayear', replace

//	#5
//	create value labels

label define schtype	1	"Regular school", modify
label define schtype	2	"Special education school", modify
label define schtype	3	"Vocational school", modify
label define schtype	4	"Other/alternative school", modify
label define schtype	5	"Reportable program", modify


//	#6
//	rename variables

rename lstate state
rename type schooltype`datayear'
rename conum fips
rename coname county
rename g10 grade10`datayear'
rename g11 grade11`datayear'
rename g12 grade12`datayear'

//	#7
//	label variables

label variable state "School's state"
label variable schooltype`datayear' "NCES code for type of school"
label variable fips "FIPS code for school county"
label variable county "County school is in"
label variable grade10`datayear' "Total 10th grade students"
label variable grade11`datayear' "Total 11th grade students"
label variable grade12`datayear' "Total 12th grade students"

//	#8
//	include value label for inst_type`datayear'

label values schooltype`datayear' schtype

//	#9
//	recode missing data

recode grade10`datayear' grade11`datayear' grade12`datayear' (-2/-1 = .)
encode chartr, gen(charter`datayear')
label variable charter`datayear' "Indicator of school's charter status"
drop chartr
recode charter`datayear' (2=0)(3/4=.)

//	#10
//	create dummy indicator for regular schools

gen regular`datayear' = schooltype`datayear'
recode regular`datayear' (2/5 = 0)
label variable regular`datayear' "Indicator of regular school"

//	#11
//	create variables to count number of students/schools by fips code

bysort fips: egen sumg10`datayear'=total(grade10`datayear')
bysort fips: egen sumg11`datayear'=total(grade11`datayear')
bysort fips: egen sumg12`datayear'=total(grade12`datayear')
bysort fips: egen sumchar`datayear'=total(charter`datayear')
bysort fips: egen sumreg`datayear'=total(regular`datayear')


//	#12
//	label generated variables

label variable sumg10`datayear' "Total 10th graders by FIPS code in `datayear'"
label variable sumg11`datayear' "Total 11th graders by FIPS code in `datayear'"
label variable sumg12`datayear' "Total 12th graders by FIPS code in `datayear'"
label variable sumchar`datayear' "Total charter schools by FIPS code in `datayear'"
label variable sumreg`datayear' "Total regular schools by FIPS code in `datayear'"

//	#13
//	save new dataset

save CCD`datayear', replace

//	#14
//	drop unneeded variables

drop schooltype* grade* charter* regular*

//	#15
//	drop duplicates

duplicates drop fips, force

//	#16
//	save new dataset

save CCD`datayear', replace

//	#17
//	merge last year's data

merge 1:1 fips using CCD`lastyear'.dta
drop _merge

//	#18
//	save new dataset

save CCD`datayear', replace

//	#19
//	average 10th, 11th, 12th enrollment numbers

egen avg10`datayear' = rowmean(sumg10`twoyears' sumg10`lastyear' sumg10`datayear')
egen avg11`datayear' = rowmean(sumg11`twoyears' sumg11`lastyear' sumg11`datayear')
egen avg12`datayear' = rowmean(sumg12`twoyears' sumg12`lastyear' sumg12`datayear')

label variable avg10`datayear' "Three-year average of 10th grade enrollment, ending in `datayear'"
label variable avg11`datayear' "Three-year average of 11th grade enrollment, ending in `datayear'"
label variable avg12`datayear' "Three-year average of 12th grade enrollment, ending in `datayear'"

//	#20
//	save new dataset

save CCD`datayear', replace

//	#21
//	drop data no longer needed

drop sumg10`dropyear' sumg11`dropyear' sumg12`dropyear'

//	#22
//	save new dataset

save CCD`datayear', replace
