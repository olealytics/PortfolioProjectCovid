
SELECT @@GLOBAL.sql_mode global, @@SESSION.sql_mode session;
SET sql_mode = '';
SET GLOBAL sql_mode = '';    
SELECT 
    *
FROM
    PortfolioProject.coviddeaths
order by 3,4;
SELECT location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.coviddeaths
order by 1,2;

-- Looking at Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.CovidDeaths
where location like '%nistan%'
order by 1,2;
-- Looking al Total Cases vs Population
-- Show what percentege of population got covid

SELECT location, date, total_cases, population, (total_cases/population)*100 as PopulationPercentage
From PortfolioProject.CovidDeaths
where location like '%nistan%'
order by 1,2;

-- Lookign at countries with highest infection rate compared to population

SELECT location, Population, MAX(total_cases) as HightesInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject.CovidDeaths
-- where location like '%nistan%'
Group by Location, Population
order by PercentPopulationInfected desc;

-- Showing Countries with Highest Death Count Per Population

SELECT location, Population, MAX(total_deaths) as HightesDeathsCount, Max((total_deaths/population))*100 as PercentPopulationDeaths
From PortfolioProject.CovidDeaths
Group by Location, Population
order by PercentPopulationDeaths desc;


SELECT location, MAX(cast(total_deaths as unsigned)) as TotalDeathsCount
From PortfolioProject.CovidDeaths
Where continent  is not null
Group by Location
order by TotalDeathsCount desc;

-- Showing the continent with the Higest Death Count  per Population

SELECT continent, MAX(cast(total_deaths as unsigned)) as TotalDeathsCount
From PortfolioProject.CovidDeaths
Where continent  is not null
Group by Continent
order by TotalDeathsCount desc;

-- Global Number

SELECT SUM(new_cases) as Total_Cases, SUM(CAST(new_deaths as unsigned)) as Total_Deaths, SUM(CAST(new_deaths as unsigned))/SUM(CAST(new_cases as unsigned))*100 as DeathPercentage
From PortfolioProject.CovidDeaths
where continent IS NOT NULL 
-- Group by date
order by 1,2;

-- Looking at Total Population vs Vaccinations
SELECT 
* FROM PortfolioProject.coviddeaths dea
join PortfolioProject.covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date;


WITH PopvsVac (continent, location, date, population, RollingPeopleVaccinated) AS 
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location Order By dea.location, dea.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
FROM PortfolioProject.coviddeaths dea
join PortfolioProject.covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100 from PopvsVac;

-- tem table
DROP VIEW IF EXISTS PercentPopulationVaccinated; 
CREATE TABLE PercentPopulationVaccinated 
(Continent varchar(255),
Location varchar(255),
Datedetail text,
Population int,
New_Vaccinations text,
RollingPeopleVaccinated int
);

DESC PercentPopulationVaccinated; 


INSERT INTO PercentPopulationVaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order By dea.location, dea.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
FROM PortfolioProject.coviddeaths dea 
join PortfolioProject.covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null;
-- order by 2,3

Select (RollingPeopleVaccinated/Population)*100 from PercentPopulationVaccinated;

-- Creating View to Store data for later visualizations

show tables; 
Create view PercentPopulationVaccinated1 AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order By dea.location, dea.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
FROM PortfolioProject.coviddeaths dea 
join PortfolioProject.covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null;
-- order by 2,3

Select * from PercentPopulationVaccinated1
