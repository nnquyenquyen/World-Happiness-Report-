-- DATA CLEANING

-- Create a table to store data WHR_17_raw
DROP TABLE IF EXISTS dbo.WHR_17_raw
CREATE TABLE dbo.WHR_17_raw (
    Country VARCHAR(50),
	Rank INT,
	Score FLOAT,
	GDP_per_Capita FLOAT,
	Family FLOAT,
	Life_Expectancy FLOAT,
	Freedom FLOAT,
	Generosity FLOAT,
	Corruption FLOAT,
	Dystopia_Residual FLOAT
);

-- import the file
BULK INSERT dbo.WHR_17_raw
FROM '/tmp/2017.csv'
WITH (
    FIRSTROW = 2,       -- Skip header row if applicable
    FIELDTERMINATOR = ',',  -- Specify the field delimiter used in your CSV file
    ROWTERMINATOR = '<>'    -- Specify the row delimiter used in your CSV file
);

-- check the table
SELECT * FROM dbo.WHR_17_raw

--------------------
-- Create a table to store data of 2015-2016
CREATE TABLE dbo.WHR_15_raw (
    Country VARCHAR(50),
	Region VARCHAR(50),
	Rank INT,
	Score FLOAT,
	GDP_per_Capita FLOAT,
	Family FLOAT,
	Life_Expectancy FLOAT,
	Freedom FLOAT,
	Generosity FLOAT,
	Corruption FLOAT,
	Dystopia_Residual FLOAT

);

CREATE TABLE dbo.WHR_16_raw (
    Country VARCHAR(50),
	Region VARCHAR(50),
	Rank INT,
	Score FLOAT,
	GDP_per_Capita FLOAT,
	Family FLOAT,
	Life_Expectancy FLOAT,
	Freedom FLOAT,
	Generosity FLOAT,
	Corruption FLOAT,
	Dystopia_Residual FLOAT

);

-- import the file 2015.csv and 2016.csv into the data table
BULK INSERT dbo.WHR_15_raw
FROM '/tmp/2015.csv'
WITH (
    FIRSTROW = 2,       -- Skip header row if applicable
    FIELDTERMINATOR = ',',  -- Specify the field delimiter used in your CSV file
    ROWTERMINATOR = '0x0a'    -- Specify the row delimiter used in your CSV file
);

BULK INSERT dbo.WHR_16_raw
FROM '/tmp/2016.csv'
WITH (
    FIRSTROW = 2,       -- Skip header row if applicable
    FIELDTERMINATOR = ',',  -- Specify the field delimiter used in your CSV file
    ROWTERMINATOR = '0x0a'    -- Specify the row delimiter used in your CSV file
);

-- Add Region column to 2017 data
	-- Step 1: Add a new column to the existing table
	ALTER TABLE dbo.WHR_17_raw
	ADD Region VARCHAR(50);

	-- Step 2: Update the new column with data from another table
		UPDATE dbo.WHR_17_raw
	SET Region = (
    	SELECT Region
    	FROM dbo.WHR_15_raw
    	WHERE dbo.WHR_17_raw.Country = dbo.WHR_15_raw.Country
	);

	SELECT * FROM dbo.WHR_17_raw


-- Union all 2015, 2016, 2017 data into a single table 
DROP TABLE IF EXISTS dbo.WHR_1517 
CREATE TABLE dbo.WHR_1517
(
    Country VARCHAR(50),
	Region VARCHAR(50),
	Rank INT,
	Score FLOAT,
	GDP_per_Capita FLOAT,
	Family FLOAT,
	Life_Expectancy FLOAT,
	Freedom FLOAT,
	Generosity FLOAT,
	Corruption FLOAT,
	Dystopia_Residual FLOAT,
	Report_Year INT

);

INSERT INTO dbo.WHR_1517 (
	Country ,
	Region,
	Rank ,
	Score ,
	GDP_per_Capita ,
	Family ,
	Life_Expectancy ,
	Freedom ,
	Generosity ,
	Corruption ,
	Dystopia_Residual ,
	Report_Year
)
SELECT Country ,
	Region,
	Rank ,
	Score ,
	GDP_per_Capita ,
	Family ,
	Life_Expectancy ,
	Freedom ,
	Generosity ,
	Corruption ,
	Dystopia_Residual , '2015' 
FROm dbo.WHR_15_raw
UNION ALL
SELECT Country ,
	Region,
	Rank ,
	Score ,
	GDP_per_Capita ,
	Family ,
	Life_Expectancy ,
	Freedom ,
	Generosity ,
	Corruption ,
	Dystopia_Residual , '2016' 
FROM dbo.WHR_16_raw
UNION ALL
SELECT Country ,
	Region,
	Rank ,
	Score ,
	GDP_per_Capita ,
	Family ,
	Life_Expectancy ,
	Freedom ,
	Generosity ,
	Corruption ,
	Dystopia_Residual , '2017' 
FROM dbo.WHR_17_raw

SELECT * FROM dbo.WHR_1517



------------------
-- LOAD 2018 and 2019 DATA

-- Create table to store data 2018-2019
CREATE TABLE dbo.WHR_18_raw (
	Rank INT,
    Country VARCHAR(50),
	Score FLOAT,
	GDP_per_Capita FLOAT,
	Social_Support FLOAT,
	Life_Expectancy FLOAT,
	Freedom FLOAT,
	Generosity FLOAT,
	Corruption FLOAT

);

CREATE TABLE dbo.WHR_19_raw (
    Rank INT,
    Country VARCHAR(50),
	Score FLOAT,
	GDP_per_Capita FLOAT,
	Social_Support FLOAT,
	Life_Expectancy FLOAT,
	Freedom FLOAT,
	Generosity FLOAT,
	Corruption FLOAT

);

-- import the file 2018.csv and 2019.csv into the data table
BULK INSERT dbo.WHR_18_raw
FROM '/tmp/2018.csv'
WITH (
    FIRSTROW = 2,       -- Skip header row if applicable
    FIELDTERMINATOR = ',',  -- Specify the field delimiter used in your CSV file
    ROWTERMINATOR = '0x0a'    -- Specify the row delimiter used in your CSV file
);

BULK INSERT dbo.WHR_19_raw
FROM '/tmp/2019.csv'
WITH (
    FIRSTROW = 2,       -- Skip header row if applicable
    FIELDTERMINATOR = ',',  -- Specify the field delimiter used in your CSV file
    ROWTERMINATOR = '0x0a'    -- Specify the row delimiter used in your CSV file
);

SELECT * FROM dbo.WHR_18_raw
SELECT * FROM dbo.WHR_19_raw

-- Union 2018 and 2019 in a single table
DROP TABLE IF EXISTS dbo.WHR_1819
CREATE TABLE dbo.WHR_1819 (
	Rank INT,
    Country VARCHAR(50),
	Score FLOAT,
	GDP_per_Capita FLOAT,
	Social_Support FLOAT,
	Life_Expectancy FLOAT,
	Freedom FLOAT,
	Generosity FLOAT,
	Corruption FLOAT,
	Report_Year INT,
	Region VARCHAR(50)
)

INSERT INTO dbo.WHR_1819(
	Rank ,
    Country ,
	Score ,
	GDP_per_Capita ,
	Social_Support ,
	Life_Expectancy ,
	Freedom ,
	Generosity ,
	Corruption ,
	Report_Year 
)

SELECT 
	Rank ,
    Country ,
	Score ,
	GDP_per_Capita ,
	Social_Support ,
	Life_Expectancy ,
	Freedom ,
	Generosity ,
	Corruption,
	'2018'
FROM dbo.WHR_18_raw
UNION ALL
SELECT 
	Rank ,
    Country ,
	Score ,
	GDP_per_Capita ,
	Social_Support ,
	Life_Expectancy ,
	Freedom ,
	Generosity ,
	Corruption,
	'2019'
FROM dbo.WHR_19_raw

-- Add Region to WHR_1819
		UPDATE dbo.WHR_1819
	SET Region = (
    	SELECT Region
    	FROM dbo.WHR_15_raw
    	WHERE dbo.WHR_1819.Country = dbo.WHR_15_raw.Country
	);

---------------
--Load 2020-2021 data
CREATE TABLE dbo.WHR_20_raw (
    Country VARCHAR(50),
	Region VARCHAR(50),
	Score FLOAT,
	Logged_GDP FLOAT,
	Social_Support FLOAT,
	Life_Expectancy FLOAT,
	Freedom FLOAT,
	Generosity FLOAT,
	Corruption FLOAT,
	Dystopia_Residual FLOAT

);

CREATE TABLE dbo.WHR_21_raw (
   Country VARCHAR(50),
	Region VARCHAR(50),
	Score FLOAT,
	Logged_GDP FLOAT,
	Social_Support FLOAT,
	Life_Expectancy FLOAT,
	Freedom FLOAT,
	Generosity FLOAT,
	Corruption FLOAT,
	Dystopia_Residual FLOAT

);

-- import the file 2018.csv and 2019.csv into the data table
BULK INSERT dbo.WHR_20_raw
FROM '/tmp/2020.csv'
WITH (
    FIRSTROW = 2,       -- Skip header row if applicable
    FIELDTERMINATOR = ',',  -- Specify the field delimiter used in your CSV file
    ROWTERMINATOR = '0x0a'    -- Specify the row delimiter used in your CSV file
);

BULK INSERT dbo.WHR_21_raw
FROM '/tmp/2021.csv'
WITH (
    FIRSTROW = 2,       -- Skip header row if applicable
    FIELDTERMINATOR = ',',  -- Specify the field delimiter used in your CSV file
    ROWTERMINATOR = '0x0a'    -- Specify the row delimiter used in your CSV file
);

SELECT * FROM dbo.WHR_20_raw
SELECT * FROM dbo.WHR_21_raw

-- Union 2020 and 2021 in a single table
DROP TABLE IF EXISTS dbo.WHR_2021
CREATE TABLE dbo.WHR_2021 (
	Country VARCHAR(50),
	Region VARCHAR(50),
	Score FLOAT,
	Logged_GDP FLOAT,
	Social_Support FLOAT,
	Life_Expectancy FLOAT,
	Freedom FLOAT,
	Generosity FLOAT,
	Corruption FLOAT,
	Dystopia_Residual FLOAT,
	Report_Year INT
)

INSERT INTO dbo.WHR_2021(
    Country ,
	Region,
	Score ,
	Logged_GDP ,
	Social_Support ,
	Life_Expectancy ,
	Freedom ,
	Generosity ,
	Corruption ,
	Dystopia_Residual,
	Report_Year 
)

SELECT 
	Country ,
	Region,
	Score ,
	Logged_GDP ,
	Social_Support ,
	Life_Expectancy ,
	Freedom ,
	Generosity ,
	Corruption ,
	Dystopia_Residual,
	'2020'
FROM dbo.WHR_20_raw
UNION ALL
SELECT 
	Country ,
	Region,
	Score ,
	Logged_GDP ,
	Social_Support ,
	Life_Expectancy ,
	Freedom ,
	Generosity ,
	Corruption ,
	Dystopia_Residual,
	'2021'
FROM dbo.WHR_21_raw

SELECT * FROM dbo.WHR_2021
 
 -- Add Ranking column to WHR_2021
ALTER TABLE dbo.WHR_2021
	ADD Rank INT
	-- Add CTE Table for rank 
	WITH Rank_CTE AS (
		SELECT *,
			ROW_NUMBER() OVER (PARTITION BY Report_Year ORDER BY Score DESC) AS NewRank
		FROM dbo.WHR_2021
	)
	-- Update the rank column
	UPDATE dbo.WHR_2021
		SET Rank =
			(SELECT NewRank
			FROM Rank_CTE
			WHERE dbo.WHR_2021.Country = Rank_CTE.Country
			AND dbo.WHR_2021.Report_Year = Rank_CTE.Report_Year
			);

-- Update some null value in the region in WHR_1819 and WHR_1517

	-- temp table for region
	DROP TABLE IF EXISTS #temp_region
	CREATE TABLE #temp_region (
		Country VARCHAR(50),
		Region VARCHAR(50)
	);
	INSERT INTO #temp_region (Country, Region)
	VALUES 
		('Taiwan Province of China', 'Eastern Asia'),
		('Belize', 'Northern America'),
		('Somalia', ' Southern America'),
		('Namibia', 'Southern America'),
		('South Sudan', 'Northern America'),
		('Trinidad & Tobago', 'Southern America'),
		('Northern Cyprus', 'Western Asia'),
		('Gambia' , 'Western Africa'),
		('North Macedonia', 'Southeast Europe')
SELECT * FROM #temp_region

	-- Update WHR_1819
	UPDATE dbo.WHR_1819
	SET Region = (
		SELECT Region
		FROM #temp_region
		WHERE dbo.WHR_1819.Country = #temp_region.Country
		)
	WHERE Region IS NULL;

	-- Update WHR_1517
	UPDATE dbo.WHR_1517
	SET Region = (
		SELECT Region
		FROM #temp_region
		WHERE dbo.WHR_1517.Country = #temp_region.Country
		)
	WHERE Region IS NULL;

-- Create a union table fro data from 2015-2021 with similar columns
DROP TABLE IF EXISTS dbo.WHR_1521
CREATE TABLE dbo.WHR_1521 (
	Report_Year INT,
	Rank INT,
	Country VARCHAR(50),
	Region VARCHAR(50),
	Score FLOAT,
	Life_Expectancy FLOAT,
	Freedom FLOAT,
	Generosity FLOAT,
	Corruption FLOAT
)

INSERT INTO dbo.WHR_1521(
	Report_Year,
	Rank,
	Country,
	Region,
	Score,
	Life_Expectancy,
	Freedom,
	Generosity,
	Corruption
)

SELECT 
	Report_Year,
	Rank,
	Country,
	Region,
	Score,
	Life_Expectancy,
	Freedom,
	Generosity,
	Corruption
FROM dbo.WHR_1517
UNION ALL
SELECT 
	Report_Year,
	Rank,
	Country,
	Region,
	Score,
	Life_Expectancy,
	Freedom,
	Generosity,
	Corruption
FROM dbo.WHR_1819
UNION ALL
SELECT 
	Report_Year,
	Rank,
	Country,
	Region,
	Score,
	Life_Expectancy,
	Freedom,
	Generosity,
	Corruption
FROM dbo.WHR_2021

SELECT * FROM dbo.WHR_1521





