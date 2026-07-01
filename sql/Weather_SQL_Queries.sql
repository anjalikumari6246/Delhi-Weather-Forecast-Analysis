CREATE TABLE weather (
    date DATE,
    meantemp DECIMAL(5,2),
    humidity DECIMAL(5,2),
    wind_speed DECIMAL(6,2),
    meanpressure DECIMAL(8,2),
    year INT,
    month INT,
    day INT,
    meantemp_lag1 DECIMAL(5,2),
    meantemp_roll_mean DECIMAL(5,2)
);
SELECT * FROM weather LIMIT 10;
SELECT COUNT(*) AS total_records FROM weather;

ALTER TABLE weather
ADD COLUMN month_name VARCHAR(15);

UPDATE weather
SET month_name = TRIM(TO_CHAR(date, 'Month'));

--Queries
-- 1. Which month has the highest average temperature?
SELECT month_name, ROUND(AVG(meantemp),2) AS avg_month_temperature FROM weather
GROUP BY month_name
ORDER BY avg_month_temperature DESC

--2. Which month has the highest average humidity?
SELECT month_name, ROUND(AVG(humidity),2) AS avg_month_humidity FROM weather
GROUP BY month_name
ORDER BY avg_month_humidity DESC

--3. Which year recorded the highest average temperature?
SELECT year, ROUND(AVG(meantemp),2) AS avg_year_temperature FROM weather
GROUP BY year
ORDER BY avg_year_temperature DESC

--4. Top 10 hottest days
SELECT date, meantemp FROM weather
ORDER BY meantemp DESC LIMIT 10

--5. Top 10 coldest days
SELECT date, meantemp FROM weather
ORDER BY meantemp ASC LIMIT 10

--6. Average wind speed by month
SELECT month_name, ROUND(AVG(wind_speed),2) AS avg_month_wind_speed FROM weather
GROUP BY month, month_name
ORDER BY month

--7. Average atmospheric pressure by month
SELECT month_name, ROUND(AVG(meanpressure),2) AS avg_month_meanpressure FROM weather
GROUP BY month, month_name
ORDER BY month

--cheking the range of humidity
SELECT
    MIN(humidity) AS min_humidity,
    MAX(humidity) AS max_humidity,
    ROUND(AVG(humidity),2) AS avg_humidity
FROM weather;
--8. Relationship between humidity and temperature
--(We'll categorize humidity into Low, Medium, High using CASE.)
SELECT 
   CASE
      WHEN humidity < 40 then 'Low Humidity'
	  WHEN humidity BETWEEN 40 AND 70 then 'Midium Humidity'
	  ELSE 'High Humidity'
   END AS humidity_level,
   ROUND(AVG(meantemp),2) AS avg_temperature
FROM weather
GROUP BY humidity_level
ORDER BY avg_temperature DESC;

--9.n each year, how many days were warmer than that year's average?
-- (CTE)
WITH yearly_avg AS(
SELECT year, ROUND(AVG(meantemp),2) AS avg_temp FROM weather
GROUP BY year
)

SELECT w.year, COUNT(*) AS days_above_yearly_avg 
FROM weather w JOIN yearly_avg y
ON w.year = y.year
WHERE w.meantemp > y.avg_temp
GROUP BY w.year
ORDER BY w.year;

--10. Rank the hottest months in each year
--(Window Functions)
WITH monthly_avg AS (
    SELECT
        year,
        month_name,
        ROUND(AVG(meantemp),2) AS avg_temp,
        RANK() OVER(
            PARTITION BY year
            ORDER BY AVG(meantemp) DESC
        ) AS temp_rank
    FROM weather
    GROUP BY year, month, month_name
)

SELECT *
FROM monthly_avg
WHERE temp_rank = 1;
