/* Portfolio Project*/

/* To explore the data of the Covid Deaths occurred in the year 2021 and the vaccinations provided to the patients in the same year */


SELECT * FROM PortfolioProject..CovidDeaths;


SELECT location, date, total_cases, new_cases, total_deaths, population FROM PortfolioProject..CovidDeaths ORDER BY 1,2;


-- Total Cases vs Total Deaths
-- Death Percentage of each country

SELECT location, date, total_cases, total_deaths, (CAST(total_deaths as float) / CAST(total_cases as float)) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;


-- Total Cases vs Total Population
-- Percentage of affected population

SELECT location, date, total_cases, total_deaths, population, (CAST(total_deaths as float) / CAST(population as float)) * 100 AS AffectedPercentage
FROM PortfolioProject..CovidDeaths 
ORDER BY 1,2;


-- Countries with highest infection rate

SELECT location, population, MAX(total_cases) As HighestInfectionCount, MAX((CAST(total_deaths as float) / CAST(population as float))) * 100 AS AffectedPercentage
FROM PortfolioProject..CovidDeaths 
GROUP BY location, population
ORDER BY AffectedPercentage desc;

-- Countries with highest death count per population

SELECT location, population, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY TotalDeathCount DESC;

-- Based on the continents

SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;


-- Total Death Percentage

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int))as total_deaths, 
(SUM(CAST(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2


SELECT * FROM PortfolioProject..CovidVaccinations;

/* Joining Both CovidDeaths and CovidVaccinations on location and date*/

SELECT * FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v ON
d.location = v.location AND
d.date = v.date;

/* Total Population Vs Vaccinations (Joining both tables on location and date) */

-- Country with highest number of new vaccinations created (Starting From highest to lowest)

SELECT d.location, d.date, d.population, v.new_vaccinations FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v ON
d.location = v.location AND
d.date = v.date
WHERE new_vaccinations IS NOT NULL
ORDER BY new_vaccinations DESC;


-- Calculating the sum of all new vaccinations and then getting the result divided amongst the locations

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(bigint, v.new_vaccinations)) 
OVER (PARTITION BY d.location ORDER BY d.location, d.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v ON
d.location = v.location AND
d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2,3;


-- Getting the RollingPeopleVaccinated per population

-- By creating a Common Table Expression

WITH PerPop
AS
(SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(bigint, v.new_vaccinations)) 
OVER (PARTITION BY d.location ORDER BY d.location, d.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v ON
d.location = v.location AND
d.date = v.date
WHERE d.continent IS NOT NULL
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/Population)*100 As Percentage FROM PerPop;


/* Creating views  */

CREATE VIEW PerPop AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(bigint, v.new_vaccinations)) 
OVER (PARTITION BY d.location ORDER BY d.location, d.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v ON
d.location = v.location AND
d.date = v.date
WHERE d.continent IS NOT NULL;




