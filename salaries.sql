
/*
1. You're a Compensation analyst employed by a multinational corporation. 
Your Assignment is to Pinpoint Countries that give work fully remotely, for the title 'managers’, paying salaries exceeding $90,000
*/

select distinct company_location from salaries
where job_title like '%Manager%' and remote_ratio = 100 and salary_in_usd > 90000;

/*
2. AS a remote work advocate Working for a progressive HR tech startup who place their freshers’ clients IN large tech firms. 
you're tasked WITH Identifying top 5 Country Having greatest count of large (company size) number of companies.
*/

select company_location, count(*) as number_of_companies
from salaries
where company_size = 'L' and experience_level = 'EN'
group by 1
order by 2 desc
limit 5;


/*
3. Picture yourself AS a data scientist Working for a workforce management platform. Your objective is to calculate the percentage of employees. 
Who enjoy fully remote roles WITH salaries Exceeding $100,000 USD, Shedding light ON the attractiveness of high-paying remote positions IN today's job market.
*/

set @total = (select count(*) from salaries where salary_in_usd > 100000);
set @remote = (select count(*) from salaries where salary_in_usd > 100000 and remote_ratio = 100);

set @percent = round(((select @remote)/(select @total))*100,2);
select @percent;


/*
4. Imagine you're a data analyst Working for a global recruitment agency. Your Task is to identify the Locations where entry-level average salaries exceed the average salary 
for that job title IN market for entry level, helping your agency guide candidates towards lucrative opportunities.
*/
with cte as 
(
select job_title, Avg(salary_in_usd) as avg_salary
from salaries
where experience_level = 'EN'
group by 1
)

select t1.company_location, t1.experience_level, t1.salary_in_usd, t2.avg_salary
from salaries as t1
inner join cte as t2
on t1.job_title = t2.job_title
where t1.experience_level = 'EN';


/*
5. You've been hired by a big HR Consultancy to look at how much people get paid IN different Countries. Your job is to Find out for each job title which country pays the maximum average salary. 
This helps you to place your candidates IN those countries.
*/
select * from
(
select 
	job_title,  
    company_location,
    avg(salary_in_usd) as avg_salary,
    rank() over(partition by job_title order by avg(salary_in_usd) desc) as rnk
from salaries
group by 1,2
order by 1,2,3
) as t
where rnk=1;


/*AS a data-driven Business consultant, you've been hired by a multinational corporation to analyze salary trends across different company Locations. 
Your goal is to Pinpoint Locations WHERE the average salary Has consistently Increased over the Past few years (Countries WHERE data is available for 3 years 
Only(present year and past two years) providing Insights into Locations experiencing Sustained salary growth.
*/
with cte as
(
	select 
    t1.company_location, 
    t1.work_year as '2024', 
    t1.avg_salary as '2024_avg', 
    t2.work_year as '2023', 
    t2.avg_salary as '2023_avg', 
	t3.work_year as '2022', 
    t3.avg_salary as '2022_avg' 
    from 
		(select 
			company_location, 
			work_year, 
			avg(salary_in_usd) as avg_salary
			from salaries
		where work_year = 2024
		group by 1,2
		order by 1,2 desc,3) as t1
		join 
		(
		select 
			company_location, 
			work_year, 
			avg(salary_in_usd) as avg_salary
			from salaries
		where work_year = 2023
		group by 1,2
		order by 1,2 desc,3
		) as t2
		on t1.company_location = t2.company_location
		join
		(
		select 
			company_location, 
			work_year, 
			avg(salary_in_usd) as avg_salary
			from salaries
		where work_year = 2022
		group by 1,2
		order by 1,2 desc,3
		) as t3
		on t2.company_location = t3.company_location
)

select * from cte
where 2024_avg > 2023_avg and 2023_avg > 2022_avg;


/*
7. Picture yourself AS a workforce strategist employed by a global HR tech startup. Your Mission is to Determine the percentage of fully remote work for each experience level IN 2021 and compare 
it WITH the corresponding figures for 2024, Highlighting any significant Increases or decreases IN remote work Adoption over the years.
*/

select t1.experience_level, (remote_2021/total_2021)*100 as '2021_percentage', (remote_2024/total_2024)*100 as '2024_percentage' from 
(
select experience_level, count(*) as 'remote_2021'
from salaries 
where remote_ratio = 100 and work_year=2021
group by 1
order by 1
) as t1
join
(
select experience_level, count(*) as 'total_2021'
from salaries 
where work_year=2021
group by 1
order by 1
) as t2
on t1.experience_level = t2.experience_level
join
(
select experience_level, count(*) as 'remote_2024'
from salaries 
where remote_ratio = 100 and work_year=2024
group by 1
order by 1
) as t3
on t1.experience_level  = t3.experience_level
join
(
select experience_level, count(*) as 'total_2024'
from salaries 
where work_year=2024
group by 1
order by 1
) as t4
on t1.experience_level = t4.experience_level;




/*
8. AS a Compensation specialist at a Fortune 500 company, you're tasked WITH analyzing salary trends over time. Your objective is to calculate the average salary increase percentage for each 
experience level and job title between the years 2023 and 2024, helping the company stay competitive IN the talent market.
*/
select t1.experience_level, t1.job_title, concat(round((avg_salary_2023/avg_salary_2024)*100,0),'%') as percentage_change from
(
select experience_level, job_title, work_year, avg(salary_in_usd) as avg_salary_2024
from salaries
where work_year = 2024
group by 1,2,3
order by 1,2,3
) as t1
join
(
select experience_level, job_title, work_year, avg(salary_in_usd) as avg_salary_2023
from salaries
where work_year = 2023
group by 1,2,3
order by 1,2,3
) as t2
on t1.experience_level = t2.experience_level and t1.job_title = t2.job_title;

/*
9. As a market researcher, your job is to Investigate the job market for a company that analyzes workforce data. Your Task is to know how many people were employed IN different types of 
companies AS per their size IN 2021.
*/

select company_size, count(*) people_employed
from salaries
where work_year = 2021
group by 1;

/*
10.You have been hired by a market research agency where you have been assigned the task to show the percentage of different employment type (full time, part time) in Different job roles, in the 
format where each row will be job title, each column will be type of employment type and cell value for that row and column will show the % value.
*/
 
SELECT
    job_title,
    ROUND(SUM(CASE WHEN employment_type = 'FT' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS full_time_pct,
    ROUND(SUM(CASE WHEN employment_type = 'PT' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS part_time_pct,
    ROUND(SUM(CASE WHEN employment_type = 'CT' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS contract_pct,
    ROUND(SUM(CASE WHEN employment_type = 'FL' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS freelance_pct
FROM
    salaries
GROUP BY
    job_title
ORDER BY
    job_title;


/*
11. You are a researcher and you have been assigned the task to Find the year with the highest average salary for each job title.
*/
select job_title, work_year, avg_salary from
(
select 
	job_title, 
    work_year,
	avg(salary_in_usd) as avg_salary,
    rank() over(partition by job_title order by avg(salary_in_usd)) as rnk
from salaries
group by 1,2
order by 1,2
) as t
where rnk=1;

































































