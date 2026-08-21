-- Verifying tables
SELECT * FROM train LIMIT 5;
SELECT COUNT(*) FROM train;

SELECT * FROM validation LIMIT 5;
SELECT COUNT(*) FROM validation;

SELECT * FROM test LIMIT 5;
SELECT COUNT(*) FROM test;

-- Total reviews in training dataset
SELECT COUNT(review_text) FROM train;

SELECT COUNT(*) FROM train
WHERE review_text IS NULL;

-- Unique buissness
SELECT COUNT(DISTINCT business_id) FROM train;
SELECT COUNT(DISTINCT business_id) FROM validation;
SELECT COUNT(DISTINCT business_id) FROM test;

-- Unique user ids
SELECT COUNT(DISTINCT user_id) FROM train;
SELECT COUNT(DISTINCT user_id) FROM validation;
SELECT COUNT(DISTINCT user_id) FROM test;

-- DISTINCT rating
SELECT DISTINCT rating FROM train;

-- How many DISTINCT review_text
SELECT COUNT(DISTINCT review_text) FROM train;

-- How many reviews have NULL review_text
SELECT COUNT(*) FROM train
WHERE review_text IS NULL;

-- Show reviews with rating = 5
SELECT review_text FROM train
WHERE rating = 5;

-- Show reviews with rating <= 2
SELECT review_text FROM train
WHERE rating <= 2;

-- Finding reviews containing particular word 'Like'
SELECT * FROM train
WHERE review_text LIKE '%like%';

-- Find business IDs match a pattern using like
SELECT Business_id FROM train
WHERE review_text LIKE '%like%';



-- Count number of reviews for each rating
SELECT rating , COUNT(review_text) AS num_of_reviews FROM train
GROUP BY rating
ORDER BY num_of_reviews DESC;

-- Average rating
SELECT AVG(rating) FROM train;

-- Minimum rating
SELECT MIN(rating) FROM train; 

-- Maximum rating
SELECT MAX(rating) FROM train; 

-- COUNT reviews for each business id
SELECT business_id, COUNT(review_text) AS num_of_reviews
FROM train
GROUP BY business_id;

-- Top 10 business by number of reviews
SELECT business_id, COUNT(review_text) AS num_of_reviews
FROM train
GROUP BY business_id
ORDER BY num_of_reviews DESC
LIMIT 10;

-- Find business having more than 100 reviews
SELECT business_id, COUNT(review_text) AS num_of_reviews
FROM train
GROUP BY business_id
HAVING COUNT(review_text)>100; 

-- calculate average rating for each business
SELECT business_id , AVG(rating) 
FROM train
GROUP BY business_id;

-- Find business whose average is reater than 4
SELECT business_id , AVG(rating) 
FROM train
GROUP BY business_id
HAVING AVG(rating)>4;

-- Fing top 10 business having avg greater than 4 order from highest to lowest
SELECT business_id , AVG(rating) AS avg_rating
FROM train
GROUP BY business_id
HAVING AVG(rating)>4
ORDER BY avg_rating DESC
LIMIT 10;

-- How many table contain business_id
SELECT table_name , column_name
FROM information_schema.columns
WHERE column_name = 'business_id';

-- JOIN
SELECT t.business_id , t.rating AS train_rating, v.rating AS validation_rating
FROM train t
INNER JOIN validation v
ON t.business_id = v.business_id;

-- Find all reviews whose rating is greater than overall average rating
WITH avg_rating AS(
SELECT AVG(rating) AS average FROM train
)
SELECT t.review_text, t.rating
FROM train t, avg_rating a
WHERE t.rating > a.average;

-- Find business whose rating is greater than avg rating
WITH counts AS(
SELECT business_id , COUNT(review_text) AS review_count
FROM train
GROUP BY business_id
),
filtering AS(
SELECT business_id, review_count
FROM counts
WHERE review_count >= 100
),
avg_review AS(
SELECT AVG(review_count) AS avg_review_count 
FROM filtering
)
SELECT f.business_id, f.review_count FROM filtering f
CROSS JOIN avg_reviEw a
WHERE f.review_count > a.avg_review_count
ORDER BY f.review_count DESC;

-- Business with rating with above overall average
WITH i_rating AS(
SELECT business_id , AVG(rating) AS avg_rating
FROM train
GROUP BY business_id
),
o_rating AS(
SELECT AVG(avg_rating) AS overall_rating
FROM i_rating
)
SELECT i.business_id, i.avg_rating
FROM i_rating i
CROSS JOIN o_rating o
WHERE i.avg_rating > o.overall_rating
ORDER BY i.avg_rating;

-- Business with more review than average
WITH counts AS(
SELECT business_id , COUNT(review_text) AS review_count
FROM train
GROUP BY business_id
),
avg_count AS(
SELECT AVG(review_count) AS avg_review_count FROM counts
)
SELECT c.business_id, c.review_count FROM counts c
CROSS JOIN avg_count a
WHERE c.review_count > a.avg_review_count
ORDER BY c.review_count DESC;

-- Reviews more than 20 and rating >4
WITH counts AS(
SELECT business_id, COUNT(review_text) AS review_count,  AVG(rating) AS a_rating
FROM train
GROUP BY business_id
)
SELECT c.business_id, c.review_count, c.a_rating 
FROM counts c
WHERE c.review_count > 20 AND c.a_rating > 4
ORDER BY c.review_count DESC;



                     -- WINDOW FUNCTION
					 
-- Overall average using window function
SELECT business_id, rating, 
AVG(rating) OVER() AS overall_avg_rating
FROM train;

-- Business average beside every review
SELECT business_id, rating, 
AVG(rating) OVER(PARTITION BY business_id) AS overall_avg_rating
FROM train;

-- Number of reviews for each business while keeping 
SELECT business_id, rating,
COUNT(review_text) OVER(PARTITION BY business_id) AS review_count
FROM train;

-- Number of reviews written by each user
SELECT business_id, rating, user_id,
COUNT(review_text) OVER(PARTITION BY user_id)  AS num_of_reviews
FROM train;

-- Rank business by number of reviews
SELECT 
      business_id, 
	  COUNT(review_text) AS review_count,
      RANK() OVER(
	      ORDER BY COUNT(review_text) DESC
      ) AS review_rank
FROM train
GROUP BY business_id
ORDER BY review_rank;

-- Show each business with average rating and overall average rating
SELECT business_id, rating,
AVG(rating) OVER(PARTITION BY business_id) AS bus_avg_rating,
AVG(rating) OVER() AS overall_average
FROM train;

-- Difference between Business average and overall average
SELECT business_id, rating,
AVG(rating) OVER(PARTITION BY business_id) AS bus_avg_rating,
AVG(rating) OVER() AS overall_average,
AVG(rating) OVER(PARTITION BY business_id) - AVG(rating) OVER() AS difference
FROM train;

-- Top 10 Businesses by review count
WITH business_count AS(
SELECT business_id, COUNT(*) AS review_count
FROM train 
GROUP BY business_id
),
ranked_business AS(
SELECT business_id, review_count,
RANK() OVER(ORDER BY review_count DESC) AS review_rank
FROM business_count
)
SELECT * FROM ranked_business
ORDER BY review_rank
LIMIT 10;

-- Top 3 business by average rating
WITH business_count AS(
SELECT business_id , AVG(rating) AS avg_rating
FROM train
GROUP BY business_id
),
ranked_business AS(
SELECT business_id, avg_rating,
RANK() OVER(ORDER BY avg_rating DESC) AS average_rank
FROM business_count
)
SELECT * FROM ranked_business
WHERE average_rank <=3
ORDER BY average_rank;

-- Business with more than 20 reviews and average_rating>4
WITH business_reviews AS(
SELECT business_id, COUNT(review_text) AS review_count,
AVG(rating) AS avg_rating
FROM train
GROUP BY business_id
HAVING COUNT(review_text)>=20
AND 
avg(rating)>4
),
ranked_business AS (
SELECT business_id, review_count, avg_rating,
RANK() OVER(ORDER BY review_count DESC) AS ranking
FROM business_reviews
)
SELECT * FROM ranked_business
ORDER BY ranking;


                                -- BUSINESS INSIGHTS
-- Which 10 business have highest number of reviews
SELECT business_id, COUNT(review_text) AS review_count
FROM train
GROUP BY business_id
ORDER BY COUNT(review_text) DESC
LIMIT 10;

-- Most high rated business
SELECT business_id, AVG(rating) AS avg_rating
FROM train
GROUP BY business_id
HAVING AVG(rating) > 4
ORDER BY AVG(rating) ASC;

-- Which business have at least 20 reviews and average rating above 4
WITH business_reviews AS(
SELECT business_id, COUNT(review_text) AS review_count,
AVG(rating) AS avg_rating
FROM train
GROUP BY business_id
HAVING COUNT(review_text)>=20
AND 
avg(rating)>4
)
SELECT business_id, review_count, avg_rating
FROM business_reviews;

-- Business with poor performance
SELECT business_id , AVG(rating) AS avg_rating
FROM train
GROUP BY business_id
HAVING AVG(rating) <=3;

-- Business with unusually high review volume than average
WITH count_review AS(
SELECT business_id, COUNT(review_text) AS review_count
FROM train
GROUP BY business_id
),
avg_review AS(
SELECT AVG(review_count) AS avg_review_count
FROM count_review
)
SELECT business_id c, review_count c , avg_review_count a
FROM count_review c
CROSS JOIN avg_review a
WHERE c.review_count > a.avg_review_count;

-- Most active users
SELECT user_id, COUNT(review_text) AS review_count
FROM train
GROUP BY user_id
ORDER BY COUNT(review_text) DESC
LIMIT 10;

-- One time vs repeat time
WITH counts AS(
SELECT user_id,COUNT(*) AS review_count
FROM train
GROUP BY user_id
)
SELECT 
     CASE 
	    WHEN review_count = 1
		THEN 'One review'
		ELSE
		    'Multiple reviews'
		END AS
		     "User type",
COUNT(*) AS total_review  FROM counts
GROUP BY 
       CASE 
	      WHEN review_count = 1 
		  THEN 'One review'
		  ELSE
		     'Multiple reviews'
	      END;

-- Top 10 business by average rating
WITH avg_rating AS(
SELECT business_id, AVG(rating) AS average
FROM train
GROUP BY business_id
),
count_reviews AS(
SELECT business_id, COUNT(*) AS num_of_reviews
FROM train
GROUP BY business_id
)
SELECT a.business_id, a.average, c.num_of_reviews
FROM avg_rating a
JOIN count_reviews c
ON a.business_id = c.business_id
WHERE num_of_reviews > 20
ORDER BY num_of_reviews DESC
LIMIT 10;

-- Business with high reviews with low average rating
WITH high_review AS(
SELECT business_id, AVG(rating) AS avg_rating,
COUNT(*) AS review_count
FROM train
GROUP BY business_id
)
SELECT business_id, avg_rating, review_count
FROM high_review
WHERE avg_rating < 4 AND review_count > 40
ORDER BY review_count DESC;

-- Business with low reviews with high average rating
WITH high_review AS(
SELECT business_id, AVG(rating) AS avg_rating,
COUNT(*) AS review_count
FROM train
GROUP BY business_id
)
SELECT business_id, avg_rating, review_count
FROM high_review
WHERE avg_rating > 4.5 AND review_count < 20
ORDER BY review_count DESC;

-- Overall average rate distribution
SELECT rating , COUnt(*) AS review_count
FROM train
GROUP BY rating
ORDER BY rating;
