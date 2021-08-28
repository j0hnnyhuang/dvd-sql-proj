/* Query 1 - query used for first insight*/

SELECT DISTINCT(film_title),
       category_name,
       rental_count
    FROM (
          SELECT f.title film_title,
              c.name category_name,
              COUNT(r.rental_id) OVER main_window AS rental_count
          FROM film f
          JOIN film_category fc
          ON f.film_id = fc.film_id
          JOIN category c
          ON fc.category_id = c.category_id
          JOIN inventory i
          ON i.film_id = f.film_id
          JOIN rental r
          ON r.inventory_id = i.inventory_id
    WINDOW main_window AS (PARTITION BY f.title)) sub
WHERE category_name IN ('Animation','Children','Classics','Comedy','Family',
'Music')
ORDER BY 3 DESC
LIMIT 10;



/*Query 2 - query used for second insight*/

  SELECT DISTINCT(sub2.category),
         sub2.quartile,
         COUNT(*)
  FROM (
        SELECT sub.title,
              sub.category,
              DATE_PART('doy',sub.return_date)-
              DATE_PART('doy',sub.rental_date) AS rental_duration,
              NTILE(4) OVER (ORDER BY(DATE_PART('doy',sub.return_date)-
              DATE_PART('doy',sub.rental_date))) AS quartile
        FROM (
            SELECT f.title title,
                   c.name category,
                   r.return_date return_date,
                   r.rental_date rental_date
                   FROM rental r
                   JOIN inventory i
                   ON r.inventory_id = i.inventory_id
                   JOIN film f
                   ON f.film_id = i.film_id
                   JOIN film_category fc
                   ON fc.film_id = f.film_id
                   JOIN category c
                   ON c.category_id = fc.category_id) sub
        WHERE sub.category IN ('Animation','Children','Classics','Comedy','Family',
        'Music')) sub2
    GROUP BY 1,2
    ORDER BY 2 DESC
    LIMIT 6;



/*Query 3 - query used for third insight*/

SELECT sub2.title,
       sub2.quartile,
       COUNT(*)
FROM (
    SELECT sub.title,
          NTILE(4) OVER (ORDER BY(DATE_PART('doy',sub.return_date)-
          DATE_PART('doy',sub.rental_date))) AS quartile
    FROM (
        SELECT f.title AS title,
               c.name category,
               r.return_date return_date,
               r.rental_date rental_date
               FROM rental r
               JOIN inventory i
               ON r.inventory_id = i.inventory_id
               JOIN film f
               ON f.film_id = i.film_id
               JOIN film_category fc
               ON fc.film_id = f.film_id
               JOIN category c
               ON c.category_id = fc.category_id) sub
    WHERE sub.category IN ('Animation','Children','Classics','Comedy','Family',
    'Music')) sub2
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 10;



/*Query 4 - query used for fourth insight*/

SELECT sub.month,
       sub.year,
       COUNT(*) AS count_rentals
FROM (
    SELECT DATE_PART('year',r.rental_date) AS year,
           DATE_PART ('month',r.rental_date) AS month,
           s.store_id AS store_id
    FROM rental r
    JOIN payment p
    ON r.customer_id = p.customer_id
    JOIN staff s
    ON s.staff_id = p.staff_id
    JOIN store st
    ON st.store_id = s.store_id) sub
GROUP BY 1,2
ORDER BY 2,1;
