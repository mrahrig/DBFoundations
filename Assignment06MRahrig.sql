--*************************************************************************--
-- Title: Assignment06
-- Author: MeganRahrig
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2021-02-17, Megan Rahrig, Created File
-- 2021-02-18, Megan Rahrig, Answered questions 1 - 9
-- 2021-02-22, Megan Rahrig, Answered question 10. Moved "order by" clauses into body of views.
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_MeganRahrig')
	 Begin 
	  Alter Database [Assignment06DB_MeganRahrig] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_MeganRahrig;
	 End
	Create Database Assignment06DB_MeganRahrig;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_MeganRahrig;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5 pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

--Select * From Categories;
--Columns: CategoryID, CategoryName

--Select * From Products;
--Columns: ProductID, ProductName, CategoryID, UnitPrice

--Select * From Employees;
--Columns: EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID

--Select * From Inventories;
--Columns: InventoryID, InventoryDate, EmployeeID, ProductID, Count

/*
drop view vcategories
drop view vproducts
drop view vinventories
drop view vemployees
*/

Create View vCategories
With Schemabinding
As
 Select CategoryID, CategoryName
 From dbo.Categories
Go
Select * From vCategories
Go

Create View vProducts
With Schemabinding
As
 Select ProductID, ProductName, CategoryID, UnitPrice
 From dbo.Products
Go
Select * From vProducts
Go

Create View vEmployees
With Schemabinding
As
 Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
 From dbo.Employees
Go
Select * From vEmployees
Go

Create View vInventories
With Schemabinding
As
 Select InventoryID, InventoryDate, EmployeeID, ProductID, Count
 From dbo.Inventories
Go
Select * From vInventories
Go

-- Question 2 (5 pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

Deny Select On dbo.Categories to Public;
Go
Deny Select On dbo.Products to Public;
Go
Deny Select On dbo.Employees to Public;
Go
Deny Select On dbo.Inventories to Public;
Go

Grant Select On vCategories to Public;
Go
Grant Select On vProducts to Public;
Go
Grant Select On vEmployees to Public;
Go
Grant Select On vInventories to Public;
Go


-- Question 3 (10 pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

--Drop view vproductprices 

Create view vProductPrices
With Schemabinding
As
Select Top 100000
 CategoryName, ProductName, UnitPrice
 From dbo.Categories as c
 Inner Join dbo.Products as p
   On c.CategoryID = p.CategoryID
Order by CategoryName, ProductName
Go
Select * from vProductPrices 

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,UnitPrice
-- Beverages,Chai,18.00
-- Beverages,Chang,19.00
-- Beverages,Chartreuse verte,18.00


-- Question 4 (10 pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

Create view vProductCounts
With Schemabinding
As
Select Top 100000
 ProductName, InventoryDate, Count
 From dbo.Inventories as i
 Inner Join dbo.Products as p
   On p.ProductID = i.ProductID
Order by ProductName, InventoryDate, Count
Go
Select * from vProductCounts

-- Here is an example of some rows selected from the view:
--ProductName,InventoryDate,Count
--Alice Mutton,2017-01-01,15
--Alice Mutton,2017-02-01,78
--Alice Mutton,2017-03-01,83


-- Question 5 (10 pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

Create view vEmployeeLog
With Schemabinding
As
Select Distinct Top 100000
  InventoryDate, EmployeeFirstName +' ' + EmployeeLastname as EmployeeName 
 From dbo.Inventories as i
 Inner Join dbo.Employees as e
   On e.EmployeeID = i.EmployeeID
Order by inventorydate
Go
Select * from vEmployeeLog 

/*
GO
CREATE VIEW vInventoriesByEmployeesByDates
WITH SCHEMABINDING
AS
SELECT TOP 100000
DISTINCT(i.InventoryDate),
   e.EmployeeID,
   e.EmployeeFirstName,
   e.EmployeeLastName
FROM dbo.Inventories AS i
INNER JOIN dbo.Employees AS e
   ON e.EmployeeID = i.EmployeeID
ORDER BY i.InventoryDate
GO
*/

-- Here is an example of some rows selected from the view:
-- InventoryDate,EmployeeName
-- 2017-01-01,Steven Buchanan
-- 2017-02-01,Robert King
-- 2017-03-01,Anne Dodsworth


-- Question 6 (10 pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

Create view vInventoryLog
With Schemabinding
As
Select Top 100000
 CategoryName, ProductName, InventoryDate, Count
 From dbo.Categories as c
 Inner Join dbo.Products as p
   On c.CategoryID = p.CategoryID
 Inner Join dbo.Inventories as i
   On p.ProductID = i.ProductID
Order by 1, 2, 3, 4
Go
Select * from vInventoryLog 
Go


-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- Beverages,Chai,2017-01-01,72
-- Beverages,Chai,2017-02-01,52
-- Beverages,Chai,2017-03-01,54


-- Question 7 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

Create View vEmployeeInventoryLog
With Schemabinding
As
Select Top 100000 
 CategoryName, ProductName, InventoryDate, Count, EmployeeFirstName +' ' + EmployeeLastname as EmployeeName
 From dbo.Categories as c
 Inner Join dbo.Products as p
   On c.CategoryID = p.CategoryID
 Inner Join dbo.Inventories as i
   On p.ProductID = i.ProductID
 Inner Join dbo.Employees as e
   On e.EmployeeID = i.EmployeeID
Order by 3, 1, 2, 5, 4
Go
Select * From vEmployeeInventoryLog 

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chartreuse verte,2017-01-01,61,Steven Buchanan


-- Question 8 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

--drop view vChaiAndChang

Create View vChaiAndChang
With Schemabinding 
As 
Select Top 100000 
 CategoryName, ProductName, InventoryDate, Count, EmployeeFirstName +' ' + EmployeeLastname as EmployeeName
 From dbo.Categories as c
 Inner Join dbo.Products as p
   On c.CategoryID = p.CategoryID
 Inner Join dbo.Inventories as i
   On p.ProductID = i.ProductID
 Inner Join dbo.Employees as e
   On e.EmployeeID = i.EmployeeID
    Where p.ProductID in 
     (Select ProductID 
      From dbo.Products 
      Where ProductName = 'chai' or ProductName = 'chang')
Order by 3, 1, 2, 5, 4
Go
Select * From vChaiAndChang 
Go

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chai,2017-02-01,52,Robert King


-- Question 9 (10 pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

Create View vReportsTo
With Schemabinding
As
Select Top 100000 
  [Manager] = IIF(IsNull(m.EmployeeId, 0) = 0, 'General Manager', m.EmployeeFirstName + ' ' + m.EmployeeLastName),
  [Employee] =  e.EmployeeFirstName + ' ' + e.EmployeeLastName 
 From dbo.Employees as e
 Inner Join dbo.Employees as m
   On e.ManagerID = m.EmployeeID 
Order By 1, 2
Go
Select * From vReportsTo 

-- Here is an example of some rows selected from the view:
-- Manager,Employee
-- Andrew Fuller,Andrew Fuller
-- Andrew Fuller,Janet Leverling
-- Andrew Fuller,Laura Callahan


-- Question 10 (10 pts): How can you create one view to show all the data from all four 
-- BASIC Views?

--Select * From Categories;
--Columns: CategoryID, CategoryName

--Select * From Products;
--Columns: ProductID, ProductName, CategoryID, UnitPrice

--Select * From Employees;
--Columns: EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID

--Select * From Inventories;
--Columns: InventoryID, InventoryDate, EmployeeID, ProductID, Count


Create View vAllStoreData
With Schemabinding
As
 Select 
	p.CategoryID, 
	CategoryName, 
	p.ProductID, 
	ProductName, 
	UnitPrice, 
	e.EmployeeID, 
	EmployeeFirstName, 
	EmployeeLastName, 
	ManagerID, 
	InventoryID, 
	InventoryDate, 
	Count 
 From dbo.vCategories as c
 Inner Join dbo.vProducts as p
	On c.CategoryID = p.CategoryID
 Inner Join dbo.vInventories as i
	On p.ProductID = i.ProductID
 Inner Join dbo.vEmployees as e
	On i.EmployeeID = e.EmployeeID
Go
Select * From vAllStoreData
--nope



-- Here is an example of some rows selected from the view:
-- CategoryID,CategoryName,ProductID,ProductName,UnitPrice,InventoryID,InventoryDate,Count,EmployeeID,Employee,Manager
-- 1,Beverages,1,Chai,18.00,1,2017-01-01,72,5,Steven Buchanan,Andrew Fuller
-- 1,Beverages,1,Chai,18.00,78,2017-02-01,52,7,Robert King,Steven Buchanan
-- 1,Beverages,1,Chai,18.00,155,2017-03-01,54,9,Anne Dodsworth,Steven Buchanan

-- Test your Views (NOTE: You must change the names to match yours as needed!)
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductPrices]
Select * From [dbo].[vProductCounts]
Select * From [dbo].[vEmployeeLog]
Select * From [dbo].[vInventoryLog]
Select * From [dbo].[vEmployeeInventoryLog]
Select * From [dbo].[vChaiAndChang]
Select * From [dbo].[vReportsTo]
Select * From [dbo].[vAllStoreData]
/***************************************************************************************/