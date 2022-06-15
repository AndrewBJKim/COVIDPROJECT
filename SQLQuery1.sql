
Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

 --Select Data that will be used


Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Morbidity in you contract COVID in US
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Where Location like '%states%'
order by 1,2


-- Looking at Total Cases vs Population
Select location, date, total_cases, population, (total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
Where Location = 'united states'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
Select location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location, Population
order by PercentagePopulationInfected desc

-- Looking at Countries with the Highest Death Count per Population
Select location, Population, MAX(total_deaths) as HighestDeathCount, MAX((total_deaths/population))*100 as PercentagePopulationDeaths
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location, Population
order by PercentagePopulationDeaths desc

--Total Death Count
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- BY CONTINENT

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
Group by location
order by TotalDeathCount desc

-- Looking at Continent with Highest Death Count per Population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global #
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
--Group by Date
order by 1,2


--Join CovidVaccinations & CovidDeaths

Select *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

-- Looking at Total Population vs Vaccinations

With PopvsVac (Continent, Location, Date, Population, people_fully_vaccinated, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.people_fully_vaccinated
, SUM(CONVERT(bigint, vac.people_fully_vaccinated)) OVER (Partition by dea.location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
From PopvsVac

-- USE CTE ROUND 2
With PopvsVac (Continent, Location, Date, Population, people_fully_vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, cast(vac.people_fully_vaccinated as int)
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (people_fully_vaccinated/Population)*100 as PercentPopulationFullyVaccinated
From PopvsVac

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationFullyVaccinated
Create Table #PercentPopulationFullyVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
people_fully_vaccinated numeric
)

Insert into #PercentPopulationFullyVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.people_fully_vaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (people_fully_vaccinated/Population)*100 as PercentPeopleFullyVaccinated
From #PercentPopulationFullyVaccinated

-- Creating View to store data for later Viz

Create View PercentPopulationFullyVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.people_fully_vaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *
From PercentPopulationFullyVaccinated

