create or replace view v_rfm_segmenti as(
with rfm as (
select c.customer_unique_id as identificatore_cliente,
	   (select max(order_purchase_timestamp) from orders)::date
	   -max(o.order_purchase_timestamp)::date as recency,
	   count(distinct c.customer_id) as frequency,
	   round(sum(i.price)::numeric,2) as monetary
from customers as c
join orders as o on o.customer_id=c.customer_id
join order_items as i on i.order_id=o.order_id
group by c.customer_unique_id
),
scores as (
select identificatore_cliente, recency, frequency,monetary, 
		ntile(5) over (order by monetary) as m_score,
		ntile(5) over (order by recency desc) as r_score,
		CASE
    		WHEN frequency = 1 THEN 1
    		WHEN frequency = 2 THEN 3
    		ELSE 5
		END AS f_score
from rfm
),
segmenti as
(select identificatore_cliente, r_score,f_score, m_score,
		case
			when f_score=3 then 'Fedeli (rari)'
			when m_score>=4 and r_score>=4 then 'Campioni'
			when m_score>=4 and r_score <=2 then 'A rischio'
			when m_score<=2 and r_score>=4 then 'Nuovi/Promettenti'
			when m_score<=2 and r_score<=2 then 'Persi/Basso valore'
			else 'Nel mezzo'
		end as segmento
from scores
)

select segmento, count(*) as n_clienti,
	   round(100.0 * count(*)/(select count(*) from segmenti),2) as pct
from segmenti
group by segmento
order by n_clienti desc
);