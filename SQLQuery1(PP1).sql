select * 
from [Portfolio Project] ..CovidDeaths1$
where continent is not null
order by 3,4

--select * 
--from [Portfolio Project] ..CovidDeaths1$
where continent is not null
--order by 3,4

-- select the data we are going to use
select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Project] ..CovidDeaths1$
where continent is not null
order by 1,2

-- looking at total case vs total deaths
-- shows the likelyhood by dying if you contract covind in India

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from [Portfolio Project] ..CovidDeaths1$
where location like'%Indi%'
and continent is not null
order by 1,2

--looking at the total cases vs population 
-- shows what percentage of pepole got covid

select location, date,  population, total_cases, (total_cases/population)*100 as Contracted_covid
from [Portfolio Project] ..CovidDeaths1$
where location like'%Indi%'
and continent is not null
order by 1,2

--countries with highest infection rate compare to populatiuon

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as Percentagepopulationinfected
from [Portfolio Project] ..CovidDeaths1$
where continent is not null
Group by location, Population
order by Percentagepopulationinfected Desc

-- countries with the highest death count per population

select location, max(cast (total_deaths as int))as totaldeathCount
from [Portfolio Project] ..CovidDeaths1$
where continent is not null
Group by location
order by totaldeathCount Desc

-- showing continents with the highest death counts per population

select location, max(cast (total_deaths as int))as totaldeathCount
from [Portfolio Project] ..CovidDeaths1$
where continent is null
Group by location
order by totaldeathCount Desc


--Global numbers

select  date, sum(new_cases) as total_cases, sum(cast (new_deaths AS INT)) as total_deaths , sum(cast (new_deaths AS INT))/SUM(new_cases)*100 as deathpercentage
from [Portfolio Project] ..CovidDeaths1$
where continent is not null
group by date
order by 1,2

--looking at total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_count
from [Portfolio Project]..CovidDeaths1$ as dea
join [Portfolio Project]..CovidVaccination1$ as vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


-- USE CTE(common table expression)

with PopvsVac ( continent, location, date, population, new_vaccinations, rolling_count)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_count
from [Portfolio Project]..CovidDeaths1$ as dea
join [Portfolio Project]..CovidVaccination1$ as vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
select *, (Rolling_count/population)*100
from PopvsVac


--Temp table

Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
 Continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 Rolling_count numeric
 )
 Insert into #PercentPopulationVaccinated
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_count
from [Portfolio Project]..CovidDeaths1$ as dea
join [Portfolio Project]..CovidVaccination1$ as vac
    on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 1,2,3

select *, (Rolling_count/population)*100
from #PercentPopulationVaccinated

--creating views for data visualisation

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_count
from [Portfolio Project]..CovidDeaths1$ as dea
join [Portfolio Project]..CovidVaccination1$ as vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3



select * from PercentPopulationVaccinated
 

