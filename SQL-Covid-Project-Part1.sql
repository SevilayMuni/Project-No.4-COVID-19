CREATE TABLE Covid_Death (iso_code varchar,
						  continent varchar,
						  location varchar,
						  date varchar,
						  population numeric,
						  total_cases numeric,
						  new_cases numeric,
						  new_cases_smoothed numeric,
						  total_deaths numeric,
						  new_deaths numeric,
						  new_deaths_smoothed numeric,
						  total_cases_per_million numeric,
						  new_cases_per_million numeric,
						  new_cases_smoothed_per_million numeric,
						  total_deaths_per_million numeric, 
						  new_deaths_per_million numeric,
						  new_deaths_smoothed_per_million numeric,
						  reproduction_rate numeric,
						  icu_patients numeric,
						  icu_patients_per_million numeric,
						  hosp_patients numeric,
						  hosp_patients_per_million numeric,
						  weekly_icu_admissions numeric,
						  weekly_icu_admissions_per_million numeric,
						  weekly_hosp_admissions numeric,
						  weekly_hosp_admissions_per_million numeric);
						  
--importing data into table from csv file
--checking table
select * from covid_death;

--adjusting date column into correct data type
alter table covid_death
alter column date
type date
using to_date(date, 'DD-MM-YYYY');


--creating 2nd table
create table covid_vaccine (iso_code varchar,
							continent varchar,
							location varchar,
							date varchar,
							population numeric,
							total_tests numeric,
							new_tests numeric,
							total_tests_per_thousand numeric,
							new_tests_per_thousand numeric,
							new_tests_smoothed numeric,
							new_tests_smoothed_per_thousand numeric,
							positive_rate numeric,
							tests_per_case numeric,
							tests_units varchar,
							total_vaccinations numeric,
							people_vaccinated numeric,
							people_fully_vaccinated numeric,
							total_boosters numeric,
							new_vaccinations numeric,
							new_vaccinations_smoothed numeric,
							total_vaccinations_per_hundred numeric,
							people_vaccinated_per_hundred numeric,
							people_fully_vaccinated_per_hundred numeric,
							total_boosters_per_hundred numeric,
							new_vaccinations_smoothed_per_million numeric,
							new_people_vaccinated_smoothed numeric,
							new_people_vaccinated_smoothed_per_hundred numeric,
							stringency_index numeric,
							median_age numeric,
							aged_65_older numeric,
							aged_70_older numeric,
							gdp_per_capita numeric,
							extreme_poverty numeric,
							cardiovasc_death_rate numeric,
							diabetes_prevalence numeric,
							female_smokers numeric,
							male_smokers numeric,
							handwashing_facilities numeric,
							hospital_beds_per_thousand numeric,
							life_expectancy numeric,
							human_development_index numeric,
							excess_mortality_cumulative_absolute numeric,
							excess_mortality_cumulative numeric,
							excess_mortality numeric,
							excess_mortality_cumulative_per_million numeric);

alter table covid_vaccine
alter column date
type date
using to_date(date, 'DD-MM-YYYY');						

select * from covid_vaccine;

--verifying ordinary query run
select * from covid_death;

select continent, location, date, population, new_cases, total_cases, new_deaths, total_deaths, hosp_patients,
icu_patients, weekly_hosp_admissions, weekly_icu_admissions
from covid_death
order by 1,2,3;

--creating summary tables for each major table
--1st table
create table summary_covid_deaths
(continent varchar,
 location varchar,
 date date,
 population numeric, 
 new_cases numeric, 
 total_cases numeric, 
 new_deaths numeric, 
 total_deaths numeric, 
 hosp_patients numeric,
 icu_patients numeric, 
 weekly_hosp_admissions numeric, 
 weekly_icu_admissions numeric);

insert into summary_covid_deaths
select continent, location, date, population, new_cases, total_cases, new_deaths, total_deaths, hosp_patients,
icu_patients, weekly_hosp_admissions, weekly_icu_admissions
from covid_death
order by 1,2,3;
select * from summary_covid_deaths;

select * from covid_vaccine;
--2nd table
create table summary_covid_vaccine
(continent varchar,
 location varchar,
 date date,
 population numeric, 
 new_tests numeric, 
 total_tests numeric, 
 tests_per_case numeric, 
 positive_rate numeric, 
 people_vaccinated numeric, 
 people_fully_vaccinated numeric, 
 total_vaccinations numeric);

insert into summary_covid_vaccine
select continent, location, date, population, new_tests, total_tests, 
tests_per_case, positive_rate, people_vaccinated, people_fully_vaccinated, total_vaccinations
from covid_vaccine
order by 1,2,3;

select * from summary_covid_vaccine;

--3rd table
create table covid_details
(continent varchar,
 location varchar,
 date date,
 population numeric, 
 handwashing_facilities numeric, 
 stringency_index numeric, 
 hospital_beds_per_thousand numeric, 
 cardiovasc_death_rate numeric, 
 diabetes_prevalence numeric, 
 life_expectancy numeric, 
 gdp_per_capita numeric, 
 human_development_index numeric);

insert into covid_details
select continent, location, date, population, handwashing_facilities, stringency_index, 
hospital_beds_per_thousand, cardiovasc_death_rate, diabetes_prevalence, 
life_expectancy, gdp_per_capita, human_development_index
from covid_vaccine
order by 1,2,3;
select * from covid_details;

--4th table
create table covid_excess_mortality
(continent varchar,
 location varchar,
 date date,
 population numeric, 
 excess_mortality numeric, 
 excess_mortality_cumulative numeric, 
 excess_mortality_cumulative_absolute numeric);

insert into covid_excess_mortality
select continent, location, date, population,
excess_mortality, excess_mortality_cumulative, excess_mortality_cumulative_absolute
from covid_vaccine
order by 1,2,3;
select * from covid_excess_mortality;


--analyzing total death vs. total cases
select continent, location, date, total_deaths, total_cases, (total_deaths/total_cases)*100 as percentage_death
from summary_covid_deaths
order by 1, 2, 3;

--altering existing tables
alter table summary_covid_deaths
add percentage_death numeric;

update summary_covid_deaths
set percentage_death = (total_deaths/total_cases)*100;
select * from summary_covid_deaths;

--analyzing new cases vs. new death 
select continent, location, date, new_cases, new_deaths, (new_deaths/new_cases)*100 as percentage_new_death
from summary_covid_deaths
where new_cases > 0
order by 1, 2, 3;

--analyzing hospitalized vs. total cases
select continent, location, date, 
hosp_patients, total_cases, (hosp_patients/total_cases)*100 as percentage_hosp
from summary_covid_deaths
where location = 'United States'
order by 1, 2, 3;

--analyzing hospitalized vs. total deaths
select continent, location, date, hosp_patients, total_deaths,
(hosp_patients/total_deaths)*100 as percentage_hosp_death
from summary_covid_deaths
where location = 'United States'
order by 1, 2, 3;

--analyzing hospitalized vs. icu patients
select continent, location, date, hosp_patients, icu_patients, 
(icu_patients/hosp_patients)*100 as percentage_icu_hosp
from summary_covid_deaths
where location = 'United States'
order by 1, 2, 3;

--analyzing icu patients vs. total deaths
select continent, location, date, icu_patients, total_deaths,
(icu_patients/total_deaths)*100 as percentage_icu_death
from summary_covid_deaths
where location = 'United States'
order by 1, 2, 3;

alter table summary_covid_deaths
add percentage_new_death numeric; 
update summary_covid_deaths
set percentage_new_death = (new_deaths/new_cases)*100
where new_cases >0;

alter table summary_covid_deaths
add percentage_hosp numeric;
update summary_covid_deaths
set percentage_hosp = (hosp_patients/total_cases)*100;

alter table summary_covid_deaths
add percentage_hosp_death numeric;
update summary_covid_deaths
set percentage_hosp_death = (hosp_patients/total_deaths)*100;

alter table summary_covid_deaths
add percentage_icu_hosp numeric;
update summary_covid_deaths
set percentage_icu_hosp = (icu_patients/hosp_patients)*100
where hosp_patients > 0;
select * from summary_covid_deaths
where location = 'United States';

alter table summary_covid_deaths
add percentage_icu_death numeric;
update summary_covid_deaths
set percentage_icu_death = (icu_patients/total_deaths)*100;

--analyzing parameters based on population 
alter table summary_covid_deaths
add population_death_percent numeric;
update summary_covid_deaths
set population_death_percent = (total_deaths/population)*100;

alter table summary_covid_deaths
add population_case_percent numeric;
update summary_covid_deaths
set population_case_percent = (total_cases/population)*100; 

alter table summary_covid_deaths
add population_hosp_percent numeric;
update summary_covid_deaths
set population_hosp_percent = (hosp_patients/population)*100; 

alter table summary_covid_deaths
add population_icu_percent numeric;
update summary_covid_deaths
set population_icu_percent = (icu_patients/population)*100; 

--to check addition and update of new columns (USA checked since data flow is consistent and accurate)
select * from summary_covid_deaths
where location = 'United States'
order by 1,2,3;

--Universal Numbers (to avoid grouping, I used sum)
select date, sum(new_cases) as tot_cases, sum(new_deaths) as tot_deaths, 
(sum(new_deaths)/sum(new_cases))*100 as world_death_percent
from covid_death
where continent is not null and (new_cases)>0 
group by date
order by 1;

create table world_covid
(date date, 
 tot_cases numeric, 
 tot_deaths numeric, 
 world_death_percent numeric);
insert into world_covid
select date, sum(new_cases) as tot_cases, sum(new_deaths) as tot_deaths, 
(sum(new_deaths)/sum(new_cases))*100 as world_death_percent
from covid_death
where continent is not null and (new_cases)>0 
group by date
order by 1;


--investigating highest infection rates 
select location, population, max(total_cases) as highest_infection_count,
max((total_cases/population)*100) as case_max_percent,
max(total_deaths) as max_tot_deaths,
max((total_deaths/population)*100) as death_max_percent
from covid_death
where total_cases is not null and total_deaths is not null
group by location, population
order by population desc;

create table max_numbers_covid
(location varchar, 
 population numeric,
 highest_infection_count numeric, 
 case_max_percent numeric, 
 max_tot_deaths numeric, 
 death_max_percent numeric);
insert into max_numbers_covid
select location, population, max(total_cases) as highest_infection_count,
max((total_cases/population)*100) as case_max_percent,
max(total_deaths) as max_tot_deaths,
max((total_deaths/population)*100) as death_max_percent
from covid_death
where total_cases is not null and total_deaths is not null
group by location, population
order by population desc;


create table max_hosp_icu
(location varchar, population numeric, 
 highest_hosp numeric, hosp_max_percent numeric, 
 highest_icu numeric, icu_max_percent numeric);
insert into max_hosp_icu
select location, population, max(hosp_patients) as highest_hosp, 
max((hosp_patients/population)*100) as hosp_max_percent,
max(icu_patients) as highest_icu,
max((icu_patients/population)*100) as icu_max_percent
from covid_death
where hosp_patients is not null and icu_patients is not null 
group by location, population;


--Rounding up percentages columns
update max_hosp_icu
set hosp_max_percent = ROUND(hosp_max_percent, 4); 
update max_hosp_icu
set icu_max_percent = ROUND(icu_max_percent, 4); 

update world_covid
set world_death_percent = ROUND(world_death_percent, 4); 

update max_numbers_covid
set case_max_percent = ROUND(case_max_percent, 4); 
update max_numbers_covid
set death_max_percent = ROUND(death_max_percent, 4); 


update summary_covid_deaths
set percentage_death = ROUND(percentage_death, 4);
update summary_covid_deaths
set percentage_new_death = ROUND(percentage_new_death, 4);
update summary_covid_deaths
set percentage_hosp = ROUND(percentage_hosp, 4);
update summary_covid_deaths
set percentage_hosp_death = ROUND(percentage_hosp_death, 4);
update summary_covid_deaths
set percentage_icu_hosp = ROUND(percentage_icu_hosp, 4);
update summary_covid_deaths
set percentage_icu_death = ROUND(percentage_icu_death, 4);
update summary_covid_deaths
set population_death_percent = ROUND(population_death_percent, 4);
update summary_covid_deaths
set population_case_percent = ROUND(population_case_percent, 4);
update summary_covid_deaths
set population_hosp_percent = ROUND(population_hosp_percent, 4);
update summary_covid_deaths
set population_icu_percent = ROUND(population_icu_percent, 4);

--for verification of updates
SELECT * 
FROM summary_covid_deaths
where location = 'United States';

--copying tables made so far
COPY summary_covid_deaths TO '/Applications/PostgreSQL 16/Custom/summary-covid-deaths.csv' DELIMITER ',' CSV HEADER;
COPY world_covid TO '/Applications/PostgreSQL 16/Custom/world-covid.csv' DELIMITER ',' CSV HEADER;
COPY max_numbers_covid TO '/Applications/PostgreSQL 16/Custom/max-numbers-covid.csv' DELIMITER ',' CSV HEADER;
COPY max_hosp_icu TO '/Applications/PostgreSQL 16/Custom/max-hosp-icu' DELIMITER ',' CSV HEADER;



