-- Create the table with sample data if it doesn't exist
CREATE TABLE IF NOT EXISTS productdetail (
    orderid INTEGER,
    customername VARCHAR(100),
    products VARCHAR(255)
);

-- Insert sample data
INSERT INTO productdetail (orderid, customername, products) VALUES
(101, 'John Doe', 'Laptop, Mouse'),
(102, 'Jane Smith', 'Tablet, Keyboard, Mouse'),
(103, 'Emily Clark', 'Phone')
-- Select order details with products split into atomic values (1NF)
SELECT 
    OrderID,
    CustomerName,
    TRIM(product) AS Product   -- Clean up spaces around each product
FROM ProductDetail,
-- Use JSON_TABLE to split the comma-separated 'Products' column
JSON_TABLE(
    -- Convert the comma-separated string into a valid JSON array
    -- Example: 'Laptop, Mouse' -> '["Laptop","Mouse"]'
    CONCAT('["', REPLACE(Products, ',', '","'), '"]'),
    "$[*]" COLUMNS (
        product VARCHAR(100) PATH "$"  -- Extract each product as a row
    )
) AS jt;
