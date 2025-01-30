SELECT category.name, count(category.name) as category_count
FROM film
JOIN film_category ON film.film_id = film_category.film_id
JOIN category ON film_category.category_id = category.category_id
GROUP BY category.name
ORDER BY category_count desc;

SELECT avg(rental_rate), film_category.category_id, category.name
FROM film
JOIN film_category ON film.film_id = film_category.film_id
JOIN category ON film_category.category_id = category.category_id
GROUP BY film_category.category_id
ORDER BY avg(rental_rate) DESC;

SELECT count(rental_duration) as rental_length, rental_duration
FROM film
JOIN film_category ON film.film_id = film_category.film_id
JOIN category ON film_category.category_id = category.category_id
WHERE category.name = "Comedy"
GROUP BY rental_duration
ORDER BY rental_length DESC;









