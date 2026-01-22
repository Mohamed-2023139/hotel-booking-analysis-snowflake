--KPI
SELECT 
    SUM(num_guests) AS total_guests
FROM FACT_BOOKINGS;
--KPI
SELECT 
    ROUND(AVG(
        CASE 
            WHEN currency = 'USD' THEN total_amount
            WHEN currency = 'EUR' THEN total_amount * 1.08
            WHEN currency = 'INR' THEN total_amount * 0.012
            ELSE total_amount
        END
    ), 2) AS "Avg Booking Value (USD)"
FROM FACT_BOOKINGS
WHERE booking_status = 'Confirmed';
--KPI
SELECT 
    SUM(total_amount) AS total_revenue
FROM FACT_BOOKINGS;
--KPI
SELECT 
    ROUND(
        COUNT(CASE WHEN booking_status = 'Cancelled' THEN 1 END) * 100.0 / 
        COUNT(*), 
        2
    ) AS "Cancellation Rate %"
FROM FACT_BOOKINGS;
/*===============================================================================
Revenue by City
Chart Type: Bar Chart (Horizontal)
X-Axis: Revenue
Y-Axis: City Name
===============================================================================*/
SELECT 
    h.hotel_city AS "City",
    ROUND(SUM(
        CASE 
            WHEN f.currency = 'USD' THEN f.total_amount
            WHEN f.currency = 'EUR' THEN f.total_amount * 1.08
            WHEN f.currency = 'INR' THEN f.total_amount * 0.012
            ELSE f.total_amount
        END
    ), 2) AS "Revenue (USD)",
    COUNT(DISTINCT f.booking_id) AS "Bookings"
FROM FACT_BOOKINGS f
JOIN DIM_HOTEL h ON f.hotel_sk = h.hotel_sk
WHERE f.booking_status = 'Confirmed'
GROUP BY h.hotel_city
ORDER BY "Revenue (USD)" DESC
LIMIT 10;
/*===============================================================================
Monthly Cancellation Rate Trend
Chart Type: Line Chart
X-Axis: Month
Y-Axis: Cancellation Rate %
Best for: Monitoring cancellation patterns
Target Line: 15% (industry benchmark)
===============================================================================*/
SELECT 
    TO_CHAR(check_in_date, 'YYYY-MM') AS "Month",
    ROUND(
        COUNT(CASE WHEN booking_status IN ('Cancelled', 'No-Show') THEN 1 END) * 100.0 / 
        NULLIF(COUNT(*), 0),
        2
    ) AS "Cancellation Rate %",
    COUNT(*) AS "Total Bookings"
FROM FACT_BOOKINGS
WHERE check_in_date >= DATEADD(month, -12, CURRENT_DATE())
GROUP BY TO_CHAR(check_in_date, 'YYYY-MM')
ORDER BY "Month";
/*===============================================================================
Heatgrid:Booking Density by Day of Week and Month
===============================================================================*/
SELECT
    DAYOFWEEK(check_in_date) AS day_num,
    DAYNAME(check_in_date) AS day_of_week,
    MONTHNAME(check_in_date) AS month_name,
    COUNT(*) AS total_bookings
FROM FACT_BOOKINGS
GROUP BY day_num, day_of_week, month_name
ORDER BY day_num;
/*===============================================================================
Booking Status Distribution
Chart Type: Column Chart (Vertical Bar)
X-Axis: Status
Y-Axis: Number of Bookings
Include data labels showing count and percentage
===============================================================================*/
SELECT 
    booking_status AS "Status",
    COUNT(*) AS "Bookings",
    CONCAT(COUNT(*), ' (', ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1), '%)') AS "Count & %"
FROM FACT_BOOKINGS
GROUP BY booking_status
ORDER BY "Bookings" DESC;
