
-- **********************Creating SubCategory table for NHS HRG Subcategories) *************************************************

if object_id('stage.subchapter') is not null
begin
    drop table stage.subchapter
end

create table stage.subchapter
(
	 id int identity primary key
	,value varchar(20)
	,[Description] varchar(500)
)
Insert into stage.subchapter
(value, [Description])

values
('AA', 'Nervous System Procedures and Disorders')
,('AB', 'Pain Management')
,('BZ', 'Eyes and Periorbita Procedures and Disorders')
,('CA', 'Ear, Nose, Mouth, Throat and Neck Procedures')
,('CB', 'Ear, Nose, Mouth, Throat and Neck Disorders')
,('CD', 'Dental and Orthodontic Procedures')
,('DZ', 'Respiratory System Procedures and Disorders')
,('EB', 'Cardiac Disorders')
,('EC', 'Open and Interventional Procedures for Congenital Heart Disease')
,('ED', 'Open Cardiac Procedures for Acquired Conditions')
,('EY', 'Interventional Cardiology for Acquired Conditions')
,('FZ', 'Digestive System Procedures and Disorders')
,('GA', 'Hepatobiliary and Pancreatic System Open Procedures')
,('GB', 'Hepatobiliary and Pancreatic System Endoscopic Procedures')
,('GC', 'Hepatobiliary and Pancreatic System Disorders')
,('HC', 'Spinal Procedures and Disorders')
,('HD', 'Musculoskeletal and Rheumatological Disorders')
,('HE', 'Orthopaedic Disorders')
,('HN', 'Orthopaedic Non-Trauma Procedures')
,('HT', 'Orthopaedic Trauma Procedures')
,('JA', 'Breast Procedures and Disorders')
,('JB', 'Burns Procedures and Disorders')
,('JC', 'Skin Procedures')
,('JD', 'Skin Disorders')
,('KA', 'Endocrine System Disorders')
,('KB', 'Diabetic Medicine')
,('KC', 'Metabolic Disorders')
,('LA', 'Renal Procedures and Disorders')
,('LB', 'Urological and Male Reproductive System Procedures and Disorders')
,('LD', 'Renal Dialysis for Chronic Kidney Disease')
,('LE', 'Renal Dialysis for Acute Kidney Injury')
,('MA', 'Female Reproductive System Procedures')
,('MB', 'Female Reproductive System Disorders')
,('MC', 'Assisted Reproductive Medicine')
,('NZ', 'Obstetric Medicine')
,('PB', 'Neonatal Disorders')
,('PC', 'Paediatric Ear Nose and Throat Disorders')
,('PD', 'Paediatric Respiratory Disorders')
,('PE', 'Paediatric Cardiology Disorders')
,('PF', 'Paediatric Gastroenterology Disorders')
,('PG', 'Paediatric Hepatobiliary Disorders')
,('PH', 'Paediatric Rheumatology Disorders')
,('PJ', 'Paediatric Dermatology Disorders')
,('PK', 'Paediatric Diabetology, Endocrinology and Metabolic Disorders')
,('PL', 'Paediatric Renal Disorders')
,('PM', 'Paediatric Haematological-Oncology Disorders')
,('PN', 'Paediatric Non-Malignant Haematological Disorders')
,('PP', 'Paediatric Ophthalmic Disorders')
,('PQ', 'Paediatric Immune System Disorders')
,('PR', 'Paediatric Nervous System Disorders')
,('PT', 'Paediatric Mental Health Disorders')
,('PV', 'Paediatric Trauma Medicine')
,('PW', 'Paediatric Infectious Diseases')
,('PX', 'Paediatric Medicine')
,('RD', 'Diagnostic Imaging Procedures')
,('RN', 'Nuclear Medicine Procedures')
,('SA', 'Haematological Procedures and Disorders')
,('SB', 'Chemotherapy')
,('SC', 'Radiotherapy')
,('SD', 'Specialist Palliative Care')
,('UZ', 'Undefined Groups')
,('VA', 'Multiple Trauma')
,('VB', 'Emergency Medicine')
,('VC', 'Rehabilitation')
,('WD', 'Treatment of Mental Health Patients by Non-Mental Health Service Providers')
,('WF', 'Non-Admitted Consultations')
,('WH', 'Poisoning, Toxic Effects, Special Examinations, Screening and Other Healthcare Contacts')
,('WJ', 'Infectious Diseases and Immune System Disorders')
,('XA', 'Neonatal Critical Care')
,('XB', 'Paediatric Critical Care')
,('XC', 'Adult Critical Care')
,('XD', 'High Cost Drugs')
,('YA', 'Neurological Imaging Interventions')
,('YD', 'Thoracic Imaging Interventions')
,('YF', 'Gastrointestinal Imaging Interventions')
,('YG', 'Hepatobiliary and Pancreatic Imaging Interventions')
,('YH', 'Musculoskeletal Imaging Interventions')
,('YJ', 'Breast Imaging Interventions')
,('YL', 'Urological Imaging Interventions')
,('YQ', 'Vascular Open Procedures and Disorders')
,('YR', 'Vascular Imaging Interventions')

-- **********************Creating Chapter table for NHS HRG Chapter) *************************************************


if object_id('stage.chapter') is not null
begin
    drop table stage.chapter
end

create table stage.chapter
(
	 id int identity primary key
	,value varchar(20)
	,[Description] varchar(500)
)
Insert into stage.chapter
(value, [Description])

values
('A', 'Nervous System')
,('B', 'Eyes and Periorbita')
,('C', 'Ear, Nose, Mouth, Throat, Neck and Dental')
,('D', 'Respiratory System')
,('E', 'Cardiac')
,('F', 'Digestive System')
,('G', 'Hepatobiliary and Pancreatic System')
,('H', 'Musculoskeletal System')
,('J', 'Skin, Breast and Burns')
,('K', 'Endocrine and Metabolic System')
,('L', 'Urinary Tract and Male Reproductive System')
,('M', 'Female Reproductive System and Assisted Reproduction')
,('N', 'Obstetrics')
,('P', 'Diseases of Childhood and Neonates')
,('R', 'Diagnostic Imaging and Nuclear Medicine')
,('S', 'Haematology, Chemotherapy, Radiotherapy and Specialist Palliative Care')
,('U', 'Undefined Groups')
,('V', 'Multiple Trauma, Emergency Medicine and Rehabilitation')
,('W', 'Infectious Diseases, Immune System Disorders and other Healthcare contacts')
,('X', 'Critical Care and High Cost Drugs')
,('Y', 'Vascular Procedures and Disorders and Imaging Interventions')


--*************************************Union tariff 2018/19 and 2017/18 with chapters and subchapters and create a view ****************************************************
--*******************************************************************For Tableau*******************************************************************************

 IF EXISTS(SELECT *
     FROM sys.views
     WHERE name = 'vw_tariffgood' AND
     schema_id = SCHEMA_ID('dbo'))
     DROP VIEW [dbo].[vw_tariffgood]
 GO

create view vw_tariffgood as


select

cte.[HRG code],
cte.[HRG name],
'2018/19' as [Year],
cast(cte.[Outpatient procedure tariff (£)] as money) [Outpatient_tariff]
,cast(cte.[Combined day case / ordinary elective spell tariff (£) emergency] as money) Combined
,cast(cte.[Ordinary elective spell tariff (£)] as money) Non_emergency_Tariff
,cast(cte.[Non-elective spell tariff (£) patent chosen and planned] as money) Emergency_Tariff
,cast(cte.[Day case spell tariff (£)] as money) [Day_case_Tariff]
,sub.[value] as Subchapter
,sub.[description] as [Subchapter Description]
,cha.[value] as Chapter
,(cha.[Description]) as [Chapter name]
 from [stage].[1a2018/19] cte
left join [stage].[subchapter] sub
on left(cte.[HRG code], 2) = sub.value
left join [stage].[chapter] cha
on left(cte.[HRG code], 1) = cha.value


UNION


select 

cte.[HRG code],
cte.[HRG name],
'2017/18' as [Year],
cast(cte.[Outpatient procedure tariff (£)] as money) [Outpatient_tariff]
,cast(cte.[Combined day case / ordinary elective spell tariff (£)] as money) Combined
,cast(cte.[Ordinary elective spell tariff (£)] as money) Non_emergency_Tariff
,cast(cte.[Non-elective spell tariff (£)] as money) Emergency_Tariff
,cast(cte.[Day case spell tariff (£)] as money) [Day_case_Tariff]
,sub.[value] as Subchapter
,sub.[description] as [Subchapter Description]
,cha.[value] as Chapter
,(cha.[Description]) as [Chapter name]
from [stage].[1a2017/18] cte
left join [stage].[subchapter] sub
on left(cte.[HRG code], 2) = sub.value
left join [stage].[chapter] cha
on left(cte.[HRG code], 1) = cha.value


