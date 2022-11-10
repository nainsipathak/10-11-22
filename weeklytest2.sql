use northwind;

-- Order Subtotals
select OrderID, 
format(sum(UnitPrice * Quantity * (1 - Discount)), 2) as Subtotal
from order_details
group by OrderID
order by OrderID;

-- Sales by Year
select distinct date(a.ShippedDate) as ShippedDate, 
    a.OrderID, 
    b.Subtotal, 
    year(a.ShippedDate) as Year
from Orders a 
inner join
(
    select distinct OrderID, 
        format(sum(UnitPrice * Quantity * (1 - Discount)), 2) as Subtotal
    from order_details
    group by OrderID    
) b on a.OrderID = b.OrderID
where a.ShippedDate is not null
and a.ShippedDate between date('1996-12-24') and date('1997-09-30')
order by a.ShippedDate;

-- Employee Sales by Country

SELECT  E.Country,
			E.LastName, 
			E.FirstName, 
			O.ShippedDate,
			O.OrderID,
			I.Subtotal AS Sale_Amount
	FROM Employees E
	INNER JOIN Orders O  
    INNER JOIN(
				SELECT DISTINCT OrderID, 
				SUM(UnitPrice * Quantity) AS Subtotal
				FROM Order_details
				GROUP BY OrderID ) I
	ON E.EmployeeID = O.EmployeeID
	WHERE O.ShippedDate IS NOT NULL;	

-- Alphabetical List of Products
select distinct b.*, a.CategoryName
from Categories a 
inner join Products b on a.CategoryID = b.CategoryID
where b.Discontinued = 'N'
order by b.ProductName;

-- Current Product List
select ProductID, ProductName
from products
where Discontinued = 'N'
order by ProductName;

-- Order Details Extended
select distinct OrderID, 
    y.ProductID, 
    x.ProductName, 
    y.UnitPrice, 
    y.Quantity, 
    y.Discount, 
    round(y.UnitPrice * y.Quantity * (1 - y.Discount), 2) as ExtendedPrice
from Products x
inner join Order_Details y on x.ProductID = y.ProductID
order by y.OrderID;

--  Sales by Category
select distinct a.CategoryID, 
    a.CategoryName,  
    b.ProductName, 
    sum(round(y.UnitPrice * y.Quantity * (1 - y.Discount), 2)) as ProductSales
from Order_Details y
inner join Orders d on d.OrderID = y.OrderID
inner join Products b on b.ProductID = y.ProductID
inner join Categories a on a.CategoryID = b.CategoryID
where d.OrderDate between date('1997/1/1') and date('1997/12/31')
group by a.CategoryID, a.CategoryName, b.ProductName
order by a.CategoryName, b.ProductName, ProductSales;

-- Ten Most Expensive Products
select * from
(
    select distinct ProductName as Ten_Most_Expensive_Products, 
	UnitPrice
    from Products
    order by UnitPrice desc
) as a
limit 10;

-- Products by Category
select distinct a.CategoryName, 
    b.ProductName, 
    b.QuantityPerUnit, 
    b.UnitsInStock, 
    b.Discontinued
from Categories a
inner join Products b on a.CategoryID = b.CategoryID
where b.Discontinued = 'N'
order by a.CategoryName, b.ProductName;

-- Customers and Suppliers by City
select City, CompanyName, ContactName, 'Customers' as Relationship 
from Customers
union
select City, CompanyName, ContactName, 'Suppliers'
from Suppliers
order by City, CompanyName;

-- Products Above Average Price
select distinct ProductName, UnitPrice
from Products
where UnitPrice > (select avg(UnitPrice) from Products)
order by UnitPrice;

-- Product Sales for 1997
select distinct a.CategoryName, 
    b.ProductName, 
    format(sum(c.UnitPrice * c.Quantity * (1 - c.Discount)), 2) as ProductSales,
    concat('Qtr ', quarter(d.ShippedDate)) as ShippedQuarter
from Categories a
inner join Products b on a.CategoryID = b.CategoryID
inner join Order_Details c on b.ProductID = c.ProductID
inner join Orders d on d.OrderID = c.OrderID
where d.ShippedDate between date('1997-01-01') and date('1997-12-31')
group by a.CategoryName, 
    b.ProductName, 
    concat('Qtr ', quarter(d.ShippedDate))
order by a.CategoryName, 
    b.ProductName, 
    ShippedQuarter;
    
-- Category Sales for 1997
select CategoryName, format(sum(ProductSales), 2) as CategorySales
from
(
    select distinct a.CategoryName, 
        b.ProductName, 
        format(sum(c.UnitPrice * c.Quantity * (1 - c.Discount)), 2) as ProductSales,
        concat('Qtr ', quarter(d.ShippedDate)) as ShippedQuarter
    from Categories as a
    inner join Products as b on a.CategoryID = b.CategoryID
    inner join Order_Details as c on b.ProductID = c.ProductID
    inner join Orders as d on d.OrderID = c.OrderID 
    where d.ShippedDate between date('1997-01-01') and date('1997-12-31')
    group by a.CategoryName, 
        b.ProductName, 
        concat('Qtr ', quarter(d.ShippedDate))
    order by a.CategoryName, 
        b.ProductName, 
        ShippedQuarter
) as x
group by CategoryName
order by CategoryName;

-- Quarterly Orders by Product
select a.ProductName, 
    d.CompanyName, 
    year(OrderDate) as OrderYear,
    format(sum(case quarter(c.OrderDate) when '1' 
        then b.UnitPrice*b.Quantity*(1-b.Discount) else 0 end), 0) "Qtr 1",
    format(sum(case quarter(c.OrderDate) when '2' 
        then b.UnitPrice*b.Quantity*(1-b.Discount) else 0 end), 0) "Qtr 2",
    format(sum(case quarter(c.OrderDate) when '3' 
        then b.UnitPrice*b.Quantity*(1-b.Discount) else 0 end), 0) "Qtr 3",
    format(sum(case quarter(c.OrderDate) when '4' 
        then b.UnitPrice*b.Quantity*(1-b.Discount) else 0 end), 0) "Qtr 4" 
from Products a 
inner join Order_Details b on a.ProductID = b.ProductID
inner join Orders c on c.OrderID = b.OrderID
inner join Customers d on d.CustomerID = c.CustomerID 
where c.OrderDate between date('1997-01-01') and date('1997-12-31')
group by a.ProductName, 
    d.CompanyName, 
    year(OrderDate)
order by a.ProductName, d.CompanyName;

--  Invoice
select distinct b.ShipName, 
    b.ShipAddress, 
    b.ShipCity, 
    b.ShipRegion, 
    b.ShipPostalCode, 
    b.ShipCountry, 
    b.CustomerID, 
    c.CompanyName, 
    c.Address, 
    c.City, 
    c.Region, 
    c.PostalCode, 
    c.Country, 
    concat(d.FirstName,  ' ', d.LastName) as Salesperson, 
    b.OrderID, 
    b.OrderDate, 
    b.RequiredDate, 
    b.ShippedDate, 
    a.CompanyName, 
    e.ProductID, 
    f.ProductName, 
    e.UnitPrice, 
    e.Quantity, 
    e.Discount,
    e.UnitPrice * e.Quantity * (1 - e.Discount) as ExtendedPrice,
    b.Freight
from Shippers a 
inner join Orders b on a.ShipperID = b.ShipVia 
inner join Customers c on c.CustomerID = b.CustomerID
inner join Employees d on d.EmployeeID = b.EmployeeID
inner join Order_Details e on b.OrderID = e.OrderID
inner join Products f on f.ProductID = e.ProductID
order by b.ShipName;

-- Number of units in stock by category and supplier continent
select c.CategoryName as "Product Category", 
       case when s.Country in 
                 ('UK','Spain','Sweden','Germany','Norway',
                  'Denmark','Netherlands','Finland','Italy','France')
            then 'Europe'
            when s.Country in ('USA','Canada','Brazil') 
            then 'America'
            else 'Asia-Pacific'
        end as "Supplier Continent", 
        sum(p.UnitsInStock) as UnitsInStock
from Suppliers s 
inner join Products p on p.SupplierID=s.SupplierID
inner join Categories c on c.CategoryID=p.CategoryID 
group by c.CategoryName, 
         case when s.Country in 
                 ('UK','Spain','Sweden','Germany','Norway',
                  'Denmark','Netherlands','Finland','Italy','France')
              then 'Europe'
              when s.Country in ('USA','Canada','Brazil') 
              then 'America'
              else 'Asia-Pacific'
         end;