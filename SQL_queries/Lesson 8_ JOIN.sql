-- Урок 8. JOIN (соединения)

--8.1. Объедините таблицы user_actions и users по ключу user_id. В результат включите две колонки с user_id из обеих таблиц.
-- Эти две колонки назовите соответственно user_id_left и user_id_right. 
-- Также в результат включите колонки order_id, time, action, sex, birth_date. 
-- Отсортируйте получившуюся таблицу по возрастанию id пользователя (в любой из двух колонок с id).
-- Поля в результирующей таблице: user_id_left, user_id_right,  order_id, time, action, sex, birth_date

SELECT us_a.user_id AS user_id_left, us_i.user_id AS user_id_right,  order_id, time, action, sex, birth_date
FROM user_actions us_a JOIN users us_i ON us_a.user_id= us_i.user_id
ORDER BY us_a.user_id;

--8.2. Необходимо посчитать количество уникальных id в объединённой таблице.
-- То есть снова объедините таблицы, но в этот раз просто посчитайте уникальные user_id в одной из колонок с id.
-- Выведите это количество в качестве результата. Колонку с посчитанным значением назовите users_count.
-- Поле в результирующей таблице: users_count

SELECT COUNT(DISTINCT us_a.user_id) AS users_count
FROM user_actions us_a JOIN users us_i ON us_a.user_id= us_i.user_id;

-- 8.3. С помощью LEFT JOIN объедините таблицы user_actions и users по ключу user_id. 
-- В результат включите две колонки с user_id из обеих таблиц. 
-- Эти две колонки назовите соответственно user_id_left и user_id_right. 
-- Также в результат включите колонки order_id, time, action, sex, birth_date. 
-- Отсортируйте получившуюся таблицу по возрастанию id пользователя (в колонке из левой таблицы).
-- Поля в результирующей таблице: user_id_left, user_id_right,  order_id, time, action, sex, birth_date

SELECT us_a.user_id AS user_id_left, us_i.user_id AS user_id_right,  order_id, time, action, sex, birth_date
FROM user_actions us_a LEFT JOIN users us_i ON us_a.user_id= us_i.user_id
ORDER BY us_a.user_id;

-- 8.4. Теперь снова попробуйте немного переписать запрос из прошлого задания и посчитайте количество уникальных id в колонке user_id,
-- пришедшей из левой таблицы user_actions. Выведите это количество в качестве результата. 
-- Колонку с посчитанным значением назовите users_count.
-- Поле в результирующей таблице: users_count

SELECT COUNT(DISTINCT us_a.user_id) AS users_count
FROM user_actions us_a LEFT JOIN users us_i ON us_a.user_id= us_i.user_id;

--8.5. Возьмите запрос из задания 3, где вы объединяли таблицы user_actions и users с помощью LEFT JOIN, 
-- добавьте к запросу оператор WHERE и исключите NULL значения в колонке user_id из правой таблицы.
-- Включите в результат все те же колонки и отсортируйте получившуюся таблицу по возрастанию id пользователя в колонке из левой таблицы.
-- Поля в результирующей таблице: user_id_left, user_id_right,  order_id, time, action, sex, birth_date

SELECT us_a.user_id AS user_id_left, us_i.user_id AS user_id_right,  order_id, time, action, sex, birth_date
FROM user_actions us_a LEFT JOIN users us_i ON us_a.user_id= us_i.user_id
WHERE  us_i.user_id IS NOT NULL
ORDER BY us_a.user_id;

-- 8.6. С помощью FULL JOIN объедините по ключу birth_date таблицы.
-- В результат включите две колонки с birth_date из обеих таблиц. 
-- Эти две колонки назовите соответственно users_birth_date и couriers_birth_date.
-- Также включите в результат колонки с числом пользователей и курьеров — users_count и couriers_count. 
-- Отсортируйте получившуюся таблицу сначала по колонке users_birth_date по возрастанию,
-- затем по колонке couriers_birth_date — тоже по возрастанию.
-- Поля в результирующей таблице: users_birth_date, users_count,  couriers_birth_date, couriers_count

WITH users_table AS (
    SELECT
        birth_date,
        COUNT(user_id) AS users_count
    FROM
        users
    WHERE
        birth_date IS NOT NULL
    GROUP BY
        birth_date
    ),
    couriers_table AS (
    SELECT
        birth_date,
        COUNT(courier_id) AS couriers_count
    FROM
        couriers
    WHERE
        birth_date IS NOT NULL
    GROUP BY
        birth_date
    )

SELECT
    users_table.birth_date AS users_birth_date,
    users_count,
    couriers_table.birth_date AS couriers_birth_date,
    couriers_count
FROM
    users_table
FULL JOIN
    couriers_table
        ON users_table.birth_date = couriers_table.birth_date
ORDER BY
    users_birth_date ASC,
    couriers_birth_date ASC;
    
--8.7. Объедините два следующих запроса друг с другом так, чтобы на выходе получился набор уникальных дат из таблиц users и couriers.
-- Поместите в подзапрос полученный после объединения набор дат и посчитайте их количество. Колонку с числом дат назовите dates_count.
-- Поле в результирующей таблице: dates_count

SELECT COUNT(birth_date) AS dates_count
FROM
(
    SELECT birth_date
    FROM users
    WHERE birth_date IS NOT NULL
    UNION
    SELECT birth_date
    FROM couriers
    WHERE birth_date IS NOT NULL
) as t;

--8.8. Из таблицы users отберите id первых 100 пользователей (просто выберите первые 100 записей, используя простой LIMIT)
-- и с помощью CROSS JOIN объедините их со всеми наименованиями товаров из таблицы products. 
-- Выведите две колонки — id пользователя и наименование товара. 
-- Результат отсортируйте сначала по возрастанию id пользователя, затем по имени товара — тоже по возрастанию.
-- Поля в результирующей таблице: user_id, name

SELECT user_id, name
FROM 
(SELECT user_id FROM users LIMIT 100) AS t
CROSS JOIN 
(SELECT name FROM products) AS t1
ORDER BY user_id, name;

--8.9. Для начала объедините таблицы user_actions и orders.
-- В качестве ключа используйте поле order_id. Выведите id пользователей и заказов, а также список товаров в заказе.
-- Отсортируйте таблицу по id пользователя по возрастанию, затем по id заказа — тоже по возрастанию.
-- Добавьте в запрос оператор LIMIT и выведите только первые 1000 строк результирующей таблицы.
-- Поля в результирующей таблице: user_id, order_id, product_ids

SELECT user_id, a.order_id, product_ids
FROM user_actions a LEFT JOIN orders b ON a.order_id = b.order_id
ORDER BY user_id, a.order_id
LIMIT 1000;

--8.10. Объедините таблицы user_actions и orders, но теперь оставьте только уникальные неотменённые заказы.
-- Остальные условия задачи те же: вывести id пользователей и заказов, а также список товаров в заказе. 
-- Отсортируйте таблицу по id пользователя по возрастанию, затем по id заказа — тоже по возрастанию.
-- Добавьте в запрос оператор LIMIT и выведите только первые 1000 строк результирующей таблицы.
-- Поля в результирующей таблице: user_id, order_id, product_ids

WITH orders_not_cancel AS (SELECT DISTINCT order_id
                           FROM   user_actions
                           WHERE  action = 'cancel_order')

SELECT user_id, user_actions.order_id, product_ids
FROM user_actions LEFT JOIN orders USING(order_id)
WHERE order_id NOT IN (SELECT order_id FROM orders_not_cancel)
ORDER BY user_id, user_actions.order_id
LIMIT 1000;

--8.11. Используя запрос из предыдущего задания, посчитайте, сколько в среднем товаров заказывает каждый пользователь.
-- Выведите id пользователя и среднее количество товаров в заказе.
-- Среднее значение округлите до двух знаков после запятой. 
-- Колонку посчитанными значениями назовите avg_order_size. Результат выполнения запроса отсортируйте по возрастанию id пользователя. 
-- Добавьте в запрос оператор LIMIT и выведите только первые 1000 строк результирующей таблицы.
-- Поля в результирующей таблице: user_id, avg_order_size

WITH orders_not_cancel AS (SELECT DISTINCT order_id
                           FROM   user_actions
                           WHERE  action = 'cancel_order')

SELECT user_id, ROUND(AVG(array_length(product_ids, 1)), 2) AS avg_order_size
FROM user_actions LEFT JOIN orders USING(order_id)
WHERE order_id NOT IN (SELECT order_id FROM orders_not_cancel)
GROUP BY user_id
ORDER BY user_id
LIMIT 1000;

-- или 

SELECT user_id,
       ROUND(AVG(array_length(product_ids, 1)), 2) AS avg_order_size
FROM   (SELECT user_id,
               order_id
        FROM   user_actions
        WHERE  order_id NOT in (SELECT order_id
                                FROM   user_actions
                                WHERE  action = 'cancel_order')) t
LEFT JOIN orders using(order_id)
GROUP BY user_id
ORDER BY user_id LIMIT 1000;

--8.12. А что если бы мы захотели посчитать среднюю стоимость заказа (средний чек) каждого клиента?
-- Для начала к таблице с заказами (orders) нужно применить функцию unnest. 
-- Колонку с id товаров назовите product_id. Затем к образовавшейся расширенной таблице по ключу product_id 
-- добавьте информацию о ценах на товары (из таблицы products).
-- Должна получиться таблица с заказами, товарами внутри каждого заказа и ценами на эти товары. 
-- Выведите колонки с id заказа, id товара и ценой товара. 
-- Результат отсортируйте сначала по возрастанию id заказа, затем по возрастанию id товара.
-- Добавьте в запрос оператор LIMIT и выведите только первые 1000 строк результирующей таблицы.
-- Поля в результирующей таблице: order_id, product_id, price

WITH unnest_product AS
(
    SELECT  order_id, unnest(product_ids) AS product_id
    FROM orders
)

SELECT order_id, product_id, price
FROM unnest_product LEFT JOIN products USING(product_id)
ORDER BY order_id, product_id
LIMIT 1000;

--8.13. Имея таблицу с заказами, входящими в них товарами и ценами на эти товары, можно посчитать стоимость каждого заказа.
-- Используя запрос из предыдущего задания, рассчитайте суммарную стоимость каждого заказа. 
-- Выведите колонки с id заказов и их стоимостью. Колонку со стоимостью заказа назовите order_price.
-- Результат отсортируйте по возрастанию id заказа.
-- Добавьте в запрос оператор LIMIT и выведите только первые 1000 строк результирующей таблицы.

WITH unnest_product AS
(
    SELECT  order_id, unnest(product_ids) AS product_id
    FROM orders
)

SELECT order_id, SUM(price) AS order_price
FROM unnest_product LEFT JOIN products USING(product_id)
GROUP BY order_id
ORDER BY order_id
LIMIT 1000;

-- 8.14. Теперь есть всё необходимое, чтобы сделать аналитический запрос и посчитать разные пользовательские метрики.

-- Объединим в один запрос данные о количестве товаров в заказах наших пользователей с информацией о стоимости каждого заказа,
-- а затем рассчитаем несколько полезных показателей.

-- Объедините запрос с  запросом со стоимостью заказов с запросом, в котором считали размер каждого заказа из таблицы user_actions.
-- На основе объединённой таблицы для каждого пользователя рассчитайте следующие показатели:
-- общее число заказов — колонку назовите orders_count
-- среднее количество товаров в заказе — avg_order_size
-- суммарную стоимость всех покупок — sum_order_value
-- среднюю стоимость заказа — avg_order_value
-- минимальную стоимость заказа — min_order_value
-- максимальную стоимость заказа — max_order_value
-- Полученный результат отсортируйте по возрастанию id пользователя.
-- Добавьте в запрос оператор LIMIT и выведите только первые 1000 строк результирующей таблицы.
-- В расчётах учитываем только неотменённые заказы. При расчёте средних значений, округляйте их до двух знаков после запятой.
-- Поля в результирующей таблице: user_id, orders_count, avg_order_size, sum_order_value, avg_order_value, min_order_value, max_order_value

WITH unnest_product_ids AS (
SELECT o.order_id,
unnest(o.product_ids) AS product_id --развернули product_ids в отдельные продукты
FROM orders o
),
prod_join_price AS (
SELECT un_p.order_id, un_p.product_id, p.price
FROM unnest_product_ids un_p
LEFT JOIN products p --соединили продукты и цены
using (product_id)
),
orders_prices AS(  --номер и стоимость каждого заказа
SELECT pjp.order_id, sum(pjp.price) as order_price
FROM prod_join_price pjp
GROUP BY pjp.order_id
),
only_cancel_order AS ( --выбрали только отмененные заказы
SELECT ua.order_id
FROM user_actions ua
WHERE ua.action = 'cancel_order'
),
orders_sizes AS (
SELECT t1.user_id, t1.order_id, 
array_length(o.product_ids, 1) AS order_size --посчитали размер каждого заказа
FROM (SELECT ua.user_id, ua.order_id FROM user_actions ua
WHERE ua.order_id NOT in (SELECT * FROM only_cancel_order)) t1
LEFT JOIN orders o
using (order_id)
),
pivot_table_user_order_price_size AS ( --сводная таблица пользователь-заказ-стоимость-размер
SELECT os.user_id, op.order_id, op.order_price, os.order_size
FROM orders_sizes os 
LEFT JOIN orders_prices op
using(order_id)
)

SELECT piv_t.user_id,
count(piv_t.order_id) AS orders_count,
round(avg(piv_t.order_size), 2) AS avg_order_size,
sum(piv_t.order_price) AS sum_order_value, 
round(avg(piv_t.order_price), 2) AS avg_order_value,
min(piv_t.order_price) AS min_order_value,
max(piv_t.order_price) AS max_order_value
FROM pivot_table_user_order_price_size piv_t
GROUP BY 1
LIMIT 1000;

-- или

SELECT user_id,
       count(order_price) as orders_count,
       round(avg(order_size), 2) as avg_order_size,
       sum(order_price) as sum_order_value,
       round(avg(order_price), 2) as avg_order_value,
       min(order_price) as min_order_value,
       max(order_price) as max_order_value
FROM   (SELECT user_id,
               order_id,
               array_length(product_ids, 1) as order_size
        FROM   (SELECT user_id,
                       order_id
                FROM   user_actions
                WHERE  order_id not in (SELECT order_id
                                        FROM   user_actions
                                        WHERE  action = 'cancel_order')) t1
            LEFT JOIN orders using(order_id)) t2
    LEFT JOIN (SELECT order_id,
                      sum(price) as order_price
               FROM   (SELECT order_id,
                              product_ids,
                              unnest(product_ids) as product_id
                       FROM   orders
                       WHERE  order_id not in (SELECT order_id
                                               FROM   user_actions
                                               WHERE  action = 'cancel_order')) t3
                   LEFT JOIN products using(product_id)
               GROUP BY order_id) t4 using (order_id)
GROUP BY user_id
ORDER BY user_id limit 1000;

-- 8.15. По таблицам courier_actions , orders и products определите 10 самых популярных товаров, доставленных в сентябре 2022 года.
-- Самыми популярными товарами будем считать те, которые встречались в заказах чаще всего. 
-- Если товар встречается в одном заказе несколько раз (было куплено несколько единиц товара), 
-- то при подсчёте учитываем только одну единицу товара. Выведите наименования товаров и сколько раз они встречались в заказах.
-- Новую колонку с количеством покупок товара назовите times_purchased. 
-- Поля в результирующей таблице: name, times_purchased

SELECT name,
       count(product_id) as times_purchased
FROM   (SELECT DISTINCT order_id,
                        unnest(product_ids) as product_id
        FROM   orders) as t
    LEFT JOIN products using (product_id)
    RIGHT JOIN courier_actions using (order_id)
WHERE  action = 'deliver_order'
   and date_part('month', time) = 9
   and date_part('year', time) = 2022
GROUP BY name
ORDER BY times_purchased DESC LIMIT 10;

--8.16. Возьмите запрос, составленный на одном из прошлых уроков, и подтяните в него из таблицы users данные о поле пользователей таким образом,
-- чтобы все пользователи из таблицы users_actions остались в результате. 
-- Затем посчитайте среднее значение cancel_rate для каждого пола, округлив его до трёх знаков после запятой. 
-- Колонку с посчитанным средним значением назовите avg_cancel_rate.
-- Помните про отсутствие информации о поле некоторых пользователей после join, 
-- так как не все пользователи из таблицы user_action есть в таблице users. 
-- Для этой группы тоже посчитайте cancel_rate и в результирующей таблице для пустого значения в колонке с полом укажите ‘unknown’ (без кавычек).
-- Возможно, для этого придётся вспомнить, как работает COALESCE.
-- Результат отсортируйте по колонке с полом пользователя по возрастанию.
-- Поля в результирующей таблице: sex, avg_cancel_rate

SELECT coalesce(sex,'unknown') AS sex,
       coalesce(ROUND(AVG(cancel_rate), 3)::text, 'unknown') AS avg_cancel_rate
FROM (SELECT
    user_id,
    ROUND(COUNT(action) FILTER (WHERE action = 'cancel_order') :: DECIMAL / COUNT(DISTINCT order_id), 3) AS cancel_rate
        FROM user_actions
        GROUP BY user_id) rate
LEFT JOIN users
ON rate.user_id = users.user_id
GROUP BY sex
ORDER BY sex;

--8.17. По таблицам orders и courier_actions определите id десяти заказов, которые доставляли дольше всего.
-- Поле в результирующей таблице: order_id

WITH max_time AS
(
    SELECT order_id, MAX(time - creation_time) AS ras_time 
    FROM orders LEFT JOIN courier_actions USING(order_id)
    GROUP BY order_id
    ORDER BY ras_time DESC
    LIMIT 10
)

SELECT order_id
FROM max_time;