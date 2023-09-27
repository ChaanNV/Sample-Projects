select * 
from Projectportfolio..CovidDeaths
order by 3,4


--select *  from Projectportfolio..CovidVaccination order by 3,4


---select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from Projectportfolio..CovidDeaths
order by 1,2;

---looking at total cases vs total deaths
--- likelihood of dying if you contract covid in the country
select location, date, total_cases,  total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from Projectportfolio..CovidDeaths
where location like 'India'
order by 1,2;

--- looking at total cases and the population
--- shows what percentage of population got covid
select location, date, total_cases,  population,(total_cases/population)*100 as PercentageofCovid
from Projectportfolio..CovidDeaths
where location like 'India'
order by 1,2;
---Looking at countries with highest infection rate compared to population
select location,population, max(total_cases) as 'Highest Infection Count',max((total_cases/population))*100 as PercentagePopulationInfected
from Projectportfolio..CovidDeaths
group by location,population
order by PercentagePopulationInfected desc;


---showing countries with Highest Death Count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount 
from Projectportfolio..CovidDeaths
group by location
order by TotalDeathCount desc; 

select * 
from Projectportfolio..CovidDeaths
where continent is not null
order by 3,4;

select location, max(cast(total_deaths as int)) as TotalDeathCount 
from Projectportfolio..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc; 

---Breaking things by continent
Select continent, max(cast(total_deaths as int)) as TotalContinentDeathCount
from Projectportfolio..CovidDeaths
where continent is not null
group by continent
order by TotalContinentDeathCount desc;

Select location, max(cast(total_deaths as int)) as TotalDeathCount
from Projectportfolio..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc;

---GLOBAL NUMBERS
---DeathPercentage
select  date, sum(new_cases) 'Total Cases', sum(cast(new_deaths as int)) 'Total Deaths', sum(cast(new_deaths as int))/sum(new_cases)* 100 'DeathPercentage'
from Projectportfolio..CovidDeaths
where continent is not null
group by date
order by 1,2;

---Total Deaths
select   sum(new_cases) 'Total Cases', sum(cast(new_deaths as int)) 'Total Deaths', sum(cast(new_deaths as int))/sum(new_cases)* 100 'DeathPercentage'
from Projectportfolio..CovidDeaths
where continent is not null
order by 1,2;


---JOINing CovidDeaths and CovidVaccinations
select * 
from Projectportfolio..CovidDeaths dea
join Projectportfolio..CovidVaccination vac
	on dea.location=vac.location
	and dea.date=vac.date;


----- Looking at total population vs vaccination
----- Total People vaccinated over location and over date, Partition table
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from Projectportfolio..CovidDeaths dea
join Projectportfolio..CovidVaccination vac
	on dea.date=vac.date
	and dea.location=vac.location
	where dea.continent is not null
	order by 2,3;

Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, 
SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location  order by dea.location,dea.date) as RollingPeopleVaccinated
from Projectportfolio..CovidDeaths dea
join Projectportfolio..CovidVaccination vac
	on dea.date=vac.date
	and dea.location=vac.location
where dea.continent is not null 
order by 2,3;

---Using CTE to obtain total percentage population vaccinated partitioned by location and date.

WITH PopVac as 
(
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, 
SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location  order by dea.location,dea.date) as RollingPeopleVaccinated
from Projectportfolio..CovidDeaths dea
join Projectportfolio..CovidVaccination vac
	on dea.date=vac.date
	and dea.location=vac.location
where dea.continent is not null and vac.new_vaccinations is not null
)
select *, (RollingPeopleVaccinated/population)*100 'Percentage Vaxxed'
from PopVac;



---TEMP Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Projectportfolio..CovidDeaths dea
Join Projectportfolio..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated;


---CREATING VIEW to store data for later visualisation

create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Projectportfolio..CovidDeaths dea
Join Projectportfolio..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date;
