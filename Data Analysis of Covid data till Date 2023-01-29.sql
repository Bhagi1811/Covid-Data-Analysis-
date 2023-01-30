--SELECT *
--FROM ProjectOnCovid..CovidDeaths
--ORDER BY 3,4

--SELECT location, date, total_cases, new_cases, total_deaths, population
--FROM ProjectOnCovid..CovidDeaths
--ORDER BY 1,2

-- Total cases vs Total deaths
-- total percrntage of deaths by covid

SELECT location,date, total_cases ,total_deaths, (total_deaths/total_cases) * 100 AS DeathPercemtage
FROM ProjectOnCovid..CovidDeaths
WHERE location like 'India'
ORDER BY 1,2


-- Total cases vs populations
-- total percentage of people who got covid

SELECT location,date,population,total_cases , (total_cases/population) * 100 AS CasePercentage
FROM ProjectOnCovid..CovidDeaths
--WHERE location like 'India'
ORDER BY 1,2


-- Highest infection rate

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) * 100 AS PercentagePopulationInfected
FROM ProjectOnCovid..CovidDeaths
--WHERE location like '%States%'
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC

-- Highest Death Rate

SELECT location, population, MAX(total_deaths) AS HighestDeathCount, MAX((total_deaths/population)) * 100 AS PercentagePopulationDeath
FROM ProjectOnCovid..CovidDeaths
--WHERE location like '%States%' AND 
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY HighestDeathCount DESC


-- Breaking down by location


SELECT location, MAX(total_deaths) AS HighestDeathCount
FROM ProjectOnCovid..CovidDeaths
--WHERE location like '%States%' AND 
WHERE location IS NULL
GROUP BY location
ORDER BY HighestDeathCount DESC

-- Breaking down by Continent

SELECT continent, MAX(total_deaths) AS HighestDeathCount
FROM ProjectOnCovid..CovidDeaths
--WHERE location like '%States%' AND 
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC


-- global numbers

SELECT  SUM(new_cases) AS TotalCasesPerDate, SUM(CAST(new_deaths AS int)), SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM ProjectOnCovid..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER by TotalCasesPerDate



-- Location vs Vaccinations

SELECT dea.location, MAX(vac.total_vaccinations) AS HighestVaccinated, 
FROM ProjectOnCovid..CovidDeaths dea
JOIN ProjectOnCovid..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.location IS NOT NULL
GROUP BY dea.location
ORDER BY HighestVaccinated DESC


--Tootal Population Vs Vaccinations


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Counter
FROM ProjectOnCovid..CovidDeaths dea
JOIN ProjectOnCovid..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.location IS NOT NULL
ORDER BY 2,3





-- USE CTE

WITH popvsvac (continent, location, date, population, new_vaccinations, Counter)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Counter
--Counter/dea.po
FROM ProjectOnCovid..CovidDeaths dea
JOIN ProjectOnCovid..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.location IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (Counter/population)*100  
FROM popvsvac


-- Temp Table


DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date Datetime,
population numeric,
new_vaccinations numeric,
Counter numeric
)

INSERT INTO #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Counter
--Counter/dea.po
FROM ProjectOnCovid..CovidDeaths dea
JOIN ProjectOnCovid..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.location IS NOT NULL
--ORDER BY 2,3

SELECT *, (Counter/population)*100  
FROM #PercentPopulationVaccinated



-- Creating Views for later Visulization

CREATE View PercentPopulationVaccinated2 AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Counter
--Counter/dea.po
FROM ProjectOnCovid..CovidDeaths dea
JOIN ProjectOnCovid..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.location IS NOT NULL
--ORDER BY 2,3














