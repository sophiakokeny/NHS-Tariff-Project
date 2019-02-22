
/*****
 ------------------Part 3 – Analysis of Tariff which would be chargeable for our dummy patient episodes based upon grouper output HRG codes ---- 

 There are certain assumtions made when anlysing the Tariff on dummy patient episodes:
 Assumtion 1: Table name for Annex_A_-_National_tariff_workbook (Official NHS Document) is [stage].[1A2018/19] for tariffs in 2018/19
																						   [stage].[1A2017/18] for tariffs in 2017/18
 Assumtion 2: Table name for dummy patient episodes with HRG codes is: [stage].[1A2018/19] for tariffs in 2018/19

Sense Check 1: Put the code in cte and analyse how many zeros are for Tariff - identify the error in the code and try to fix it.	
			   There are 30 rows which do not have a Tariff, as those HRG codes does not have a dummy patient epidode assigned.	
			   																									*****/

--with cte as (

declare @Tariff money   
--Check 2 drop view if it already exists ---
 IF EXISTS(SELECT *
     FROM sys.views
     WHERE name = 'vw_part3_tariff2017_18' AND
     schema_id = SCHEMA_ID('dbo'))
     DROP VIEW [dbo].[vw_part3_tariff2017_18]
 GO

---Create a view, as instead of running a select query, a view signifantly decreases the query cost. (Especially the cost of sorting, it decreased by ~30% for a view)
Create view [vw_part3_tariff2017_18] as

/*****
To determine which Tariff should be charged for each patient, the following cases have been applied:

		1st case condition: Reduced short stay emergency - Reduced short stay emergency adjustment Tariff
							When reduced emergency short stay tariff is applicable, the patient is 19 or older, the method of admission is emergency and the LoS is 0 or 1.

		2nd case condition: Planned outpatients (not staying overnight) and non-emergency - Outpatient Tariff. If outpatient tariff is empty, it is assumed to have combined day case / orderinary tariff		
							When classpat is not day case admission, the method of admission is non-emergency and the difference between epistart and epidur is 0 (same day)
							Note: I found that 'epidur' is not always correct, thus I took the date difference between 'epistart' and 'epiend' instead.										
		
		3rd case condition: Emergency outpatients - Outpatient Tariff - not specified in NHS National Tariff Payment System, thus emergency outpateints who do not stay overnight are assumed to have outpatient tariff 
							When classpat is not day case admissione, the method of admission is emergency and the difference between epistart and epidur is 0 (same day)

		4th case condition: Planned or emergency day cases - Day case spell tariff
							When the patient classification is 'day case admission' and the difference between epistart and epidur is 0 (same day)

		5th case condition: Emergency regular day or night attender - if not null: Combined day case / ordinary elective spell tariff, otherwise Non-elective spell tariff
							As what falls under Day case is not specified in detail in n NHS National Tariff Payment System,
							when patient classification is regular day or night attender and the difference between epistart and epidur is 0 (same day) the aforementioned tariff is applied.
						
		6th case condition: Non-emergency regular day or night attender - if not null: Combined day case / ordinary elective spell tariff, otherwise Elective spell tariff
							As what falls under Day case is not specified in detail in n NHS National Tariff Payment System,
							when patient classification is regular day or night attender and the difference between epistart and epidur is 0 (same day) the aforementioned tariff is applied.
		
		7th case condition: Non-emergency admissions over long stay trim point - if not null: Combined day case / ordinary elective spell tariff (£), otherwise Elective spell tariff
							Plus the extra days (over the long stay trim point) multipled by the Per day long stay payment (for days exceeding trim point) (£)

		8th case condition: Non-emergency admissions below or equal to the long stay trim point. if not null: Combined day case / ordinary elective spell tariff (£), otherwise Elective spell tariff

		9th case condition: Emergency admissions over long stay trim point - Non-elective spell tariff
							Plus the extra days (over the long stay trim point) multipled by the Per day long stay payment (for days exceeding trim point) (£)
							 	
		10th case condition: Emergency admissions below or equal to the long stay trim point - Non-elective spell tariff 

		11th case condition: Contradictory data: Unclassified or day case admission when the patient stays more than 1 days -  Combined day case / ordinary elective spell tariff
							 Not specified in NHS National Tariff Payment System thus the tariff is the best assumption

		12th case condition: Validation error: When the method of admission is not known and the patient stays more than 1 days - Combined day case / ordinary elective spell tariff (£)
							 Not specified in NHS National Tariff Payment System thus the tariff is the best assumption

		13th case condition: Validation error: When the method of admission is not known and the difference between epistart and epidur is 0 (same day)
							 If not null: Outpatient procedure tariff (£), otherwise Combined day case / ordinary elective spell tariff (£)
			   				 Not specified in NHS National Tariff Payment System thus the tariff is the best assumption																					*****/
select distinct
[HRG code]
,[HRG name]
,epistart
,epiend
,admimeth
,classpat
,admiage
,[Tariff (£)] =																									
	case
		when tar.[Reduced short stay emergency tariff _applicable?] = 'yes' and admiage >= 19 and admimeth like '2%' and datediff(dd,epistart,epiend) in ('1','0')
			then tar.[Reduced short stay emergency tariff (£)]	
		
		when classpat not in ('2') and admimeth like '1%' and datediff(dd,epistart,epiend) = 0
			then nullif(cast(replace(tar.[Outpatient procedure tariff (£)],',','')as int), '-')	
		
		when classpat not in ('2') and admimeth like '2%' and datediff(dd,epistart,epiend) = 0
			then nullif(cast(replace(tar.[Outpatient procedure tariff (£)],',','')as int), '-')
											
		when classpat in ('2') and datediff(dd,epistart,epiend) = 0
			then nullif(cast(replace(tar.[Day case spell tariff (£)],',','') as int), '-')

		when classpat in ('3','4') and admimeth like '2%' and datediff(dd,epistart,epiend) = 0 
			then coalesce (nullif(cast(replace(tar.[Combined day case / ordinary elective spell tariff (£)],',','') as int), '-'), nullif(cast(replace(tar.[Non-elective spell tariff (£)],',','') as int),'-'))

		when classpat in ('3','4') and admimeth like '1%' and datediff(dd,epistart,epiend) = 0 
			then coalesce (nullif(cast(replace(tar.[Combined day case / ordinary elective spell tariff (£)],',','') as int), '-'), nullif(cast(replace(tar.[Ordinary elective spell tariff (£)],',','') as int),'-'))

		when admimeth like '1%' and datediff(dd,epistart,epiend) > tar.[ordinary elective long stay trim point (days)]	
			then coalesce (nullif(cast(replace(tar.[Combined day case / ordinary elective spell tariff (£)],',','') as int),'-'), nullif(cast(replace(replace(tar.[Ordinary elective spell tariff (£)],',',''),'.','') as int),'-'))
				+ tar.[Per day long stay payment (for days exceeding trim point) (£)]*(datediff(dd,epistart,epiend)-tar.[ordinary elective long stay trim point (days)])
		
		when admimeth like '1%' and datediff(dd,epistart,epiend) <= tar.[ordinary elective long stay trim point (days)]	
			then coalesce(nullif(cast(replace(tar.[Combined day case / ordinary elective spell tariff (£)],',','') as int), '-'), nullif(cast(replace(tar.[Ordinary elective spell tariff (£)],',','') as int),'-'))
		
		when admimeth like '2%' and datediff(dd,epistart,epiend) > tar.[Non-elective long stay trim point (days)]
			then nullif(cast(replace(tar.[Non-elective spell tariff (£)],',','') as int), '-')
				+ (tar.[Per day long stay payment (for days exceeding trim point) (£)]*(datediff(dd,epistart,epiend)-tar.[Non-elective long stay trim point (days)]))
		
		when admimeth like '2%' and datediff(dd,epistart,epiend) <= tar.[Non-elective long stay trim point (days)]
			then nullif(cast(replace(tar.[Non-elective spell tariff (£)],',','') as int), '-')

		when classpat in ('2', '9') and datediff(dd,epistart,epiend) > 1
			then nullif(cast(replace(tar.[Combined day case / ordinary elective spell tariff (£)],',','') as int), '-')

		when admimeth = 99 and datediff(dd,epistart,epiend) > 0 
			then nullif(cast(replace(tar.[Combined day case / ordinary elective spell tariff (£)],',','') as int), '-')

		when admimeth = 99 and datediff(dd,epistart,epiend) = 0 
			then coalesce(nullif(cast(replace(tar.[Outpatient procedure tariff (£)],',','') as int),'-'), nullif(cast(replace(tar.[Combined day case / ordinary elective spell tariff (£)],',','') as int),'-'))
	else 0
	end
FROM [stage].[1a2017/18] tar
left join [stage].[HRG_and_HESdata] hrg
on hrg.[HRG_code] = tar.[HRG code]


--) select * from cte where [Tariff (£)] = 0

/**************************************************************************************************************************************
The same procedure is repeated for tariff in 2018/19 and a separate view is created.
***********************************************************************************************************************************/
 declare @Tariff money 
 IF EXISTS(SELECT *
     FROM sys.views
     WHERE name = 'vw_part3_tariff2018_19' AND
     schema_id = SCHEMA_ID('dbo'))
     DROP VIEW [dbo].[vw_part3_tariff2018_19]
 GO

 create view vw_part3_tariff2018_19 as
--with cte as (

 select distinct
 [HRG code]
,[HRG name]
,epistart
,epiend
,admimeth
,classpat
 ,[Tariff (£)] =																									
	case
		when tar.[Reduced short stay emergency tariff _applicable?] = 'yes' and admiage >= 19 and admimeth like '2%' and datediff(dd,epistart,epiend) in ('1','0')
			then tar.[Reduced short stay emergency tariff (£)]	
		
		when classpat not in ('2') and admimeth like '1%' and datediff(dd,epistart,epiend) = 0
			then nullif(cast(replace(tar.[Outpatient procedure tariff (£)],',','')as int), '-')	
		
		when classpat not in ('2') and admimeth like '2%' and datediff(dd,epistart,epiend) = 0
			then nullif(cast(tar.[Outpatient procedure tariff (£)]as int), '-')
											
		when classpat in ('2') and datediff(dd,epistart,epiend) = 0
			then nullif(cast(tar.[Day case spell tariff (£)] as int), '-')

		when classpat in ('3','4') and admimeth like '2%' and datediff(dd,epistart,epiend) = 0 
			then coalesce (nullif(cast(replace(tar.[Combined day case / ordinary elective spell tariff (£) emergency],',','') as int), '-'), nullif(cast(replace(tar.[Non-elective spell tariff (£) patent chosen and planned],',','') as int),'-'))

		when classpat in ('3','4') and admimeth like '1%' and datediff(dd,epistart,epiend) = 0 
			then coalesce (nullif(cast(replace(tar.[Combined day case / ordinary elective spell tariff (£) emergency],',','') as int), '-'), nullif(cast(replace(tar.[Ordinary elective spell tariff (£)],',','') as int),'-'))

		when admimeth like '1%' and datediff(dd,epistart,epiend) > [ordinary elective long stay trim point (days)]	
			then coalesce (nullif(cast(replace(tar.[Combined day case / ordinary elective spell tariff (£) emergency],',','') as int),'-'), nullif(cast(replace(replace(tar.[Ordinary elective spell tariff (£)],',',''),'.','') as int),'-'))
				+ tar.[Per day long stay payment (for days exceeding trim point) (£)]*(datediff(dd,epistart,epiend)-tar.[ordinary elective long stay trim point (days)])
		
		when admimeth like '1%' and datediff(dd,epistart,epiend) <= [ordinary elective long stay trim point (days)]	
			then coalesce(nullif(cast(replace(tar.[Combined day case / ordinary elective spell tariff (£) emergency],',','') as int), '-'), nullif(cast(replace(tar.[Ordinary elective spell tariff (£)],',','') as int),'-'))
		
		when admimeth like '2%' and datediff(dd,epistart,epiend) > tar.[Non-elective long stay trim point (days)]
			then nullif(cast(replace(tar.[Non-elective spell tariff (£) patent chosen and planned],',','') as int), '-')
				+ (tar.[Per day long stay payment (for days exceeding trim point) (£)]*(datediff(dd,epistart,epiend)-tar.[Non-elective long stay trim point (days)]))
		
		when admimeth like '2%' and datediff(dd,epistart,epiend) <= tar.[Non-elective long stay trim point (days)]
			then nullif(cast(replace(tar.[Non-elective spell tariff (£) patent chosen and planned],',','') as int), '-')

		when classpat in ('2', '9') and datediff(dd,epistart,epiend) > 1
			then nullif(cast(replace(tar.[Combined day case / ordinary elective spell tariff (£) emergency],',','') as int), '-')

		when admimeth = 99 and datediff(dd,epistart,epiend) > 0 
			then nullif(cast(replace(tar.[Combined day case / ordinary elective spell tariff (£) emergency],',','') as int), '-')

		when admimeth = 99 and datediff(dd,epistart,epiend) = 0 
			then coalesce(nullif(cast(replace(tar.[Outpatient procedure tariff (£)],',','') as int),'-'), nullif(cast(replace(tar.[Combined day case / ordinary elective spell tariff (£) emergency],',','') as int),'-'))
	else 0
	end
FROM [stage].[1a2018/19] tar
left join [stage].[HRG_and_HESdata] hrg
on hrg.[HRG_code] = tar.[HRG code]

--)  * from cte where [Tariff (£)] = 0
---------------------In order to eliminate duplicates: only distinct values are selected

select * from [dbo].[vw_part3_tariff2017_18]
select * from [dbo].[vw_part3_tariff2017_18]