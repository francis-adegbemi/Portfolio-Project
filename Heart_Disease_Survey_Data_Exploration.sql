-- Number of respondents with or without heart disease.
--I made use of a temporary table to show the number of respondents with heart disease, the number of respodents without, and the sum of both.
--It also shows what percent of the total respondents have and do not have heart disease.
Drop table if exists #temp_table
Create table #temp_table (
HeartDisease varchar(50),
Yes_No int,
total_respondents int)

Insert into #temp_table
Select HeartDisease, count(HeartDisease) as Yes_No, 
	(SELECT count(HeartDisease) 
	from dbo.heart_data) as total_respondents
from dbo.heart_data
group by HeartDisease

Select *, 
	(cast(Yes_No as decimal(8,2)) / total_respondents) * 100 as percent_of_respondents
from #temp_table
order by HeartDisease desc

--Percentage of people with Heart disease by Race.
--I made use of a common table expression to show the total count of each race among respondents, 
--the total count of respondents with heart disease grouped by their race, and the percentage of people with heart disease by each race.
With percent_withHD (Race, count_of_race, with_HD)
as
(
	Select Race, 
	count(Race) as count_of_race,
	SUM(CASE WHEN (HeartDisease) = 'Yes' THEN 1 ELSE 0 END) as with_HD
	From dbo.heart_data
	group by Race
)
Select *, 
	(cast(with_HD as decimal(7,2)) / count_of_race) * 100 as percent_withHD
from percent_withHD


--Heart disease count by Sex and Race
--This query displays the number of Male and Female respondents in each race with heart disease
Select Race, 
	Sex, 
	count(Sex) as count_by_sex
from dbo.heart_data
where HeartDisease like 'Y%'
group by Race, Sex
order by Race 

--Number of people(based on age group) with HeartDisease and Body Mass Index of 30 and over
--A body mass index of 30 or over indicates obesity which is also a causative of heart disease.
--This query shows the number of people (grouped by age) with a BMI of 30 and above that have heart disease.
With over_30 (Sex, HeartDisease, BMI, AgeCategory)
as
(
	Select Sex, 
	HeartDisease, 
	BMI, 
	AgeCategory
	from dbo.heart_data
)
Select HeartDisease, 
	AgeCategory, count(sex) as count_of_sex
from over_30
Where BMI >= 30.0 and HeartDisease = 'Yes'
group by HeartDisease, AgeCategory
order by AgeCategory

--This query shows what percentage the people with BMI of 30 and over make up the total people with heart disease.
With percentBMI_withHD (count_withHD, total_bmi_HD)
as
(
	Select 
	sum(case when HeartDisease = 'Yes' Then 1 else 0 end) as count_withHD,
	sum(case when HeartDisease = 'Yes' and BMI >= 30.0 Then 1 else 0 end) as total_bmi_HD
	from dbo.heart_data
)
Select *, 
	(cast(total_bmi_HD as decimal(7,2)) / count_withHD) * 100 as percentBMI_withHD
from percentBMI_withHD


