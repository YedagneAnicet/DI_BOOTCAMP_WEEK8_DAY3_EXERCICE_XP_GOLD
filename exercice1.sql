--Get a list of all rentals which are out (have not been returned). How do we identify these films in the database?
SELECT *
FROM rental
WHERE return_date IS NULL;
-- we identify the films with the iventory_id 
-- Get a list of all customers who have not returned their rentals. Make sure to group your results.
SELECT customer.first_name,
    customer.last_name,
    COUNT(*) as rentals_notreturned
FROM rental
    JOIN customer ON rental.customer_id = customer.customer_id
WHERE rental.return_date IS NULL
GROUP BY customer.customer_id;
-- Get a list of all the Action films with Joe Swank
SELECT film.title
FROM film
    JOIN film_actor ON film.film_id = film_actor.film_id
    JOIN actor ON film_actor.actor_id = actor.actor_id
WHERE film.rating = 'R'
    AND actor.first_name = 'Joe'
    AND actor.last_name = 'Swank'
    AND film.special_features LIKE '%Action%';
--Before you start, could there be a shortcut to getting this information? Maybe a view?
--Yes we can it's very simple :
CREATE VIEW joe_swank_movies AS
SELECT film.title
FROM film
    JOIN film_actor ON film.film_id = film_actor.film_id
    JOIN actor ON film_actor.actor_id = actor.actor_id
WHERE actor.first_name = 'Joe'
    AND actor.last_name = 'Swank';
SELECT title
FROM joe_swank_movies
WHERE special_features LIKE '%Action%';