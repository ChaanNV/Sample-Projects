---For Tableau 
---1.Total_cases,deaths,death percentage

select sum(new_cases) total_cases, SUM(cast(new_deaths as int)) total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
from Projectportfolio..CovidDeaths
where continent is not null 
order by 1,2;

---2.By continent. Location discrepancies exist in the data set pertaining to location.
---select location from Projectportfolio..CovidDeaths
---where location in ('World', 'European Union','International')

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From Projectportfolio..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


---3. finding the highest infected count and percentage population infected in each country

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Projectportfolio..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc


----4. Coninuation of the previous query but grouping by date to give the data on infected on a date basis

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Projectportfolio..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc
