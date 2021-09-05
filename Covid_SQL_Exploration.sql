/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

select *
from Portfolio_Project ..Covid_deaths
where continent is not null
order by 3,4

--select *
--from Portfolio_Project ..Covid_Vaccination
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from Portfolio_Project..Covid_deaths
Where continent is not null
order by 1,2


--Total_cases vs Total_Deaths in Percentage
--Likelihood of dying if you contract covid in you country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Portfolio_Project..Covid_deaths
--Where location like '%Ireland'
where continent is not null
order by 1,2


----Total_cases vs Population in percentage
--Shows Percentage of Population who got covid
select location, date,population, total_cases, (total_cases/population)*100 as InfectedPercentage
from Portfolio_Project..Covid_deaths
--Where location like '%Ireland'
where continent is not null
order by 1,2


--Countries with highest infection rate compared to population
select location, population, MAX(total_cases) as HighInfectionCount , MAX((total_cases/population)) * 100 as InfectedPerecentage
from Portfolio_Project..Covid_deaths
--Where location like '%Ireland'
where continent is not null
Group by location,population
order by InfectedPerecentage desc


--Countries with Highest Death count per population
--total_death datattype is varchar and this will not display correct results. Converting to int type. Using Cast
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from Portfolio_Project..Covid_deaths
--Where location like '%Ireland'
where continent is not null
Group by location
order by TotalDeathCount desc	


--breakdown by continent but the numbers are not real after running query but only usefull because i want to run drill down in tableau
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from Portfolio_Project..Covid_deaths
--Where location like '%Ireland'
where continent is not null
Group by continent
order by TotalDeathCount desc	

--These are the actual numbers
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from Portfolio_Project..Covid_deaths
--Where location like '%Ireland'
where continent is null
Group by location
order by TotalDeathCount desc	



--Global Numbers of cases and deaths by date.
select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as  DeathPercentage
from Portfolio_Project..Covid_deaths
--Where location like '%Ireland'
where continent is not null
Group by date
order by 1,2

--Total global numbers and not by date
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as  DeathPercentage
from Portfolio_Project..Covid_deaths
where continent is not null
order by 1,2

-------------------------------------------------------------------------------------------------------------------------------------------------------

select *
from Portfolio_Project ..Covid_Vaccination

--Joins on Vaccination and Death data 
select *
from Portfolio_Project ..Covid_deaths dea
Join Portfolio_Project ..Covid_Vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date

--Total population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from Portfolio_Project ..Covid_deaths dea
Join Portfolio_Project ..Covid_Vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Using CTE(Common Table expression) to create percentage of people vaccinated by date. CTE and select should have same columns
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
( 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from Portfolio_Project ..Covid_deaths dea
Join Portfolio_Project ..Covid_Vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 as PercentagePopulationVaccinated
from PopvsVac




--TEMP Table. Same thing as above but using Temp Table
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
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from Portfolio_Project ..Covid_deaths dea
Join Portfolio_Project ..Covid_Vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as PercentagePopulationVaccinated
From #PercentPopulationVaccinated


--Creaitng view to store data and use it to visualize it later.
Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from Portfolio_Project ..Covid_deaths dea
Join Portfolio_Project ..Covid_Vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *
from PercentPopulationVaccinated