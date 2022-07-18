select * from Covid_Project..covid_deaths$
where continent is not null
order by 3,4

--select * from Covid_Project..covid_vac$
--order by 3,4

select Location, date, total_cases, new_cases, total_deaths, population
from Covid_Project..covid_deaths$
order by 1, 2

--total cases vs total deaths
--can search by certain countries 

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathrate
from Covid_Project..covid_deaths$
where location like '%canada%'
order by 1, 2

--total cases vs population
select Location, date, total_cases, population, (total_cases/population)*100 as CovidPositivePercent
from Covid_Project..covid_deaths$
where location like '%canada%'
order by 1, 2

--Countries with the highest infection rate to population
select Location, population, max(total_cases) as HighestCases, population, max((total_cases/population))*100 as HighestPopulationInfected
from Covid_Project..covid_deaths$
group by Location, population
order by HighestPopulationInfected desc

--Countries with highest death count to population
select Location, max(cast(total_deaths as int)) as TotalDeathCount
from Covid_Project..covid_deaths$
where continent is not null
group by location 
order by TotalDeathCount desc

--highest death count per continent 

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from Covid_Project..covid_deaths$
where continent is not null
group by continent
order by TotalDeathCount desc

--global numbers

select  date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathrate
from Covid_Project..covid_deaths$
where continent is not null
group by date
order by 1, 2

--total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from Covid_Project..covid_vac$ vac
join Covid_Project..covid_deaths$ dea
	on dea.location =vac.location
	and dea.date =vac.date
where dea.continent is not null
order by 2,3


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as PeopleVaccinated
from Covid_Project..covid_vac$ vac
join Covid_Project..covid_deaths$ dea
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--using cte
WITH populationVSvaccination (continent, Location, Date, Population, New_vaccinations, PeopleVaccinated) as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as PeopleVaccinated
from Covid_Project..covid_vac$ vac
join Covid_Project..covid_deaths$ dea
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
select *, (PeopleVaccinated/population)*100
from populationVSvaccination

--temporary table
Drop table if exists #PopulationVaccinatedPercent
Create table #PopulationVaccinatedPercent
(
continent nvarchar(255),
Location nvarchar(255),
date datetime, 
population numeric,
new_vaccinations numeric,
PeopleVaccinated numeric
)

insert into #PopulationVaccinatedPercent
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as PeopleVaccinated
from Covid_Project..covid_vac$ vac
join Covid_Project..covid_deaths$ dea
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

select *, (PeopleVaccinated/population)*100
from #PopulationVaccinatedPercent

DROP VIEW IF EXISTS PopulationVaccinatedPercent
Create View PopulationVaccinatedPercent as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as PeopleVaccinated
from Covid_Project..covid_vac$ vac
join Covid_Project..covid_deaths$ dea
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


select * from PopulationVaccinatedPercent