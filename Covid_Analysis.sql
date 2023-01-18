select * from 
portfolio_project..CovidDeaths
where continent is not null

--select * from 
--portfolio_project..CovidVaccinations

--select data that we are going to be using

select location,date,total_cases,total_deaths,population
from portfolio_project..CovidDeaths
where continent is not null

--looking at total cases vs total death

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
from portfolio_project..CovidDeaths
where location = 'India'
and continent is not null
order by 1,2

--looking at total cases vs population

select location,date,population,total_cases,(total_cases/population)*100 as cases_percentage
from portfolio_project..CovidDeaths
where continent is not null
--where location = 'India'
order by 1,2

--countries with highest infection rate in comparision to population

select location,population,max(total_cases) as highest_cases,max((total_cases/population))*100 as cases_percentage
from portfolio_project..CovidDeaths
where continent is not null
group by location,population
order by cases_percentage desc

--showing countries with highest death rate

select location,max(cast(total_deaths as int)) as death_rate
from portfolio_project..CovidDeaths
where continent is not null
group by location
order by death_rate desc

--now by continent
--showing continent by highest death counts

select continent,max(cast(total_deaths as int)) as death_rate
from portfolio_project..CovidDeaths
where continent is not null
group by continent
order by death_rate desc

--global numbers

select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from portfolio_project..CovidDeaths
where continent is not null
--group by date
order by 1,2



--looking at total population vs vaccination


with popvsvacc (continent,location,date,population,new_vaccinations,people_vaccinated)
as(
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum (convert(int,v.new_vaccinations)) over (partition by d.location order by d.location,d.date) as people_vaccinated
from 
portfolio_project..CovidDeaths d
join portfolio_project..CovidVaccinations v
on d.location=v.location
and d.date=v.date
where d.continent is not null
)
select *,(people_vaccinated/population)*100
from popvsvacc


--creating views

create view  percentpopulationvaccinated as
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum (convert(int,v.new_vaccinations)) over (partition by d.location order by d.location,d.date) as people_vaccinated
from 
portfolio_project..CovidDeaths d
join portfolio_project..CovidVaccinations v
on d.location=v.location
and d.date=v.date
where d.continent is not null