--How many stores there are, and in which city and country they are located.
SELECT COUNT(*) AS store_count,
    city,
    country
FROM store
GROUP BY city,
    country;
--How many hours of viewing time there are in total in each store – in other words, the sum of the length of every inventory item in each store
SELECT SUM(inventory.length) AS total_hours,
    store.store_id
FROM inventory
    JOIN store ON inventory.store_id = store.store_id
    LEFT JOIN rental ON inventory.inventory_id = rental.inventory_id
    AND rental.return_date IS NULL
WHERE rental.rental_id IS NULL
GROUP BY store.store_id;
-- Make sure to exclude any inventory items which are not yet returned. (Yes, even in the time of zombies there are people who do not return their DVDs) 
SELECT store.store_id,
    store.city,
    store.country,
    SUM(inventory.length) as total_viewing_time_minute,
    SUM(inventory.length) / 60 as total_viewing_time_hour,
    SUM(inventory.length) / 1440 as total_viewing_time_day
FROM store
    JOIN inventory ON store.store_id = inventory.store_id
    JOIN rental ON inventory.inventory_id = rental.inventory_id
WHERE rental.return_date IS NOT NULL
GROUP BY store.store_id;
-- A list of all customers in the cities where the stores are located.
SELECT customer.first_name,
    customer.last_name,
    customer.email,
    city,
    country
FROM customer
    JOIN address ON customer.address_id = address.address_id
    JOIN city ON address.city_id = city.city_id
    JOIN country ON city.country_id = country.country_id
WHERE city IN (
        SELECT DISTINCT city
        FROM store
    );
-- A list of all customers in the countries where the stores are located.
SELECT customer.first_name,
    customer.last_name,
    customer.email,
    country
FROM customer
    JOIN address ON customer.address_id = address.address_id
    JOIN city ON address.city_id = city.city_id
    JOIN country ON city.country_id = country.country_id
WHERE country IN (
        SELECT DISTINCT country
        FROM store
    );
-- Some people will be frightened by watching scary movies while zombies walk the streets. Create a ‘safe list’ of all movies which do not include the ‘Horror’ category, or contain the words ‘beast’, ‘monster’, ‘ghost’, ‘dead’, ‘zombie’, or ‘undead’ in their titles or descriptions… Get the sum of their viewing time (length).
CREATE VIEW safe_movies AS
SELECT *
FROM film
WHERE category_id != (
        SELECT category_id
        FROM category
        WHERE name = 'Horror'
    )
    AND (
        LOWER(description) NOT LIKE '%beast%'
        AND LOWER(description) NOT LIKE '%monster%'
        AND LOWER(description) NOT LIKE '%ghost%'
        AND LOWER(description) NOT LIKE '%dead%'
        AND LOWER(description) NOT LIKE '%zombie%'
        AND LOWER(description) NOT LIKE '%undead%'
        AND LOWER(title) NOT LIKE '%beast%'
        AND LOWER(title) NOT LIKE '%monster%'
        AND LOWER(title) NOT LIKE '%ghost%'
        AND LOWER(title) NOT LIKE '%dead%'
        AND LOWER(title) NOT LIKE '%zombie%'
        AND LOWER(title) NOT LIKE '%undead%'
    );
-- Get the sum of their viewing time (length).
SELECT SUM(length) AS total_hours
FROM inventory
    JOIN film ON inventory.film_id = film.film_id
    JOIN safe_movies ON film.film_id = safe_movies.film_id
GROUP BY inventory.store_id;
-- For both the ‘general’ and the ‘safe’ lists above, also calculate the time in hours and days (not just minutes).
SELECT SUM(
        EXTRACT(
            MINUTE
            FROM length
        )
    ) / 60.0 AS total_hours,
    SUM(
        EXTRACT(
            MINUTE
            FROM length
        )
    ) / 1440 AS total_days
FROM inventory
WHERE NOT EXISTS (
        SELECT *
        FROM rental
        WHERE inventory.inventory_id = rental.inventory_id
            AND rental.return_date IS NULL
    )
    AND rating IN ('G', 'PG', 'PG-13', 'R')
SELECT SUM(
        EXTRACT(
            MINUTE
            FROM length
        )
    ) / 60 AS total_hours,
    SUM(
        EXTRACT(
            MINUTE
            FROM length
        )
    ) / 1440 AS total_days
FROM inventory
WHERE NOT EXISTS (
        SELECT *
        FROM rental
        WHERE inventory.inventory_id = rental.inventory_id
            AND rental.return_date IS NULL
    )
    AND rating IN ('G', 'PG', 'PG-13', 'R')
    AND (
        category != 'Horror'
        AND (
            title NOT ILIKE '%beast%'
            AND title NOT ILIKE '%monster%'
            AND title NOT ILIKE '%ghost%'
            AND title NOT ILIKE '%dead%'
            AND title NOT ILIKE '%zombie%'
            AND title NOT ILIKE '%undead%'
            AND description NOT ILIKE '%beast%'
            AND description NOT ILIKE '%monster%'
            AND description NOT ILIKE '%ghost%'
            AND description NOT ILIKE '%dead%'
            AND description NOT ILIKE '%zombie%'
            AND description NOT ILIKE '%undead%'
        )
    )