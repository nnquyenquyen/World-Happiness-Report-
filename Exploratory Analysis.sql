-- Answer some basic questions to explore the data:
    -- WHR_1517: dataset about World Happiness Report from 2015 to 2017
    -- WHR_1819: dataset about World Happiness Report from 2018 to 2019
    -- WHR_2021: dataset about World Happiness Report from 2020 to 2021

-- 1. What are top 5 countries with highest happiness score in each year? (EDA1.csv)
SELECT Report_Year, Rank, Country, ROUND(Score,3) as Score
FROM 
    (SELECT Country, Score, Report_Year, Rank
    FROM dbo.WHR_1517
    UNION 
    SELECT Country, Score, Report_Year, Rank
    FROM dbo.WHR_1819
    UNION
    SELECT Country, Score, Report_Year, Rank
    FROM dbo.WHR_2021) AS WHR_1521
WHERE Rank <= 5
ORDER BY Rank, Report_Year ASC;

-- 2. What are top countries appear most in the top 10 happiest countries in 2015-2021? (EDA2.csv)
SELECT Country, Region, COUNT(Country) AS Count,
    AVG(Score) AS Average_Score
FROM 
    (SELECT Country, Region, Score, Report_Year, Rank
    FROM dbo.WHR_1517
    UNION 
    SELECT Country, Region,Score, Report_Year, Rank
    FROM dbo.WHR_1819
    UNION
    SELECT Country, Region, Score, Report_Year, Rank
    FROM dbo.WHR_2021) AS WHR_1521
WHERE Rank <= 10
GROUP BY Country, Region
ORDER BY COUNT(Country) DESC
    -- Western Europe is the region that appears most in the top 10 happiest countries in 2015-2021, 
    -- with 7 countries in the top 10 happiest countries 7 years in 2015-2021

-- 3. What are top 5 countries with highest happiness score in each region in 2015-2021? (EDA3.csv)
WITH Top_Region AS (
SELECT Region, Country, Score, Report_Year, 
    RANK() OVER (PARTITION BY Region, Report_Year ORDER BY Score DESC) AS Region_Rank
FROM 
    (SELECT Country, Region, Score, Report_Year, Rank
    FROM dbo.WHR_1517
    UNION 
    SELECT Country, Region,Score, Report_Year, Rank
    FROM dbo.WHR_1819
    UNION
    SELECT Country, Region, Score, Report_Year, Rank
    FROM dbo.WHR_2021) AS WHR_1521
)

SELECT Report_Year, Region,  Region_Rank, Country, ROUND(Score, 3) AS Score
FROM Top_Region
WHERE Region_Rank <= 5
ORDER BY Report_Year, Region, Region_Rank ASC;

-- 4. Does the perception of generosity depend on GDP per capita (exclude 20-21 data)? (EDA4.csv)
    -- Check the range of GDP per capita in 2015-2019
    SELECT Report_Year, 
        MAX(GDP_per_Capita)  as max, 
        MIN(GDP_per_Capita) as MIN, 
        AVG(GDP_per_Capita) as AVG
    FROM 
        (SELECT Report_Year, GDP_per_Capita
        FROM dbo.WHR_1517
        UNION
        SELECT Report_Year, GDP_per_Capita
        FROM dbo.WHR_1819) AS WHR_1519
    GROUP BY Report_Year

    -- Divide the GDP per capita into 3 groups: low, medium, high to see the correlation with generousity
    SELECT 
        CASE
            WHEN GDP_per_Capita < 0.5 THEN 'Low'
            WHEN GDP_per_Capita >= 0.5 AND GDP_per_Capita < 1.5 THEN 'Medium'
            ELSE 'High'
        END AS GDP_range,
        AVG(Generosity) AS Avg_Generosity
       
    FROM 
        (SELECT Report_Year, GDP_per_Capita, Generosity 
        FROM dbo.WHR_1517
        UNION
        SELECT Report_Year, GDP_per_Capita, Generosity 
        FROM dbo.WHR_1819) AS WHR_1519
    GROUP BY
        CASE 
            WHEN GDP_per_Capita < 0.5 THEN 'Low'
            WHEN GDP_per_Capita >= 0.5 AND GDP_per_Capita < 1.5 THEN 'Medium'
            ELSE 'High'
        END
    ORDER BY Avg_Generosity DESC
-- The result shows that the highest average generosity is in the group with highest GDP per capita but 
-- there is no significant correlation between GDP per capita and generosity

-- 5. Correlation between each variable and score (EDA5.csv): WHR_1521
    
    -- Calculate mean of each variable 
    WITH mean AS (
    -- Calculate mean of each variable 
    SELECT  
        Score, AVG(Score) OVER() AS Avg_Score,
        Life_Expectancy, AVG(Life_Expectancy) OVER() AS Avg_Life_Expectancy, 
        Freedom, AVG(Freedom) OVER() AS Avg_Freedom, 
        Generosity, AVG(Generosity) OVER() AS Avg_Generosity, 
        Corruption, AVG(Corruption) OVER() AS Avg_Corruption
    FROM dbo.WHR_1521
)

,
covar AS (
    -- Calculate covariance of each variable
    SELECT 
        AVG( (Score - Avg_Score) * (Life_Expectancy - Avg_Life_Expectancy)) AS Covar_Score_Life_Expectancy,
        AVG( (Score - Avg_Score) * (Freedom - Avg_Freedom)) AS Covar_Score_Freedom,
        AVG( (Score - Avg_Score) * (Generosity - Avg_Generosity)) AS Covar_Score_Generosity,
        AVG( (Score - Avg_Score) * (Corruption - Avg_Corruption)) AS Covar_Score_Corruption
    FROM mean
    
),
stdev AS (
    -- Calculate StDev of each variable
    SELECT 
        SQRT(AVG(POWER(Score - Avg_Score, 2))) AS StDev_Score,
        SQRT(AVG(POWER(Life_Expectancy - Avg_Life_Expectancy, 2))) AS StDev_Life_Expectancy,
        SQRT(AVG(POWER(Freedom - Avg_Freedom, 2))) AS StDev_Freedom,
        SQRT(AVG(POWER(Generosity - Avg_Generosity, 2))) AS StDev_Generosity,
        SQRT(AVG(POWER(Corruption - Avg_Corruption, 2))) AS StDev_Corruption
    FROM mean
  
)
SELECT
    covar.Covar_Score_Life_Expectancy / (stdev.StDev_Score * stdev.StDev_Life_Expectancy) AS Corr_Score_Life_Expectancy,
    covar.Covar_Score_Freedom / (stdev.StDev_Score * stdev.StDev_Freedom) AS Corr_Score_Freedom,
    covar.Covar_Score_Generosity / (stdev.StDev_Score * stdev.StDev_Generosity) AS Corr_Score_Generosity,
    covar.Covar_Score_Corruption / (stdev.StDev_Score * stdev.StDev_Corruption) AS Corr_Score_Corruption
FROM covar, stdev 

-- The result shows that there is a strong correlation between score and freedom, score and life expectancy. 




