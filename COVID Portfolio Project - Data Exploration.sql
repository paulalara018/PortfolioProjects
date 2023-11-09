-- Scan data to be used
Select location, date, total_cases, new_cases, new_deaths, total_deaths, population from PortfolioProject..CovidDeaths

-- Looking at Total Cases vs Total Deaths
-- Shows likelyhood of dying if you contract covid in Colombia
Select location, date, total_cases, total_deaths, (try_convert(float,total_deaths)/try_convert(float,total_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths where location = 'Colombia' order by date desc

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid in Colombia
Select Location, date, total_cases, population, (try_convert(float,total_cases)/try_convert(float,population))*100 as DeathPercentage 
from PortfolioProject..CovidDeaths where location = 'Colombia' order by date desc

-- Looking at Countries with highest infection rate compared to population
Select location, MAX(try_convert(float,total_cases)) as HighestInfectionCount, population, MAX(try_convert(float,total_cases)/try_convert(float,population))*100 as PercentPopulationInfected 
from PortfolioProject..CovidDeaths group by location, population order by PercentPopulationInfected desc

-- Showing countries with highest death count per population
Select location, MAX(cast(total_deaths as int)) as HighestDeathCount, population, MAX(try_convert(float,total_deaths)/try_convert(float,population))*100 as PercentPopulationDeath 
from PortfolioProject..CovidDeaths group by location, population order by PercentPopulationDeath desc

-- Showing countries with the highest death
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths where location not in ('World','High income', 'Upper middle income', 'Europe', 'Asia','North America','South America','Lower middle income', 'European Union') group by location order by TotalDeathCount desc

-- Showing continents with the highest death
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
group by continent
order by TotalDeathCount desc

-- Global numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
from PortfolioProject..CovidDeaths

-- Fix zero
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/ nullif (SUM(new_cases),0)*100 as DeathPercentage 
from PortfolioProject..CovidDeaths group by date  order by date desc

-- The date with highest deaths vs date 
Select date, location, MAX(cast(new_deaths as int)) as total_deaths 
from PortfolioProject..CovidDeaths where location not in ('World','High income', 'Upper middle income', 'Europe', 'Asia','North America','South America','Lower middle income', 'European Union') group by date,location order by total_deaths desc

-- Looking at Total Population vs Vaccinations 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by dea.location, dea.date

-- Looking at total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) over (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent <> ''
order by dea.location, dea.date

---------- Use CTE, Temporary Table and View show the percentage of people vaccinated ------------

-- CTE
with PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) over (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent <> ''
)
Select *,(RollingPeopleVaccinated/Population)*100 as percent_people_vaccinated from PopvsVac

-- Temporary Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated float
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, convert(float,vac.new_vaccinations) as new_vaccionations,
sum(convert(float,vac.new_vaccinations)) over (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent <> ''

Select *,(RollingPeopleVaccinated/Population)*100 as percent_people_vaccinated from #PercentPopulationVaccinated

-- Creating view to store data for later visualizations
Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) over (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent <> ''

Select *, (RollingPeopleVaccinated/Population)*100 as percent_people_vaccinated from PercentPopulationVaccinated
