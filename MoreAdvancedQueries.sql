SELECT TOP 100 *
FROM [CovidGlobalDataSet].[dbo].[CovidVaccinations$];

SELECT TOP 100 *
FROM [CovidGlobalDataSet].[dbo].[CovidDeaths$];

--	Showing Global death, infection and death rate:
SELECT 
	date,
	SUM(new_cases) AS TotalInfections, 
	SUM(new_deaths) AS TotalDeaths,
	CASE
		WHEN SUM(new_cases) > 0 THEN (SUM(new_deaths) / SUM(new_cases)) * 100
		ELSE 0
	END
	AS TotalDeathRate
FROM [CovidGlobalDataSet].[dbo].[CovidDeaths$]
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY TotalDeathRate DESC;

-- The following query will copy those data to the CovidVaccinations Table
INSERT INTO [CovidGlobalDataSet].[dbo].[CovidVaccinations$] (
	total_tests, 
	new_tests, 
	new_tests_per_thousand, 
	new_tests_smoothed, 
	new_tests_per_thousand_smoothed, 
	positive_rate, 
	tests_per_case)
SELECT 
	total_tests, 
	new_tests, 
	new_tests_per_thousand, 
	new_tests_smoothed, 
	new_tests_smoothed_per_thousand, 
	positive_rate, 
	tests_per_case
FROM CovidGlobalDataSet.dbo.CovidDeaths$;

-- Adds new columns to a table:
USE CovidGlobalDataSet;
ALTER TABLE CovidVaccinations$
ADD
	total_tests INT,
	new_tests INT,
	new_tests_per_thousand FLOAT,
	new_tests_smoothed INT,
	new_tests_per_thousand_smoothed FLOAT,
	positive_rate FLOAT,
	tests_per_case FLOAT;

-- changes the datatype of a column in a table
ALTER TABLE CovidVaccinations$
ALTER COLUMN 
	new_tests_smoothed FLOAT;
	--total_tests FLOAT;
	--new_tests FLOAT;


--Joins
SELECT 
	Deaths.continent,
	Deaths.country,
	Vacc.date,
	Deaths.population,
	Vacc.new_vaccinations,
	SUM(Vacc.new_vaccinations) OVER (PARTITION BY Deaths.country 
									 ORDER BY Deaths.date) AS vaccinations
FROM [CovidGlobalDataSet].[dbo].[CovidDeaths$] AS Deaths
JOIN [CovidGlobalDataSet].[dbo].[CovidVaccinations$] AS Vacc
	ON Deaths.country = Vacc.country
	AND Deaths.date = Vacc.date
WHERE Deaths.country LIKE 'Al%'
ORDER BY Vacc.country;


-- delete a specific column from a table
USE CovidGlobalDataSet
ALTER TABLE CovidVaccinations$
DROP COLUMN gdp_per_capita;
-- population_density, median_age, life_expectancy, gdp_per_capita

SELECT 
	Deaths.continent,
	Deaths.country,
	Vacc.date,
	Deaths.population,
	Vacc.new_vaccinations,
	SUM(Vacc.new_vaccinations) OVER (PARTITION BY Deaths.country ORDER BY Deaths.country, Deaths.date) AS total_vaccinations
FROM [CovidGlobalDataSet].[dbo].[CovidDeaths$] AS Deaths
JOIN [CovidGlobalDataSet].[dbo].[CovidVaccinations$] AS Vacc
	ON Deaths.country = Vacc.country
	AND Deaths.date = Vacc.date
WHERE Deaths.continent IS NOT NULL
ORDER BY 2, 3


-- Candidates to use CTEs
WITH PopVsVacc (continent, country, date, population, new_vaccinations, total_vaccinations)
AS
(
SELECT 
	Deaths.continent,
	Deaths.country,
	Vacc.date,
	Deaths.population,
	Vacc.new_vaccinations,
	SUM(Vacc.new_vaccinations) OVER (PARTITION BY Deaths.country ORDER BY Deaths.country, Deaths.date) AS total_vaccinations
FROM [CovidGlobalDataSet].[dbo].[CovidDeaths$] AS Deaths
JOIN [CovidGlobalDataSet].[dbo].[CovidVaccinations$] AS Vacc
	ON Deaths.country = Vacc.country
	AND Deaths.date = Vacc.date
WHERE Deaths.continent IS NOT NULL
)
SELECT *, (total_vaccinations / population) * 100 AS Vaccination_percentage
FROM PopVsVacc
ORDER BY country, date;
