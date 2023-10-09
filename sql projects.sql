select * from covid_deaths
limit 1000, 1000;

update covid_deaths
 set continent = "null"
 where iso_code = "OWID_...";

select location, date, total_cases, new_cases, total_deaths, population
from covid_deaths;

# Total cases vs Total Deaths

select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from covid_deaths;

# Total cases vs Population
# shows the percentage of the population that has got covid
select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from covid_deaths;

# Looking at countries with the highest infection rate compared to their population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 
as PercentPopulationInfected
from covid_deaths
group by location, population
order by PercentPopulationInfected desc;

# this is showing the countries with highest death count per population

select location,  max(cast(total_deaths as decimal)) as TotalDeathCount
from covid_deaths
where continent is not null
group by location
order by TotalDeathCount desc;

# lets break things down by continent

select location,  max(cast(total_deaths as decimal)) as TotalDeathCount
from covid_deaths
where continent is  null
group by location
order by TotalDeathCount desc;

select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100
as DeathPercentage
from covid_deaths
group by date;

select  sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100
as DeathPercentage
from covid_deaths;

# Total Population vs Vaccinations
with popvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from covid_deaths dea 
inner join
covid_vaccinations vac
on dea.location = vac.location
 and dea.date = vac.date)
 select *,  (RollingPeopleVaccinated/population) * 100
 from popvac;
 
 # temporary table
 drop table PercentPopulationVaccinated;
 create temporary table PercentPopulationVaccinated (
    continent text,
    location text,
    date text, 
    population int,
    new_vaccinations text,
    RollingPeopleVaccinated int
 );
 
 insert into PercentPopulationVaccinated
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from covid_deaths dea 
inner join
covid_vaccinations vac
on dea.location = vac.location
 and dea.date = vac.date;
 
 select *,  (RollingPeopleVaccinated/population) * 100
 from PercentPopulationVaccinated;
 
 select * from covid_vaccinations;
 
 # creating view for later visualization
 
 create view PercentPopulationVaccinated as
  select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from covid_deaths dea 
inner join
covid_vaccinations vac
on dea.location = vac.location
 and dea.date = vac.date;
 
 select * from PercentPopulationVaccinated;