SELECT TOP 100 *
FROM PortfollioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 3, 4

--SELECT TOP 100 *
--FROM PortfollioProject..CovidVaccinations
--ORDER BY 3, 4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfollioProject..CovidDeaths
ORDER BY location, date


-- Looking at total case vs total deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfollioProject..CovidDeaths
WHERE location LIKE '%africa%'
ORDER BY location, date



-- Looking at the total cases vs the population
-- Shows what percentage of population got Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfollioProject..CovidDeaths
WHERE location LIKE '%state%'
ORDER BY location, date


-- Looking at Country with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfollioProject..CovidDeaths
-- WHERE location LIKE '%state%'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(Total_deaths) TotalDeathCount
FROM PortfollioProject..CovidDeaths
-- WHERE location LIKE '%state%'
WHERE continent is  NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- LET'S BREAK THINGS DOWN BY CONTINENT

SELECT continent, MAX(Total_deaths) TotalDeathCount
FROM PortfollioProject..CovidDeaths
-- WHERE location LIKE '%state%'
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- Showing the Contintent with Highest Death Counts

SELECT continent, MAX(Total_deaths) TotalDeathCount
FROM PortfollioProject..CovidDeaths
-- WHERE location LIKE '%state%'
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS Total_cases, SUM(new_deaths) AS Total_deaths,  SUM(new_deaths)/ SUM(new_cases) * 100 AS DeathPercentage
FROM PortfollioProject..CovidDeaths
--WHERE location LIKE '%state%'
WHERE continent is NOT NULL
--GROUP BY date
ORDER BY 1, 2


-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfollioProject..CovidDeaths dea
JOIN PortfollioProject..CovidVaccinations vac
	ON dea.date = vac.date
	AND dea.location = vac.location
WHERE dea.continent IS NOT NULL
--AND dea.location LIKE '%canada%'
ORDER BY dea.location, dea.date


-- USE CTE

WITH PopvsVac (continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfollioProject..CovidDeaths dea
JOIN PortfollioProject..CovidVaccinations vac
	ON dea.date = vac.date
	AND dea.location = vac.location
WHERE dea.continent IS NOT NULL
--AND dea.location LIKE '%canada%'
--ORDER BY dea.location, dea.date
)

SELECT *, (RollingPeopleVaccinated/Population) * 100
FROM PopvsVac

--select Location, population, MAX((RollingPeopleVaccinated/Population) * 100)
--from PopvsVac
--GROUP BY location, population
--ORDER BY location

--SELECT *, (RollingPeopleVaccinated/Population)* 100
--FROM PopvsVac
--WHERE location IN ('Angola', 'Armenia', 'Belarus', 'Benin')


-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfollioProject..CovidDeaths dea
JOIN PortfollioProject..CovidVaccinations vac
	ON dea.date = vac.date
	AND dea.location = vac.location
WHERE dea.continent IS NOT NULL
--AND dea.location LIKE '%canada%'
--ORDER BY dea.location, dea.date

SELECT *, (RollingPeopleVaccinated/Population)
FROM #PercentPopulationVaccinated



-- Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfollioProject..CovidDeaths dea
JOIN PortfollioProject..CovidVaccinations vac
	ON dea.date = vac.date
	AND dea.location = vac.location
WHERE dea.continent IS NOT NULL
--AND dea.location LIKE '%canada%'
--ORDER BY dea.location, dea.date

CREATE VIEW PercentPopulationInfected AS
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfollioProject..CovidDeaths
-- WHERE location LIKE '%state%'
GROUP BY location, population
--ORDER BY PercentPopulationInfected desc

 -- This one is by continents

CREATE VIEW TotalDeathCounts AS
SELECT location, MAX(Total_deaths) TotalDeathCount
FROM PortfollioProject..CovidDeaths
-- WHERE location LIKE '%state%'
WHERE continent is  NULL
GROUP BY location
--ORDER BY TotalDeathCount DESC


-- This one is by locations


CREATE VIEW 
TotalDeathcountsLocations AS
SELECT location, MAX(Total_deaths) TotalDeathCount
FROM PortfollioProject..CovidDeaths
-- WHERE location LIKE '%state%'
WHERE continent is  NULL
GROUP BY location
--ORDER BY TotalDeathCount DESC