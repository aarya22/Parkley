--1.	Find all the available driveways in Seattle that are under 10$/hour
SELECT * 
FROM Driveway 
WHERE priceRate < 10
AND city = 'Seattle';

--2.	Find all available driveways that operate from 12pm to 4pm.
SELECT *
FROM Driveway
WHERE timein <= '12:00:00' AND timeout >= '16:00:00'
AND availible = 1;

--3.	Calculate the profit to date for the user “Aman”, “Arya”.
SELECT SUM(totalCost) AS Profit 
FROM Booking b, Renter r, Users u
WHERE b.rid = r.rid AND r.uid = u.id AND u.fname = 'Aman' AND u.lname = 'Arya';

--4.	Find the driveway for “Leandro Solidum” which makes him the most money.
SELECT * FROM Driveway D WHERE d.did = (
	SELECT TOP 1 B.did FROM Booking B 
	WHERE B.rid = (
		SELECT r.rid 
		FROM Renter r, Users u 
		WHERE r.uid = u.id AND u.fname = 'Leandro' AND u.lname = 'Solidum'
	) 
	ORDER BY B.totalcost DESC
);

--5.	Apply a 10% discount on “Aman” “Arya” last booking.
SELECT TOP 1 totalcost*.9 AS 'TotalCost + 10% Discount' FROM Booking B WHERE B.rid = (
		SELECT r.rid 
		FROM Renter r, Users u 
		WHERE r.uid = u.id AND u.fname = 'Aman' AND u.lname = 'Arya'
) ORDER BY dt DESC;

--6.	Get the phone #’s of the client and user booking made on today’s date(2017-11-05).
SELECT u.phone 
FROM booking b, Client c, users u 
WHERE b.cid = c.cid AND c.uid = u.id AND b.dt = '2017-11-05'
ORDER BY b.dt;

--7.	Find the price of all driveways that contain “Harrison Street” (street of Space Needle) in their address.
SELECT priceRate FROM Driveway d
WHERE d.address LIKE '%Harrison Street%';

--8.	Find all the users who made a booking in a city that is not their own.
SELECT fname, lname FROM Booking B, Driveway D, Client C, Users U
WHERE B.did = D.did AND B.Cid = C.cid AND C.uid = U.id AND U.city != D.city
GROUP BY fname, lname;

--9.	Rank the top 5 renters by their amount made to date.
SELECT u.fname, u.lname, SUM(totalCost) AS Profit 
FROM Booking b, Renter r, Users u
WHERE b.rid = r.rid AND r.uid = u.id
GROUP BY b.rid, u.fname, u.lname
ORDER BY Profit DESC;

--10.	For each driveway find the average amount time in hours that they are booked.
SELECT avg(DATEDIFF(hour, checkin, checkout)) AS 'avgTimeBooked (hrs)' FROM Booking GROUP BY did;

--11.	Find the renter with the most “available” driveway. (Driveway with the most time between time-in and time-out).
SELECT TOP 1 fname, lname FROM Driveway D, Renter R, Users U WHERE D.rid = R.rid AND R.uid = u.id ORDER BY DATEDIFF(hour, timein, timeout) DESC;

--12.	Return how many spots are currently available in the city of Seattle.
Select ((SELECT SUM(spotsAvailible) FROM Driveway WHERE City = 'Seattle' GROUP BY City) -
(SELECT SUM(spotsBooked) FROM Booking B, Driveway D WHERE B.did = d.did AND city = 'Seattle')) AS currentlyAvailable;
