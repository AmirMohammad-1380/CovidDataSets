-- How to find the specifications of a table.
USE CovidGlobalDataSet;
EXEC sp_help 'CovidDeaths$';

-- Show the tables in a database
USE CovidGlobalDataSet;
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES;

-- Shows the infection and death rate
SELECT 
	country, 
	date, 
	population, 
	total_cases, 
	total_deaths, 
	case_percentage,
	death_percentage
FROM (
	SELECT
		country,
		date,
		population,
		total_cases,
		total_deaths,
		CASE 
			WHEN total_cases > 0 THEN (total_cases / population) * 100
			ELSE 0
		END AS case_percentage,
		CASE
			WHEN total_deaths > 0 THEN (total_deaths / total_cases) * 100
			ELSE 0
		END AS death_percentage
	FROM CovidGlobalDataSet.dbo.CovidDeaths$
) AS subquery
WHERE country LIKE 'United States' AND death_percentage > 5
ORDER BY date;

-- Looking ar countries with Highest infection rate compared to population.
SELECT 
	country, 
	population, 
	MAX(total_cases) AS MaximumInfectionCount, 
	MAX((total_cases / population)) * 100 AS MaximumInfectionRate
FROM CovidGlobalDataSet.dbo.CovidDeaths$
GROUP BY country, population
ORDER BY MaximumInfectionRate DESC;

--Looking for a specific country's Maximum Infection Rate and Count.
SELECT 
	country,
	population, 
	MaximumInfectionCount,
	MaximumInfectionRate
FROM (
	SELECT 
		country, 
		population, 
		MAX(total_cases) AS MaximumInfectionCount, 
		MAX((total_cases / population)) * 100 AS MaximumInfectionRate
	FROM CovidGlobalDataSet.dbo.CovidDeaths$
	GROUP BY country, population
) AS subquery
WHERE country IN ('United States', 'Iran', 'Japan', 'India', 'South Africa')
ORDER BY MaximumInfectionRate DESC;

-- Looking at countries with highest death count, death per population and death per infected cases:
SELECT 
	country,
	population,
	MAX(total_deaths) AS MaximumDeathCount,
	MAX((total_deaths / population) * 100) AS MaximumDeathPerPopulation,
	MAX(
		CASE	
			WHEN total_cases > 0 THEN (total_deaths / total_cases) * 100
			ELSE 0
		END 
	)AS MaximumDeathPerInfectedCases
FROM [CovidGlobalDataSet].[dbo].[CovidDeaths$]
GROUP BY country, population
ORDER BY MaximumDeathPerInfectedCases DESC;

-- Looking at countries with highest death count, death per population and death per infected cases for a specific country:
SELECT 
	country,
	population,
	MaximumDeathCount,
	MaximumDeathPerPopulation,
	MaximumDeathPerInfectedCases
FROM (
	SELECT 
		country,
		population,
		MAX(total_deaths) AS MaximumDeathCount,
		MAX((total_deaths / population) * 100) AS MaximumDeathPerPopulation,
		MAX(
			CASE	
				WHEN total_cases > 0 THEN (total_deaths / total_cases) * 100
				ELSE 0
			END 
		)AS MaximumDeathPerInfectedCases
	FROM [CovidGlobalDataSet].[dbo].[CovidDeaths$]
	GROUP BY country, population
) AS subquery
WHERE country IN ('Iran', 'United States', 'Germany', 'Nigeria', 'Brazil', 'Argentina', 'China')
ORDER BY MaximumDeathCount DESC;

-- Looking at Maximum death, infection, death rate and infection rate over continents:
SELECT
	country,
	population,
	MAX(total_cases) AS MaximumContinentionalCases,
	MAX(total_deaths) AS MaximumContinentionalDeath,
	MAX(
		CASE
			WHEN total_cases > 0 THEN (total_deaths / total_cases) * 100
			ELSE 0
		END
	) AS ContinentionalDeathRate
FROM [CovidGlobalDataSet].[dbo].[CovidDeaths$]
WHERE continent IS NULL AND country IN ('North America', 'Africa', 'Oceania', 'Europe', 'Asia', 'World')
GROUP BY country, population
ORDER BY MaximumContinentionalDeath DESC;



