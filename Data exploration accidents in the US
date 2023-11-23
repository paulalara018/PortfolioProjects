--- Standardize year ---
ALTER TABLE accidents_us
ADD year INT
UPDATE accidents_us SET year = YEAR(Start_Time)

---County vs accidents per year
SELECT county, year, count(*) as num_accidents FROM accidents_us group by County, year order by year desc, num_accidents desc

-- Cities vs accidents per year --
SELECT city, year, count(*) as num_accidents FROM accidents_us group by city, year order by year desc, num_accidents desc

-- Street vs accidents per year --
SELECT street, year, count(*) as num_accidents FROM accidents_us group by street, year order by year desc, num_accidents desc

-- Accidents per month and year --
SELECT year, month(Start_Time) as month, count(*) as num_accidents FROM accidents_us group by year, month(Start_Time) order by year desc, month desc

--- Standardize weather-condition for visualizations ---
ALTER TABLE accidents_us
ADD weatherSplitCondition NVARCHAR(255)

-- SELECT SUBSTRING(Weather_Condition,1,CHARINDEX('/',Weather_Condition)-1) as weather from accidents_us where Weather_Condition like '%/%'
UPDATE accidents_us SET weatherSplitCondition = SUBSTRING(Weather_Condition,1,CHARINDEX('/',Weather_Condition)-1) 
		where Weather_Condition like '%/%'
UPDATE accidents_us SET weatherSplitCondition = TRIM(weatherSplitCondition) 
UPDATE accidents_us SET weatherSplitCondition = Weather_Condition where weatherSplitCondition is null
UPDATE accidents_us SET weatherSplitCondition = 'Rain' where weatherSplitCondition = 'N'
UPDATE accidents_us SET weatherSplitCondition = 'Rain Shower' where weatherSplitCondition='Rain Showers'

---- Add Another Field ------
ALTER TABLE accidents_us ADD weatherSplitMoreCondition NVARCHAR(255)

---- Standarize fields weather for visualization -----
UPDATE accidents_us SET weatherSplitMoreCondition = 'Cloudy' where Weather_Condition like '%Scattered Clouds%'

---- Update field to 'Other' instead of NULL ----
UPDATE accidents_us SET weatherSplitMoreCondition='Other' where weatherSplitMoreCondition is null

--- Create table for visualization in Power BI----
CREATE TABLE weather_group (tmp_weatherSplit VARCHAR(255), tmp_weatherGroup varchar(255));
INSERT INTO weather_group
SELECT DISTINCT weatherSplitCondition, weatherSplitMoreCondition from accidents_us

--- Create table weather vs accidents per year ---
CREATE TABLE weather_accidents (weather VARCHAR(255), year INT, num_accidents INT)
INSERT INTO weather_accidents
SELECT weatherSplitCondition, year, COUNT(*) as number from accidents_us group by weatherSplitCondition, year order by year desc, number desc

--- Join tables weather power BI ---
SELECT B.tmp_weatherGroup as weatherGroup, A.weather, A.year, A.num_accidents 
from weather_accidents as A inner join weather_group as B ON B.tmp_weatherSplit = A.weather
order by year desc, num_accidents desc

-- Create view weather---
CREATE VIEW weather AS
SELECT B.tmp_weatherGroup as weatherGroup, A.weather, A.year, A.num_accidents 
from weather_accidents as A inner join weather_group as B ON B.tmp_weatherSplit = A.weather

-- view cities vs accidents per year---
CREATE VIEW cities_accidents AS
SELECT city, year, count(*) as num_accidents FROM accidents_us group by city, year

-- Street vs accidents per year --
CREATE VIEW street_accidents AS
SELECT street, year, count(*) as num_accidents FROM accidents_us group by street, year

-- Accidents per month and year --
CREATE VIEW month_accidents AS
SELECT month(Start_Time) as month, year, count(*) as num_accidents FROM accidents_us group by year, month(Start_Time) 

CREATE VIEW month_name_accidents AS
Select MONTH, DateName(MONTH, DateAdd( month , month , -1 )) as month_name, YEAR, num_accidents from month_accidents
