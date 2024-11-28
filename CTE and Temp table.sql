USE CovidGlobalDataSet;

SELECT 
	Deaths.continent,
	Deaths.country,
	Deaths.date,
	Deaths.population,
	Vacc.new_vaccinations,
	SUM(new_vaccinations) OVER (PARTITION BY Deaths.country 
								ORDER BY Deaths.country, Deaths.date) AS total_vaccinations
FROM CovidGlobalDataSet.dbo.CovidDeaths$ AS Deaths
JOIN CovidGlobalDataSet.dbo.CovidVaccinations$ AS Vacc
	ON Deaths.country = Vacc.country
	AND Deaths.date = vacc.date
WHERE Deaths.continent IS NOT NULL
ORDER BY 2, 3;


--Temp Table

DROP TABLE IF EXISTS #VaccinatedPercentage
CREATE TABLE #VaccinatedPercentage (
	continent NVARCHAR(255),
	country NVARCHAR(255),
	date datetime,
	population NUMERIC,
	new_vaccinations NUMERIC,
	total_vaccinations NUMERIC)

INSERT INTO #VaccinatedPercentage
SELECT 
	Deaths.continent,
	Deaths.country,
	Deaths.date,
	Deaths.population,
	Vacc.new_vaccinations,
	SUM(new_vaccinations) OVER (PARTITION BY Deaths.country 
								ORDER BY Deaths.country, Deaths.date) AS total_vaccinations
FROM CovidGlobalDataSet.dbo.CovidDeaths$ AS Deaths
JOIN CovidGlobalDataSet.dbo.CovidVaccinations$ AS Vacc
	ON Deaths.country = Vacc.country
	AND Deaths.date = vacc.date;

SELECT *, (total_vaccinations / population) * 100 AS Vaccinated_percent
FROM #VaccinatedPercentage
ORDER BY 2, 3;