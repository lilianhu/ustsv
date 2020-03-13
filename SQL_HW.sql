USE `classicmodels`;


/* ---Single entity--- */


/* 1. Prepare a list of offices sorted by country, state, city. */
Select country, state, city
From offices; 

/* 2. How many employees are there in the company? */
Select count(distinct(employeeNumber)) as num
From employees;

/* 3. What is the total of payments received? */
Select sum(amount) as totalPayments
From payments;

/* 4. List the product lines that contain 'Cars'. */
Select productLine
From productlines
Where productline Like '%Cars%';

/* 5. Report total payments for October 28, 2004. */
Select sum(amount) as totoalPaymenys
From payments
Where paymentdate='2004-10-28';

/* 6. Report those payments greater than $100,000. */
Select *
From payments
Having amount > 100000;

/* 7. List the products in each product line. */
Select *
From products
Order By productline;

/* 8. How many products in each product line? */
Select count(distinct(productCode)), productline
From products
Group By productline;

/* 9. What is the minimum payment received? */
Select min(amount)
From payments;

/* 10. List all payments greater than twice the average payment. */
Select *
From payments p,
    (
      Select 2*avg(amount) as twiceAverage
      From payments
	 ) as A
Having amount > twiceAverage;

/* 11. What is the average percentage markup of the MSRP on buyPrice? */
Select avg((MSRP-buyprice)/buyprice)*100
From products;

/* 12. How many distinct products does ClassicModels sell? */
Select distinct(productCode)
From orderdetails;

/* 13. Report the name and city of customers who don't have sales representatives? */
Select customerName, city
From customers
Where salesRepEmployeeNumber is null;

/* 14. What are the names of executives with VP or Manager in their title? 
Use the CONCAT function to combine the employee's first name and last name 
into a single field for reporting. */
Select Concat(firstname,' ',lastname) as Ename, jobTitle
From employees
Where jobTitle Like '%VP%' Or jobTitle Like '%Manager%';

/* 15. Which orders have a value greater than $5,000? */
Select *
From orderdetails
Having quantityOrdered*priceEach > 5000;


/* ---One to many relationship--- */


/* 1. Report the account representative for each customer. */
Select c.customerNumber, c.customerName, c.salesRepEmployeeNumber, 
       Concat(firstname,' ',lastname) as Ename
From customers c, employees e
Where c.salesRepEmployeeNumber = e.employeeNumber;

/* 2. Report total payments for Atelier graphique. */
Select sum(p.amount) as totalPayment
From customers c, payments p
Where c.customerNumber = p.customerNumber And c.customerName = 'Atelier graphique';

/* 3. Report the total payments by date */
Select sum(p.amount), o.orderDate
From payments p, customers c, orders o
Where p.customerNumber = c.customerNumber And c.customerNumber = o.customerNumber
Group By orderDate;

/* 4. Report the products that have not been sold. */
Select p.productCode, p.productName
From products p
Where p.productCode Not In (Select o.productCode From orderdetails o);

/* 5. List the amount paid by each customer. */
Select c.customerNumber, c.customerName, sum(p.amount)
From customers c, payments p
Where c.customerNumber = p.customerNumber
Group By c.customerNumber;

/* 6. How many orders have been placed by Herkku Gifts? */
Select count(o.orderNumber)
From orders o, customers c
Where c.customerNumber = o.customerNumber
And c.customerName = 'Herkku Gifts';

/* 7. Who are the employees in Boston? */
Select e.employeeNumber, Concat(e.firstname,' ',e.lastname) as Ename, o.city
From employees e, offices o
Where e.officeCode = o.officeCode And o.city = 'Boston';

/* 8. Report those payments greater than $100,000. 
Sort the report so the customer who made the highest payment appears first. */
Select c.customerName, p.amount
From customers c, payments p
Where c.customerNumber = p.customerNumber
Having p.amount > 100000
Order By p.amount desc;

/* 9. List the value of 'On Hold' orders. */
Select od.quantityOrdered * od.priceEach as value, o.status
From orderdetails od, orders o
Where od.orderNumber = o.orderNumber And o.status = 'On Hold';

/* 10. Report the number of orders 'On Hold' for each customer. */
Select c.customerNumber, c.customerName, count(o.orderNumber) as num
From customers c, orders o
Where c.customerNumber = o.customerNumber And o.status = 'On Hold'
Group By c.customerNumber;


/* ---Many to many relationship--- */


/* 1. List products sold by order date.*/
Select p.productCode, p.productName, p.productLine, od.orderNumber, o.orderDate
From products p, orderdetails od, orders o
Where p.productCode = od.productCode And od.orderNumber = o.orderNumber
Order By o.orderdate;

/* 2. List the order dates in descending order for orders for the 1940 Ford Pickup Truck. */
Select p.productCode, p.productName, o.orderDate
From products p, orderdetails od, orders o
Where p.productCode = od.productCode And od.orderNumber = o.orderNumber
And p.productName = '1940 Ford Pickup Truck'
Order By o.orderdate desc;

/* 3. List the names of customers and their corresponding order number 
where a particular order from that customer has a value greater than $25,000?*/
Select c.customerName, o.orderNumber, p.amount
From customers c, orders o, payments p
Where c.customerNumber = o.customerNumber And c.customerNumber = p.customerNumber
Having p.amount > 25000;

/* 4. Are there any products that appear on all orders? */
Select p.productCode, p.productName
From products p
Right Join orderdetails o On p.productCode = o.productCode
Where p.productCode = All (Select productCode From orderdetails Group By orderNumber);

/* 5. List the names of products sold at less than 80% of the MSRP. */
Select p.productCode, p.productName
From products p, orderdetails o
Where p.productCode = o.productCode And o.priceEach < (.8*p.MSRP);

/* 6. Reports those products that have been sold with a markup of 100% or more 
(i.e.,  the priceEach is at least twice the buyPrice) */
Select p.productCode, p.productName, o.orderNumber, o.priceEach, p.buyPrice
From products p, orderdetails o
Where p.productCode = o.productCode And o.priceEach >= (2*p.buyPrice);

/* 7. List the products ordered on a Monday. */
Select p.productName, o.orderDate
From products p, orderdetails od, orders o
Where p.productCode = od.productCode And od.orderNumber = o.orderNumber
And dayofweek(o.orderDate) = 2;

/* 8. What is the quantity on hand for products listed on 'On Hold' orders?  */
Select p.productName, sum(od.quantityOrdered), o.status
From orderdetails od, products p, orders o
Where p.productCode = od.productCode And od.orderNumber = o.orderNumber And o.status = 'On Hold'
Group By p.productCode;


/* ---Regular expressions--- */


/* 1. Find products containing the name 'Ford'. */
Select productCode, productName
From products
Where productName Like '%Ford%';

/* 2. List products ending in 'ship'. */
Select productCode, productName
From products
Where productName Like '%ship';

/* 3. Report the number of customers in Denmark, Norway, and Sweden. */
Select count(customerNumber), country
From customers
Where country In ('Denmark', 'Norway', 'Sweden')
Group By country;

/* 4. What are the products with a product code in the range S700_1000 to S700_1499? */
Select productCode, productName
From products
Where productCode Regexp 'S700_1[0-4][0-9][0-9]';

/* 5. Which customers have a digit in their name? */
Select *
From customers
Where customerName Regexp '[0-9]';

/* 6. List the names of employees called Dianne or Diane. */
Select *
From Employees
Where lastName Regexp 'Dianne|Diane' Or firstName Regexp 'Dianne|Diane';

/* 7. List the products containing ship or boat in their product name. */
Select *
From products
Where productName Regexp 'ship|boat';

/* 8. List the products with a product code beginning with S700. */
Select *
From products
Where productCode Regexp '^S700';

/* 9. List the names of employees called Larry or Barry. */
Select *
From Employees
Where lastName Regexp 'Larry|Barry' Or firstName Regexp 'Larry|Barry';

/* 10. List the names of employees with non-alphabetic characters in their names. */
Select *
From Employees
Where lastname Regexp '\W' Or firstname Regexp '\W';

/* 11. List the vendors whose name ends in Diecast */
Select *
From products
Where productVendor Regexp 'Diecast$';


/* ---General queries--- */


/* 1. Who is at the top of the organization (i.e.,  reports to no one). */
Select *
From employees
Where reportsTo is Null;

/* 2. Who reports to William Patterson? */
Select *
From employees e1
Left Join employees e2 On e1.reportsTo = e2.employeeNumber
Where Concat(e2.firstname,' ',e2.lastname) = 'William Patterson';

/* 3. List all the products purchased by Herkku Gifts. */
Select p.productName, c.customerName
From products p, customers c, orderdetails od, orders o
Where p.productCode = od.productCode And od.orderNumber = o.orderNumber
      And  o.customerNumber = c.customerNumber
And c.customerName = 'Herkku Gifts';

/* 4. Compute the commission for each sales representative, 
assuming the commission is 5% of the value of an order. 
Sort by employee last name and first name. */
Select e.lastname, e.firstname, sum(0.05 * p.amount) As commission
From customers c
Left Join employees e On c.salesRepEmployeeNumber = e.employeeNumber
Left Join payments p On c.customerNumber = p.customerNumber
Group By c.salesRepEmployeeNumber
Order By e.lastname, e.firstname;

/* 5. What is the difference in days between the most recent and oldest order date 
in the Orders file? */
Select max(orderDate), min(orderDate), datediff(max(orderDate), min(orderDate)) As diff
From orders;

/* 6. Compute the average time between order date and ship date for each customer 
ordered by the largest difference. */
Select avg(datediff(shippedDate,orderDate)) As diff
From orders
Group By customerNumber
Order By diff desc;

/* 7. What is the value of orders shipped in August 2004? (Hint). */
SELECT SUM(od.quantityOrdered * od.priceEach) AS value_of_orders
FROM ClassicModels.OrderDetails od
LEFT JOIN ClassicModels.Orders o ON od.orderNumber = o.orderNumber
WHERE o.shippedDate LIKE '2004-08%'
GROUP BY o.shippedDate;

/* 8. Compute the total value ordered, total amount paid, 
and their difference for each customer for orders placed in 2004 and payments received in 2004 
(Hint; Create views for the total paid and total ordered). */


/* 9. List the employees who report to those employees who report to Diane Murphy. 
Use the CONCAT function to combine the employee's first name and last name 
into a single field for reporting. */


/* 10. What is the percentage value of each product in inventory sorted by the highest percentage first 
(Hint: Create a view first). */




/* 11.  */


/* 12.  */


/* 13.  */


/* 14.  */


/* 15.  */


/* 16.  */


/* 17.  */


/* 18.  */


/* 19.  */


/* 20.  */


/* 1.  */


/* 2.  */


/* 3.  */


/* 4.  */


/* 5.  */


/* 6.  */


/* 7.  */


/* 8.  */


/* 9.  */


/* 10.  */

