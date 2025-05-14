-- Database Normalization Assignment - MySQL Solution

-- 1. Create the database (if it doesn't exist)
--    This ensures that the database is available for the assignment.
CREATE DATABASE IF NOT EXISTS normalization_assignment;

-- 2. Select the database to use
--    This sets the active database context for the following operations.
USE normalization_assignment;

-- 3.  Create the initial tables with the provided data.
--     These tables represent the starting point for the normalization exercise.
--     Dropping them first ensures a clean slate for each execution.

DROP TABLE IF EXISTS ProductDetail;
CREATE TABLE ProductDetail (
    OrderID INT,
    CustomerName VARCHAR(255),
    Products VARCHAR(255)
);

INSERT INTO ProductDetail (OrderID, CustomerName, Products) VALUES
(101, 'John Doe', 'Laptop, Mouse'),
(102, 'Jane Smith', 'Tablet, Keyboard, Mouse'),
(103, 'Emily Clark', 'Phone');

DROP TABLE IF EXISTS OrderDetails;
CREATE TABLE OrderDetails (
    OrderID INT,
    CustomerName VARCHAR(255),
    Product VARCHAR(255),
    Quantity INT
);

INSERT INTO OrderDetails (OrderID, CustomerName, Product, Quantity) VALUES
(101, 'John Doe', 'Laptop', 2),
(101, 'John Doe', 'Mouse', 1),
(102, 'Jane Smith', 'Tablet', 3),
(102, 'Jane Smith', 'Keyboard', 1),
(102, 'Jane Smith', 'Mouse', 2),
(103, 'Emily Clark', 'Phone', 1);


-- 4. Question 1: Achieving 1NF (First Normal Form)
--    Task: Transform the ProductDetail table into 1NF.
--    The Products column contains multiple values, violating 1NF.
--    We create a new table ProductDetail_1NF where each row represents a single product for an order.

DROP TABLE IF EXISTS ProductDetail_1NF;  -- Drop if exists for clean re-creation
CREATE TABLE ProductDetail_1NF (
    OrderID INT,
    CustomerName VARCHAR(255),
    Product VARCHAR(255),
    PRIMARY KEY (OrderID, Product)  -- Correct Primary Key for 1NF
);

-- Populate ProductDetail_1NF by splitting the Products column.
INSERT INTO ProductDetail_1NF (OrderID, CustomerName, Product)
SELECT
    OrderID,
    CustomerName,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Products, ',', n), ',', -1)) AS Product  -- Extract and trim product names
FROM
    ProductDetail
CROSS JOIN (  -- Generate numbers 1 to maximum products (in this case 3)
    SELECT 1 AS n UNION ALL
    SELECT 2 UNION ALL
    SELECT 3
) AS numbers
WHERE
    n <= LENGTH(Products) - LENGTH(REPLACE(Products, ',', '')) + 1;  -- Correctly count products in the string

-- Display the 1NF table
SELECT * FROM ProductDetail_1NF;



-- 5. Question 2: Achieving 2NF (Second Normal Form)
--    Task: Transform the OrderDetails table into 2NF.
--    The CustomerName column depends only on OrderID, violating 2NF.
--    We decompose OrderDetails into two tables: Orders and OrderItems.

DROP TABLE IF EXISTS Orders;       -- Drop tables to start with a clean state
DROP TABLE IF EXISTS OrderItems;

-- Create the Orders table (R1 in 2NF).
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerName VARCHAR(255)
);

-- Populate the Orders table.
INSERT INTO Orders (OrderID, CustomerName)
SELECT DISTINCT OrderID, CustomerName
FROM OrderDetails;

-- Create the OrderItems table (R2 in 2NF).
CREATE TABLE OrderItems (
    OrderID INT,
    Product VARCHAR(255),
    Quantity INT,
    PRIMARY KEY (OrderID, Product),  -- Composite Primary Key
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)  -- Foreign Key constraint
);

-- Populate the OrderItems table.
INSERT INTO OrderItems (OrderID, Product, Quantity)
SELECT OrderID, Product, Quantity
FROM OrderDetails;

-- Display the 2NF tables.
SELECT * FROM Orders;
SELECT * FROM OrderItems;
