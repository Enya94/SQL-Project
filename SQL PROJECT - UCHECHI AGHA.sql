--1. Retrieve a list of customers and the total amount they’ve spent on orders
SELECT c.CustomerID,
    CONCAT(p.FirstName, ' ', p.LastName) AS CustomerName,
    SUM(sod.LineTotal) AS TotalSpent
FROM 
    Sales.Customer AS c
JOIN 
    Person.Person AS p ON c.PersonID = p.BusinessEntityID
JOIN 
    Sales.SalesOrderHeader AS soh ON c.CustomerID = soh.CustomerID
JOIN 
    Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY 
    c.CustomerID, p.FirstName, p.LastName
ORDER BY 
    TotalSpent DESC;

--2 List all employees and their respective department names

SELECT 
    e.BusinessEntityID AS EmployeeID,
   CONCAT( p.FirstName, ' ', p.LastName) AS EmployeeName,
    d.Name AS DepartmentName
FROM 
    HumanResources.Employee AS e
JOIN 
    Person.Person AS p ON e.BusinessEntityID = p.BusinessEntityID
JOIN 
    HumanResources.EmployeeDepartmentHistory AS edh ON e.BusinessEntityID = edh.BusinessEntityID
JOIN 
    HumanResources.Department AS d ON edh.DepartmentID = d.DepartmentID
WHERE 
    edh.EndDate IS NULL
ORDER BY 
    EmployeeName

--3 Find the products that have been sold along with their categories
SELECT 
    p.ProductID,
    p.Name AS ProductName,
    pc.Name AS ProductCategory,
    SUM(sod.OrderQty) AS TotalQuantitySold
FROM 
    Production.Product AS p
JOIN 
    Production.ProductSubcategory AS psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN 
    Production.ProductCategory AS pc ON psc.ProductCategoryID = pc.ProductCategoryID
JOIN 
    Sales.SalesOrderDetail AS sod ON p.ProductID = sod.ProductID
GROUP BY 
    p.ProductID, p.Name, pc.Name
ORDER BY 
    TotalQuantitySold DESC;

--4 Get the sales representatives and the number of customers they manage

	SELECT 
		e.BusinessEntityID AS SalesRepID,
		CONCAT(p.FirstName, ' ', p.LastName) AS SalesRepName,
		COUNT(DISTINCT c.CustomerID) AS NumberOfCustomers
	FROM 
		Sales.SalesTerritory AS st
	JOIN 
		Sales.SalesPerson AS sp ON st.TerritoryID = sp.TerritoryID
	JOIN 
		HumanResources.Employee AS e ON sp.BusinessEntityID = e.BusinessEntityID
	JOIN 
		Person.Person AS p ON e.BusinessEntityID = p.BusinessEntityID
	LEFT JOIN 
		Sales.Customer AS c ON st.TerritoryID = c.TerritoryID
	GROUP BY 
		e.BusinessEntityID, p.FirstName, p.LastName
	ORDER BY 
		NumberOfCustomers DESC;
--5 Identify orders with their shipping addresses and sales information
SELECT 
    soh.SalesOrderID,
    soh.OrderDate,
    soh.TotalDue,
    CONCAT(a.AddressLine1, ', ', a.City, ', ', sp.Name) AS ShippingAddress,
    CONCAT(p.FirstName, ' ', p.LastName) AS CustomerName
FROM 
    Sales.SalesOrderHeader AS soh
JOIN 
    Person.Address AS a ON soh.ShipToAddressID = a.AddressID
JOIN 
    Person.StateProvince AS sp ON a.StateProvinceID = sp.StateProvinceID
JOIN 
    Sales.Customer AS c ON soh.CustomerID = c.CustomerID
JOIN 
    Person.Person AS p ON c.PersonID = p.BusinessEntityID
ORDER BY 
    soh.OrderDate DESC;

--6. Subquery to find the average sales amount per order

SELECT 
    CustomerID,
    (
        SELECT AVG(TotalDue)
        FROM Sales.SalesOrderHeader
        WHERE CustomerID = s.CustomerID
    ) AS AverageOrderValue
FROM 
    Sales.SalesOrderHeader AS s
GROUP BY 
    CustomerID;

--7 Subquery to find the total number of orders for each customer
SELECT 
    CustomerID,
    (
        SELECT COUNT(*)
        FROM Sales.SalesOrderHeader AS soh2
        WHERE soh2.CustomerID = s.CustomerID
    ) AS TotalOrders
FROM 
    Sales.SalesOrderHeader AS s;

--8. Subquery to find the highest product price
SELECT 
    (
        SELECT MAX(ListPrice)
        FROM Production.Product
    ) AS HighestProductPrice
FROM 
    Production.Product;

--9 Subquery to find the maximum order total across all orders

SELECT 
    (
        SELECT MAX(TotalDue)
        FROM Sales.SalesOrderHeader
    ) AS MaxOrderTotal
FROM 
    Sales.SalesOrderHeader;

--10 Subquery to find the count of unique products sold in each category
SELECT 
    ProductCategoryID,
    (
        SELECT COUNT(DISTINCT ProductID)
        FROM Production.Product
        WHERE ProductCategoryID = pc.ProductCategoryID
    ) AS UniqueProductsCount
FROM 
    Production.ProductCategory AS pc;

--11 Total Orders per Customer
WITH CustomerOrderCountCTE AS (
    SELECT 
        CustomerID,
        COUNT(*) AS TotalOrders
    FROM 
        Sales.SalesOrderHeader
    GROUP BY 
        CustomerID
)
SELECT 
    CustomerID,
    TotalOrders
FROM 
    CustomerOrderCountCTE;

--12 Top 5 products by total sales revenue
WITH ProductSalesCTE AS (
    SELECT 
        p.ProductID,
        p.Name AS ProductName,
        SUM(sod.LineTotal) AS TotalSales
    FROM 
        Production.Product AS p
    JOIN 
        Sales.SalesOrderDetail AS sod ON p.ProductID = sod.ProductID
    GROUP BY 
        p.ProductID, p.Name
)
SELECT 
    ProductID, 
    ProductName, 
    TotalSales
FROM 
    ProductSalesCTE
ORDER BY 
    TotalSales DESC
--13. total sales per year
	WITH SalesPerYearCTE AS (
    SELECT 
        YEAR(soh.OrderDate) AS OrderYear,
        SUM(sod.LineTotal) AS TotalSales
    FROM 
        Sales.SalesOrderHeader AS soh
    JOIN 
        Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
    GROUP BY 
        YEAR(soh.OrderDate)

--14 Retreieve data of employees still in the department
SELECT 
    CONCAT(p.FirstName, ' ', p.LastName) AS EmployeeName,
    e.JobTitle,
    edh.DepartmentID
FROM 
    HumanResources.Employee e
JOIN 
    Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
JOIN 
    HumanResources.EmployeeDepartmentHistory edh ON e.BusinessEntityID = edh.BusinessEntityID
WHERE 
    edh.EndDate IS NULL;
--15. Calcualte the total sales amount or each customer and list only customers 
--with sales greater than 10,000
WITH CustomerSales AS (
    SELECT 
        soh.CustomerID,
        SUM(soh.TotalDue) AS TotalSales
    FROM 
        Sales.SalesOrderHeader soh
    GROUP BY 
        soh.CustomerID
)
SELECT 
    CONCAT(p.FirstName, ' ', p.LastName) AS CustomerName,
    cs.CustomerID,
    cs.TotalSales
FROM 
    CustomerSales cs
JOIN 
    Sales.Customer c ON cs.CustomerID = c.CustomerID
JOIN 
    Person.Person p ON c.PersonID = p.BusinessEntityID
WHERE 
    cs.TotalSales > 10000;























