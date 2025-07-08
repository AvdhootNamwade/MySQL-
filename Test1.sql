SHOW DATABASES;
CREATE DATABASE db1;
USE db1;

CREATE TABLE pizza_types (
pizza_type_id VARCHAR(100) PRIMARY KEY,
name VARCHAR(255),
category VARCHAR(255),
ingredients VARCHAR(255)
);

CREATE TABLE pizzas (
pizza_id VARCHAR(100) PRIMARY KEY,
pizza_type_id VARCHAR(100),
size VARCHAR(50),
price DECIMAL(10,2),
FOREIGN KEY (pizza_type_id) REFERENCES pizza_types (pizza_type_id)
);


CREATE TABLE orders (
order_id INT PRIMARY KEY,
date DATE,
time TIME
);

CREATE TABLE order_details (
order_details_id INT PRIMARY KEY,
order_id INT,
pizza_id VARCHAR(100),
quantity INT,
FOREIGN KEY (order_id) REFERENCES orders(order_id),
FOREIGN KEY (pizza_id) REFERENCES pizzas(pizza_id)
);

SET GLOBAL local_infile=1; 


LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\pizza_types.csv"
INTO TABLE pizza_types
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\pizzas.csv"
INTO TABLE pizzas
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\orders.csv"
INTO TABLE orders
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\order_details.csv"
INTO TABLE order_details
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from orders;
select * from pizza_types;

SELECT COUNT(order_id) FROM orders; -- Total Orders

SELECT DISTINCT SUM(price) FROM pizzas p RIGHT JOIN order_details od ON p.pizza_id = od.pizza_id; -- Total revenue

SELECT pizza_id FROM pizzas ORDER BY price DESC LIMIT 1; -- Highest Priced

SELECT DISTINCT size, count(size) FROM pizzas GROUP BY size ORDER BY COUNT(size) DESC LIMIT 1; -- Most Common Pizza Size

SELECT DISTINCT pizza_type_id, count(size) FROM pizzas GROUP BY pizza_type_id ORDER BY COUNT(pizza_type_id) DESC LIMIT 5; -- Top 5 Orderes Pizza Type

SELECT HOUR(time),COUNT(order_id) FROM orders GROUP BY HOUR(time); -- Order By Hour

SELECT DISTINCT pizza_type_id,SUM(price) FROM pizzas p RIGHT JOIN order_details od ON p.pizza_id = od.pizza_id GROUP BY pizza_type_id; -- Top 3 orders based on revenue

SELECT DISTINCT category,count(category) FROM pizza_types pt RIGHT JOIN pizzas p  ON pt.pizza_type_id = p.pizza_type_id  GROUP BY  category;

SELECT category,COUNT() FROM pizza_types pt RIGHT JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id WHERE p.pizza_id IN
(SELECT p.pizza_id FROM pizzas p RIGHT JOIN order_details od ON p.pizza_id = od.pizza_id);

SELECT quantity,category FROM (SELECT * FROM pizzas p RIGHT JOIN order_details od ON p.pizza_id = od.pizza_id) AS t1
JOIN (SELECT * FROM pizza_types pt RIGHT JOIN pizzas p1 ON pt.pizza_type_id = p.pizza_type_id) AS t2 ON p.pizza_id = p1.pizza_id; 

select name, revenue 
from
(select category,name,revenue,
rank() over (partition by category order by revenue desc)as 
rn
from
(select pizza_types.category,pizza_types.name,
sum((order_details.quantity)*pizzas.price) as revenue
from pizza_types join pizzas
on 
pizza_types.pizza_type_id= pizzas.pizza_type_id
join 
order_details
on order_details.pizza_id = pizzas.pizza_id
group by 
pizza_types.category, pizza_types.name) as a ) as b
where rn <=3;