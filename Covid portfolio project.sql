Select *
From [Portfolio Project Covid].dbo.[covid.deaths]
Where continent is not null
Order by 3,4

--Select *
--From [Portfolio Project Covid].dbo.CovidVaccinations
--Order by 3,4


--Select Data that we are going to be using

Select 
location,
date,
total_cases,
new_cases,
total_deaths,
population
From [Portfolio Project Covid].dbo.[covid.deaths]
Where continent is not null
Order by 1,2

--looking at the total cases vs total deaths
--shows the likelihood of dying if you contract covid in your country
Select 
location,
date,
total_cases,
total_deaths,
(total_deaths/total_cases)*100 as deathpercentage
From [Portfolio Project Covid].dbo.[covid.deaths]
Where location like '%states%'
and continent is not null
Order by 1,2

--Looking at the total cases vs population
--shows what percentage of population got covid
Select 
location,
date,
total_cases,
population,
(total_cases/population)*100 as percentpopulation_infected
From [Portfolio Project Covid].dbo.[covid.deaths]
Where location like '%states%'
and continent is not null
Order by 1,2

--looking at countries with highest infection rate compared to population

Select 
location,
population,
max (total_cases) as highest_infection_count,
max(total_cases/population)*100 as percentpopulation_infected
From [Portfolio Project Covid].dbo.[covid.deaths]
--Where location like '%states%'
Where continent is not null
Group by location,population
Order by percentpopulation_infected desc

--Showing countries with highest death count per population
Select 
location,
max (cast(total_deaths as int)) as totaldeath_count
From [Portfolio Project Covid].dbo.[covid.deaths]
--Where location like '%states%'
Where continent is not null
Group by location
Order by totaldeath_count desc


--let's break things down by continent

--showing the continents with the highest death count per population

Select 
continent,
max (cast(total_deaths as int)) as totaldeath_count
From [Portfolio Project Covid].dbo.[covid.deaths]
--Where location like '%states%'
Where continent is not null
Group by continent
Order by totaldeath_count desc

--global numbers
Select 
date,
sum(new_cases) as totalcases,
sum(cast(new_deaths as int)) as totaldeaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
--total_deaths,
--(total_deaths/total_cases)*100 as deathpercentage
From [Portfolio Project Covid].dbo.[covid.deaths]
--Where location like '%states%'
Where continent is not null
Group by date
Order by 1,2

--looking at total population vs vaccinations

Select 
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
sum(convert (int,vac.new_vaccinations )) Over (Partition by dea.location Order by dea.location, 
dea.date) as rollingpple_vaccinated
From [Portfolio Project Covid].dbo.[covid.deaths] dea
Join [Portfolio Project Covid].dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


With popvsvac (continent, location, date, population,new_vaccinations, rollingpple_vaccinated)
as
(
Select 
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
sum(convert (int,vac.new_vaccinations )) Over (Partition by dea.location Order by dea.location, 
dea.date) as rollingpple_vaccinated
From [Portfolio Project Covid].dbo.[covid.deaths] dea
Join [Portfolio Project Covid].dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (rollingpple_vaccinated/population)*100
From popvsvac


--temp table

Drop Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpple_vaccinated numeric,
)

Insert into #PercentPopulationVaccinated
Select 
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
sum(convert (int,vac.new_vaccinations )) Over (Partition by dea.location Order by dea.location, 
dea.date) as rollingpple_vaccinated
From [Portfolio Project Covid].dbo.[covid.deaths] dea
Join [Portfolio Project Covid].dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3

Select *, (rollingpple_vaccinated/population)*100
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create view PercentPopulationVaccinated as
Select 
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
sum(convert (int,vac.new_vaccinations )) Over (Partition by dea.location Order by dea.location, 
dea.date) as rollingpple_vaccinated
From [Portfolio Project Covid].dbo.[covid.deaths] dea
Join [Portfolio Project Covid].dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3