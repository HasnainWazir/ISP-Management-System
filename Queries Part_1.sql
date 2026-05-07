
--Create User:
--Inserts a new record into Users table storing login credentials and role.
INSERT INTO Users (role, username, passwords) VALUES ('Customer', 'ali123', 'pass123');

--Login Validation:
--Checks if provided username and password match an existing user and returns role.
SELECT user_id, role FROM Users WHERE username = 'ali123' AND passwords = 'pass123';

--View All Users:
--Fetches all records from Users table.
SELECT * FROM Users;

--Add Customer:
--Inserts a new customer record linked to an area.
INSERT INTO Customers (customer_name, phone_number, address, area_id) VALUES ('Ali Khan', '03001234567', 'Street 5, Topi', 1);

--View All Customers:
--Retrieves all customer records.
SELECT * FROM Customers;

--View Customers with Area:
--Uses JOIN to combine Customers and Areas tables.
SELECT c.customer_id, c.customer_name, c.phone_number, a.area_name FROM Customers c JOIN Areas a ON c.area_id = a.area_id;

--Search Customer:
--Finds customers whose name matches pattern using case-insensitive search.
SELECT * FROM Customers WHERE customer_name ILIKE '%ali%';

--Update Customer:
--Modifies existing customer record.
UPDATE Customers SET phone_number = '03111234567' WHERE customer_id = 1;

--Delete Customer:
--Removes customer from database.
DELETE FROM Customers WHERE customer_id = 1;

--Add Area:
--Stores a new area in Areas table.
INSERT INTO Areas (area_name) VALUES ('Topi');

--View Areas:
--Retrieves all area records.
SELECT * FROM Areas;

--Add Package:
--Inserts new package details.
INSERT INTO Packages (internet_speed, price, data_limit) VALUES ('20 Mbps', 2000, '100GB');

--View Packages:
--Fetches all packages.
SELECT * FROM Packages;

--Update Package:
--Modifies package details.
UPDATE Packages SET price = 2500 WHERE package_id = 1;

--Delete Package:
--Removes package record.
DELETE FROM Packages WHERE package_id = 1;

--Customer Profile:
--Combines customer and area info for detailed view.
SELECT c.customer_id, c.customer_name, c.phone_number, c.address, a.area_name FROM Customers c JOIN Areas a ON c.area_id = a.area_id WHERE c.customer_id = 1;
