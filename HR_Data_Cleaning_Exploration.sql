select * from dbo.HumanResources
go

--RENAMING COLUMN NAME FROM ID TO EMP_ID

exec sp_rename 'HumanResources.id', 'emp_id'

alter table dbo.HumanResources
alter column emp_id varchar(20) not null
go

-- CHANING COLUMN TYPE FOR BIRTHDATE FROM NAVARCHAR TO DATE TYPE

begin tran

alter table dbo.HumanResources
alter column birthdate date not null

commit tran

select * from dbo.HumanResources
go

--CHANGING COLUMN TYPE FOR HIRE_DATE FROM NVARCHAR TO DATE TYPE

begin tran
alter table dbo.HumanResources
alter column hire_date date null

commit tran
go

--CHANGING COLUMN TYPE FOR TERMDATE FROM NVARCHAR TO DATE TYPE

BEGIN TRAN

update dbo.HumanResources
set termdate = substring(termdate,1,10)

alter table dbo.HumanResources
alter column termdate date

commit tran

select * from dbo.HumanResources
go

--ADDING AN AGE COLUMN

alter table dbo.HumanResources
add Age int
go

--CALCUATING THE EMPLOYEE AGE AND INSERTING INTO THE AGE COLUMN

begin tran

update dbo.HumanResources
set Age = DATEDIFF(year,birthdate,getdate())

commit tran

select * from dbo.HumanResources
go


--ANSWERING BUSINESS QUESTIONS

-- Q1: WHAT IS THE CURRENT TOTAL EMPLOYEE NUMBER BY GENDER IN THE COMPANY?

SELECT gender, count(*) AS CountByGender
FROM dbo.HumanResources
WHERE termdate IS NULL OR termdate > GETDATE()
GROUP BY gender
ORDER BY CountByGender
GO


--Q2: WHAT IS THE CURRENT TOTAL EMPLOYEE NUMBER BY RACE/ETHINCITY IN THE COMPANY?

SELECT race, COUNT(*) AS CountByRace
FROM dbo.HumanResources
WHERE termdate IS NULL OR termdate > GETDATE()
GROUP BY race
ORDER BY CountByRace DESC
GO


--Q3: WHAT IS THE AGE DISTRIBUTION OF EMPLOYEES IN THE COMPANY?

SELECT MIN(Age) AS YoungestAge, MAX(Age) AS OldestAge
FROM dbo.HumanResources
WHERE termdate IS NULL OR termdate > GETDATE()

SELECT 
		CASE
		WHEN Age >= 18 AND Age <= 24 THEN '18-24'
		WHEN Age >= 25 AND Age <= 34 THEN '25-34'
		WHEN Age >= 35 AND Age <= 44 THEN '35-44'
		WHEN Age >= 45 AND Age <= 54 THEN '45-54'
		WHEN Age >= 55 AND Age <= 64 THEN '55-64'
		ELSE '65+'
		END AS AgeGroup,
		COUNT(*) AS CountByAgeGroup
FROM dbo.HumanResources
WHERE termdate IS NULL OR termdate > GETDATE()
GROUP BY Age
ORDER BY AgeGroup


SELECT 
		CASE
		WHEN Age >= 18 AND Age <= 24 THEN '18-24'
		WHEN Age >= 25 AND Age <= 34 THEN '25-34'
		WHEN Age >= 35 AND Age <= 44 THEN '35-44'
		WHEN Age >= 45 AND Age <= 54 THEN '45-54'
		WHEN Age >= 55 AND Age <= 64 THEN '55-64'
		ELSE '65+'
		END AS AgeGroup, gender,
		COUNT(*) AS CountByAgeGroup
FROM dbo.HumanResources
WHERE termdate IS NULL OR termdate > GETDATE()
GROUP BY Age, gender
ORDER BY CountByAgeGroup, gender



SELECT 
		CASE
		WHEN Age between 18 and 24 THEN '18-24'
		WHEN Age between 25 and 34 THEN '25-34'
		WHEN Age between 35 and 44 THEN '35-44'
		WHEN Age between 45 and 54 THEN '45-54'
		WHEN Age between 55 and 64 THEN '55-64'
		ELSE '65+'
		END AS AgeGroup
	--	COUNT(Age) AS CountByAgeGroup
FROM dbo.HumanResources
WHERE termdate IS NULL OR termdate > GETDATE()
GROUP BY Age
--ORDER BY CountByAgeGroup DESC


select * from dbo.HumanResources


--Q4: HOW MANY EMPLOYEES WORK AT THE HEADQUARTERS VERSUS REMOTE LOCATIONS?

SELECT location, COUNT(*) AS CountByLocation
FROM dbo.HumanResources
WHERE termdate IS NULL OR termdate > GETDATE()
GROUP BY location


--Q5: WHAT IS THE AVERAGE LENGTH OF EMPLOYMENT FOR EMPLOYEES WHO HAVE BEEN TERMINATED?

SELECT AVG(DATEDIFF(YEAR, hire_date, termdate)) AS AvergeEmploymentLength
FROM dbo.HumanResources
WHERE termdate IS NOT NULL OR termdate <= GETDATE()


--Q6: HOW DOES THE GENDER DISTRIBUTION VARY ACROSS DEPARTMENTS AND JOB TITLES?

SELECT gender, department, COUNT(*) AS GenderDistByDept
FROM dbo.HumanResources
WHERE termdate IS NULL OR termdate > GETDATE()
GROUP BY gender, department
ORDER BY department


--Q7: WHAT IS THE DISTRIBUTION OF JOB TITLES ACROSS THE COMPANY?

SELECT jobtitle, COUNT(*) AS DistByJobTitle
FROM dbo.HumanResources
WHERE termdate IS NULL OR termdate > GETDATE()
GROUP BY jobtitle
ORDER BY jobtitle DESC


--Q8: WHICH DEPARTMENT HAS THE HIGHEST TURNOVER RATE?

SELECT department, total_employee, total_terminated, ROUND((total_terminated/total_employee)*100,0) AS TerminationRate
FROM 
	(SELECT department
	, COUNT(*) AS total_employee
	, SUM(CASE WHEN termdate IS NOT NULL AND termdate <= GETDATE() THEN 1 ELSE 0 END) AS total_terminated
	FROM dbo.HumanResources
	GROUP BY department) AS TerminationTable
ORDER BY TerminationRate DESC


--Q9: WHAT IS THE DISTRIBUTION OF EMPLOYEES ACROSS LOCATIONS BY STATE?

SELECT location_state, COUNT(*) AS	DistByLocationState
FROM dbo.HumanResources
WHERE termdate IS NULL OR termdate > GETDATE()
GROUP BY location_state
ORDER BY DistByLocationState DESC


--Q10: HOW HAS THE COMPANY'S EMPLOYEE COUNT CHANGED OVER TIME BASED ON HIRE AND TERM DATES?

SELECT year, hires, terminations, hires-terminations AS ChangeOverTime,
ROUND(((hires-terminations)/hires)*100,2) AS PercentChangeOverTime
FROM
	(SELECT YEAR(hire_date) AS year, COUNT(*) AS hires,
			SUM(CASE WHEN termdate IS NOT NULL AND termdate <= GETDATE() THEN 1 ELSE 0 END) AS terminations
	FROM dbo.HumanResources
	GROUP BY YEAR(hire_date)
	) AS EmployeeCountOverTime
ORDER BY year ASC


--Q11: WHAT IS THE TENURE DISTRIBUTION FOR EACH DEPARTMENT?

SELECT department,AVG(DATEDIFF(YEAR,hire_date,termdate)) AS AvgTenure
FROM dbo.HumanResources
WHERE termdate IS NULL OR termdate > GETDATE()
GROUP BY department