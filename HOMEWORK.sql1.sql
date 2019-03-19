USE sakila;
-- 1a Display the first and last names of all actors from the table `actor`.
SELECT first_name, last_name FROM sakila.actor; 
-- 1b Display the first and last names of all actors from the table `actor`.
SELECT CONCAT(first_name ," ",last_name) as ActorName FROM sakila.actor;
-- 2a You need to find the ID number, first name, and last name of an actor, 
-- of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?
SELECT * FROM sakila.actor WHERE first_name = "JOE";
-- 2b Find all actors whose last name contain the letters `GEN`:
select * FROM sakila.actor 
WHERE last_name Like "%GEN%" ;
-- 2c Find all actors whose last names contain the letters `LI`. 
-- This time, order the rows by last name and first name, in that order:
SELECT last_name, first_name from sakila.actor
WHERE last_name like "%LI%" ;
-- 2d Using `IN`, 
-- display the `country_id` and `country` columns of the following countries:
--  Afghanistan, Bangladesh, and China:
SELECT  country_id, country from sakila.country
WHERE country in ("Afghanistan", "Bangladesh", "China");
-- 3a You want to keep a description of each actor. 
-- You don't think you will be performing queries on a description, 
-- so create a column in the table `actor` named `description` and use the data type `BLOB` 
-- (Make sure to research the type `BLOB`,
--  as the difference between it and `VARCHAR` are significant).

ALTER TABLE sakila.actor ADD Description BLOB;
SELECT * FROM sakila.actor;

-- 3b Very quickly you realize that entering descriptions for each actor is too much effort.
--  Delete the `description` column.

ALTER TABLE actor DROP Description ;
SELECT * FROM sakila.actor;

-- 4a List the last names of actors, as well as how many actors have that last name.

SELECT COUNT(actor_id), last_name
FROM actor
GROUP BY last_name;	

-- 4b List last names of actors and the number of actors who have that last name,
--  but only for names that are shared by at least two actors
SELECT COUNT(actor_id), last_name
FROM actor
GROUP BY last_name
HAVING COUNT(actor_id) >= 2; 
-- 4c The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as
--  `GROUCHO WILLIAMS`. Write a query to fix the record.
SELECT actor_id, last_name, first_name
FROM actor
WHERE actor_id = 172;

UPDATE actor
SET first_name ='HARPO'
WHERE  actor_id = 172;

-- 4d Perhaps we were too hasty in changing `GROUCHO` to `HARPO`.
--  It turns out that `GROUCHO` was the correct name after all! In a single query,
--  if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE actor
SET first_name = 'GROUCHO'
WHERE actor_id = 172;

-- 5a You cannot locate the schema of the `address` table. Which query would you use to re-create it?
SELECT *
FROM INFORMATION_SCHEMA.TABLES
WHERE Table_name = 'address';

-- 6a use Join to display first, last name and address of each staf members. use tables 'address' and 'staff'
SELECT first_name, last_name, address
FROM Sakila.staff
INNER JOIN Sakila.address
ON address.address_id = staff.address_id;
-- 6b 
-- Use `JOIN` to display the total amount rung up by each staff member in August of 2005.
-- Use tables `staff` and `payment`.
SELECT staff.first_name, staff.last_name , SUM(payment.amount)
FROM payment
INNER JOIN staff 
ON staff.staff_id = payment.staff_id
WHERE MONTH(payment.payment_date) = 08 AND YEAR(payment.payment_date) = 2005
GROUP BY staff.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. 
-- Use tables `film_actor` and `film`. Use inner join.
SELECT film.title, COUNT(film_actor.actor_id)
FROM film
INNER JOIN film_actor
ON film.film_id = film_actor.film_id
GROUP BY film.title;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT FILM.TITLE, COUNT(inventory.inventory_id)
FROM film
INNER JOIN INVENTORY
ON FILM.FILM_ID = INVENTORY.FILM_ID
WHERE FILM.TITLe = "Hunchback Impossible"
GROUP BY FILM.TITLE;

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer.
-- List the customers alphabetically by last name:
SELECT customer.first_name, CUSTOMER.last_name, SUM(payment.amount)
From customer
INNER JOIN PAYMENT
ON CUSTOMER.CUSTOMER_ID = PAYMENT.CUSTOMER_ID
Group by customer.customer_id; 

-- 7a Use subqueries to display the titles of movies starting with the 
-- letters `K` and `Q` whose language is English.


SELECT title
FROM film
WHERE title LIKE 'K%' OR  TITLE LIKE 'Q%'
AND title IN 
(
SELECT TITLE
FROM FILM
WHERE language_id = 1);

-- 7b Use subqueries to display all actors who appear in the film `Alone Trip`.

SELECT first_name, last_name
FROM actor
WHERE actor_id IN
(SELECT actor_id FROM film_actor WHERE film_id = (
SELECT film_id from film 
where title = 'Alone Trip'));


-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses 
-- of all Canadian customers. 
-- Use joins to retrieve this information.
-- no direct joins between customers data and country, so it needs to be through city then country.
SELECT FIRST_NAME, LAST_NAME, EMAIL
FROM CUSTOMER
INNER JOIN address
ON customer.address_id = address.address_id
INNER JOIN city
ON address.city_id = city.city_id
INNER JOIN country
ON city.country_id = country.country_id
WHERE country = 'Canada';

-- 7d. Sales have been lagging among young families, 
-- and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as _family_ films.

SELECT title 
FROM film
INNER JOIN film_category
ON film.film_id = film_category.film_id
INNER JOIN category
ON (film_category.category_id=category.category_id)
WHERE NAME = 'family'; 

-- 7e. Display the most frequently rented movies in descending order.
SELECT film.title, COUNT(film.film_id) AS rented_movies
FROM film
INNER JOIN INVENTORY
ON film.film_id = inventory.film_id
INNER JOIN rental
ON rental.inventory_id = inventory.inventory_id
GROUP BY  title
ORDER BY rented_movies DESC;

 -- 7f. Write a query to display how much business, in dollars, each store brought in.
 SELECT payment_id, SUM(amount) AS REVENUE
 FROM payment
 INNER JOIN rental
 ON payment.rental_id = rental.rental_id
 INNER JOIN inventory
 ON rental.inventory_id = inventory.inventory_id
 GROUP BY payment_id ;
 
-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT store_id, city, country
FROM store
INNER JOIN address
ON store.address_id = address.address_id
INNER JOIN city
ON city.city_id = address.city_id
INNER JOIN country
ON city.country_id = country.country_id;

-- 7h. List the top five genres in gross revenue in descending order. 
-- (**Hint**: you may need to use the following tables:
-- category, film_category, inventory, payment, and rental.)

SELECT category.name, SUM(amount) AS 'gross_revenue'
FROM category
INNER JOIN film_category
ON category.category_id = film_category.category_id
INNER JOIN inventory
ON film_category.film_id = inventory.film_id
INNER JOIN rental
ON inventory.inventory_id = rental.inventory_id
INNER JOIN payment
ON payment.rental_id = rental.rental_id
GROUP BY category.name 
ORDER BY gross_revenue Desc
LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the 
-- Top five genres by gross revenue. Use the solution from the problem above to create a view.
-- If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW genre_revenue AS
SELECT category.name AS 'genre', SUM(amount) AS 'gross_revenue'
FROM category
INNER JOIN film_category
ON category.category_id = film_category.category_id
INNER JOIN inventory
ON film_category.film_id = inventory.film_id
INNER JOIN rental
ON inventory.inventory_id = rental.inventory_id
INNER JOIN payment
ON payment.rental_id = rental.rental_id
GROUP BY category.name
ORDER BY gross_revenue 
LIMIT 5;

-- 8b. How would you display the view that you created in 8a?

SELECT *
FROM genre_revenue;
 
-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.

DROP VIEW genre_revenue;
 

-- SELECT  some column_name from the table one, that makes sense in the reference to the question
-- FROM table1
-- INNER JOIN table2
-- ON table1.column_name = table2.column_name
-- INNER JOIN table3
-- ON table2.column_name = table3.column_name


