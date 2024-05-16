 -- To avoid any errors, check missing value / null value 


-- Q1. Write a code to check NULL values

SELECT *
  FROM [Corona Virus].[dbo].[Corona Virus Dataset]
  --where Province , Country  , Region  ,Latitude ,Longitude, Deaths, Recovered ,Confirmed ,Date is null
 
 

--Q2. If NULL values are present, update them with zeros for all columns. 


  update [Corona Virus].[dbo].[Corona Virus Dataset]
  set Confirmed  = coalesce(Confirmed,0)


-- Q3. check total number of rows


select count(*) as total_Rows
from [Corona Virus].[dbo].[Corona Virus Dataset]


-- Q4. Check what is start_date and end_date

 --Made three new columns to  combine
alter table [Corona Virus].[dbo].[Corona Virus Dataset]
add day_column int,
    month_column int,
    year_column int;


 --insert in each column from the date column 
update  [Corona Virus].[dbo].[Corona Virus Dataset]
set day_column = CAST(SUBSTRING(Date, 1, 2) AS int),
    month_column = CAST(SUBSTRING(Date,4,2) as int),
	year_column = CAST(SUBSTRING(Date, 7, 4) AS int);


--make the converted Date column  to the right data type to make calculation
ALTER TABLE [Corona Virus].[dbo].[Corona Virus Dataset]
ADD Converted_Date date; 


--updated and combine  the three column 
UPDATE  [Corona Virus].[dbo].[Corona Virus Dataset]
SET Converted_Date= TRY_CONVERT(datetime, CONCAT(year_column, '-', month_column, '-', day_column));


--Start_date

select MIN(Converted_Date) as Start_date
from [Corona Virus].[dbo].[Corona Virus Dataset]


---   End_date

select MAX(Converted_Date) as End_date
from [Corona Virus].[dbo].[Corona Virus Dataset]



alter table [Corona Virus].[dbo].[Corona Virus Dataset]
drop column converted_time,Converted_Datetime;


-- Q5. Number of month present in dataset

SELECT COUNT(DISTINCT MONTH(Converted_Date)) AS num_of_months
FROM  [Corona Virus].[dbo].[Corona Virus Dataset];

-- Q6. Find monthly average for confirmed, deaths, recovered

 -- make new columns to  convert 

alter table  [Corona Virus].[dbo].[Corona Virus Dataset]
 add Converted_Deaths  float,
 converted_Confirmed float,
 Converted_Recovered float;

 -- update them with new data type to make caclulations

UPDATE [Corona Virus].[dbo].[Corona Virus Dataset]
SET Converted_Deaths = TRY_CAST(Deaths AS int),
    converted_Confirmed = TRY_CAST(Confirmed AS int),
    Converted_Recovered = TRY_CAST(Recovered AS int);

	-- Delete any zeros and null values

	DELETE FROM [Corona Virus].[dbo].[Corona Virus Dataset]
WHERE Converted_Deaths IS NULL OR Converted_Deaths = '0'
   OR Converted_Deaths IS NULL OR Converted_Deaths = '0'
   OR Converted_Deaths IS NULL OR Converted_Deaths = '0';

 
  -- The caclulations
SELECT 
    MONTH(Converted_Date) AS month,
    ROUND(AVG(converted_Confirmed), 2) AS avg_confirmed,
    ROUND(AVG(Converted_Deaths), 2) AS avg_deaths,
    ROUND(AVG(Converted_Recovered), 2) AS avg_recovered
FROM 
    [Corona Virus].[dbo].[Corona Virus Dataset]
GROUP BY 
    MONTH(Converted_Date)
ORDER BY 
    MONTH(Converted_Date);


-- Q7. Find most frequent value for confirmed, deaths, recovered each month 


 WITH MonthFreq AS(
 Select MONTH(Converted_Date) as month,
 converted_Confirmed as Confirmed,
 Converted_Deaths as Deaths,
 Converted_Recovered as Recoverd,
 ROW_NUMBER() over ( partition by month(Converted_Date) order by count (*)desc) as rn
 from[Corona Virus].[dbo].[Corona Virus Dataset]
 group by MONTH(Converted_Date),converted_Confirmed , Converted_Deaths,Converted_Recovered
 )
 select month,Confirmed as  most_freq_confirmed
 ,Deaths as  most_freq_Deaths
 ,Recoverd as  most_freq_Recoverd
 from MonthFreq
 where rn = 1;


-- Q8. Find minimum values for confirmed, deaths, recovered per year


select 
YEAR(Converted_Date) as year,
min(converted_Confirmed) as min_Confirmed,
min(Converted_Deaths) as min_Deaths,
min(Converted_Recovered) as min_Recovered
from [Corona Virus].[dbo].[Corona Virus Dataset]
group by  YEAR(Converted_Date);


-- Q9. Find maximum values of confirmed, deaths, recovered per year

select 
YEAR(Converted_Date) as year,
max(converted_Confirmed) as max_Confirmed,
max(Converted_Deaths) as max_Deaths,
max(Converted_Recovered) as max_Recovered
from [Corona Virus].[dbo].[Corona Virus Dataset]
group by  YEAR(Converted_Date);

-- Q10. The total number of case of confirmed, deaths, recovered each month


select 
month(Converted_Date) as month,
sum(converted_Confirmed) as Total_Confirmed,
sum(Converted_Deaths) as Total_Deaths,
sum(Converted_Recovered) as Total_Recovered
from [Corona Virus].[dbo].[Corona Virus Dataset]
group by  month(Converted_Date) 
order by month;


-- Q11. Check how corona virus spread out with respect to confirmed case
--      (Eg.: total confirmed cases, their average, variance & STDEV )
-- Calculate total confirmed cases


SELECT 
    ROUND(SUM(converted_Confirmed),2) AS total_confirmed,
   ROUND( AVG(converted_Confirmed),2) AS avg_confirmed,
    ROUND(VAR(converted_Confirmed),2) AS variance_confirmed,
    ROUND(STDEV(converted_Confirmed),2) AS stdev_confirmed
FROM 
    [Corona Virus].[dbo].[Corona Virus Dataset];


-- Q12. Check how corona virus spread out with respect to death case per month
--      (Eg.: total confirmed cases, their average, variance & STDEV )


SELECT 
    month(Converted_Date) as month,
    ROUND(SUM(Converted_Deaths),2) AS total_Deaths,
    ROUND( AVG(Converted_Deaths),2) AS avg_Deaths,
    ROUND(VAR(Converted_Deaths),2) AS variance_Deaths,
    ROUND(STDEV(Converted_Deaths),2) AS stdev_Deaths
FROM   [Corona Virus].[dbo].[Corona Virus Dataset]
group by  month(Converted_Date)
order by month;


-- Q13. Check how corona virus spread out with respect to recovered case
--      (Eg.: total confirmed cases, their average, variance & STDEV )


SELECT 
    month(Converted_Date) as month,
    ROUND(SUM(Converted_Recovered),2) AS total,
    ROUND( AVG(Converted_Recovered),2) AS avg,
    ROUND(VAR(Converted_Recovered),2) AS variance,
    ROUND(STDEV(Converted_Recovered),2) AS stdev
FROM   [Corona Virus].[dbo].[Corona Virus Dataset]
group by  month(Converted_Date)
order by month;


-- Q14. Find Country having highest number of the Confirmed case


SELECT TOP 5
   [Country Region],
    MAX(converted_Confirmed) AS highest_confirmed_cases
FROM 
    [Corona Virus].[dbo].[Corona Virus Dataset]
GROUP BY 
    [Country Region]
ORDER BY 
    highest_confirmed_cases DESC;


-- Q15. Find Country having lowest number of the death case

SELECT TOP 5
   [Country Region],
    min(Converted_Deaths) AS Lowest_Deaths_cases
FROM 
    [Corona Virus].[dbo].[Corona Virus Dataset]
GROUP BY 
    [Country Region]
ORDER BY 
    Lowest_Deaths_cases DESC;

-- Q16. Find top 5 countries having highest recovered case

SELECT TOP 5
   [Country Region],
    max(Converted_Recovered) AS highest_Recovered_cases
FROM 
    [Corona Virus].[dbo].[Corona Virus Dataset]
GROUP BY 
    [Country Region]
ORDER BY 
    highest_Recovered_cases DESC;