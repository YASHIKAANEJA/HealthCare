                  -- Analysis of the Data (Part 1) -----------------------------------
use rides;
show tables;
select * from railway limit 10;

-- DATA ANALYSIS ---------------------------------------------------------

-- QUESTION 1 : What is the total number of tickets purchased ? ------------------------
select count(transaction_id) as total_tickets from railway; 

-- find tickets that are booked earlier than 2024
select min(date_of_purchase) as earliest_purchase , 
min(date_of_journey) as earliest_journey from railway;

-- calculate total number of tickets that are purchased in 2024
select count(transaction_id) as total_tickets_in_2024 from railway where year(date_of_purchase)=2024; 

	      -- Question 2 How many tickets are purchased on average each day --------------
select count(transaction_id) / datediff(max(date_of_purchase),min(date_of_purchase)) 
as avg_tickets_per_day_in_2024 from railway where year(date_of_purchase)=2024;

		  -- Question 3 Where do they purchase the ticket and how do they pay for it? --------
          -- WINDOW FUNCTIONS (IMPORTANT) ------
select purchase_type ,count(transaction_id) as total_tickets,
count(transaction_id)/sum(count(transaction_id)) over() as per_tickets
from railway where year(date_of_purchase)=2024 group by 1 order by 2 desc;

select payment_method ,count(transaction_id) as total_tickets,
count(transaction_id)/sum(count(transaction_id)) over() as per_tickets from railway 
where year(date_of_purchase)=2024 group by 1 ORDER BY 2 desc;     

       -- Question 4 How many destination stations and arrival destinations that we have ? --------
select count(distinct departure_station) as departure_stations
,count(distinct arrival_destination) as arrival_destinations from railway;

       -- Question 5 What are the Total Routes piled by the trains ? --------
select count(*) as total_unique_routes FROM (select departure_station , arrival_destination , 
count(transaction_id) AS total_rides from railway group by 1,2) as routes;

-- method 2 using CTE (COMMON TABLE EXPRESSION)
WITH routes as (select departure_station , arrival_destination , 
count(transaction_id) AS total_rides from railway group by 1,2)
select count(*) as total_routes from routes;

-- Question 6 What are the most and least piled routes ? --------
-- top 10 most piled routes
select departure_station , arrival_destination , count(transaction_id) from
railway group by 1,2 order by 3 desc limit 10;

-- top 10 least piled routes
select departure_station , arrival_destination , count(transaction_id) from
railway group by 1,2 order by 3 asc limit 10;

-- Question 7 How many rides were successful and how many cancelled ? ----------------- 
select 
    CASE WHEN journey_status IN ('On Time','Delayed') THEN 'Successful Rides'
    Else 'Cancelled Rides' 
    END AS train_status ,
    count(transaction_id) as total_rides ,
    count(transaction_id)/sum(count(transaction_id)) over() as per_rides
    from railway group by 1;

-- Question 8 What percentage of the successful rides were On-Time and Delayed ? ------------ 
select journey_status,count(transaction_id),
count(transaction_id) / sum(count(transaction_id)) over() as per_rides
from railway 
where journey_status in ('On time','Delayed') group by 1;

-- Question 9 What is the minimum , maximum and average delay time ? ------------ 

-- step 1 Calculate Delay Time in minutes
WITH delay_time as
(select time_to_sec(timediff(actual_arrival_time,arrival_time))/60 as delay_time from railway where
journey_status = 'Delayed')
    select min(delay_time) as min_delay_time , max(delay_time) as max_delay_time ,
    avg(delay_time) from delay_time where delay_time !=0;
    
-- checking why minimum delay time is 0
-- all rows with delay time = 0 (so 18 records are there with delay time =0 , so its error in data)
-- WITH delay_time as
-- (select * , time_to_sec(timediff(actual_arrival_time,arrival_time))/60 as delay_time 
-- from railway where journey_status = 'Delayed')
--     select * from delay_time where delay_time =0;

-- Question 10 What are the reasons for delay and cancelled rides ? ------------

-- Delayed rides
select reason_for_delay,count(transaction_id),
count(transaction_id) / sum(count(transaction_id)) over() as per_delay_rides
from railway where journey_status ='Delayed' 
group by 1 order by 2 desc;

-- Cancelled rides
select reason_for_delay,count(transaction_id) as total_rides,
count(transaction_id) / sum(count(transaction_id)) over() as per_delay_rides
from railway where journey_status ='Cancelled' 
group by 1 order by 2 desc;

