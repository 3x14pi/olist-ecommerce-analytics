-- Viste di analisi --

--1. Fatturato per categoria
create or replace view v_fatturato_categoria as
select t.product_category_name_english, round(sum(o.price::numeric),2) as fatturato
from order_items as o
join products as p on o.product_id=p.product_id
join category_translation as t on p.product_category_name=t.product_category_name
group by t.product_category_name_english
order by fatturato desc;

--2. Fatturato mensile
create or replace view v_fatturato_mensile as
select date_trunc('month',o.order_purchase_timestamp) as mese, round(sum(i.price::numeric),2) as fatturato
from order_items as i
join orders as o on i.order_id=o.order_id
group by mese
order by mese;

--3. Fatturato per stato
create or replace view v_fatturato_per_stato as
select c.customer_state as stato, round(sum(i.price::numeric),2) as fatturato
from order_items as i
join orders as o on o.order_id=i.order_id
join customers as c on c.customer_id=o.customer_id
group by stato
order by fatturato desc;

--4. Ordini per cliente
create or replace view v_ordini_per_cliente as
select c.customer_unique_id, count(c.customer_id) as Numero_di_acquisti
from orders as o
join customers as c on o.customer_id=c.customer_id
group by c.customer_unique_id;


