USE salesdb;
-- Step 1: Create the table
CREATE TABLE ProductDetail (
    OrderID INT,
    CustomerName VARCHAR(100),
    Products VARCHAR(255)
);

-- Step 2: Insert sample data
INSERT INTO ProductDetail (OrderID, CustomerName, Products)
VALUES
(101, 'John Doe', 'Laptop, Mouse'),
(102, 'Jane Smith', 'Tablet, Keyboard, Mouse'),
(103, 'Emily Clark', 'Phone');


-- Create a temporary numbers table to help with splitting
-- This generates a sequence of numbers from 1 to 5
WITH numbers AS (
    SELECT 1 AS n  -- Start with number 1
    UNION 
    SELECT 2       -- Add number 2
    UNION 
    SELECT 3       -- Add number 3
    UNION 
    SELECT 4       -- Add number 4
    UNION 
    SELECT 5       -- Add number 5 (maximum expected products per order)
),
-- Split the comma-separated products into individual rows
split_products AS (
    SELECT 
        OrderID,          -- Keep the original OrderID
        CustomerName,     -- Keep the original CustomerName
        -- Extract the nth product from the comma-separated list:
        -- 1. SUBSTRING_INDEX(Products, ',', n) gets everything up to the nth comma
        -- 2. SUBSTRING_INDEX(..., ',', -1) gets the last element after splitting by comma
        -- 3. TRIM() removes any leading/trailing spaces
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Products, ',', n), ',', -1)) AS Product
    FROM ProductDetail
    -- Join with numbers table to create multiple rows per order
    JOIN numbers
        -- Only join where the product position exists:
        -- Calculate number of commas in Products string and ensure n is within bounds
        -- CHAR_LENGTH(Products) - CHAR_LENGTH(REPLACE(Products, ',', '')) gives comma count
        -- >= n - 1 ensures we only generate rows for actual products
        ON CHAR_LENGTH(Products) - CHAR_LENGTH(REPLACE(Products, ',', '')) >= n - 1
)
-- Final selection from the split data
SELECT 
    OrderID,
    CustomerName,
    Product
FROM split_products
-- Order results for better readability
ORDER BY OrderID, Product;


-- QUESTION 2
CREATE TABLE OrderDetail (
    OrderID INT,
    CustomerName VARCHAR(100),
    Product VARCHAR(100),
    Quantity INT
);
INSERT INTO OrderDetail (OrderID, CustomerName, Product, Quantity) VALUES
(101, 'John Doe', 'Laptop', 2),
(101, 'John Doe', 'Mouse', 1),
(102, 'Jane Smith', 'Tablet', 3),
(102, 'Jane Smith', 'Keyboard', 1),
(102, 'Jane Smith', 'Mouse', 2),
(103, 'Emily Clark', 'Phone', 1);


SELECT OrderID,
       COUNT(DISTINCT CustomerName) AS name_count,
       GROUP_CONCAT(DISTINCT CustomerName SEPARATOR '; ') AS names
FROM OrderDetail
GROUP BY OrderID
HAVING name_count > 1;
-- create parent table
CREATE TABLE Orders2NF (
    OrderID INT NOT NULL,
    CustomerName VARCHAR(100) NOT NULL,
    PRIMARY KEY (OrderID)
);

-- populate Orders (deterministic choice if there's any ambiguity)
INSERT INTO Orders2NF (OrderID, CustomerName)
SELECT OrderID, MIN(CustomerName)
FROM OrderDetail
GROUP BY OrderID;

SELECT 
    o.CustomerName,                     -- pick the customer's name from Orders2NF
    o.OrderID,                          -- show the order ID
    GROUP_CONCAT(d.Product ORDER BY d.Product SEPARATOR ', ') AS Products -- merge products into one list
FROM Orders2NF o                        -- parent table (customers & orders)
JOIN OrderDetails_Normalized d          -- child table (products in each order)
    ON o.OrderID = d.OrderID            -- join on the common column
GROUP BY o.CustomerName, o.OrderID;     -- group so each customer/order is one row
