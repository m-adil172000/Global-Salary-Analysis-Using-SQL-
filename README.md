````markdown
# 🌍 Global Salary Analysis SQL Project

Welcome to the **Global Salary Analysis** SQL project, where real-world business problems meet data-driven solutions. In this repository, I have solved 11 business scenarios using SQL, showcasing different personas such as Compensation Analysts, HR Consultants, Data Scientists, and Market Researchers to derive key insights from global salary data.

---

## 📁 Dataset
The queries are based on a hypothetical dataset named `salaries`, which includes:
- `job_title`
- `experience_level`
- `employment_type`
- `salary_in_usd`
- `remote_ratio`
- `company_location`
- `company_size`
- `work_year`

---

## 🔍 Business Scenarios & SQL Solutions

### 1. 🌐 Remote Manager Roles with High Salaries
**Role**: Compensation Analyst  
**Objective**: Identify countries offering **fully remote jobs** for **Managers** with salaries above **$90,000**.

```sql
SELECT DISTINCT company_location 
FROM salaries
WHERE job_title LIKE '%Manager%' 
  AND remote_ratio = 100 
  AND salary_in_usd > 90000;
````

---

### 2. 🧑‍💼 Entry-Level Opportunities in Large Companies

**Role**: Remote Work Advocate
**Objective**: Find **Top 5 countries** with the **most large companies** hiring **entry-level (EN)** employees.

```sql
SELECT company_location, COUNT(*) AS number_of_companies
FROM salaries
WHERE company_size = 'L' AND experience_level = 'EN'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
```

---

### 3. 💸 Remote Jobs with High Salaries

**Role**: Data Scientist
**Objective**: Calculate the **percentage** of fully remote employees earning **more than \$100,000 USD**.

```sql
SET @total = (SELECT COUNT(*) FROM salaries WHERE salary_in_usd > 100000);
SET @remote = (SELECT COUNT(*) FROM salaries WHERE salary_in_usd > 100000 AND remote_ratio = 100);
SELECT ROUND((@remote/@total)*100, 2) AS percent;
```

---

### 4. 🌍 High-Paying Locations for Entry-Level Roles

**Role**: Data Analyst
**Objective**: Identify countries where **entry-level salaries exceed the global average** for that job title.

```sql
WITH cte AS (
  SELECT job_title, AVG(salary_in_usd) AS avg_salary
  FROM salaries
  WHERE experience_level = 'EN'
  GROUP BY 1
)

SELECT t1.company_location, t1.experience_level, t1.salary_in_usd, t2.avg_salary
FROM salaries AS t1
JOIN cte AS t2 ON t1.job_title = t2.job_title
WHERE t1.experience_level = 'EN';
```

---

### 5. 🌏 Countries Paying the Most by Job Title

**Role**: HR Consultant
**Objective**: For each job title, identify the **country with the highest average salary**.

```sql
SELECT * FROM (
  SELECT 
    job_title,  
    company_location,
    AVG(salary_in_usd) AS avg_salary,
    RANK() OVER(PARTITION BY job_title ORDER BY AVG(salary_in_usd) DESC) AS rnk
  FROM salaries
  GROUP BY 1,2
) AS t
WHERE rnk = 1;
```

---

### 6. 📈 Countries with Consistent Salary Growth

**Role**: Business Consultant
**Objective**: Find countries with **increasing average salaries** over 2022, 2023, and 2024.

```sql
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

```

---

### 7. 🔁 Remote Work Trends by Experience Level

**Role**: Workforce Strategist
**Objective**: Compare **fully remote work adoption** between **2021 and 2024** for each experience level.

```sql
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

```

---

### 8. 📊 Salary Growth by Role and Experience

**Role**: Compensation Specialist
**Objective**: Calculate **average salary change %** from 2023 to 2024 per job title & experience level.

```sql
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

```

---

### 9. 🧮 Company Sizes in 2021

**Role**: Market Researcher
**Objective**: Count how many people worked in each company size category in 2021.

```sql
SELECT company_size, COUNT(*) AS people_employed
FROM salaries
WHERE work_year = 2021
GROUP BY 1;
```

---

### 10. 📌 Employment Type Distribution per Job Role

**Role**: Market Research Analyst
**Objective**: Show % distribution of employment types (FT, PT, CT, FL) per job title.

```sql
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

```

---

### 11. 🏆 Year with Highest Salary by Job

**Role**: Researcher
**Objective**: Find the year with the **highest average salary** for each job title.

```sql
SELECT job_title, work_year, avg_salary FROM (
  SELECT 
    job_title, 
    work_year,
    AVG(salary_in_usd) AS avg_salary,
    RANK() OVER(PARTITION BY job_title ORDER BY AVG(salary_in_usd) DESC) AS rnk
  FROM salaries
  GROUP BY 1,2
) AS t
WHERE rnk = 1;
```

---

## 🧠 Learnings & Insights

* Worked with **Common Table Expressions (CTEs)** and **window functions**
* Applied **conditional aggregation** for distribution insights
* Practised real-world SQL business use cases
* Reinforced analytical thinking and storytelling with data

