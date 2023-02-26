select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4


--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying from Covid if you contract it in the United States

select location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

-- Looking at the Total Cases vs Population
-- Shows what percentage of the population got Covid

select location, date, population, total_cases, (total_cases / population)*100 as PrecentPopulationInfected
from PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

-- Looking at countries with highest infection rate compared to population

select location,  population, Max(total_cases) as HighestInfectionCount, max((total_cases / population))*100 as PrecentPopulationInfected
from PortfolioProject..CovidDeaths
--Where location like '%states%'
group by location, population
order by PrecentPopulationInfected desc


-- Showing countries with Highest Death Count per Population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc

-- Break down by continent and income

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is null
group by location
order by TotalDeathCount desc

-- Showing the continents with highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global numbers

select  date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int) ) /sum(new_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where  continent is not null
group by date
order by 1,2

-- Total global numbers as of 2/24/23

select   sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int) ) /sum(new_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where  continent is not null
--group by date
order by 1,2

-- Total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast( vac.new_vaccinations as bigint )) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinated

from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- use CTE

with PopvsVac (continent, Location, Date, Population, New_Vaccinations, RollingVaccinated) as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast( vac.new_vaccinations as bigint )) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinated

from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)

Select *, (RollingVaccinated /Population) * 100
from PopvsVac

-- Temp Table

drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast( vac.new_vaccinations as bigint )) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinated

from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
-- order by 2,3

Select *, (RollingVaccinated /Population) * 100
from #PercentPopulationVaccinated


-- Create View for visualizations

Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast( vac.new_vaccinations as bigint )) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinated

from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
-- order by 2,3

Create view USDeathPerc as
select location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where location like '%states%'


Create view USInfPop as 
select location, date, population, total_cases, (total_cases / population)*100 as PrecentPopulationInfected
from PortfolioProject..CovidDeaths
Where location like '%states%'


Create view GlobalInfRate as
select location,  population, Max(total_cases) as HighestInfectionCount, max((total_cases / population))*100 as PrecentPopulationInfected
from PortfolioProject..CovidDeaths
--Where location like '%states%'
group by location, population
--order by PrecentPopulationInfected desc

Create view ContDeaths as
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
group by continent
--order by TotalDeathCount desc
