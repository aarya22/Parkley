create database parkley;

use parkley;

CREATE TABLE Users(
	id INT PRIMARY KEY IDENTITY(1, 1),
	fname VARCHAR(20) NOT NULL,
	lname VARCHAR(20) NOT NULL,
	email VARCHAR(30) NOT NULL,
	phone VARCHAR(15) NOT NULL,
	city VARCHAR(20) NOT NULL
);

CREATE TABLE Client(
	cid INT PRIMARY KEY IDENTITY(1, 1),
	rating TINYINT,
	uid INT NOT NULL FOREIGN KEY REFERENCES Users(id)
);

CREATE TABLE Renter(
	rid INT PRIMARY KEY IDENTITY(1, 1),
	rating TINYINT,
	uid INT NOT NULL FOREIGN KEY REFERENCES Users(id)
);

CREATE TABLE Driveway(
	did INT PRIMARY KEY IDENTITY(1, 1),
	address VARCHAR(100),
	city VARCHAR(20),
	state VARCHAR(2) NOT NULL,
	zip VARCHAR(5) NOT NULL,
	spotsAvailible TINYINT NOT NULL,
	availible BIT NOT NULL,
	priceRate DECIMAL(19,4) NOT NULL,
	timein TIME NOT NULL,
	timeout TIME NOT NULL,
	rid INT NOT NULL FOREIGN KEY REFERENCES Renter(rid)
);

alter table Driveway drop column zip;

CREATE TABLE Booking(
	bid INT PRIMARY KEY IDENTITY(1, 1),
	checkin TIME NOT NULL,
	checkout TIME NOT NULL,
	dt DATE NOT NULL,
	totalcost DECIMAL(19, 4) NOT NULL,
	spotsBooked TINYINT NOT NULL,
	rid INT NOT NULL FOREIGN KEY REFERENCES Renter(rid),
	cid INT NOT NULL FOREIGN KEY REFERENCES Client(cid),
	did INT NOT NULL FOREIGN KEY REFERENCES Driveway(did)
);

ALTER PROCEDURE uspInsert_Users
@fname VARCHAR(20), --parameter variables
@lname VARCHAR(20),
@email VARCHAR(30),
@phone VARCHAR(15),
@city VARCHAR(20)
AS 
BEGIN
INSERT INTO Users(fname, lname, email, phone, city) VALUES (@fname, @lname, @email, @phone, @city);
END

Select * from Users;

alter procedure uspInsert_Client
@fname VARCHAR(20),
@lname VARCHAR(20)
as
declare @uid int
begin
set @uid = (Select u.id from Users u where u.fname = @fname
			and u.lname = @lname);
IF @uid IS NULL
BEGIN
	RAISERROR ('cid was null', 12, 1)
	RETURN	
END
---- Create the variables for the random number generation
DECLARE @Random INT;
DECLARE @Upper INT;
DECLARE @Lower INT
 
---- This will create a random number between 1 and 999
SET @Lower = 1 ---- The lowest random number
SET @Upper = 6---- The highest random number
SELECT @Random = ROUND(((@Upper - @Lower -1) * RAND() + @Lower), 0)
insert into Client (uid, rating) values (@uid, @Random);
end

Select * from Client;

alter procedure uspInsert_Renter
@fname VARCHAR(20),
@lname VARCHAR(20)
as
declare @uid int
begin
set @uid = (Select u.id from Users u where u.fname = @fname
			and u.lname = @lname);
IF @uid IS NULL
BEGIN
	RAISERROR ('cid was null', 12, 1)
	RETURN	
END
---- Create the variables for the random number generation
DECLARE @Random INT;
DECLARE @Upper INT;
DECLARE @Lower INT
 
---- This will create a random number between 1 and 999 
SET @Lower = 1 ---- The lowest random number
SET @Upper = 6---- The highest random number
SELECT @Random = ROUND(((@Upper - @Lower -1) * RAND() + @Lower), 0)

insert into Renter(uid, rating) values (@uid, @Random);
end

Select * from Renter;

alter procedure make_booking
@checkin time,
@checkout time,
@date date,
@cfname varchar(20),
@clname varchar(20),
@spotsBooked tinyint,
@did int
as 
declare @totalcost decimal(19,4)
declare @pricerate decimal(19,4)
declare @cid int
declare @rid int
declare @spotsAvailible int
declare @spotsleft int
begin

--exec uspInsert_Client @cfname, @clname;
if not exists (Select cid from Client c, Users u where u.id = c.uid 
			and u.fname = @cfname and u.lname = @clname)
Begin
	exec uspInsert_Client @cfname, @clname;
end

set @pricerate = (Select priceRate from Driveway d where d.did = @did);
set @totalcost = @spotsBooked * @pricerate * DATEDIFF(hour, @checkin, @checkout);
set @cid = (Select cid from Client c, Users u where u.id = c.uid 
			and u.fname = @cfname and u.lname = @clname);
set @rid = (Select rid from Driveway d where d.did = @did);
set @spotsAvailible = (Select spotsAvailible from Driveway d where d.did = @did);
set @spotsleft = @spotsBooked / @spotsAvailible;

if @spotsleft = 1
begin 
	update Driveway  
	set availible = 0 
	where Driveway.did = @did
end

insert into Booking(checkin, checkout, dt, totalcost, cid, rid, did, spotsBooked) 
values (@checkin, @checkout, @date, @totalcost, @cid, @rid, @did, @spotsBooked);

end

alter procedure register_driveway
@address VARCHAR(100),
@city varchar(50),
@state varchar(2),
@spotsAvailible int,
@pricerate decimal(19,4),
@timein time,
@timeout time,
@rfname varchar(20),
@rlname varchar(20)
as
declare @rid int
declare @availible bit
begin

if not exists (Select rid from Renter r, Users u where u.id = r.uid and u.fname = @rfname and u.lname = @rlname)
Begin
	exec uspInsert_Renter @rfname, @rlname;
end
set @rid = (Select rid from Renter r, Users u where u.id = r.uid
			and u.fname = @rfname and u.lname = @rlname);
set @availible = 1;

insert into Driveway(address, city, state, spotsAvailible, priceRate, timein, timeout, rid, availible)
values (@address, @city, @state, @spotsAvailible, @pricerate, @timein, @timeout, @rid, @availible);

end




Select * from Renter r, Users u where u.id = r.uid and u.fname = 'Aman' and u.lname = 'Arya'

-- Adding Sample Data --

-- Select
SELECT * FROM Users;
SELECT * FROM Client;
SELECT * FROM Renter;
SELECT * FROM Driveway;
SELECT * FROM Booking;

-- Create Users
EXEC uspInsert_Users 'Aman', 'Arya', 'aarya22@uw.edu', '222-222-2222', 'Seattle';
EXEC uspInsert_Users 'Leandro', 'Solidum', 'lndrgs@uw.edu', '000-000-000', 'Bellevue';
EXEC uspInsert_Users 'Kevin', 'Fleming', 'kfleming@uw.edu', '123-456-789', 'Seattle';
EXEC uspInsert_Users 'Barack', 'Obama', 'bobama@uw.edu', '111-111-1111', 'Honolulu';
EXEC uspInsert_Users 'Bill', 'Gates', 'bgates@uw.edu', '333-333-3333', 'Medina';
EXEC uspInsert_Users 'Paul', 'Allen', 'pga@uw.edu', '444-444-4444', 'Mercer Island';
EXEC uspInsert_Users 'Larry', 'Page', 'lp@uw.edu', '900-913-0000', 'Palo Alto';
EXEC uspInsert_Users 'John', 'Jones', 'John@gmail.com', '360-160-2425', 'Seattle';
EXEC uspInsert_Users 'Bob', 'Bones', 'bob@gmail.com', '360-7478-9482', 'Seattle';
EXEC uspInsert_Users 'Don', 'Doe', 'ddoe@gmail.com', '360-160-2425', 'Honolulu';
EXEC uspInsert_Users 'Robert', 'Rows', 'rrows@gmail.com', '312-120-2552', 'Chicago';


-- Create Client & Renter
exec uspInsert_Client 'Leandro', 'Solidum';
exec uspInsert_Renter 'Aman', 'Arya';

-- Create Driveways
EXEC register_driveway 'Harrison Street', 'Seattle', 'WA', 5, 12.00, '00:00:00', '12:00:00', 'Aman', 'Arya';
EXEC register_driveway 'University of Washington', 'Seattle', 'WA', 3, .10, '06:00:00', '23:00:00', 'Aman', 'Arya';
EXEC register_driveway 'West Lake Sammamish', 'Bellevue', 'WA', 2, 8.00, '09:00:00', '18:00:00', 'Leandro', 'Solidum';
EXEC register_driveway 'Snowy Mountain', 'Anchorage', 'AK', 250, 9.00, '04:00:00', '20:00:00', 'Leandro', 'Solidum';
EXEC register_driveway 'Microsoft Campus', 'Redmond', 'WA', 12, 11.00, '12:00:00', '16:00:00', 'Kevin', 'Fleming';
EXEC register_driveway 'Harrison Street', 'Seattle', 'WA', 2, 11.00, '12:00:00', '16:00:00', 'Kevin', 'Fleming';
EXEC register_driveway 'Microsoft Campus', 'Redmond', 'WA', 25, 20.00, '12:00:00', '16:00:00', 'Bill', 'Gates';
EXEC register_driveway 'Microsoft Campus', 'Redmond', 'WA', 50, 1.00, '00:00:00', '23:00:00', 'Paul', 'Allen';
EXEC register_driveway 'Pike Place', 'Seattle', 'WA', 50, 11.00, '00:00:00', '23:00:00', 'Paul', 'Allen';
EXEC register_driveway 'Lake Washington', 'Medina', 'WA', 10, 200.00, '00:00:00', '23:00:00', 'Bill', 'Gates';
EXEC register_driveway 'Google HQ', 'Mountain View', 'CA', 100, 20.00, '08:00:00', '19:00:00', 'Larry', 'Page';
EXEC register_driveway 'Wall Street', 'NYC', 'NY', 10, 100.00, '08:00:00', '22:00:00', 'Larry', 'Page';	
EXEC register_driveway 'White House', 'Washington DC', 'PA', 1, 200.00, '12:00:00', '16:00:00', 'Barack', 'Obama';
EXEC register_driveway 'Beach Way', 'Honolulu', 'PA', 1, 200.00, '12:00:00', '16:00:00', 'Barack', 'Obama';

-- Create Bookings
EXEC make_booking '11:00:00', '12:00:00', '2017-10-30', 'Aman', 'Arya', 1, 63;
EXEC make_booking '13:00:00', '15:00:00', '2017-11-03', 'Aman', 'Arya', 1, 64;
EXEC make_booking '09:00:00', '18:00:00', '2017-11-05', 'John', 'Jones', 1, 65;
EXEC make_booking '12:00:00', '20:00:00', '2017-11-05', 'Bob', 'Bones', 1, 66;
EXEC make_booking '13:00:00', '15:00:00', '2017-11-05', 'Robert', 'Rows', 1, 67;
EXEC make_booking '01:00:00', '15:00:00', '2017-11-04', 'Leandro', 'Solidum', 1, 68;
EXEC make_booking '07:00:00', '16:00:00', '2017-11-02', 'Robert', 'Rows', 1, 69;
EXEC make_booking '13:00:00', '15:00:00', '2017-11-05', 'Paul', 'Allen', 1, 70;
EXEC make_booking '13:00:00', '15:00:00', '2017-11-01', 'Paul', 'Allen', 1, 71;
EXEC make_booking '13:00:00', '15:00:00', '2017-11-02', 'Paul', 'Allen', 1, 72;
EXEC make_booking '13:00:00', '15:00:00', '2017-11-03', 'Paul', 'Allen', 1, 73;
EXEC make_booking '13:00:00', '15:00:00', '2017-11-04', 'Paul', 'Allen', 1, 74;
EXEC make_booking '13:00:00', '15:00:00', '2017-11-05', 'Paul', 'Allen', 1, 75;
EXEC make_booking '13:00:00', '15:00:00', '2017-11-06', 'Paul', 'Allen', 1, 76;


-- Delete rows
Delete from Users
Delete from Booking
Delete from Driveway
delete from renter
Delete from Client

Alter procedure getProfit
@fname	varchar(20),
@lname	varchar(20)
as
declare @rid int
begin 
set @rid = (Select rid from Renter r, Users u where 
			r.uid = u.id and u.fname = @fname and u.lname = @lname);
if @rid IS NULL
begin
	raiserror ('rid was null', 12, 1)
	return
end
Select SUM(totalCost) as Profit from Booking b where b.rid = @rid;
end

exec getProfit 'Aman', 'Arya'; 
