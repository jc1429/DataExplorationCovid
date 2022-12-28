USE PortfolioProject

SELECT * 
FROM CovidDeaths
WHERE continent IS NOT NULL

SELECT * 
FROM CovidVaccinations

SELECT
	location,date,total_cases,new_cases,total_deaths,population
FROM 
	CovidDeaths
ORDER BY 1,2

-- Checking Malaysia's Death Rate
SELECT
	location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 death_percentage
FROM 
	CovidDeaths
WHERE
	location = 'Malaysia'
ORDER BY 
	1 ASC,2 DESC

-- Total Cases vs Population
SELECT
	location,date,total_cases,Population,(total_cases/population)*100 total_cases_against_population
FROM 
	CovidDeaths
WHERE
	location = 'Malaysia'
ORDER BY 
	1 ASC,2 DESC

-- Highest infection rate compared to the population

SELECT
	location,Population,MAX(total_cases) Highest_Infection_Count,MAX(total_cases/population)*100 total_cases_against_population
FROM 
	CovidDeaths
WHERE continent IS NOT NULL
GROUP BY 
	location, population
ORDER BY 
	4 DESC

-- Showing each country death count
SELECT
	location,MAX(total_deaths) Total_Death_Count
FROM 
	CovidDeaths
WHERE 
	continent IS NOT NULL
GROUP BY 
	location
ORDER BY CAST(MAX(total_deaths) AS INT) DESC

-- Showing accurate each continent death count
SELECT
	location,MAX(CAST(total_deaths AS INT)) Total_Death_Count
FROM 
	CovidDeaths
WHERE 
	continent IS NULL
GROUP BY 
	location
ORDER BY MAX(CAST(total_deaths AS INT)) DESC

-- Showing Continent (Not accurate)
--SELECT
--	CONTINENT,MAX(CAST(total_deaths AS INT)) Total_Death_Count
--FROM 
--	CovidDeaths
--WHERE 
--	continent IS NOT NULL
--GROUP BY 
--	CONTINENT
--ORDER BY CAST(MAX(total_deaths) AS INT) DESC

-- Total deaths vs Population (Continent)
SELECT
	location,MAX(CAST(total_deaths AS INT)) Total_Death_Count,population,MAX(CAST(total_deaths AS INT))/population * 100 Total_Deaths_VS_Population
FROM 
	CovidDeaths
WHERE 
	continent IS NULL
GROUP BY 
	location,population
HAVING 
	population IS NOT NULL
ORDER BY 
	MAX(CAST(total_deaths AS INT)) DESC


-- Global numbers
SELECT
	date,SUM(new_cases) new_cases_per_day, SUM(CAST(new_deaths AS int)) new_deaths_per_day, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS death_rate
FROM 
	CovidDeaths
WHERE
	continent IS NOT NULL
GROUP BY
	date
HAVING SUM(new_cases) IS NOT NULL
ORDER BY 
	1,2

-- Total cases
SELECT
	SUM(new_cases) total_cases, SUM(CAST(new_deaths AS int)) total_death, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS death_rate
FROM 
	CovidDeaths
WHERE
	continent IS NOT NULL

-- Total Population vs Vaccination Rate
SELECT death.continent,death.location,death.date,death.population,vac.new_vaccinations
FROM
	CovidDeaths death
	JOIN
	CovidVaccinations vac
ON death.location = vac.location AND death.date = death.date
WHERE death.continent IS NOT NULL
ORDER BY 2,3

-- Rolling Total Vaccinations For Each Country
SELECT 
	death.continent,death.location,death.date,death.population,vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY death.location ORDER BY death.location,death.date) AS Total_Vaccinations
FROM
	CovidDeaths death
	JOIN
	CovidVaccinations vac
ON death.location = vac.location AND death.date = vac.date
WHERE death.continent IS NOT NULL
ORDER BY 2,3

-- USE CTE
WITH PopvsVac (Continent,Location,Date,Population,NewVaccinations,RollingPeopleVaccinated) 
AS 
(
SELECT 
	death.continent,death.location,death.date,death.population,vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY death.location ORDER BY death.location,death.date) AS Total_Vaccinations
FROM
	CovidDeaths death
	JOIN
	CovidVaccinations vac
ON death.location = vac.location AND death.date = vac.date
WHERE death.continent IS NOT NULL
)
SELECT location,Population,MAX(RollingPeopleVaccinated), (MAX(RollingPeopleVaccinated)/Population) * 100 Population_Against_Vaccination
FROM PopvsVac
GROUP BY Location,Population
ORDER BY Population_Against_Vaccination DESC

-- TEMP TABLE
-- DROP TABLE IF EXISTS (#PercentPopulationVaccinated)
CREATE TABLE #PercentPopulationVaccinated
(
	Continent  nvarchar(255),
	Location   nvarchar(255),
	Date       datetime     ,
	Population numeric      ,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT 
	death.continent,death.location,death.date,death.population,vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY death.location ORDER BY death.location,death.date) AS Total_Vaccinations
FROM
	CovidDeaths death
	JOIN
	CovidVaccinations vac
ON death.location = vac.location AND death.date = vac.date
WHERE death.continent IS NOT NULL
ORDER BY 2,3

SELECT location,Population,MAX(RollingPeopleVaccinated), (MAX(RollingPeopleVaccinated)/Population) * 100 Population_Against_Vaccination
FROM #PercentPopulationVaccinated
GROUP BY Location,Population
ORDER BY Population_Against_Vaccination DESC

-- CREATE VIEW TO STORE DATA

CREATE VIEW PercentPopulationVaccinated AS
SELECT 
	death.continent,death.location,death.date,death.population,vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY death.location ORDER BY death.location,death.date) AS Total_Vaccinations
FROM
	CovidDeaths death
	JOIN
	CovidVaccinations vac
ON death.location = vac.location AND death.date = vac.date
WHERE death.continent IS NOT NULL
--ORDER BY 2,3