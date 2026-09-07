-- Viste di analisi --
-- Eseguito automaticamente da notebook/02-ETL.ipynb dopo il caricamento delle
-- tabelle. In alternativa, a mano: psql -d olist -f sql/analisi.sql

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

--5. KPI generali (le quattro metriche in testa alla dashboard)
--   L'universo è quello dei clienti con almeno un ordine fatturato:
--   il join con order_items esclude gli ordini senza righe di dettaglio.
create or replace view v_kpi_generali as
select round(sum(i.price::numeric),2) as fatturato,
       count(distinct i.order_id) as ordini,
       count(distinct c.customer_unique_id) as clienti
from order_items as i
join orders as o on o.order_id=i.order_id
join customers as c on c.customer_id=o.customer_id;

--6. Retention: quota di clienti che hanno acquistato più di una volta
create or replace view v_retention as
with ordini_per_cliente as (
    select c.customer_unique_id, count(distinct o.order_id) as n_ordini
    from customers as c
    join orders as o on o.customer_id=c.customer_id
    join order_items as i on i.order_id=o.order_id
    group by c.customer_unique_id
)
select count(*) as clienti,
       count(*) filter (where n_ordini>1) as clienti_ricorrenti,
       round(100.0*count(*) filter (where n_ordini>1)/count(*),2) as pct_retention
from ordini_per_cliente;

--7. Impatto dei ritardi di consegna sulla soddisfazione
--   Solo ordini effettivamente consegnati: il ritardo è definito rispetto
--   alla data di consegna stimata comunicata al cliente.
create or replace view v_consegne_recensioni as
select case when o.order_delivered_customer_date>o.order_estimated_delivery_date
            then 'In ritardo' else 'In orario' end as consegna,
       count(*) as n_recensioni,
       round(avg(r.review_score)::numeric,2) as voto_medio
from orders as o
join order_reviews as r on r.order_id=o.order_id
where o.order_delivered_customer_date is not null
group by consegna
order by voto_medio desc;
