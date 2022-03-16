SELECT *
FROM [Portfolio Project Covid]..CovidDeaths
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project Covid]..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths per country
-- Shows likelihood of dying of covid in each country (USA selected)
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Case_Mortality
FROM [Portfolio Project Covid]..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

-- Looking at Total Cases vs Population
SELECT location, date, total_cases, population, (total_cases/population)*100 as Case_Rate
FROM [Portfolio Project Covid]..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

-- Countries with the Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionRate, MAX((total_cases/population))*100 as
	PercentPopulationInfected
FROM [Portfolio Project Covid]..CovidDeaths
GROUP BY location, population
ORDER BY 4 DESC



--Showing countries with the highest death count per population
SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project Covid]..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--Broken down by Continent, excluding country income group, non-specified international.

SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project Covid]..CovidDeaths
WHERE continent is null
AND location NOT LIKE '%income%' 
AND location NOT LIKE 'International'
GROUP BY location
ORDER BY TotalDeathCount DESC

--Global Numbers
SELECT SUM(new_cases) as 'Total Cases', SUM(CAST(new_deaths as int)) as 'Total Deaths', 
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as 'Case Mortality'
FROM [Portfolio Project Covid]..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


--Total Population vs Vaccinations CTE
With PopvsVax (Continent , location, date, population, New_Vaccinations, RollingVaccinationCount)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
	SUM(CAST(vax.new_vaccinations as bigint)) OVER(Partition by dea.location Order by dea.location,
	dea.Date) as RollingVaccinationCount
--(RollingVaccinationCount/population)*100
FROM [Portfolio Project Covid]..CovidDeaths dea
JOIN [Portfolio Project Covid]..CovidVaccinations vax
	On dea.location =vax.location
	And dea.date = vax.date
WHERE dea.continent is not null 
)
SELECT * , (RollingVaccinationCount/population)*100
FROM PopvsVax

-- TEMP TABLE 
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric, 
RollingVaccinationCount numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
	SUM(CAST(vax.new_vaccinations as bigint)) OVER(Partition by dea.location Order by dea.location,
	dea.Date) as RollingVaccinationCount
FROM [Portfolio Project Covid]..CovidDeaths dea
JOIN [Portfolio Project Covid]..CovidVaccinations vax
	On dea.location =vax.location
	And dea.date = vax.date
WHERE dea.continent is not null 
SELECT *, (RollingVaccinationCount/population)*100 as PercentVaccinated
FROM #PercentPopulationVaccinated


CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
	SUM(CAST(vax.new_vaccinations as bigint)) OVER(Partition by dea.location Order by dea.location,
	dea.Date) as RollingVaccinationCount
FROM [Portfolio Project Covid]..CovidDeaths dea
JOIN [Portfolio Project Covid]..CovidVaccinations vax
	On dea.location =vax.location
	And dea.date = vax.date
WHERE dea.continent is not null 

SELECT *
From PercentPopulationVaccinated