
USE group1; 

-- Code below provides a snapshot overview of all ETFs. This data represents the key metrics as an average over the time period of the data set (<1 month). 
CREATE OR REPLACE VIEW ETF_Snapshot AS
SELECT 
    symbol,
    AVG(fund_aum) AS avg_fund_aum,
    AVG(avg_daily_trading_volume) AS avg_daily_trading_volume,
    AVG(management_fee) AS avg_management_fee,
    AVG(other_expense) AS avg_other_expense,
    AVG(total_expense) AS avg_total_expense,
    AVG(fee_waiver) AS avg_fee_waiver,
    AVG(net_expense) AS avg_net_expense
FROM 
    ETF
WHERE 
    as_of_date BETWEEN '2023-01-03' AND '2023-01-31'
GROUP BY 
    symbol;
    


-- Attempting to determine which asset classes have the most assets under management (AUM) across different ETFs.
-- The sum of assets under management is a direct measure of the popularity and scale of an asset class. 
-- Asset classes with higher total AUM are likely more attractive to investors, reflecting a larger market share.
-- Average assets under management gives us an idea of the typical size
-- This may be useful if you want to examine which areas people are investing in the most.
-- Tracking this over time will help analyze investor/market sentiments, market trends, and popularity.

CREATE OR REPLACE VIEW asset_class_ranked AS
SELECT 
    ac.asset_class, 
    SUM(e.fund_aum) AS total_aum,
	AVG(fund_aum) AS avg_fund_aum
FROM 
    ETF e
JOIN 
    ETF_Asset_Classes eac ON e.symbol = eac.symbol
JOIN 
    Asset_Classes ac ON eac.asset_class_id = ac.asset_class_id
GROUP BY 
    ac.asset_class
ORDER BY 
    total_aum DESC;



SELECT * FROM asset_class_ranked;
    
    
    
-- Code below counts the number of unique ETFs associated with each country based on their geographic exposures
-- Helps understand market representation and over time can help identify emerging/declining markets.    
SELECT 
    ge.country,
    COUNT(DISTINCT e.symbol) AS etf_count
FROM 
    ETF e
JOIN 
    Geographic_Exposures ge ON e.symbol = ge.symbol AND e.as_of_date = ge.as_of_date
GROUP BY 
    ge.country
ORDER BY 
    etf_count DESC;
    
    
    
 -- Code below shows the number of countries each ETF is invested in. This shows the geographical diversity of their portfolio.
 -- Used in evaluating the geographic spread and financial scale of ETFs.
CREATE OR REPLACE VIEW etf_geographic_makeup AS
SELECT 
    e.symbol,
    COUNT(DISTINCT ge.country) AS country_count,
    SUM(e.fund_aum) AS total_aum,
    AVG(e.fund_aum) AS average_aum_per_country
FROM 
    ETF e
JOIN 
    Geographic_Exposures ge ON e.symbol = ge.symbol
GROUP BY 
    e.symbol;
    

    


-- View below joins the latitude/longitude of country/country ID with the geographic exposures table.
-- This allows visualization and PowerBI tools to place our ETFs on a map by country
CREATE OR REPLACE VIEW ETF_Geographic_Details AS
SELECT 
    ge.symbol,
    ge.as_of_date,
    ge.country AS country_code,
    ge.weight AS geographic_weight,
    cm.country_name,
    cm.latitude,
    cm.longitude,
    gm.country_count 
FROM 
    Geographic_Exposures ge
JOIN 
    Country_Mapping cm ON ge.country = cm.country_code
JOIN 
    etf_geographic_makeup gm ON ge.symbol = gm.symbol;

SELECT * FROM etf_geographic_details


  -- ETFs may have duplicate countries depending on the date
  -- 
    
    
-- Code below creates a view to calculate the sector weight composition of each ETF.



CREATE OR REPLACE VIEW Sector_Weight_Makeup AS
SELECT 
    e.symbol,
    se.sector,
    AVG(se.weight) AS avg_sector_weight -- Average weight of each sector for each ETF over the time period of the data (>1 month)
FROM 
    ETF e
JOIN 
    Sector_Exposures se ON e.symbol = se.symbol
GROUP BY 
    e.symbol, 
    se.sector
ORDER BY 
    e.symbol, 
    se.sector;



-- Used ChatGPT to identify where an index is most optimal and makes the most sense.
-- Symbol is often joined on the as of date, to identify a metric about an ETF on a certain date, etc
-- The view created will show the total and average assets under management for each sector.
-- Provides insight into sectors with top assets under management, and how many ETFs fall within each sector
-- to identify trends and performance across sectors. Helps identify which sectors people are investing most in.
-- Tracking this over time can help track performance trends, and declining/emerging markets.

CREATE INDEX idx_etf_symbol_date ON ETF(symbol, as_of_date);
CREATE INDEX idx_sector_symbol_date ON Sector_Exposures(symbol, as_of_date);
CREATE OR REPLACE VIEW assets_by_sector AS
SELECT 
    se.sector,
    AVG(e.fund_aum) AS avg_aum,
    SUM(e.fund_aum) AS total_aum,
    COUNT(DISTINCT e.symbol) AS etf_count
FROM 
    ETF e
JOIN 
    Sector_Exposures se ON e.symbol = se.symbol
GROUP BY 
    se.sector
ORDER BY 
    total_aum DESC;


CREATE OR REPLACE VIEW ETF_over_time AS
SELECT 
    e.symbol,
    e.as_of_date,
    AVG(e.fund_aum) AS avg_aum,
    ep.close_price
FROM 
    ETF e
JOIN 
    ETF_Prices ep ON e.symbol = ep.symbol AND e.as_of_date = ep.as_of_date
GROUP BY 
    e.symbol, 
    e.as_of_date,
    ep.close_price
ORDER BY 
    e.symbol, 
    e.as_of_date;




