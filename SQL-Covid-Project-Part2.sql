--vaccination table exploration
select * from summary_covid_vaccine
where location = 'United States';

select continent, location, date, population, 
people_vaccinated, people_fully_vaccinated,
(people_vaccinated/population)*100 as vaccination_percent,
(people_fully_vaccinated/population)*100 as full_vaccination_percent,
(people_fully_vaccinated/people_vaccinated)*100 as vac_vs_full
from summary_covid_vaccine
order by 1, 2, 3;

--altering existing tables
alter table summary_covid_vaccine
add vaccination_percent numeric;
alter table summary_covid_vaccine
add full_vaccination_percent numeric;
alter table summary_covid_vaccine
add vac_vs_full numeric;

update summary_covid_vaccine
set vaccination_percent = (people_vaccinated/population)*100;
update summary_covid_vaccine
set full_vaccination_percent = (people_fully_vaccinated/population)*100;
update summary_covid_vaccine
set vac_vs_full = (people_fully_vaccinated/people_vaccinated)*100;

--verifying column additions and update of table
select * from summary_covid_vaccine
where location = 'United States';

--Rounding up percentages
update summary_covid_vaccine
set vaccination_percent = ROUND(vaccination_percent, 4);
update summary_covid_vaccine
set full_vaccination_percent = ROUND(full_vaccination_percent, 4);
update summary_covid_vaccine
set vac_vs_full = ROUND(vac_vs_full, 4);

--verifying update of table
select * from summary_covid_vaccine
where location = 'United States';


--Universal Numbers (to avoid grouping, I used sum)
select date, sum(population) as population, sum(new_tests) as total_tests,
(sum(new_tests)/sum(population))*100 as world_test_percent
from covid_vaccine
where continent is not null
group by date
order by 1;

create table world_vaccine
(date date,
 population numeric, 
 total_tests numeric,
 total_test_percent numeric, 
 total_vac_number numeric, 
 total_full_vac_number numeric, 
 vac_percent numeric);
insert into world_vaccine
select date, sum(population) as population, sum(new_tests) as total_tests, 
(sum(new_tests)/sum(population))*100 as total_test_percent, 
sum(people_vaccinated) as total_vac_number, 
sum(people_fully_vaccinated) as total_full_vac_number, 
(sum(people_vaccinated)/sum(population))*100 as vac_percent
from covid_vaccine
where continent is not null
group by date
order by 1;

--verifying the created table
select * from world_vaccine;

--deleting rows from the table
delete from world_vaccine
where date in ('2020-01-01', '2020-01-02', '2020-01-03', '2020-01-04');

--rounding up percentage columns
update world_vaccine
set total_test_percent = ROUND(total_test_percent, 5);
update world_vaccine
set vac_percent = ROUND(vac_percent, 4);

--verifying the changes made
select * from world_vaccine;

-- analyzing vaccination based on continents
select location, max(people_vaccinated) as highest_vaccination_count,
max(people_fully_vaccinated) as highest_full_vaccination_count
from covid_vaccine
where continent is null
group by location
order by highest_vaccination_count desc;

create table max_vaccination
(location varchar, 
 highest_vaccination_count numeric, 
 highest_full_vaccination_count numeric);
insert into max_vaccination
select location, max(people_vaccinated) as highest_vaccination_count,
max(people_fully_vaccinated) as highest_full_vaccination_count
from covid_vaccine
where continent is null
group by location
order by highest_vaccination_count desc;

--verifying the newly created table
select * from max_vaccination;


select * from max_vaccination;
alter table max_vaccination
add vaccination_percent numeric;

update max_vaccination
set vaccination_percent = (highest_full_vaccination_count/highest_vaccination_count)*100;
update max_vaccination
set vaccination_percent = ROUND (vaccination_percent, 4);

select * from covid_details
where stringency_index is not null and gdp_per_capita is not null
order by 2, 3;

create table covid_details_2
(location varchar,
date date,
population numeric,
stringency_index numeric,
life_expectancy numeric,
gdp_per_capita numeric,
human_development_index numeric);
insert into covid_details_2
select location, date, population, stringency_index, 
life_expectancy, gdp_per_capita, human_development_index
from covid_details
where stringency_index is not null and gdp_per_capita is not null
order by 1,2;
select * from covid_details_2
where location = 'India';


select location, max(population) as population, 
avg(stringency_index) as avg_stringency, max(life_expectancy) as life_expectancy,
max(gdp_per_capita) as gdp_per_capita, max(human_development_index) as human_development_index
from covid_details_2
where human_development_index is not null
group by location
order by avg_stringency desc;

create table covid_stringency
(location varchar, 
 population numeric, 
 avg_stringency numeric, 
 life_expectancy numeric, 
 gdp_per_capita numeric, 
 human_development_index numeric);
insert into covid_stringency
select location, max(population) as population, 
avg(stringency_index) as avg_stringency, max(life_expectancy) as life_expectancy,
max(gdp_per_capita) as gdp_per_capita, max(human_development_index) as human_development_index
from covid_details_2
where human_development_index is not null
group by location
order by avg_stringency desc;

update covid_stringency
set avg_stringency = ROUND (avg_stringency, 4);
select * from covid_stringency;


select * from covid_excess_mortality;

create table excess_mortality_europe
(continent varchar, 
 location varchar, 
 date date, 
 excess_mortality numeric);
insert into excess_mortality_europe
select continent, location, date, excess_mortality
from covid_excess_mortality
where continent = 'Europe' and excess_mortality is not null
order by 2, 3;
select * from excess_mortality_europe;

create table NorthAmerica_excess_mortality
(continent varchar, 
 location varchar, 
 date date, 
 excess_mortality numeric);
insert into NorthAmerica_excess_mortality
select continent, location, date, excess_mortality
from covid_excess_mortality
where continent = 'North America' and excess_mortality is not null
order by 2, 3;
select * from NorthAmerica_excess_mortality;


create table Asia_excess_mortality
(continent varchar, 
 location varchar, 
 date date, 
 excess_mortality numeric);
insert into Asia_excess_mortality
select continent, location, date, excess_mortality
from covid_excess_mortality
where continent = 'Asia' and excess_mortality is not null
order by 2, 3;
select * from Asia_excess_mortality;

--copying tables I created 
COPY summary_covid_vaccine TO '/Applications/PostgreSQL 16/Custom/summary-covid-vaccine.csv' DELIMITER ',' CSV HEADER;
COPY asia_excess_mortality TO '/Applications/PostgreSQL 16/Custom/asia-excess-mortality.csv' DELIMITER ',' CSV HEADER;
COPY covid_details_2 TO '/Applications/PostgreSQL 16/Custom/covid-details-2.csv' DELIMITER ',' CSV HEADER;
COPY covid_stringency TO '/Applications/PostgreSQL 16/Custom/covid-stringency.csv' DELIMITER ',' CSV HEADER;

COPY excess_mortality_europe TO '/Applications/PostgreSQL 16/Custom/europe-excess-mortality.csv' DELIMITER ',' CSV HEADER;
COPY max_vaccination TO '/Applications/PostgreSQL 16/Custom/max-vaccination.csv' DELIMITER ',' CSV HEADER;
COPY northamerica_excess_mortality TO '/Applications/PostgreSQL 16/Custom/northamerica-excess-mortality.csv' DELIMITER ',' CSV HEADER;
COPY world_vaccine TO '/Applications/PostgreSQL 16/Custom/world-vaccine.csv' DELIMITER ',' CSV HEADER;


