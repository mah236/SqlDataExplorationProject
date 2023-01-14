select *
from PortfolioProject..['CovidDeath]
where continent is not null
order by 3,4 

--select *
--from PortfolioProject..['Covid Vaccination]
--order by 3,4 

--Select data that we are going to be using 

select location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..['CovidDeath]
order by 1,2


-- Looking at the total cases vs total death 
-- shows what percentage of people got covid

select location, date, population,total_cases, (total_cases/population)*100 as Percentpopulationinfected  
from PortfolioProject..['CovidDeath]
where location like '%states%' 
order by 1,2

-- Looking at countries with highest infection rate compared to population 

select location, population, Max (total_cases) as HighestInfectionCount, max((total_cases/population)) *100 as Percentpopulationinfected
from PortfolioProject..['CovidDeath]
--where location like '%states%' 
Group By location, population
order by Percentpopulationinfected desc 

--showing countries with highest death count per population 

select location, Max (cast (total_deaths as int)) as totaldeathcount 
from PortfolioProject..['CovidDeath]
--where location like '%states%' 
where continent is not null 
Group By location
order by totaldeathcount desc 


--lets's break things down by continent 

select continent, Max (cast (total_deaths as int)) as totaldeathcount 
from PortfolioProject..['CovidDeath]
--where location like '%states%' 
where continent is not null 
Group By continent
order by totaldeathcount desc 

--showing the continents with highest death counts per population 

select continent, Max (cast (total_deaths as int)) as totaldeathcount 
from PortfolioProject..['CovidDeath]
--where location like '%states%' 
where continent is not null 
Group By continent
order by totaldeathcount desc 

--Global Numbers 

select SUM (new_cases) as total_cases, SUM (cast(new_deaths as int)) as total_death, SUM (cast(new_deaths as int))/SUM (new_cases)*100 as deathpercentage
from PortfolioProject..['CovidDeath]
--where location like '%states%'
where continent is not null 
--group by date 
order by 1,2

-- looking at total population vs vaccination 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (convert (int,vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..['CovidDeath] dea
join PortfolioProject..['Covid Vaccination] vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
order by 2,3


with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (convert (int,vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..['CovidDeath] dea
join PortfolioProject..['Covid Vaccination] vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac



--Temp Table 


DROP TABLE IF EXISTS #PercentPeopleVaccinated
Create Table #PercentPeopleVaccinated 
(
continent nvarchar (255), 
Location nvarchar (255),
Date datetime, 
population numeric, 
New_Vaccinations numeric,
RollingPeopleVaccinated numeric 
)

Insert into #PercentPeopleVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (convert (int,vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..['CovidDeath] dea
join PortfolioProject..['Covid Vaccination] vac
on dea.location = vac.location 
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3


select *, (RollingPeopleVaccinated/Population)*100
from #PercentPeopleVaccinated 







--Looking at total cases vs exploration 
select location, date, , total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from PortfolioProject..['CovidDeath]
where location like '%states%' 
order by 1,2


--Creating view to store data for later visualization 

create view PercentPeopleVaccinate AS 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (convert (int,vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..['CovidDeath] dea
join PortfolioProject..['Covid Vaccination] vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

SELECT * FROM 
PercentPeopleVaccinate