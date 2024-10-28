Select * 
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select * 
--From PortfolioProject..CovidVaccinations
--order by 3,4

--Selecting the Data that we will be using

Select location, date, total_cases, new_cases, total_deaths, population 
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths in India
-- Shows the likelihood of dying if you contract COVID-19 in your country 

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths
Where location like '%india%'
and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows the percentage of people infected by COVID-19

Select location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage 
From PortfolioProject..CovidDeaths
-- Where location like '%india%'
order by 1,2

-- Looking at countries with Highest Infection Rate w.r.t Population

Select location, MAX(total_cases) as HighestInfectionCount, population, MAX(total_cases/population)*100 as HighestInfectedPercentage
From PortfolioProject..CovidDeaths
-- Where location like '%india%'
Group by location, population
order by HighestInfectedPercentage desc

-- Showing Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
-- Where location like '%india%'
Where continent is not null
Group by location
order by TotalDeathCount desc

-- CONTINENT-WISE DATA

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
-- Where location like '%india%'
Where continent is null
Group by location
order by TotalDeathCount desc


-- Showing Continent with Highest Death Count per Population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
-- Where location like '%india%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths,  SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths
--Where location like '%india%'
Where continent is not null
Group by date
order by 1,2

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths,  SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths
--Where location like '%india%'
Where continent is not null
--Group by date
order by 1,2

-- Joining both the tables
Select * 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as CumulativeVax
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- USE CTE

With PopvsVax(Continent, Location, Date, Population, NewVax, CumulativeVax)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as CumulativeVax
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (CumulativeVax/Population)*100 as CumulativeVaxPercentage
From PopvsVax

-- TEMP TABLE
Drop Table if exists #PercentPopulationVaxxed

Create Table #PercentPopulationVaxxed
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaxs numeric,
CumulativeVaxs numeric
)
Insert into #PercentPopulationVaxxed
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as CumulativeVaxs
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
Select *, (CumulativeVaxs/Population)*100 as CumulativeVaxPercentage
From #PercentPopulationVaxxed

-- Creating view to store data for later visualisations

--Drop view if exists VaxPercentPopulation
IF OBJECT_ID('dbo.VaxPercentPopulation', 'V') IS NOT NULL
    DROP VIEW dbo.VaxPercentPopulation;
GO

Create view dbo.VaxPercentPopulation 
as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as CumulativeVaxs
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
GO

Select * 
From VaxPercentPopulation
