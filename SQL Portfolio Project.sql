SELECT *
From Portfolio_Project.dbo.['CovidDeaths']
WHERE continent is not null
ORDER BY 3,4;

--SELECT *
--From Portfolio_Project.dbo.['CovidVaccinations']
--ORDER BY 3,4;

SELECT location, date, new_cases, total_cases, total_deaths, population
From Portfolio_Project.dbo.['CovidDeaths']
ORDER BY 1,2;

-- Total Cases VS Total Deaths 
-- Death Percentage of India

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From Portfolio_Project.dbo.['CovidDeaths']
WHERE location =  'India'
ORDER BY 1,2;

-- Total Cases VS Total Population
-- Infected People in India

SELECT location, date, total_cases, population ,(total_cases/population)*100 as Infected_Percentage
From Portfolio_Project.dbo.['CovidDeaths']
WHERE location =  'India'
ORDER BY 1,2;

-- Country With Highest Infection Rate Compared To Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount , MAX((total_cases/population))*100 as Infected_Percentage
From Portfolio_Project.dbo.['CovidDeaths']
GROUP BY location, population
ORDER BY Infected_Percentage desc


-- Countries With The Highest Death Count Per Population

SELECT location, population, MAX(cast (total_deaths as int)) as HighestDeathCount
From Portfolio_Project.dbo.['CovidDeaths']
WHERE continent is not null
GROUP BY location, population
ORDER BY HighestDeathCount  desc


-- Continent With The Highest Death Count Per Population

SELECT location, MAX(cast (total_deaths as int)) as HighestDeathCount
From Portfolio_Project.dbo.['CovidDeaths']
WHERE continent is null
GROUP BY location
ORDER BY HighestDeathCount  desc

--New Cases Per Date

SELECT date, location, Sum(new_cases) as TotalCases--total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From Portfolio_Project.dbo.['CovidDeaths']
WHERE continent is not null
and new_cases is not null
GROUP BY date, location
ORDER BY date 


-- Joining Tables

SELECT *
FROM ['CovidDeaths']
join ['CovidVaccinations']
on ['CovidDeaths'].location = ['CovidVaccinations'].location
and ['CovidDeaths'].date = ['CovidVaccinations'].date


-- Total Population VS Vaccination

SELECT ['CovidDeaths'].location, ['CovidVaccinations'].date, ['CovidDeaths'].population, ['CovidVaccinations'].new_vaccinations
,SUM(Cast(['CovidVaccinations'].new_vaccinations as int)) OVER (Partition by ['CovidDeaths'].location ORDER BY ['CovidDeaths'].location, ['CovidVaccinations'].date) as OnGoingVaccination
FROM ['CovidDeaths']
join ['CovidVaccinations']
on ['CovidDeaths'].location = ['CovidVaccinations'].location
and ['CovidDeaths'].date = ['CovidVaccinations'].date
WHERE ['CovidDeaths'].continent is not null
ORDER BY OnGoingVaccination desc

-- USE CTE

WITH POPVSVAC (location,date,population,new_vaccinations,OnGoingVaccination)
as
(
SELECT ['CovidDeaths'].location, ['CovidVaccinations'].date, ['CovidDeaths'].population, ['CovidVaccinations'].new_vaccinations
,SUM(Cast(['CovidVaccinations'].new_vaccinations as int)) OVER (Partition by ['CovidDeaths'].location ORDER BY ['CovidDeaths'].location, ['CovidVaccinations'].date) as OnGoingVaccination
FROM ['CovidDeaths']
join ['CovidVaccinations']
on ['CovidDeaths'].location = ['CovidVaccinations'].location
and ['CovidDeaths'].date = ['CovidVaccinations'].date
WHERE ['CovidDeaths'].continent is not null
)
SELECT *, (OnGoingVaccination/population)*100 as VaccinationPercentage
FROM POPVSVAC


--TEMP TABLE

CREATE TABLE #PercentPopulationVaccinated
( 
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
OnGoingVaccination numeric
)



INSERT INTO #PercentPopulationVaccinated
SELECT ['CovidDeaths'].location, ['CovidVaccinations'].date, ['CovidDeaths'].population, ['CovidVaccinations'].new_vaccinations
,SUM(Cast(['CovidVaccinations'].new_vaccinations as int)) OVER (Partition by ['CovidDeaths'].location ORDER BY ['CovidDeaths'].location, ['CovidVaccinations'].date) as OnGoingVaccination
FROM ['CovidDeaths']
join ['CovidVaccinations']
on ['CovidDeaths'].location = ['CovidVaccinations'].location
and ['CovidDeaths'].date = ['CovidVaccinations'].date
WHERE ['CovidDeaths'].continent is not null


SELECT *, (OnGoingVaccination/population)*100 as VaccinationPercentage
FROM #PercentPopulationVaccinated

-- Creating View for further Visualization 

CREATE VIEW PercentPopulationVaccinated as

SELECT ['CovidDeaths'].location, ['CovidVaccinations'].date, ['CovidDeaths'].population, ['CovidVaccinations'].new_vaccinations
,SUM(Cast(['CovidVaccinations'].new_vaccinations as int)) OVER (Partition by ['CovidDeaths'].location ORDER BY ['CovidDeaths'].location, ['CovidVaccinations'].date) as OnGoingVaccination
FROM ['CovidDeaths']
join ['CovidVaccinations']
on ['CovidDeaths'].location = ['CovidVaccinations'].location
and ['CovidDeaths'].date = ['CovidVaccinations'].date
WHERE ['CovidDeaths'].continent is not null

SELECT *
FROM PercentPopulationVaccinated