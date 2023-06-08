-- Урок 7. Подзапросы

-- 7.1. Используя данные из таблицы user_actions, рассчитайте среднее число заказов всех пользователей нашего сервиса.
-- Для этого сначала в подзапросе посчитайте, сколько заказов сделал каждый пользователь, а затем обратитесь к результату подзапроса
-- в блоке FROM и уже в основном запросе усредните количество заказов по всем пользователям. 
-- Полученное среднее число заказов всех пользователей округлите до двух знаков после запятой. Колонку с этим значением назовите orders_avg.
-- Поле в результирующей таблице: orders_avg

SELECT ROUND(AVG(count_order), 2) AS orders_avg
FROM
(
   SELECT user_id, COUNT(order_id) AS count_order
   FROM user_actions
   WHERE action = 'create_order'
   GROUP BY user_id
) AS t;

-- 7.2. Повторите запрос из предыдущего задания, но теперь вместо подзапроса используйте оператор WITH и табличное выражение. 
-- Условия задачи те же. Поле в результирующей таблице: orders_avg 

WITH count_orders AS
(
   SELECT user_id, COUNT(order_id) AS count_order
   FROM user_actions
   WHERE action = 'create_order'
   GROUP BY user_id
) 

SELECT ROUND(AVG(count_order), 2) AS orders_avg
FROM count_orders;

--7.3. Выведите из таблицы products информацию о всех товарах кроме самого дешёвого. Результат отсортируйте по убыванию id товара.
-- Поля в результирующей таблице: product_id, name, price
 
 SELECT product_id, name, price
 FROM products
 WHERE price <> (SELECT MIN(price) FROM products)
 ORDER BY product_id DESC;

--7.4. Выведите информацию о товарах в таблице products, цена на которые превышает среднюю цену всех товаров на 20 рублей и более. 
-- Результат отсортируйте по убыванию id товара.
-- Поля в результирующей таблице: product_id, name, price

SELECT product_id, name, price
FROM products
WHERE price >= (SELECT AVG(price) FROM products) + 20
ORDER BY product_id DESC;
 
-- 7.5. Посчитайте количество уникальных клиентов в таблице user_actions, сделавших за последнюю неделю хотя бы один заказ.
-- Полученную колонку со значением назовите users_count. В качестве текущей даты, от которой откладывать неделю, 
-- используйте последнюю дату в той же таблице user_actions.
-- Поле в результирующей таблице: users_count

SELECT COUNT(DISTINCT user_id) AS users_count
FROM user_actions
WHERE user_id IN (SELECT user_id 
                  FROM user_actions
                  WHERE time BETWEEN (SELECT MAX(time) FROM user_actions) - INTERVAL '1 week' AND (SELECT MAX(time) FROM user_actions)
                  );

-- 7.6. С помощью функции AGE() и агрегирующей функции снова рассчитайте возраст самого молодого курьера мужского пола в таблице couriers,
-- но в этот раз в качестве первой даты используйте последнюю дату из таблицы courier_actions. Чтобы получилась именно дата,
-- перед применением функции AGE() переведите посчитанную последнюю дату в формат DATE, как мы делали в этом задании. 
-- Возраст курьера измерьте количеством лет, месяцев и дней и переведите его в тип VARCHAR. 
-- Полученную колонку со значением возраста назовите min_age.
-- Поле в результирующей таблице: min_age

SELECT min(age((SELECT MAX(time) 
                FROM courier_actions)::DATE, birth_date))::varchar AS min_age
FROM couriers
WHERE sex = 'male';

-- 7.7. Из таблицы user_actions с помощью подзапроса или табличного выражения отберите все заказы, которые не были отменены пользователями.
-- Выведите колонку с id этих заказов. Результат запроса отсортируйте по возрастанию id заказа. 
-- Добавьте в запрос оператор LIMIT и выведите только первые 1000 строк результирующей таблицы.

WITH orders_not_cancel AS
(
    SELECT DISTINCT order_id
    FROM user_actions
    WHERE action = 'cancel_order'
)
SELECT DISTINCT order_id
FROM user_actions
WHERE order_id NOT IN (SELECT order_id FROM orders_not_cancel)
ORDER BY order_id
LIMIT 1000;

--или

SELECT order_id
FROM   user_actions
WHERE  order_id NOT IN (SELECT order_id
                        FROM   user_actions
                        WHERE  action = 'cancel_order')
ORDER BY order_id LIMIT 1000;






-- 7.8. Используя данные из таблицы user_actions, рассчитайте, сколько заказов сделал каждый пользователь и отразите это в столбце orders_count.
-- В отдельном столбце orders_avg напротив каждого пользователя укажите среднее число заказов всех пользователей, округлив его до двух знаков после запятой. 
-- Также для каждого пользователя посчитайте отклонение числа заказов от среднего значения. 
-- Отклонение считайте так: число заказов «минус» округлённое среднее значение. Колонку с отклонением назовите orders_diff. 
-- Результат отсортируйте по возрастанию id пользователя. Добавьте в запрос оператор LIMIT и 
-- выведите только первые 1000 строк результирующей таблицы.
-- Поля в результирующей таблице: user_id, orders_count, orders_avg, orders_diff

WITH orders_users AS (       
    SELECT user_id, count (distinct order_id) orders_count
    FROM user_actions
    GROUP BY user_id)
SELECT user_id, orders_count, round((SELECT avg(orders_count) FROM orders_users),2) AS orders_avg ,
      (orders_count - round((SELECT avg(orders_count) FROM orders_users),2)) AS orders_diff
FROM orders_users
ORDER BY user_id
LIMIT 1000;

--7.9. Выведите id и содержимое 100 последних доставленных заказов из таблицы orders. 
-- Содержимым заказов считаются списки с id входящих в заказ товаров. Результат отсортируйте по возрастанию id заказа.
-- Поля в результирующей таблице: order_id, product_ids
-- Пояснение: Обратите внимание, что содержимое заказов находится в таблице orders,
-- а информация о действиях с заказами — в таблице courier_actions.
 
WITH delivered_orders AS (
  SELECT order_id
  FROM courier_actions
  WHERE action = 'deliver_order'
  ORDER BY time DESC
  LIMIT 100
)

SELECT order_id, product_ids
FROM orders
WHERE order_id IN ( SELECT * FROM delivered_orders)
ORDER BY order_id;

-- или 

SELECT order_id,
       product_ids
FROM   orders
WHERE  order_id IN (SELECT order_id
                    FROM   courier_actions
                    WHERE  action = 'deliver_order'
                    ORDER BY time DESC LIMIT 100)
ORDER BY order_id;
 
-- 7.10 Из таблицы couriers выведите всю информацию о курьерах, которые в сентябре 2022 года доставили 30 и более заказов.
-- Результат отсортируйте по возрастанию id курьера.
-- Поля в результирующей таблице: courier_id, birth_date, sex
-- Обратите внимание, что информация о курьерах находится в таблице couriers, а информация о действиях с заказами — в таблице courier_actions.

SELECT courier_id, birth_date, sex
FROM couriers
WHERE courier_id IN (SELECT courier_id
                     FROM courier_actions 
                     WHERE DATE_PART('month', time) = 9 AND DATE_PART('year', time) = 2022 AND action = 'deliver_order'
                     GROUP BY courier_id
                     HAVING COUNT(distinct order_id) >=30)
ORDER BY courier_id;

-- 7.11. Назначьте скидку 15% на товары, цена которых превышает среднюю цену на все товары на 50 и более рублей,
-- а также скидку 10% на товары, цена которых ниже средней на 50 и более рублей. 
-- Цену остальных товаров внутри диапазона (среднее - 50; среднее + 50) оставьте без изменений. 
-- При расчёте средней цены, округлите её до двух знаков после запятой.
-- Выведите информацию о всех товарах с указанием старой и новой цены.
-- Колонку с новой ценой назовите new_price. 
-- Результат отсортируйте сначала по убыванию прежней цены в колонке price, затем по возрастанию id товара.
-- Поля в результирующей таблице: product_id, name, price, new_price

SELECT product_id, name, price, 
       (CASE WHEN  price - (SELECT ROUND(AVG(price), 2) FROM products) >= 50
             THEN  price * 0.85
             WHEN  price - (SELECT ROUND(AVG(price), 2) FROM products) <= -50
             THEN  price * 0.9
             ELSE price
             END) AS new_price
FROM products
ORDER BY price DESC, product_id;

-- или

WITH avg_price AS 
(
    SELECT round(avg(price), 2) AS price
    FROM   products
)
    
SELECT product_id, name, price,
       CASE WHEN price >= (SELECT * FROM avg_price) + 50
                           THEN price*0.85
                           WHEN price <= (SELECT * FROM  avg_price) - 50 
                           THEN price*0.9
                           ELSE price END AS new_price
FROM   products
ORDER BY price DESC, product_id

-- 7.12. Выберите все колонки из таблицы orders, но в качестве последней колонки укажите функцию unnest, 
-- применённую к колонке product_ids. Новую колонку назовите product_id. 
-- Выведите только первые 100 записей результирующей таблицы. 
-- Поля в результирующей таблице: creation_time, order_id, product_ids, product_id

SELECT creation_time, order_id, product_ids, unnest(product_ids) AS product_id
FROM orders
LIMIT 100;

-- 7.13. Используя функцию unnest, определите 10 самых популярных товаров в таблице orders. 
-- Самыми популярными будем считать те, которые встречались в заказах чаще всего. 
-- Если товар встречается в одном заказе несколько раз (т.е. было куплено несколько единиц товара), то это тоже учитывается при подсчёте. 
-- Выведите id товаров и сколько раз они встречались в заказах. Новую колонку с количеством покупок товара назовите times_purchased.
-- Поля в результирующей таблице: product_id, times_purchased

SELECT DISTINCT unnest(product_ids) AS product_id, COUNT(*) as times_purchased
FROM orders
GROUP BY product_id
ORDER BY times_purchased DESC
LIMIT 10;

-- 7.14. Из таблицы orders выведите id и содержимое заказов, которые включают хотя бы один из пяти самых дорогих товаров, 
-- доступных в нашем сервисе. Результат отсортируйте по возрастанию id заказа.
-- Поля в результирующей таблице: order_id, product_ids

WITH expensive_products AS 
(
    SELECT product_id
    FROM products
    ORDER BY price DESC  
    LIMIT 5
)
  
SELECT DISTINCT order_id, product_ids
FROM (SELECT order_id, product_ids, unnest(product_ids) AS prod
      FROM orders) t
WHERE prod IN (SELECT * FROM expensive_products)
ORDER BY order_id;

--7.15. Посчитайте возраст каждого пользователя в таблице users. Возраст считайте относительно последней даты в таблице user_actions.
-- В результат включите колонки с id пользователя и возрастом. Для тех пользователей, у которых в таблице users не указана дата рождения,
-- укажите среднее значение возраста всех остальных пользователей, округлённое до целого числа. Колонку с возрастом назовите age.
-- Результат отсортируйте по возрастанию id пользователя.
-- Поля в результирующей таблице: user_id, age

WITH last_order_date AS (
        SELECT MAX(time) FROM user_actions
    )

SELECT user_id, 
       CASE
       WHEN birth_date IS NULL THEN (SELECT ROUND(AVG(DATE_PART('year', AGE((SELECT * FROM last_order_date), birth_date))::DECIMAL), 0) as age FROM users)
       ELSE DATE_PART('year', AGE((SELECT * FROM last_order_date), birth_date))
       END as age FROM users
GROUP BY user_id
ORDER BY user_id;