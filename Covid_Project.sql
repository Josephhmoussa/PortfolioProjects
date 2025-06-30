SELECT * FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

-- SELECT * FROM covid_vaccinations
-- ORDER BY 3,4;

-- Select Data that we are going to be using

SELECT
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM covid_deaths
ORDER BY 1,2;

-- total cases vs total deaths
-- shows the likelyhood of dying if you contract covid in your country
SELECT
	location,
	date,
	total_cases,
	total_deaths,
	ROUND(total_deaths::DECIMAL / total_cases::DECIMAL * 100.0, 2) AS perc_deaths
FROM covid_deaths
WHERE location LIKE '%Lebanon%' AND continent IS NOT NULL
ORDER BY 1,2;

-- looking at the total cases vs population
-- shows what % of population got Covid
SELECT
	location,
	date,
	population,
	total_cases,
	ROUND(total_cases::DECIMAL / population::DECIMAL * 100.0, 2) AS perc_population_infected
FROM covid_deaths
WHERE location LIKE '%Lebanon%' AND continent IS NOT NULL
ORDER BY 1,2;

-- countries with highest infection rate compared to population
SELECT
	location,
	population,
	MAX(total_cases) AS highest_infection_count,
	ROUND(MAX(total_cases)::DECIMAL / population::DECIMAL * 100.0, 2) AS perc_population_infected
FROM covid_deaths
-- WHERE location LIKE '%Lebanon%'
WHERE continent IS NOT NULL
GROUP BY 1,2
ORDER BY 4 DESC NULLS LAST;

-- countires with highest death count per population
SELECT
	location,
	MAX(total_deaths) AS highest_deaths_count
FROM covid_deaths
-- WHERE location LIKE '%Lebanon%'
WHERE continent IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC NULLS LAST;

-- Showing the continents with the highest death counts
SELECT
	continent,
	MAX(total_deaths) AS highest_deaths_count
FROM covid_deaths
-- WHERE location LIKE '%Lebanon%'
WHERE continent IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC NULLS LAST;

-- GLOBAL NUMBERS

SELECT
	date,
	SUM(new_cases) AS total_cases,
	SUM(new_deaths) AS total_deaths,
	ROUND(SUM(new_deaths)::DECIMAL / SUM(new_cases)::DECIMAL * 100.0, 2) AS perc_deaths
FROM covid_deaths
-- WHERE location LIKE '%Lebanon%'
WHERE continent IS NOT NULL
GROUP BY 1
ORDER BY 1,2;

SELECT
	-- date,
	SUM(new_cases) AS total_cases,
	SUM(new_deaths) AS total_deaths,
	ROUND(SUM(new_deaths)::DECIMAL / SUM(new_cases)::DECIMAL * 100.0, 2) AS perc_deaths
FROM covid_deaths
-- WHERE location LIKE '%Lebanon%'
WHERE continent IS NOT NULL
-- GROUP BY 1
ORDER BY 1,2;

--  Looking at total population vs vaccinations

SELECT
	d.continent,
	d.location,
	d.date,
	d.population,
	v.new_vaccinations
FROM covid_vaccinations v
JOIN covid_deaths d
	ON d.location = v.location 
	AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2,3;

-- Rolling count of vaccination count

SELECT
	d.continent,
	d.location,
	d.date,
	d.population,
	v.new_vaccinations,
	SUM(v.new_vaccinations) OVER(PARTITION BY d.location ORDER BY d.date) AS rolling_people_vaccinated
FROM covid_vaccinations v
JOIN covid_deaths d
	ON d.location = v.location 
	AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2,3;

-- Use CTE

WITH pop_vs_vac AS (
	SELECT
		d.continent,
		d.location,
		d.date,
		d.population,
		v.new_vaccinations,
		SUM(v.new_vaccinations) OVER(PARTITION BY d.location ORDER BY d.date) AS rolling_people_vaccinated
	FROM covid_vaccinations v
	JOIN covid_deaths d
		ON d.location = v.location 
		AND d.date = v.date
	WHERE d.continent IS NOT NULL
	ORDER BY 2,3
)
SELECT
	*,
	ROUND((rolling_people_vaccinated::DECIMAL / population::DECIMAL) * 100.0, 2)
FROM pop_vs_vac;

-- Creating View to store data for later visualisations

CREATE VIEW percent_population_vaccinated AS (
		SELECT
		d.continent,
		d.location,
		d.date,
		d.population,
		v.new_vaccinations,
		SUM(v.new_vaccinations) OVER(PARTITION BY d.location ORDER BY d.date) AS rolling_people_vaccinated
	FROM covid_vaccinations v
	JOIN covid_deaths d
		ON d.location = v.location 
		AND d.date = v.date
	WHERE d.continent IS NOT NULL
	ORDER BY 2,3
);

SELECT *
FROM percent_population_vaccinated

	