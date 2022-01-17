--Data from OurWorldInData.org url = https://ourworldindata.org/covid-deaths from 24-02-2020 to 16-01-2022

Select*
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Shows the likelihood of dying if you contract Covid in Portugal

Select Location, date, total_deaths, total_cases, ( cast(total_deaths as float) / cast(total_cases as float))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%Portugal%'
order by 1,2

--Looking at Total Cases vs Population
-- Shows what percentage of population of Portugal got Covid

Select Location, date, Population, total_cases, ( cast(total_cases as float) / cast( Population as float))*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
where location like '%Portugal%'
order by 1,2

-- Looking at Contries with Highest Infection Rate comapred to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max( cast((total_cases) as float) / cast( Population as float))*100 as PercentPupulationInfected
from PortfolioProject..CovidDeaths
Group by Location, Population
order by PercentPupulationInfected desc

-- Showing Countries with Highest Death Count 

Select Location, Max(cast(total_deaths as float)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by Location
order by TotalDeathCount desc

-- Showing continents with highest death count per Population

Select location, SUM(cast(new_deaths as float)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International', 'High middle income', 'Lower middle income', 'Upper middle income', 'Low income', 'High income')
Group by location
order by TotalDeathCount desc

-- Global Numbers

Select date, SUM(cast(new_cases as float)) as New_Cases_WorldWide, SUM(cast(new_deaths as float)) as New_Deaths_WorldWide, (SUM(cast(new_deaths as float))/SUM(cast(new_cases as float)))*100 as death_percentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

-- Total cases, deaths and death percentage worldwide

Select  SUM(cast(new_cases as float)) as New_Cases_WorldWide, SUM(cast(new_deaths as float)) as New_Deaths_WorldWide, (SUM(cast(new_deaths as float))/SUM(cast(new_cases as float)))*100 as death_percentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Population vs Vaccination


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as VaccinationCount
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- CTE
-- Population vs Vaccination Portugal
-- We can get more then 100% because we have already vaccinated people with 2 and 3 doses, there is no way to know the real percentage of population that is vaccinated other then the numbers the government says people are vaccinated

with PopVsVacc (Continent, location, date, population, new_vaccinations, VaccinationCount)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as VaccinationCount
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select*, (VaccinationCount/population)*100 as PercentageVaccinated
From PopVsVacc
where location like '%Portugal%'

--Population vs Vaccination World
--Numbers can be more then 100% because governments have given 2 and 3 doses to some people, there is no way to know the real number of pleople who are vaccinated other then the numbers the governments say people are vaccinated

with PopVsVacc (Continent, location, date, population, new_vaccinations, VaccinationCount)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as VaccinationCount
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select*, (VaccinationCount/population)*100 as PercentageVaccinated
From PopVsVacc


--Temp table

drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
VaccinationCount numeric
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as VaccinationCount
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

Select*, (VaccinationCount/population)*100 as PercentageVaccinated
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create view PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as VaccinationCount
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *
from PercentagePopulationVaccinated
