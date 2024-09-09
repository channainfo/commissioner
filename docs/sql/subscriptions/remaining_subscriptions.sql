WITH
partition_orders AS (
	SELECT id,number, subscription_id, rank() OVER (PARTITION BY subscription_id ORDER BY id DESC) FROM spree_orders
	WHERE subscription_id IS NOT NULL
),

last_orders as (
SELECT  id, number,subscription_id,rank FROM partition_orders where rank = 1
),

remain_subscriptions AS (
    SELECT * FROM cm_subscriptions AS s
        INNER JOIN last_orders AS o ON o.subscription_id = s.id
        INNER JOIN spree_line_items AS l ON l.order_id = o.id
    WHERE l.to_date < Now()
)

SELECT * from remain_subscriptions