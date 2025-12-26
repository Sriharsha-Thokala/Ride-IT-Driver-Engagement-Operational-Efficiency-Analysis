Create Database Ride_IT;
Use Ride_IT;

Select * from Drivers;				       -- 36771 --
Select * From Drivers_Activity;			--  18,28,412 --


-- Database Exploration  --
Select * From INFORMATION_SCHEMA.TABLES;


-- Dimensions Exploration --

-- Exploring total number of drivers
Select Distinct Count(*) Driver_Cnt from Drivers;	

-- Exploring the countries the ride service provided
Select Distinct Country_Code From Drivers;

-- Exploring the types of services provided by drivers 
Select Distinct Service_Type  From Drivers;

-- Exploring the Rating_Bin Range given by the customers to drivers 
Select Distinct Rating_Bin From Drivers;


-- Data Transformation --
-- Updating Drivers who have BOTH the services --
Update Drivers 
Set Service_Type = 'BOTH'
From Drivers 
Where Id_Driver IN (Select Id_Driver From Drivers 
Group by ID_Driver 
Having Count(Distinct Service_type) > 1);
-- 402 Rows were affected --

-- Data Cleaning --
-- Removing Duplicate rows --
With Duplicate_CTE as
(Select *, 
ROW_NUMBER() Over(Partition by Id_driver Order by Id_Driver) Rn
From Drivers)
Delete From Duplicate_CTE 
Where rn > 1;
-- 201 Rows were removed -- 

-- Rounding the Driver Rating column values --
Update Drivers 
Set driver_rating = Round(driver_rating, 1)
Where driver_rating IS NOT NULL;

-- Altering table with new column Rating_Bin 
Alter Table Drivers 
ADD Rating_Bin Varchar(20);

-- Updating Rating_Bin Column 
Update Drivers
Set Rating_Bin = 
case when driver_rating IS NULL THEN 'No Rating'
		When driver_rating Between 0.0 and 1.9 Then '0.0-1.9'
		When driver_rating Between 2.0 and 2.9 Then '2.0-2.9'
		When driver_rating Between 3.0 and 3.9 Then '3.0-3.9'
		When driver_rating Between 4.0 and 4.4 Then '4.0-4.4'
		When driver_rating Between 4.5 and 5.0 Then '4.5-5.0'
		else 'Invalid'
		end;


-- Date Exploration -- 

-- Finding the first and last date registration of drivers and registration range in years and months 

Select MIN(Date_Registration) as First_Registration_Date,
		MAX(Date_Registration) as Last_Registration_Date,
		DATEDIFF(YEAR, MIN(Date_Registration), MAX(Date_Registration)) as Date_Registration_Year_Range,
		DATEDIFF(MONTH, MIN(Date_Registration), MAX(Date_Registration)) as Date_Registration_Month_Range
From Drivers;


-- Finding the drivers active date range in years, months and days 
Select MIN(Active_Date)  First_Active_Date,
		MAX(Active_Date) Last_Active_Date,
		DATEDIFF(YEAR, MIN(Active_Date), MAX(Active_Date))  as Active_Date_Year_Range,
		DATEDIFF(MONTH, MIN(Active_Date), MAX(Active_Date))+1 as  Active_Date_Month_Range,
		DATEDIFF(DAY, MIN(Active_Date), MAX(Active_Date)) as Active_Date_Days_Range
From Drivers_Activity;


-- Measures Exploration -- 

-- Finding the Total Drivers
Select Count(ID_Driver) Total_Drivers 
From Drivers;

-- Finding the average driver rating 
Select AVG(Driver_Rating) Avg_Rating
From Drivers;

-- Finding the total offers requests that drivers recieved 
Select SUM(Offers) Total_Offer_Requests 
From Drivers_Activity;

-- Finding the number of bookings requests accepetd by driver
Select SUM(Bookings) Total_Booking_Requests 
From Drivers_Activity;

-- Finding the number of bookings Cancelled by passengers
Select SUM(Bookings_Cancelled_By_Passenger) Total_Cancellations_By_Passengers
From Drivers_Activity;

-- Finding the number of bookings Cancelled by drivers 
Select SUM(Bookings_Cancelled_By_Driver) Total_Cancelled_By_Driver
From Drivers_Activity;

-- Finding the number of rides completed by drivers
Select SUM(Rides) Total_Rides
From Drivers_Activity;


-- GENERATING A REPORT THAT SHOWS ALL KEY METRICS OF THE BUSINESS --

Select 'Total Drivers' as Measure_Name, 
COUNT(ID_Driver) as Measure_Value From Drivers
UNION ALL
Select 'Avg Driver Rating' as Measure_Name, 
AVG(Driver_Rating) as Measure_Value From Drivers
UNION ALL
Select 'Total Offers Requests' as Measure_Name, 
SUM(Offers) as Measure_Value From Drivers_Activity
UNION ALL
Select 'Total Booking Requests' as Measure_Name, 
SUM(Bookings) as Measure_Value From Drivers_Activity
UNION ALL
Select 'Total Cancellations By Passengers' as Measure_Name, 
SUM(bookings_cancelled_by_passenger) as Measure_Value From Drivers_Activity
UNION ALL
Select 'Total Cancellations By Drivers' as Measure_Name, 
SUM(bookings_cancelled_by_driver) as Measure_Value From Drivers_Activity
UNION ALL
Select 'Total Rides' as Measure_Name, 
SUM(rides) as Measure_Value From Drivers_Activity;


-- Magnitude Analysis --

-- Finding total drivers in each country
Select Country_Code, 
		COUNT(ID_Driver) Total_Drivers 
From Drivers
Group By Country_Code;

-- Finding total drivers by each service type
Select Service_Type, 
		COUNT(ID_Driver) Drivers_Cnt
From Drivers
Group By Service_Type;

-- Finding how many drivers accepted to recieve marketing
Select Receive_Marketing, 
		COUNT(ID_Driver) Drivers_Cnt
From Drivers
Group By Receive_Marketing;

-- Finding how many gold level status recieved by each driver
Select Id_Driver, 
		SUM(Gold_Level_Count) Gold_Level_Cnt
From Drivers
Group By Id_Driver
Order By SUM(Gold_Level_Count) Desc;

-- Finding average rating for each driver
Select Id_Driver, 
		AVG(Driver_Rating) Avg_Driver_Rating
From Drivers
Group By Id_Driver
Order By AVG(Driver_Rating) Desc;

-- Finding total offers requests, booking requests and rides completion by each driver
Select Id_Driver, 
		SUM(Offers) Offer_Requests,
		SUM(Bookings) Booking_Requests,
		SUM(Rides) Rides_Completed
From Drivers_Activity
Group By Id_Driver
Order By SUM(Rides) Desc;

-- Finding total offers requests, bookings requests and rides completion by each Country
Select D.Country_Code, 
		SUM(DA.Offers) Offer_Requests,
		SUM(DA.Bookings) Booking_Requests,
		SUM(DA.Rides) Rides_Completed
From Drivers D
Inner Join Drivers_Activity DA
On DA.Id_Driver = D.Id_Driver
Group By D.Country_Code
Order By SUM(DA.Rides) Desc;

-- Finding total cancellations by passenger for each country
Select D.Country_Code, 
		SUM(DA.Bookings_Cancelled_By_Passenger) Cancellations_By_Passengers
From Drivers D
Inner Join Drivers_Activity DA
On DA.ID_Driver = D.ID_Driver
Group By D.Country_Code;

-- Finding total cancellations by driver for each country
Select D.Country_Code, 
		SUM(DA.bookings_cancelled_by_driver) Cancellations_By_Drivers
From Drivers D
Inner Join Drivers_Activity DA
On DA.ID_Driver = D.ID_Driver
Group By D.Country_Code;


-- Ranking Analysis --

-- Finding the top 5 Driver with highest rides completion in each service type
With Rides_CTE as
(Select D.ID_Driver, D.Service_Type,
		SUM(DA.Rides) Rides_Completed
From Drivers_Activity DA
left Join Drivers D
On D.Id_Driver = DA.ID_Driver
Group By D.ID_Driver, D.Service_Type
),
Row_num_CTE as
(Select RC.*, 
		Dense_Rank() Over (Partition By RC.Service_Type Order By RC.Rides_Completed Desc) Drnk
From Rides_CTE RC)
Select * From Row_num_CTE
Where Drnk <= 5;

-- Finding the least 5 Driver with lowest rides completion  
With Rides_CTE as
(Select D.ID_Driver, D.Service_Type,
		SUM(DA.Rides) Rides_Completed
From Drivers_Activity DA
left Join Drivers D
On D.Id_Driver = DA.ID_Driver
Group By D.ID_Driver, D.Service_Type
),
Row_num_CTE as
(Select RC.*, 
		Dense_Rank() Over (Partition By RC.Service_Type Order By RC.Rides_Completed) Drnk
From Rides_CTE RC)
Select * From Row_num_CTE
Where Drnk <= 5;


-- Change Over Time Analysis / Trend Analysis --

-- Analyzing driver performance over time 
Select YEAR(Active_Date)  Year,
		MONTH(Active_Date) Month,
		COUNT(ID_Driver) Active_Drivers,
		SUM(Offers) Bookings_Requests,
		SUM(Bookings) Bookings_Accepted,
		SUM(Rides) Rides_Completed
From Drivers_Activity
Group By YEAR(Active_Date),MONTH(Active_Date)
Order By YEAR(Active_Date),MONTH(Active_Date);

-- Analyzing Cancellations by passengers and drivers over time 
Select YEAR(Active_Date)  Year,
		MONTH(Active_Date) Month,
		SUM(bookings_cancelled_by_passenger) Cancellations_By_Passengers,
		SUM(Bookings_Cancelled_By_Driver) Cancellations_By_Passengers
From Drivers_Activity
Group By YEAR(Active_Date),MONTH(Active_Date)
Order By YEAR(Active_Date),MONTH(Active_Date);

-- Analyzing drivers registration over time 
Select YEAR(date_registration)  Year,
		MONTH(date_registration) Month,
		COUNT(Id_Driver) Drivers_Cnt
From Drivers
Group By YEAR(date_registration),MONTH(date_registration)
Order By YEAR(date_registration),MONTH(date_registration);


-- Cummulative Analysis Offers, Bookings and Rides of Over time --

With Time_Analysis_CTE as
(Select YEAR(Active_Date)  Year,
		MONTH(Active_Date) Month,
		SUM(Offers) Bookings_Requests,
		SUM(Bookings) Bookings_Accepted,
		SUM(Rides) Rides_Completed
From Drivers_Activity
Group By YEAR(Active_Date),MONTH(Active_Date))
Select Year,
		Month,
		Bookings_Requests,
		SUM(Bookings_Requests) Over (Order By Year, Month) Running_Total_Booking_Requests,
		Bookings_Accepted,
		SUM(Bookings_Accepted) Over (Order By Year, Month) Running_Total_Booking_Accepted,
		Rides_Completed,
		SUM(Rides_Completed) Over (Order By Year, Month) Running_Total_Rides_Completed

From Time_Analysis_CTE;

