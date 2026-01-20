USE chinook;

-- Drop existing tables
DROP TABLE IF EXISTS order_details, orders, products, customers, categories;

-- Create tables (exact match to your CSV structure)
CREATE TABLE categories (
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(50),
    Description TEXT
);

CREATE TABLE customers (
    CustomerID VARCHAR(10) PRIMARY KEY,
    CompanyName VARCHAR(100),
    ContactName VARCHAR(100),
    ContactTitle VARCHAR(50),
    Address VARCHAR(150),
    City VARCHAR(50),
    Region VARCHAR(50),
    PostalCode VARCHAR(20),
    Country VARCHAR(50),
    Phone VARCHAR(30),
    Fax VARCHAR(30)
);

CREATE TABLE products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    SupplierID INT,
    CategoryID INT,
    QuantityPerUnit VARCHAR(50),
    UnitPrice DECIMAL(10,2),
    UnitsInStock INT,
    UnitsOnOrder INT,
    ReorderLevel INT,
    Discontinued TINYINT
);

CREATE TABLE orders (
    OrderID INT PRIMARY KEY,
    CustomerID VARCHAR(10),
    EmployeeID INT,
    OrderDate DATE,
    RequiredDate DATE,
    ShippedDate DATE,
    ShipVia INT,
    Freight DECIMAL(10,2),
    ShipName VARCHAR(100),
    ShipAddress VARCHAR(150),
    ShipCity VARCHAR(50),
    ShipRegion VARCHAR(50),
    ShipPostalCode VARCHAR(20),
    ShipCountry VARCHAR(50)
);

CREATE TABLE order_details (
    OrderID INT,
    ProductID INT,
    UnitPrice DECIMAL(10,2),
    Quantity INT,
    Discount DECIMAL(5,2),
    PRIMARY KEY (OrderID, ProductID)
);

-- Categories (your exact data)
INSERT INTO categories VALUES
(1,'Beverages','Soft drinks, coffees, teas, beers, and ales'),
(2,'Condiments','Sweet and savory sauces, relishes, spreads, and seasonings'),
(3,'Confections','Desserts, candies, and sweet breads'),
(4,'Dairy Products','Cheeses'),
(5,'Grains/Cereals','Breads, crackers, pasta, and cereal'),
(6,'Meat/Poultry','Prepared meats'),
(7,'Produce','Dried fruit and bean curd'),
(8,'Seafood','Seaweed and fish');

-- Customers (your exact data - partial)
INSERT INTO customers VALUES
('ALFKI','Alfreds Futterkiste','Maria Anders','Sales Representative','Obere Str. 57','Berlin',NULL,'12209','Germany','030-0074321','030-0076545'),
('ANATR','Ana Trujillo Emparedados y helados','Ana Trujillo','Owner','Avda. de la Constitucin 2222','Mxico D.F.',NULL,'05021','Mexico','(5) 555-4729','(5) 555-3745'),
('ANTON','Antonio Moreno Taquera','Antonio Moreno','Owner','Mataderos  2312','Mxico D.F.',NULL,'05023','Mexico','(5) 555-3932',NULL),
('AROUT','Around the Horn','Thomas Hardy','Sales Representative','120 Hanover Sq.','London',NULL,'WA1 1DP','UK','(171) 555-7788','(171) 555-6750');

-- Products (your exact data - partial)
INSERT INTO products VALUES
(1,'Chai',1,1,'10 boxes x 20 bags',18.00,39,0,10,0),
(2,'Chang',1,1,'24 - 12 oz bottles',19.00,17,40,25,0),
(3,'Aniseed Syrup',1,2,'12 - 550 ml bottles',10.00,13,70,25,0);

-- Orders (your exact data - partial, fixed dates)
INSERT INTO orders VALUES
(10248,'VINET',5,'1996-07-04','1996-08-01','1996-07-16',3,32.38,'Vins et alcools Chevalier','59 rue de l-Abbaye','Reims',NULL,'51100','France'),
(10249,'TOMSP',6,'1996-07-05','1996-08-16','1996-07-10',1,11.61,'Toms Spezialitten','Luisenstr. 48','Mnster',NULL,'44087','Germany');

-- Add sample order_details for analysis
INSERT INTO order_details VALUES
(10248,1,18.00,2,0.00),
(10248,2,19.00,1,0.00),
(10249,3,10.00,3,0.05);

select * from customers;
ALTER TABLE products ADD FOREIGN KEY (CategoryID) REFERENCES categories(CategoryID);
ALTER TABLE orders ADD FOREIGN KEY (CustomerID) REFERENCES customers(CustomerID);
ALTER TABLE order_details ADD FOREIGN KEY (OrderID) REFERENCES orders(OrderID);
ALTER TABLE order_details ADD FOREIGN KEY (ProductID) REFERENCES products(ProductID);

#3. Multi-Table JOIN: Product Revenue by Category
SELECT 
    c.CategoryName,
    COUNT(DISTINCT od.ProductID) as products_sold,
    SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)) as total_revenue
FROM categories c
JOIN products p ON c.CategoryID = p.CategoryID
JOIN order_details od ON p.ProductID = od.ProductID
GROUP BY c.CategoryID, c.CategoryName
ORDER BY total_revenue DESC;

SELECT 
    c.CompanyName,
    c.Country,
    COUNT(o.OrderID) as total_orders,
    SUM(o.Freight) as total_freight,
    AVG(DATEDIFF(o.RequiredDate, o.OrderDate)) as avg_days_to_ship
FROM customers c
LEFT JOIN orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.CompanyName, c.Country
HAVING total_orders > 0
ORDER BY total_orders DESC;

#5. Low Stock Alert (Products + Category)
SELECT 
    p.ProductName,
    c.CategoryName,
    p.UnitsInStock,
    p.ReorderLevel,
    p.UnitsOnOrder,
    SUM(od.Quantity) as total_sold
FROM products p
JOIN categories c ON p.CategoryID = c.CategoryID
LEFT JOIN order_details od ON p.ProductID = od.ProductID
WHERE p.UnitsInStock <= p.ReorderLevel
GROUP BY p.ProductID, p.ProductName, c.CategoryName, p.UnitsInStock, p.ReorderLevel, p.UnitsOnOrder
ORDER BY total_sold DESC;

