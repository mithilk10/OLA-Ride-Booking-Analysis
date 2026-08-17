# OLA Ride Booking Analysis — SQL Queries

```sql
-- =========================================================
-- DATABASE SETUP
-- =========================================================

CREATE DATABASE ola_db;

USE ola_db;

-- Check the bookings table
SELECT *
FROM bookings;


-- =========================================================
-- #1. Retrieve all successful bookings
-- =========================================================

CREATE VIEW successful_bookings AS
SELECT *
FROM bookings
WHERE Booking_Status = 'Success';

SELECT *
FROM successful_bookings;


-- =========================================================
-- #2. Find the average ride distance for each vehicle type
-- =========================================================

CREATE VIEW avg_ride_distance_for_all_vehicle AS
SELECT
    Vehicle_Type,
    AVG(Ride_Distance_km) AS avg_ride_distance
FROM bookings
GROUP BY Vehicle_Type;

SELECT *
FROM avg_ride_distance_for_all_vehicle;


-- =========================================================
-- #3. Get the total number of rides cancelled by customers
-- =========================================================

CREATE VIEW cancelled_rides_by_customers AS
SELECT
    COUNT(*) AS cancelled_rides_count
FROM bookings
WHERE Booking_Status = 'Canceled by Customer';

SELECT *
FROM cancelled_rides_by_customers;


-- =========================================================
-- #4. List the top 5 customers who booked the highest
--     number of rides
-- =========================================================

CREATE VIEW top_5_customers AS
SELECT TOP 5
    Customer_ID,
    COUNT(Booking_ID) AS total_rides
FROM bookings
GROUP BY Customer_ID
ORDER BY total_rides DESC;

SELECT *
FROM top_5_customers;


-- =========================================================
-- #5. Get the number of rides cancelled by drivers due to
--     personal reasons or car-related issues
-- =========================================================

CREATE VIEW cancelled_by_drivers_p_c_issues AS
SELECT
    COUNT(*) AS total_cancelled_rides
FROM bookings
WHERE Reason_for_cancelling_by_Driver =
      'Personal & Car related issues';

SELECT *
FROM cancelled_by_drivers_p_c_issues;


-- =========================================================
-- #6. Find the maximum and minimum driver rating for
--     Prime Sedan bookings
-- =========================================================

CREATE VIEW max_and_min_driver_rating_for_prime_sedan AS
SELECT
    MAX(Driver_Ratings) AS max_rating,
    MIN(Driver_Ratings) AS min_rating
FROM bookings
WHERE Vehicle_Type = 'Prime Sedan';

SELECT *
FROM max_and_min_driver_rating_for_prime_sedan;


-- =========================================================
-- #7. Find the average customer rating for each vehicle type
-- =========================================================

CREATE VIEW avg_customer_rating AS
SELECT
    Vehicle_Type,
    AVG(Customer_Rating) AS avg_customer_rating
FROM bookings
GROUP BY Vehicle_Type;

SELECT *
FROM avg_customer_rating;


-- =========================================================
-- #8. Calculate the total booking value of successfully
--     completed rides
-- =========================================================

CREATE VIEW total_successful_booking_value AS
SELECT
    SUM(Booking_Value) AS total_successful_value
FROM bookings
WHERE Booking_Status = 'Success';

SELECT *
FROM total_successful_booking_value;


-- =========================================================
-- #9. List all incomplete rides along with the reason
-- =========================================================

CREATE VIEW incomplete_rides_with_reason AS
SELECT
    Booking_ID,
    Incomplete_Rides_Reason
FROM bookings
WHERE Incomplete_Rides = 1;

SELECT *
FROM incomplete_rides_with_reason;


-- =========================================================
-- #10. Booking status distribution
--      Total bookings and percentage of total bookings
-- =========================================================

SELECT
    Booking_Status,
    COUNT(*) AS total_bookings,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM bookings),
        2
    ) AS percentage
FROM bookings
GROUP BY Booking_Status
ORDER BY total_bookings DESC;


-- =========================================================
-- #11. Total rides and booking value by booking status
-- =========================================================

SELECT
    Booking_Status,
    COUNT(*) AS total_rides,
    SUM(Booking_Value) AS total_booking_value
FROM bookings
GROUP BY Booking_Status
ORDER BY total_booking_value DESC;


-- =========================================================
-- #12. Customer cancellation analysis
--      Cancellations, revenue at risk and average booking value
-- =========================================================

SELECT
    Reason_for_cancelling_by_Customer,
    COUNT(*) AS cancellations,
    SUM(Booking_Value) AS revenue_at_risk,
    AVG(Booking_Value) AS avg_booking_value
FROM bookings
WHERE LOWER(Booking_Status) LIKE '%cancel%customer%'
GROUP BY Reason_for_cancelling_by_Customer
ORDER BY revenue_at_risk DESC;


-- =========================================================
-- #13. Driver cancellation analysis
--     Cancellations, revenue at risk and average booking value
-- =========================================================

SELECT
    Reason_for_cancelling_by_Driver,
    COUNT(*) AS cancellations,
    SUM(Booking_Value) AS revenue_at_risk,
    AVG(Booking_Value) AS avg_booking_value
FROM bookings
WHERE LOWER(Booking_Status) LIKE '%cancel%driver%'
GROUP BY Reason_for_cancelling_by_Driver
ORDER BY cancellations DESC;


-- =========================================================
-- #14. Analyze pickup locations with at least 100 bookings
--      and calculate their failure rate
-- =========================================================

SELECT
    Pickup_Location,
    COUNT(*) AS total_bookings,

    SUM(
        CASE
            WHEN Booking_Status <> 'Success'
            THEN 1
            ELSE 0
        END
    ) AS failed_bookings,

    ROUND(
        SUM(
            CASE
                WHEN Booking_Status <> 'Success'
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS failure_rate

FROM bookings

GROUP BY Pickup_Location

HAVING COUNT(*) >= 100

ORDER BY failure_rate DESC;



-- #15. Revenue Contribution by Vehicle Type

SELECT
    Vehicle_Type,
    SUM(Booking_Value) AS Total_Revenue,
    ROUND(
        SUM(Booking_Value) * 100.0 /
        SUM(SUM(Booking_Value)) OVER (),
        2
    ) AS Revenue_Percentage
FROM bookings
WHERE Booking_Status = 'Success'
GROUP BY Vehicle_Type
ORDER BY Total_Revenue DESC;


-- #16. Top 10 Customers by Revenue

SELECT TOP 10
    Customer_ID,
    COUNT(Booking_ID) AS Total_Rides,
    SUM(Booking_Value) AS Total_Revenue
FROM bookings
WHERE Booking_Status = 'Success'
GROUP BY Customer_ID
ORDER BY Total_Revenue DESC;

-- #17. Vehicle Cancellation Rate

SELECT
    Vehicle_Type,
    COUNT(*) AS Total_Bookings,

    SUM(CASE
        WHEN Booking_Status <> 'Success'
        THEN 1
        ELSE 0
    END) AS Cancelled_or_Incomplete,

    ROUND(
        SUM(CASE
            WHEN Booking_Status <> 'Success'
            THEN 1
            ELSE 0
        END) * 100.0 / COUNT(*),
        2
    ) AS Failure_Rate

FROM bookings
GROUP BY Vehicle_Type
ORDER BY Failure_Rate DESC;

