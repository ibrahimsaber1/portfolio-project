
select *
from portofolioProject..CovidDeaths
WHERE continent is not null
order by 3,4

--select *
--from portofolioProject..CovidVaccinations
--order by 3,4

--1--select the data we will work on

select location, date, total_cases, new_cases, total_deaths, population
from portofolioProject..CovidDeaths
WHERE continent is not null
order by 1,2

--2--looking for total cases vs total deaths

select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
from portofolioProject..CovidDeaths
where location like '%States%' AND continent is not null
order by DeathPercentage DESC

--3--loking for the percentage of cases compear with population
-----show what percentage of population got covid

select location, date, population, total_cases, (cast(total_cases as float)/population)*100 as CasePercentage
from portofolioProject..CovidDeaths
--where location = 'brazil'
order by 1,2

--4-- looking for countries with highest infection rate compared to population

select location, max(population) as population, max (CAST(total_cases AS INT)) as MaxTotalCases, (MAX(total_cases)/MAX(population))*100 AS PERCENTAG
from portofolioProject..CovidDeaths
--where location like '%States%'
WHERE continent is not null
group by location
order by 3 DESC

--OR

WITH MaxTotalCasesCTE AS (
    SELECT location, population, MAX(total_cases) AS MaxTotalCases
    FROM portofolioProject..CovidDeaths
    GROUP BY location, population
)

SELECT
    MTC.location,
    MTC.population,
    MTC.MaxTotalCases,
    (MTC.MaxTotalCases / MTC.population) * 100 AS infectionPercentage
FROM MaxTotalCasesCTE MTC
--where location = 'united states'
ORDER BY 4 DESC;

--5--showing countres with the highist death count population

select location, max(population) as population, max (CAST(total_deaths AS INT)) as MaxTotalDeath, (MAX(total_deaths)/MAX(population))*100 AS PERCENTAGE
from portofolioProject..CovidDeaths
--where location like 'CHINA'
WHERE continent is not null
group by location
order by 3 DESC

--OR

with MaxTotalDeathCTE as (
select location, max(population) as Maxpopulation, max (total_deaths) as MaxTotalDeath
from portofolioProject..CovidDeaths
group by location
)
Select 
      MTD.location,
	  MTD.Maxpopulation,
	  MTD.MaxTotalDeath,
	  (MTD.MaxTotalDeath/MTD.Maxpopulation)*100 AS PERCENTAGE 
FROM MaxTotalDeathCTE  MTD
ORDER BY 3 DESC

--6-- NOW LET'S BREAK THINGS DOWEN BY COUNTINENT

select continent, max(population) as population, MAX(CAST(total_deaths AS INT)) as MaxTotalDeath, (MAX(total_deaths)/MAX(population))*100 AS PERCENTAGE
from portofolioProject..CovidDeaths
--where location like 'CHINA'
WHERE continent is NOT null
group by continent
order by 3 DESC

--7-- GLOBAL NUMBER

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From portofolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
--group By date
order by 1,2

--8-- Looking at total vaccination vs population

SELECT dea.location, max(cast(total_deaths as int )) as MaxDesths , 
        max(cast(total_vaccinations as float)) as MaxVaccination
FROM portofolioProject..CovidDeaths dea
JOIN portofolioProject..CovidVaccinations vac
    ON dea.location = vac.location and dea.date = vac.date
	where dea.location  is not null
	group by dea.location
	order by 3 desc

--9-- Using CTE to perform Calculation on Partition By in previous query

With vacreport (Continent, Location, Date, Population, New_Vaccinations, total_vaccination)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as total_vaccination
FROM portofolioProject..CovidDeaths dea
JOIN portofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select Continent, Location, Date, Population, New_Vaccinations, total_vaccination, (total_vaccination/Population)*100 as Per_total_vaccination
From vacreport

--10-- Using Temp Table 
Drop table if exists #vaccinationPerPopulation
Create Table #vaccinationPerPopulation
(
Continent nvarchar(300),
Location nvarchar(300),
Date datetime,
Population numeric,
New_vaccinations numeric,
total_vaccination numeric
)

Insert into #vaccinationPerPopulation
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as total_vaccination
FROM portofolioProject..CovidDeaths dea
JOIN portofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select *, (total_vaccination/Population)*100
From #vaccinationPerPopulation

--11-- creating a view

create view vaccinationPerPopulation as
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as total_vaccination
FROM portofolioProject..CovidDeaths dea
JOIN portofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


