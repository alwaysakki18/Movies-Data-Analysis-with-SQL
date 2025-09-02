-- ===========================================================
-- 🎬 MOVIE ANALYSIS SQL PROJECT
-- Author: Kavyanshu Pawar
-- Dataset: Movies_2025
-- Purpose: Answer business questions using SQL
-- ===========================================================

/* =====================
   EASY QUERIES
===================== */

-- Q1. List all movies with their title and IMDb rating
SELECT Title, IMDb_Rating
FROM Movies_2025;

-- Q2. Find movies released after 2020
SELECT Title, Release_Date
FROM Movies_2025
WHERE Release_Date > '2020-01-01';

-- Q3. Get total number of movies in the database
SELECT COUNT(*) AS Total_Movies
FROM Movies_2025;


/* =====================
   MODERATE QUERIES
===================== */

-- Q1. Top 5 movies with highest worldwide collections
SELECT TOP 5 Title, Worldwide_Collection_in_Crores
FROM Movies_2025
ORDER BY Worldwide_Collection_in_Crores DESC;

-- Q2. Average IMDb rating by language
SELECT L.Language,
       ROUND(AVG(M.IMDb_Rating), 2) AS Avg_Rating
FROM Movies_2025 M
INNER JOIN Language L ON M.LanguageID = L.LanguageID
GROUP BY L.Language
ORDER BY Avg_Rating DESC;

-- Q3. Top 3 directors based on average IMDb rating of their movies
SELECT TOP 3 D.Director,
       ROUND(AVG(M.IMDb_Rating), 2) AS Avg_Rating
FROM Movies_2025 M
INNER JOIN Director D ON M.DirectorID = D.Director_ID
GROUP BY D.Director
ORDER BY Avg_Rating DESC;


/* =====================
   ADVANCED QUERIES
===================== */

-- Q1. Top-grossing movie for each genre released after 2015 with IMDb rating above 6
WITH GenreTopMovies AS (
    SELECT M.Title,
           G.Genre,
           M.Worldwide_Collection_in_Crores,
           M.IMDb_Rating,
           M.Release_Date,
           RANK() OVER (PARTITION BY M.GenreID ORDER BY M.Worldwide_Collection_in_Crores DESC) AS GenreRank
    FROM Movies_2025 M
    INNER JOIN Genre G ON M.GenreID = G.GenreID
    WHERE M.Release_Date > '2015-01-01'
      AND M.IMDb_Rating > 6
)
SELECT Genre, Title, Worldwide_Collection_in_Crores, IMDb_Rating, Release_Date
FROM GenreTopMovies
WHERE GenreRank = 1
ORDER BY Worldwide_Collection_in_Crores DESC;

-- Q2. For each director, find their most profitable movie along with its genre, language, and OTT platform
WITH MovieProfit AS (
    SELECT M.FilmID,
           M.Title,
           M.DirectorID,
           M.LanguageID,
           M.GenreID,
           (M.Worldwide_Collection_in_Crores - M.Budget_in_Crores) AS Profits,
           M.OTT_Platform,
           RANK() OVER (PARTITION BY M.DirectorID ORDER BY (M.Worldwide_Collection_in_Crores - M.Budget_in_Crores) DESC) AS RankedDirector
    FROM Movies_2025 M
    WHERE M.Budget_in_Crores IS NOT NULL
      AND M.Worldwide_Collection_in_Crores IS NOT NULL
)
SELECT D.Director,
       MP.Title AS Movie,
       G.Genre,
       L.Language,
       MP.OTT_Platform
FROM MovieProfit MP
INNER JOIN Director D ON MP.DirectorID = D.Director_ID
INNER JOIN Genre G ON MP.GenreID = G.GenreID
INNER JOIN Language L ON MP.LanguageID = L.LanguageID
WHERE RankedDirector = 1
ORDER BY MP.Profits DESC;

-- Q3. Actor with highest grossing movie in each language
WITH ProfitableActors AS (
    SELECT M.Lead_Actor_Actress,
           M.Title,
           M.LanguageID,
           M.Worldwide_Collection_in_Crores,
           RANK() OVER (PARTITION BY M.Lead_Actor_Actress, M.LanguageID ORDER BY M.Worldwide_Collection_in_Crores DESC) AS Rank_of_Actor
    FROM Movies_2025 M
    WHERE M.Worldwide_Collection_in_Crores IS NOT NULL
)
SELECT PBA.Lead_Actor_Actress,
       PBA.Title,
       PBA.Worldwide_Collection_in_Crores,
       L.Language
FROM ProfitableActors PBA
INNER JOIN Language L ON PBA.LanguageID = L.LanguageID
WHERE PBA.Rank_of_Actor = 1
ORDER BY Worldwide_Collection_in_Crores DESC;
