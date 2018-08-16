-- Quiz Funnel Queries start:
 -----------------------------
 -- Task 1: first 10 rows all columns Quiz Funnel
 SELECT *
 FROM survey
 LIMIT 10;
 -- cols: question, user_id, response

 -- Task 2: Quiz Funnel: how many answered which q.?
 SELECT question,
 	COUNT(DISTINCT user_id)
 FROM survey
 GROUP BY question;

 -- Further queries with Quiz Funnel:
 -- Frequency of individual responses?
 SELECT question, response,
 	COUNT(response)
 FROM survey
 GROUP BY response
 ORDER BY question;

 -- How many different users are not sure Q1?
 SELECT response,
 	COUNT(DISTINCT user_id)
 FROM survey
 WHERE response = "I'm not sure. Let's skip it.";
 -- NB 96 'not sures' from 92 different users

 -- How many different users are not sure Q5?
 SELECT response,
 	COUNT(DISTINCT user_id)
 FROM survey
 WHERE response = "Not Sure. Let's Skip It";
 -- 36 'not sures' from 36 different users

 -- N.B.
 -- 'not sure' wording different in Q1 vs Q5
 -- simple 'Skip' button maybe easier on eye?

 -- How many response types per question?
 SELECT question,
 	COUNT(DISTINCT response)
 FROM survey
 GROUP BY question;
 -- How to simplify quiz funnel questions:
 -- drop men vs. women style given unisex possible?
 -- make color first question?
 -- keep shape simple: just more round or more square?
 -- make eye exam easy: > 1 year - yes/no button?
 -- for fit: = or > or < than an 'Average head size'?

 -- Task 3: see spreadsheet
 -- big response dropouts for Q3 (20%) & Q5(25%)

 -- Home Try-On Funnel Queries start:
 ------------------------------------
 -- Task 4: Home Try-On tables 1st 5 rows
 SELECT *
 FROM quiz
 LIMIT 5;
 --cols: user_id, style, fit, shape, color

 SELECT *
 FROM home_try_on
 LIMIT 5;
 --cols: user_id, number_of_pairs, address

 SELECT *
 FROM purchase
 LIMIT 5;
 --cols: user_id, product_id, style, model_name, color, price

-- Task 5: From Quiz to Home Try-On to Purchase
SELECT DISTINCT q.user_id,
   h.user_id IS NOT NULL AS 'is_home_try_on',
   h.number_of_pairs,
   p.user_id IS NOT NULL AS 'is_purchase'
FROM quiz q
LEFT JOIN home_try_on h
   ON q.user_id = h.user_id
LEFT JOIN purchase p
   ON p.user_id = q.user_id
LIMIT 10;

-- Task 6: Conversion Rates Insights
WITH converts AS(
  SELECT DISTINCT q.user_id,
   h.user_id IS NOT NULL AS 'is_home_try_on',
   h.number_of_pairs,
   p.user_id IS NOT NULL AS 'is_purchase'
FROM quiz q
LEFT JOIN home_try_on h
   ON q.user_id = h.user_id
LEFT JOIN purchase p
   ON p.user_id = q.user_id)
SELECT SUM(is_home_try_on) AS 'try_on_converts',
	SUM(is_purchase) AS 'purchase_converts',
  1.0 * SUM(is_home_try_on) / COUNT(user_id) AS 'Quiz to Home Conversion',
  1.0 * SUM(is_purchase) / SUM(is_home_try_on) AS 'Home to Purchase Conversion'
FROM converts;

-- A/B Test : 3 or 5 pair try-ons more likely to purchase?
WITH converts AS(
  SELECT DISTINCT q.user_id,
   h.user_id IS NOT NULL AS 'is_home_try_on',
   h.number_of_pairs,
   p.user_id IS NOT NULL AS 'is_purchase'
FROM quiz q
LEFT JOIN home_try_on h
   ON q.user_id = h.user_id
LEFT JOIN purchase p
   ON p.user_id = q.user_id)
SELECT CASE
	WHEN number_of_pairs LIKE '%3 pairs%' THEN '3_pair_control'
  WHEN number_of_pairs LIKE '%5 pairs%' THEN '5_pair_test'
  ELSE NULL
  END AS 'ab_test',
  COUNT(is_purchase) AS 'Purchase Made'
FROM converts
WHERE ab_test IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC;
-- NB 50% of try-ons were 3 pairs & 50% were 5 pairs
-- 3 pairs more likely to lead to purchase (379 vs 371)??

-- A/B Test Mark 2
WITH converts AS(
  SELECT DISTINCT q.user_id,
   h.user_id IS NOT NULL AS 'is_home_try_on',
   h.number_of_pairs,
   p.user_id IS NOT NULL AS 'is_purchase'
FROM quiz q
LEFT JOIN home_try_on h
   ON q.user_id = h.user_id
LEFT JOIN purchase p
   ON p.user_id = q.user_id)
SELECT number_of_pairs,
	SUM(is_purchase) AS '3 vs 5 pair Trials'
FROM converts
GROUP BY number_of_pairs;

-- Original Tables examined:
----------------------------
-- For quiz table
SELECT style,
	COUNT(DISTINCT user_id)
FROM quiz
GROUP BY style;
-- 99 individuals not sure if men or women's style
-- survey table figures differ = quiz retakes?

SELECT fit,
	COUNT(DISTINCT user_id)
FROM quiz
GROUP BY fit;
-- 89 individuals not sure about fit
-- most fall into medium / narrow categories

SELECT shape,
	COUNT(DISTINCT user_id)
FROM quiz
GROUP BY shape;
-- 97 have no preferred shape
-- most rectangular / square

SELECT color,
	COUNT(DISTINCT user_id)
FROM quiz
GROUP BY color;
-- more classic preferred: why?

-- For home_try_on table
SELECT number_of_pairs,
	COUNT(DISTINCT user_id)
FROM home_try_on
GROUP BY number_of_pairs;
-- misleading figures: see A/B Test Mark 2 instead

SELECT number_of_pairs,
	COUNT(DISTINCT address)
FROM home_try_on
GROUP BY number_of_pairs;
-- only one household had 2 home try-ons for 5 pairs each?
-- see 370 distinct addresses v-a-v 371 distinct users
-- for 3 pairs users & addresses same (both 379)

-- For purchase table
SELECT color,
	COUNT(DISTINCT user_id)
FROM purchase;
-- different colors in quiz to sea glass grey purchases

SELECT style,
	COUNT(DISTINCT user_id)
FROM purchase;
-- only men's styles purchased?

SELECT model_name,
	COUNT(DISTINCT user_id)
FROM purchase;
-- just model Brady purchased?

SELECT price,
	COUNT(DISTINCT user_id)
FROM purchase;
-- all glasses same price = standard issue / no extras?
