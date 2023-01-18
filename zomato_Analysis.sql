drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
(3,'04-21-2017');

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);

drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

--total amount each customer spend on zomato

select a.userid,sum(b.price) as total_amount--,b.price
from sales a inner join product b
on a.product_id=b.product_id
group by a.userid

--how many days each customer visited zomato

select userid,COUNT( distinct created_date) as distinct_date
from sales
group by userid

--what was the first product purchased by each customer

select * from(
select *, RANK() over(partition by userid order by created_date)rnk from sales) a
where a.rnk=1

--what is the most purchased item on the menu & how many times was it purchased by all customers

select userid,count(product_id) as cnt from
sales where product_id=
(select top 1 product_id
from sales
group by product_id
order by COUNT(product_id) desc)
group by userid

--what item was most popular for each customer
select * from
(select *,
rank() over(partition by userid order by cnt desc) rnk
from 
(select userid,product_id,count(product_id) as cnt
from sales
group by userid,product_id) a) b
where rnk =1

--which itm was first purchsed by the customer after they became member

select * from
(select a.*,
RANK() over(partition by userid order by created_date) rnk
from(
select a.userid,b.product_id,a.gold_signup_date,b.created_date
from goldusers_signup a
inner join sales b
on a.userid=b.userid and created_date>=gold_signup_date) a)b
where rnk=1

--which item was purchased just before customer became member

select * from
(select a.*,
RANK() over(partition by userid order by created_date desc) rnk
from(
select a.userid,b.product_id,a.gold_signup_date,b.created_date
from goldusers_signup a
inner join sales b
on a.userid=b.userid and created_date<=gold_signup_date) a)b
where rnk=1

--what is the total order and amount spend for each memeber before they became a member

select userid,count(created_date) as order_purchased,sum(price) as tptal_amt_spend from
(
select c.*,d.price from
(select a.userid,b.product_id,a.gold_signup_date,b.created_date
from goldusers_signup a
inner join sales b
on a.userid=b.userid and created_date<=gold_signup_date)c inner join product d on c.product_id=d.product_id)e
group by userid

--if buying each product generates points for eg 5rs=2 points and each product has different point p1 5rs=1point, p2 10rs=5point and p3 5rs=1point
--calculate point collected by each customer

select e.*,amt/point as total_points
from(select d.*,
case when product_id=1 then 5
	when product_id=2 then 2
	when product_id=3 then 5
	else 0 end as point 
from(select c.userid,c.product_id,sum(price) as amt 
from(select a.*,b.price from sales a inner join product b on a.product_id=b.product_id)c
group by userid,product_id)d)e

--rank all transaction for each memberwhen they are gold member, for every non gold member mark as 'na'


select e.*,case when rnk=0 then'na' else rnk end as rnkk from(
select c.*,cast((case when gold_signup_date is null then 0 else rank() over(partition by userid order by created_date desc) end)as varchar) as rnk from
(select a.userid,a.created_date,a.product_id,b.gold_signup_date
from sales a
left join goldusers_signup b
on a.userid=b.userid and created_date>=gold_signup_date)c)e





