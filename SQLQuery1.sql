Select *
From Covid202208..CovidDeathsOct
Order by 3,4 

--Select *
--From CovidVaccinationsOct
--Order by 3,4 

Select location, date, total_cases, new_cases, total_deaths, population
From Covid202208..CovidDeathsOct
Order by 1,2

-- Total Cases vs Total Deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as MortalityRate
From Covid202208..CovidDeathsOct
Where location like '%states%'
Order by 1,2

-- Total Cases vs Population in US
Select location, date, population, total_cases, (total_cases/population)*100 as InfectionRate
From Covid202208..CovidDeathsOct
Where location like '%states%'
Order by 1,2

-- Total Cases vs Population Global
Select location, population, MAX(total_cases) as HighestInfectionCount, (MAX(total_cases)/population)*100 as PercentPopulationInfected
From Covid202208..CovidDeathsOct
Group by population, location
Order by PercentPopulationInfected desc

-- Total Deaths vs Population Global
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Covid202208..CovidDeathsOct
Where continent is not null
Group by location
Order by TotalDeathCount desc

-- Total Deaths vs Population by Continent
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Covid202208..CovidDeathsOct
Where continent is null
Group by location
Order by TotalDeathCount desc

-- Global Numbers
Select  SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as MortalityRate
From Covid202208..CovidDeathsOct
Where continent is not null
--Group by date
Order by 1,2

-- Join Death + Vaccinations
Select *
From Covid202208..CovidDeathsOct dea
Join Covid202208..CovidVaccinationsOct vac
	on dea.location = vac.location
	and dea.date = vac.date

-- Total Pop vs Vaccinations

With PopvsVac (Continent, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From Covid202208..CovidDeathsOct dea
Join Covid202208..CovidVaccinationsOct vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as 
From PopvsVac

-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From Covid202208..CovidDeathsOct dea
Join Covid202208..CovidVaccinationsOct vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating view to store data for later data viz

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From Covid202208..CovidDeathsOct dea
Join Covid202208..CovidVaccinationsOct vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
-- Tableau Public

-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Covid202208..CovidDeathsOct
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, SUM(cast(new_deaths as bigint))/SUM(New_Cases)*100 as DeathPercentage
From Covid202208..CovidDeathsOct
--Where location like '%states%'
where location = 'World'
--Group By date
order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as bigint)) as TotalDeathCount
From Covid202208..CovidDeathsOct
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(cast(total_cases as bigint)) as HighestInfectionCount, Max((cast(total_cases as bigint)/population))*100 as PercentPopulationInfected
From Covid202208..CovidDeathsOct
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population, date, MAX(cast(total_cases as bigint)) as HighestInfectionCount, Max((cast(total_cases as bigint)/population))*100 as PercentPopulationInfected
From Covid202208..CovidDeathsOct
Group by Location, Population, date
order by PercentPopulationInfected desc
