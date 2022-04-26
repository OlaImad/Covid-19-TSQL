select top (100)*
from CovidDeaths
where continent is not NULL
order by 1,2

-- Looking at Total cases vs total death
select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100, 2) as Percentage_Death
from CovidDeaths
where location like'%brazil%'
order by 1,2

-- looking at total cases vs population
-- shows what percentage of popluation got covid
select location, date, total_cases, population, round((total_cases/population)*100, 2) as PercentOfPopulationInfected
from CovidDeaths
where location like'%brazil%'
order by 1,2

 -- Countries with highest infection rate compared to population
 select location, max(total_cases) as highestInfectionCount, population, round(max((total_cases/population))*100, 2) as PercentOfPopulationInfected
from CovidDeaths
--where location like'%brazil%'
group by location, population
order by PercentOfPopulationInfected desc

-- countries with highest death count per population
 select location, max(total_deaths) as TotalDeathCount, population, round(max((total_deaths/population))*100, 2) as PercentOfDeathOfPopulation
from CovidDeaths
--where location like'%brazil%'
group by location, population
order by PercentOfDeathOfPopulation desc

-- countries with highest death count
select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not NULL
group by location
order by TotalDeathCount desc

-- by continent

select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is NULL
group by location
order by TotalDeathCount desc

-- Global numbers
select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, (sum(cast(new_deaths as int))/(sum(new_cases)))*100 as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by 1

-- Total Population VS vaccination
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as bigint)) OVER (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from CovidDeaths d
join CovidVaccinations v
on d.location = v.location and d.date = v.date
where d.continent is not null
order by 2,3

-- USE CTE 

with PopVsVac (continent, location,date,population, new_vaccinations,RollingPeopleVaccinated)
as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as bigint)) OVER (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from CovidDeaths d
join CovidVaccinations v
on d.location = v.location and d.date = v.date
where d.continent is not null

)
select *, (RollingPeopleVaccinated/population)*100
from PopVsVac

-- TEMP TABLE
-- DROP TABLE IF EXISTS #PercentPopulationVaccinated 
CREATE TABLE #PercentPopulationVaccinated (
continent nvarchar (100),
location nvarchar (100),
date datetime,
population numeric,
new_vaccinations int,
RollingPeopleVaccinated float
)
insert into #PercentPopulationVaccinated
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as bigint)) OVER (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from CovidDeaths d
join CovidVaccinations v
on d.location = v.location and d.date = v.date
where d.continent is not null

select *, (RollingPeopleVaccinated/population)*100 as PopulationPercentageVaccinated
from #PercentPopulationVaccinated

-- CREATING A VIEW TO STORE DATA FOR LATER VISUALIZATIONS 
CREATE VIEW PercentPopulationVaccinated as

select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as bigint)) OVER (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from CovidDeaths d
join CovidVaccinations v
on d.location = v.location and d.date = v.date
where d.continent is not null
