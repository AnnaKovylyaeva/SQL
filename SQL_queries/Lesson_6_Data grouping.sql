-- 6 Урок. Группировка данных

--6.1. С помощью группировки посчитайте количество курьеров мужского и женского пола в таблице couriers.
-- Новую колонку с числом курьером назовите couriers_count. Результат отсортируйте по этой колонке по возрастанию.
-- Поля в результирующей таблице: sex, couriers_count

SELECT sex, COUNT(courier_id) AS couriers_count
FROM couriers
WHERE sex IN ('male', 'female')
GROUP BY sex
ORDER BY couriers_count;


--6.2. Посчитайте максимальный возраст пользователей мужского и женского пола в таблице users. 
-- Возраст измерьте количеством полных лет. Новую колонку с возрастом назовите max_age.
-- Результат отсортируйте по новой колонке по возрастанию возраста.
-- Поля в результирующей таблице: sex, max_age

SELECT sex, MAX(DATE_PART('YEARS', AGE(birth_date))) AS max_age
FROM users
GROUP BY sex;

--6.3. Разбейте пользователей из таблицы users на группы по возрасту (возраст измеряем количеством полных лет)
-- и посчитайте число пользователей каждого возраста. Колонку с возрастом назовите age, а колонку с числом пользователей — users_count.
-- Отсортируйте полученный результат по возрастанию возраста. Не забудем и про тех пользователей, у которых вместо возраста будет пропуск,
-- для этой группы также подсчитаем число пользователей.
-- Поля в результирующей таблице: age, users_count

SELECT date_part('YEARS', AGE(birth_date)) AS age, COUNT(user_id) AS users_count
FROM users
GROUP BY age
ORDER BY age;

--6.4. Вновь разбейте пользователей из таблицы users на группы по возрасту (возраст измеряем количеством полных лет),
-- только теперь добавьте в группировку пол пользователя. В результате в каждой возрастной группе должно появиться ещё по две подгруппы с полом.
-- В каждой такой подгруппе посчитайте число пользователей.
-- Все NULL значения в колонке birth_date заранее отфильтруйте с помощью WHERE.
-- Колонку с возрастом назовите age, а колонку с числом пользователей — users_count, имя колонки с полом оставьте без изменений.
-- Отсортируйте полученную таблицу сначала по колонке с возрастом по возрастанию, затем по колонке с полом — тоже по возрастанию.
-- Поля в результирующей таблице: age, sex, users_count

SELECT date_part('YEARS', AGE(birth_date)) AS age, sex, COUNT(user_id) AS users_count
FROM users
WHERE birth_date IS NOT NULL
GROUP BY age, sex
ORDER BY age, sex;

--6.5. Используя функцию DATE_TRUNC, посчитайте, сколько заказов было сделано и сколько было отменено в каждом месяце.
-- Расчёты проводите по таблице user_actions. Колонку с усечённой датой назовите month, колонку с количеством заказов — orders_count.
-- Результат отсортируйте сначала по месяцам — по возрастанию, затем по типу действия — тоже по возрастанию.
-- Поля в результирующей таблице: month, action, orders_count

SELECT DATE_TRUNC('MONTH', time) AS month, action, COUNT(order_id) AS orders_count
FROM user_actions
GROUP BY month, action
ORDER BY month, action;


-- 6.6. Посчитайте количество товаров в каждом заказе из таблицы orders,
-- примените к этим значениям группировку и посчитайте количество заказов в каждой группе.
-- Выведите две колонки: количество товаров в заказе и число заказов с таким количеством. 
-- Колонки назовите соответственно order_size и orders_count. Результат отсортируйте по возрастанию числа товаров в заказе.
-- Поля в результирующей таблице: order_size, orders_count

SELECT array_length(product_ids, 1) AS order_size, COUNT(order_id) AS orders_count
FROM orders
GROUP BY order_size
ORDER BY order_size;

--6.7. Дополните предыдущий запрос оператором HAVING и отберите только те размеры заказов, общее число которых превышает 5000. 
-- Вновь выведите две колонки: количество товаров в заказе и число заказов с таким количеством. 
-- Колонки назовите соответственно order_size и orders_count. Результат отсортируйте по возрастанию числа товаров в заказе.
-- Поля в результирующей таблице: order_size, orders_count

SELECT array_length(product_ids, 1) AS order_size, COUNT(order_id) AS orders_count
FROM orders
GROUP BY order_size
HAVING COUNT(order_id) > 5000 
ORDER BY order_size;

--6.8.  Из таблицы courier_actions отберите id трёх курьеров, доставивших наибольшее количество заказов в августе 2022 года. 
-- Выведите две колонки — id курьера и число доставленных заказов. Колонку с числом доставленных заказов назовите delivered_orders. 
-- Отсортируйте результат по убыванию delivered_orders.
-- Поля в результирующей таблице: courier_id, delivered_orders

SELECT courier_id, COUNT(order_id) AS delivered_orders
FROM courier_actions
WHERE DATE_PART('month', time) = 8 AND DATE_PART('year', time) = 2022 AND action = 'deliver_order'
GROUP BY courier_id
ORDER BY delivered_orders DESC
LIMIT 3;

--6.9. А теперь отберите id только тех курьеров, которые в сентябре 2022 года успели доставить только по одному заказу.
-- Таблица та же — courier_actions. Вновь выведите две колонки — id курьера и число доставленных заказов.
-- Колонку с числом заказов назовите delivered_orders. Результат отсортируйте по возрастанию id курьера.
-- Поля в результирующей таблице: courier_id, delivered_orders

SELECT courier_id, COUNT(order_id) AS delivered_orders
FROM courier_actions
WHERE DATE_PART('month', time) = 9 AND DATE_PART('year', time) = 2022 AND action = 'deliver_order'
GROUP BY courier_id
HAVING COUNT(order_id) = 1
ORDER BY courier_id;

--6.10. Из таблицы user_actions отберите пользователей, у которых последний заказ был создан до 8 сентября 2022 года.
-- Выведите только их id, дату создания заказа выводить не нужно. Результат отсортируйте по возрастанию id пользователя.
-- Поле в результирующей таблице: user_id

SELECT user_id 
FROM user_actions
WHERE action = 'create_order'
GROUP BY user_id
HAVING MAX(time) < '2022-09-08'
ORDER BY user_id ASC;

--6.11. Для каждого пользователя в таблице user_actions посчитайте долю отменённых заказов.
-- Чтобы посчитать долю отменённых заказов, необходимо поделить количество отменённых заказов на общее число уникальных заказов пользователя.
-- Выведите две колонки: id пользователя и рассчитанный показатель.
-- Новую колонку с показателем округлите до двух знаков после запятой и назовите cancel_rate. 
-- Результат отсортируйте по возрастанию id пользователя.
-- Поля в результирующей таблице: user_id, cancel_rate


SELECT user_id, ROUND(COUNT(order_id) FILTER(WHERE action='cancel_order')/COUNT(DISTINCT order_id)::DECIMAL, 2) AS cancel_rate
FROM user_actions
GROUP BY user_id
ORDER BY user_id ;

--6.12. Посчитайте число пользователей, попавших в каждую возрастную группу.
-- Группы назовите соответственно «19-24», «25-29», «30-35», «36-41» (без кавычек). 
-- Выведите наименования групп и число пользователей в них. 
-- Колонку с наименованием групп назовите group_age, а колонку с числом пользователей — users_count.
-- Отсортируйте полученную таблицу по колонке с наименованием групп по возрастанию.
-- Поля в результирующей таблице: group_age, users_count

SELECT CASE WHEN ROUND(date_part('YEAR', age(birth_date))) BETWEEN 19 AND 24
            THEN '19-24'
             WHEN ROUND(date_part('YEAR', age(birth_date))) BETWEEN 25 AND 29 
             THEN '25-29'
             WHEN ROUND(date_part('YEAR', age(birth_date))) BETWEEN 30 AND 35 
             THEN '30-35'
             WHEN ROUND(date_part('YEAR', age(birth_date))) BETWEEN 36 AND 41 
             THEN '36-41'
             END AS group_age,
       COUNT(DISTINCT user_id) AS users_count
FROM users
WHERE birth_date IS NOT NULL
GROUP BY group_age;