create or replace view v_rfm_segmenti as (
with rfm as (
    select c.customer_unique_id as identificatore_cliente,
           (select max(order_purchase_timestamp) from orders)::date
             - max(o.order_purchase_timestamp)::date as recency,
           count(distinct o.order_id) as frequency,
           round(sum(i.price)::numeric, 2) as monetary
    from customers as c
    join orders as o on o.customer_id = c.customer_id
    join order_items as i on i.order_id = o.order_id
    group by c.customer_unique_id
),
scores as (
    select identificatore_cliente, recency, frequency, monetary,
           ntile(5) over (order by monetary) as m_score,
           ntile(5) over (order by recency desc) as r_score,
           case
               when frequency = 1 then 1
               when frequency = 2 then 3
               else 5
           end as f_score
    from rfm
),
segmenti as (
    select identificatore_cliente, r_score, f_score, m_score, monetary,
           case
               when f_score >= 3 then 'Fedeli (rari)'
               when m_score >= 4 and r_score >= 4 then 'Campioni'
               when m_score >= 4 and r_score <= 2 then 'A rischio'
               when m_score <= 2 and r_score >= 4 then 'Nuovi/Promettenti'
               when m_score <= 2 and r_score <= 2 then 'Persi/Basso valore'
               else 'Nel mezzo'
           end as segmento
    from scores
)
select segmento,
       count(*) as n_clienti,
       round(100.0 * count(*) / (select count(*) from segmenti), 2) as pct_clienti,
       round(sum(monetary), 2) as fatturato,
       round(100.0 * sum(monetary) / (select sum(monetary) from segmenti), 2) as pct_fatturato
from segmenti
group by segmento
order by fatturato desc
);
