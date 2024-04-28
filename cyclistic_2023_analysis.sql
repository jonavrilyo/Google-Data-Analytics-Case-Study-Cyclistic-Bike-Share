CREATE TABLE cyclistic_2023 (
	ride_id varchar(20) NOT NULL,
	bike_type varchar(15),
	start_time timestamp(2),
	end_time timestamp(2),
	starting_station text,
	ending_station text,
	user_type text,
	ride_length numeric,
	day_of_week text,
	month text
);

-- Returning all columns:
SELECT * 
FROM cyclistic_2023
LIMIT 100;

-- Returning all columns and order rows by start time:
SELECT * 
FROM cyclistic_2023
ORDER BY start_time
LIMIT 100;

-- Confirming row count:
SELECT COUNT(*) 
FROM cyclistic_2023;

-- Number of users by user type:
SELECT 
	COUNT(CASE WHEN user_type = 'member' THEN 1 END) AS number_of_members,
	COUNT(CASE WHEN user_type = 'casual' THEN 1 END) AS number_of_casuals
FROM cyclistic_2023;

-- Calculating percentage of users by type:
SELECT 
	user_type,
	COUNT(*) AS users,
	ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM cyclistic_2023), 1)
FROM cyclistic_2023
WHERE user_type IN ('casual', 'member')
GROUP BY user_type;

-- Number of bikes used in 2023 by bike type:
SELECT 
	bike_type,
	COUNT(*) AS bikes_used
FROM cyclistic_2023
WHERE bike_type IN ('classic_bike', 'electric_bike')
GROUP BY 1;

-- Bikes used by user type:
SELECT 
	user_type,
	bike_type,
	COUNT(*) AS bikes_used
FROM cyclistic_2023
WHERE bike_type IN ('classic_bike', 'electric_bike')
GROUP BY 1, 2;

-- The distribution of bikes among members by count and percentage:
WITH members_cte AS ( 
	SELECT *
	FROM cyclistic_2023
	WHERE user_type = 'member'
)

SELECT
	user_type,
	bike_type,
	COUNT(*) AS bikes_used,
	ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM members_cte), 1) AS percentage
FROM members_cte
WHERE bike_type IN ('classic_bike', 'electric_bike')
GROUP BY 1, 2;

-- The distribution of bikes among casual riders by count and percentage:
WITH casuals_cte AS ( 
	SELECT *
	FROM cyclistic_2023
	WHERE user_type = 'casual'
)

SELECT
	user_type,
	bike_type,
	COUNT(*) AS bikes_used,
	ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM casuals_cte), 1) AS percentage
FROM casuals_cte
WHERE bike_type IN ('classic_bike', 'electric_bike')
GROUP BY 1, 2;

-- The total number of rides by day in 2023:
SELECT 
	day_of_week,
	COUNT(*) AS total_rides
FROM cyclistic_2023
GROUP BY day_of_week
ORDER BY
     CASE
          WHEN day_of_week = 'Sunday' THEN 1
          WHEN day_of_week = 'Monday' THEN 2
          WHEN day_of_week = 'Tuesday' THEN 3
          WHEN day_of_week = 'Wednesday' THEN 4
          WHEN day_of_week = 'Thursday' THEN 5
          WHEN day_of_week = 'Friday' THEN 6
          WHEN day_of_week = 'Saturday' THEN 7
     END ASC;

-- What was the most active day for members? What was the most active day for casual riders?:
SELECT 
	user_type,
	day_of_week,
	COUNT(*) AS total_rides
FROM cyclistic_2023
GROUP BY 1, 2
ORDER BY
     CASE
          WHEN day_of_week = 'Sunday' THEN 1
          WHEN day_of_week = 'Monday' THEN 2
          WHEN day_of_week = 'Tuesday' THEN 3
          WHEN day_of_week = 'Wednesday' THEN 4
          WHEN day_of_week = 'Thursday' THEN 5
          WHEN day_of_week = 'Friday' THEN 6
          WHEN day_of_week = 'Saturday' THEN 7
     END ASC;	 
--- Restructuring the previous query using a CTE and window function:
WITH ranked_days AS (
SELECT
	user_type,
	day_of_week,
	COUNT(*) AS total_rides,
	RANK() OVER(PARTITION BY user_type ORDER BY COUNT(*) DESC) AS rank
FROM cyclistic_2023
GROUP BY 1, 2
)

SELECT
	user_type,
	day_of_week,
	total_rides
FROM ranked_days
WHERE rank = 1;

-- How many rides were recorded each month?:
SELECT
	month,
	COUNT(*) AS total_rides
FROM cyclistic_2023
GROUP BY 1
ORDER BY 
	CASE
		WHEN month = 'Jan' THEN 1
		WHEN month = 'Feb' THEN 2
		WHEN month = 'Mar' THEN 3
		WHEN month = 'Apr' THEN 4
		WHEN month = 'May' THEN 5
		WHEN month = 'Jun' THEN 6
		WHEN month = 'Jul' THEN 7
		WHEN month = 'Aug' THEN 8
		WHEN month = 'Sep' THEN 9
		WHEN month = 'Oct' THEN 10
		WHEN month = 'Nov' THEN 11
		WHEN month = 'Dec' THEN 12
	END ASC; -- The month of August had the most rides, totaling 752,073.

-- In which month did members have the highest number of rides? In which month did casual riders have the highest number of rides?:
WITH ranked_months AS (
    SELECT
        user_type,
        month,
        COUNT(*) AS total_rides,
        RANK() OVER (PARTITION BY user_type ORDER BY COUNT(*) DESC) AS rank
    FROM cyclistic_2023
    GROUP BY 1, 2
)

SELECT
    user_type,
    month,
    total_rides
FROM ranked_months
WHERE rank = 1; -- The most active month for casual riders was July, while August was the most active month for members.

-- Calculate the total ride length (duration) by user type:
SELECT
	user_type,
	ROUND(SUM(ride_length), 2) AS "total_duration(minutes)"
FROM cyclistic_2023
GROUP BY 1;

-- Calculate the average ride length for all users:
SELECT
	ROUND(AVG(ride_length), 2) AS "avg_ride_length(minutes)"
FROM cyclistic_2023;
--- Calcuate the average ride length by user type:
SELECT
	user_type,
	ROUND(AVG(ride_length), 2) AS "avg_ride_length(minutes)"
FROM cyclistic_2023
GROUP BY 1;

-- Calculate the average ride length by month:
SELECT
	month,
	ROUND(AVG(ride_length), 2) AS "avg_ride_length(minutes)"
FROM cyclistic_2023
GROUP BY 1
ORDER BY
	CASE
		WHEN month = 'Jan' THEN 1
		WHEN month = 'Feb' THEN 2
		WHEN month = 'Mar' THEN 3
		WHEN month = 'Apr' THEN 4
		WHEN month = 'May' THEN 5
		WHEN month = 'Jun' THEN 6
		WHEN month = 'Jul' THEN 7
		WHEN month = 'Aug' THEN 8
		WHEN month = 'Sep' THEN 9
		WHEN month = 'Oct' THEN 10
		WHEN month = 'Nov' THEN 11
		WHEN month = 'Dec' THEN 12
	END ASC;

-- Calculate the average ride length by month and user type:
SELECT
	month,
	user_type,
	ROUND(AVG(ride_length), 2) AS "avg_ride_length(minutes)"
FROM cyclistic_2023
GROUP BY 1, 2
ORDER BY
	CASE
		WHEN month = 'Jan' THEN 1
		WHEN month = 'Feb' THEN 2
		WHEN month = 'Mar' THEN 3
		WHEN month = 'Apr' THEN 4
		WHEN month = 'May' THEN 5
		WHEN month = 'Jun' THEN 6
		WHEN month = 'Jul' THEN 7
		WHEN month = 'Aug' THEN 8
		WHEN month = 'Sep' THEN 9
		WHEN month = 'Oct' THEN 10
		WHEN month = 'Nov' THEN 11
		WHEN month = 'Dec' THEN 12
	END ASC;

-- Calculate the average ride length by bike type and user type:
SELECT
	user_type,
	bike_type,
	ROUND(AVG(ride_length), 2) AS "avg_ride_length(minutes)"
FROM cyclistic_2023
GROUP BY 1, 2;

-- What were the top 10 starting stations?:
SELECT
	starting_station,
	COUNT(*) AS number_of_starts
FROM cyclistic_2023
WHERE starting_station != 'NA'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- What were the top 10 ending stations?:
SELECT
	ending_station,
	COUNT(*) AS number_of_stops
FROM cyclistic_2023
WHERE ending_station != 'NA'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- What were the top 10 starting stations for casual riders?
SELECT
	starting_station,
	COUNT(*) AS number_of_starts
FROM cyclistic_2023
WHERE starting_station != 'NA'
	AND user_type = 'casual'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- What were the top 10 starting stations for members?
SELECT
	starting_station,
	COUNT(*) AS number_of_starts
FROM cyclistic_2023
WHERE starting_station != 'NA'
	AND user_type = 'member'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- What were the top 10 ending stations for casual riders?:
SELECT
	ending_station,
	COUNT(*) AS number_of_stops
FROM cyclistic_2023
WHERE ending_station != 'NA'
	AND user_type = 'casual'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- What were the top 10 ending stations for members?:
SELECT
	ending_station,
	COUNT(*) AS number_of_stops
FROM cyclistic_2023
WHERE ending_station != 'NA'
	AND user_type = 'member'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;