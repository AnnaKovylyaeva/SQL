-- 10 УРОК. Оконные функции

--10.1 Примените оконные функции к таблице products и с помощью ранжирующих функций упорядочьте все товары
-- по цене — от самых дорогих к самым дешёвым. Добавьте в таблицу следующие колонки:
-- Колонку product_number с порядковым номером товара (функция ROW_NUMBER).
-- Колонку product_rank с рангом товара с пропусками рангов (функция RANK).
-- Колонку product_dense_rank с рангом товара без пропусков рангов (функция DENSE_RANK).
-- Не забывайте указывать в окне сортировку записей — без неё ранжирующие функции могут давать некорректный результат,
-- если таблица заранее не отсортирована. Деление на партиции внутри окна сейчас не требуется. 
-- Сортировать записи в результирующей таблице тоже не нужно.
-- Поля в результирующей таблице: product_id, name, price, product_number, product_rank, product_dense_rank

SELECT product_id, name, price, ROW_NUMBER() OVER(ORDER BY price DESC) AS product_number,
       RANK() OVER(ORDER BY price DESC) AS product_rank,
       DENSE_RANK() OVER(ORDER BY price DESC) AS product_dense_rank
FROM products;

-- 10.2 Примените оконную функцию к таблице products и с помощью агрегирующей функции в отдельной колонке
-- для каждой записи проставьте цену самого дорогого товара. Колонку с этим значением назовите max_price. 
-- Затем для каждого товара посчитайте долю его цены в стоимости самого дорогого товара — просто поделите одну колонку на другую. 
-- Полученные доли округлите до двух знаков после запятой. Колонку с долями назовите share_of_max.
-- Выведите всю информацию о товарах, включая значения в новых колонках. 
-- Результат отсортируйте сначала по убыванию цены товара, затем по возрастанию id товара.
-- Поля в результирующей таблице: product_id, name, price, max_price, share_of_max
-- В этой задаче окном выступает вся таблица. Сортировку внутри окна указывать не нужно.

SELECT product_id, name, price,
       MAX(price) OVER() AS max_price, 
       ROUND(price/MAX(price) OVER(), 2) AS share_of_max
FROM products
ORDER BY price DESC, product_id;

-- 10.3. Примените две оконные функции к таблице products — одну с агрегирующей функцией MAX, 
-- а другую с агрегирующей функцией MIN — для вычисления максимальной и минимальной цены. 
-- Для двух окон задайте инструкцию ORDER BY по убыванию цены. Поместите результат вычислений в две колонки max_price и min_price.
-- Выведите всю информацию о товарах, включая значения в новых колонках. 
-- Результат отсортируйте сначала по убыванию цены товара, затем по возрастанию id товара.
-- Поля в результирующей таблице: product_id, name, price, max_price, min_price

SELECT product_id, name, price, 
       MAX(price) OVER(ORDER BY price DESC) AS max_price, 
       MIN(price) OVER(ORDER BY price DESC) AS min_price
FROM products
ORDER BY price DESC, product_id;

-- 10.4. Сначала на основе таблицы orders сформируйте новую таблицу с общим числом заказов по дням. 
-- При подсчёте числа заказов не учитывайте отменённые заказы (их можно определить по таблице user_actions). 
-- Колонку с днями назовите date, а колонку с числом заказов — orders_count.
-- Затем поместите полученную таблицу в подзапрос и примените к ней оконную функцию в паре с агрегирующей функцией SUM 
-- для расчёта накопительной суммы числа заказов. Не забудьте для окна задать инструкцию ORDER BY по дате.
-- Колонку с накопительной суммой назовите orders_cum_count.
-- В результате такой операции значение накопительной суммы для последнего дня должно получиться равным общему числу заказов за весь период.
-- Сортировку результирующей таблицы делать не нужно.
-- Поля в результирующей таблице: date, orders_count, orders_cum_count

SELECT date, 
       orders_count,
       SUM(orders_count) OVER(ORDER BY date) orders_cum_count
FROM (SELECT creation_time::DATE AS date, COUNT(order_id) AS orders_count
      FROM orders
      WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')
      GROUP BY date) AS t;

-- 10.5. Для каждого пользователя в таблице user_actions посчитайте порядковый номер каждого заказа. 
-- Для этого примените оконную функцию ROW_NUMBER к колонке с временем заказа.
-- Не забудьте указать деление на партиции по пользователям и сортировку внутри партиций. 
-- Отменённые заказы не учитывайте. Новую колонку с порядковым номером заказа назовите order_number. 
-- Результат отсортируйте сначала по возрастанию id пользователя, затем по возрастанию order_number. Добавьте LIMIT 1000.
-- Поля в результирующей таблице: user_id, order_id, time, order_number

SELECT user_id, order_id, time, 
       ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY time) AS order_number
FROM user_actions
WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order' )
ORDER BY user_id, order_number
LIMIT 1000;

--10.6 Дополните запрос из предыдущего задания и с помощью оконной функции для каждого заказа каждого пользователя рассчитайте,
-- сколько времени прошло с момента предыдущего заказа. 
-- Для этого сначала в отдельном столбце с помощью LAG сделайте смещение по столбцу time на одно значение назад. 
-- Столбец со смещёнными значениями назовите time_lag. Затем отнимите от каждого значения в колонке time новое значение со смещением 
-- (либо можете использовать уже знакомую функцию AGE). Колонку с полученным интервалом назовите time_diff.
-- Менять формат отображения значений не нужно, они должны иметь примерно следующий вид:
-- 3 days, 12:18:22
-- По-прежнему не учитывайте отменённые заказы. Также оставьте в запросе порядковый номер каждого заказа, рассчитанный на прошлом шаге. 
-- Результат отсортируйте сначала по возрастанию id пользователя, затем по возрастанию порядкового номера заказа. Добавьте LIMIT 1000.
-- Поля в результирующей таблице: user_id, order_id, time, order_number, time_lag, time_diff

SELECT user_id, order_id, time, 
      ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY time) AS order_number, 
      LAG(time, 1) OVER(PARTITION BY user_id ORDER BY time) AS time_lag, 
      time - LAG(time, 1) OVER (PARTITION BY user_id ORDER BY time) AS time_diff
FROM user_actions
WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order' )
ORDER BY user_id, order_id
LIMIT 1000;

--10.7. На основе запроса из предыдущего задания для каждого пользователя рассчитайте, сколько в среднем времени проходит между его заказами. 
-- Не считайте этот показатель для тех пользователей, которые за всё время оформили лишь один заказ. 
-- Полученное среднее значение (интервал) переведите в часы, а затем округлите до целого числа. 
-- Колонку со средним значением часов назовите hours_between_orders. Результат отсортируйте по возрастанию id пользователя.
-- Добавьте LIMIT 1000.
-- Поля в результирующей таблице: user_id, hours_between_orders


WITH time_LAG AS
(
    SELECT user_id, order_id, time, 
           time - LAG(time, 1) OVER (PARTITION BY user_id ORDER BY time) AS time_diff
    FROM user_actions
    WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order' )
)

SELECT user_id, ROUND((EXTRACT(epoch FROM AVG(time_diff)))/3600) AS hours_between_orders
FROM time_LAG
WHERE time_diff IS NOT NULL
GROUP BY user_id
ORDER BY user_id
LIMIT 1000;

--10.8. Сначала на основе таблицы orders сформируйте новую таблицу с общим числом заказов по дням.
-- При подсчёте числа заказов не учитывайте отменённые заказы (их можно определить по таблице user_actions). 
-- Колонку с числом заказов назовите orders_count.
-- Затем поместите полученную таблицу в подзапрос и примените к ней оконную функцию в паре с агрегирующей функцией AVG
-- для расчёта скользящего среднего числа заказов.
-- Скользящее среднее для каждой записи считайте по трём предыдущим дням. 
-- Подумайте, как правильно задать границы рамки, чтобы получить корректные расчёты.
-- Полученные значения скользящего среднего округлите до двух знаков после запятой. 
-- Колонку с рассчитанным показателем назовите moving_avg. Сортировку результирующей таблицы делать не нужно.
-- Поля в результирующей таблице: date, orders_count, moving_avg

WITH total_orders AS
(
    SELECT date(creation_time) AS date,
           COUNT(order_id) AS orders_count
    FROM   orders
    WHERE  order_id NOT IN (SELECT order_id
                            FROM   user_actions
                            WHERE  action = 'cancel_order')
    GROUP BY date
)

SELECT date,
       orders_count,
       ROUND(AVG(orders_count) OVER (ORDER BY date rows between 3 preceding and 1 preceding), 2) AS moving_avg
FROM  total_orders; 


--10.9. Отметьте в отдельной таблице тех курьеров, которые доставили в сентябре 2022 года заказов больше, чем в среднем все курьеры.
-- Сначала для каждого курьера в таблице courier_actions рассчитайте общее количество доставленных в сентябре заказов.
-- Затем в отдельном столбце с помощью оконной функции укажите, сколько в среднем заказов доставили в этом месяце все курьеры. 
-- После этого сравните число заказов, доставленных каждым курьером, со средним значением в новом столбце. 
-- Если курьер доставил больше заказов, чем в среднем все курьеры, то в отдельном столбце с помощью CASE укажите число 1,
-- в противном случае укажите 0.
-- Колонку с результатом сравнения назовите is_above_avg, колонку с числом доставленных заказов каждым курьером — delivered_orders,
-- колонку со средним значением — avg_delivered_orders. При расчёте среднего значения округлите его до двух знаков после запятой.
-- Результат отсортируйте по возрастанию id курьера.
-- Поля в результирующей таблице: courier_id, delivered_orders, avg_delivered_orders, is_above_avg 

WITH count_orders AS
(
    SELECT courier_id,
           COUNT(order_id) AS delivered_orders
    FROM courier_actions
    WHERE action = 'deliver_order' AND 
          DATE_PART('month', time) = 9 AND DATE_PART('year', time) = 2022
    GROUP BY courier_id
)

SELECT courier_id, 
       delivered_orders,
       ROUND(AVG(delivered_orders) OVER(), 2) AS avg_delivered_orders, 
       CASE WHEN delivered_orders> ROUND(AVG(delivered_orders) OVER(), 2)
       THEN 1
       ELSE 0 
       END AS is_above_avg 
FROM count_orders
ORDER BY courier_id;

-- 10.10. Примените оконную функцию к таблице products и с помощью агрегирующей функции в отдельной колонке
-- для каждой записи проставьте среднюю цену всех товаров. Колонку с этим значением назовите avg_price.
-- Затем с помощью оконной функции и оператора FILTER в отдельной колонке рассчитайте среднюю цену товаров без учёта самого дорогого.
-- Колонку с этим средним значением назовите avg_price_filtered. 
-- Полученные средние значения в колонках avg_price и avg_price_filtered округлите до двух знаков после запятой.
-- Выведите всю информацию о товарах, включая значения в новых колонках. Результат отсортируйте сначала по убыванию цены товара, затем по возрастанию id товара.
-- Поля в результирующей таблице: product_id, name, price, avg_price, avg_price_filtered

SELECT product_id, name, price,
      ROUND(AVG(price) OVER(), 2) AS avg_price, 
      ROUND(AVG(price) FILTER (WHERE price NOT IN (SELECT MAX(price) FROM products)) OVER(), 2) AS avg_price_filtered
FROM products
ORDER BY price DESC, product_id;
