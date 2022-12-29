USE PortfolioProject;

-- Queries for tableau project

-- Checking global death rate
Select 
	SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From 
	CovidDeaths
where 
	continent is not null 
order by 
	1,2

-- Search for each continent's death count
Select 
	location, SUM(cast(new_deaths as int)) as TotalDeathCount
From 
	PortfolioProject..CovidDeaths
Where 
	continent is null and location not in ('World', 'European Union', 'International','High income','Upper middle income','Lower middle income','Low income')
Group by 
	location
order by 
	TotalDeathCount desc

-- Checking for population infected
Select 
	Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From 
	CovidDeaths
Group by 
	Location, Population
Order by 
	PercentPopulationInfected Desc


-- Showing population infected for each country
Select 
	Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From 
	CovidDeaths
Group by 
	Location, Population, date
Order by 
	PercentPopulationInfected desc

-- Global numbers by date range
Select 
	date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From 
	CovidDeaths
where 
	continent is not null 
GROUP BY
	date
order by 
	1,2

