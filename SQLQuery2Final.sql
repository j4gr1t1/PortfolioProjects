Select *
From PorfolioProj.dbo.CovidDeaths
Where continent is not null
order by 3,4

--death percentage with total cases
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percent
From PorfolioProj.dbo.CovidDeaths
Where location = 'India'
order by 1,2

--case percentage with population
Select location, date, total_cases, population, (total_cases/population)*100 as cases_percent
From PorfolioProj.dbo.CovidDeaths
Where location like '%states%'
order by 1,2

--highest cases with population
Select location, max(total_cases) as highest_cases, population, max((total_cases/population))*100 as cases_percent
From PorfolioProj.dbo.CovidDeaths
Where continent is not null
Group by location, population
order by 2 desc

--highest deaths with population
Select location, max(cast(total_deaths as int)) as highest_deaths
From PorfolioProj.dbo.CovidDeaths
Where continent is not null
Group by location, population
order by 2 desc

Select location, max(cast(total_deaths as int)) as highest_deaths
From PorfolioProj.dbo.CovidDeaths
Where continent is null
Group by location, population
order by 2 desc

Select continent, max(cast(total_deaths as int)) as highest_deaths
From PorfolioProj.dbo.CovidDeaths
Where continent is not null
Group by continent
order by 2 desc

--Global death percentage
Select sum(new_cases) as tot_cases, sum(cast(new_deaths as int)) as tot_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as death_percent
from PorfolioProj.dbo.CovidDeaths
where continent is not null
--group by date
order by 1,2

--join both datasets to find out total population vs vaccinations
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, sum(convert(int, cv.new_vaccinations)) 
Over (Partition by cd.location order by cd.location, cd.date) as people_vacc
From PorfolioProj.dbo.CovidDeaths as cd
Join PorfolioProj.dbo.CovidVaccine as cv
	On cd.location=cv.location
	and cd.date=cv.date
where cd.continent is not null
order by 2,3

--Use CTE to divide people_vacc col from population
With PopvsVacc (continent, location, date, population, new_vaccinations, people_vacc)
as
(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, sum(convert(int, cv.new_vaccinations)) 
Over (Partition by cd.location order by cd.location, cd.date) as people_vacc
From PorfolioProj.dbo.CovidDeaths as cd
Join PorfolioProj.dbo.CovidVaccine as cv
	On cd.location=cv.location
	and cd.date=cv.date
where cd.continent is not null
)
Select*, (people_vacc/population)*100
From PopvsVacc

--To find maximum vaccination locations
--With PopvsVacc (continent, location, population, new_vaccinations, people_vacc)
--as
--(
--Select cd.continent, cd.location,  cd.population, cv.new_vaccinations, sum(convert(int, cv.new_vaccinations)) 
--Over (Partition by cd.location order by cd.location) as people_vacc
--From PorfolioProj.dbo.CovidDeaths as cd
--Join PorfolioProj.dbo.CovidVaccine as cv
--	On cd.location=cv.location
--where cd.continent is not null
--Group by cd.location
--)
--Select*, max((people_vacc/population)*100)
--From PopvsVacc

--Use Temp table
Drop table if exists #percentpopvaccinated 
Create table #percentpopvaccinated 
(continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
people_vacc numeric)
Insert into #percentpopvaccinated
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, sum(convert(int, cv.new_vaccinations)) 
Over (Partition by cd.location order by cd.location, cd.date) as people_vacc
From PorfolioProj.dbo.CovidDeaths as cd
Join PorfolioProj.dbo.CovidVaccine as cv
	On cd.location=cv.location
	and cd.date=cv.date
--where cd.continent is not null
Select*, (people_vacc/population)*100 as percent_vacc
From #percentpopvaccinated

--Create view to store data for later visualizations
Create view percentpopvaccinated as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, sum(convert(int, cv.new_vaccinations)) 
Over (Partition by cd.location order by cd.location, cd.date) as people_vacc
From PorfolioProj.dbo.CovidDeaths as cd
Join PorfolioProj.dbo.CovidVaccine as cv
	On cd.location=cv.location
	and cd.date=cv.date
where cd.continent is not null
Select *
From percentpopvaccinated