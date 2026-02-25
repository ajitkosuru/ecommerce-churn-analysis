-- Checking the dataset
SELECT *
FROM ecommerce_customer_churn_datase$

-- Cleaning Dataset
CREATE VIEW cleaned_ecommerce AS
SELECT
    Age,
    Gender,
    Country,
    City,
    Membership_Years,
    Login_Frequency,

    ISNULL(Session_Duration_Avg, 0) AS Session_Duration_Avg,
    ISNULL(Pages_Per_Session, 0) AS Pages_Per_Session,
    ISNULL(Cart_Abandonment_Rate, 0) AS Cart_Abandonment_Rate,
    ISNULL(Wishlist_Items, 0) AS Wishlist_Items,

    ISNULL(Total_Purchases, 0) AS Total_Purchases,
    ISNULL(Average_Order_Value, 0) AS Average_Order_Value,

    -- Safe revenue calculation
    (ISNULL(Total_Purchases, 0) * ISNULL(Average_Order_Value, 0)) AS Revenue,

    ISNULL(Days_Since_Last_Purchase, 999) AS Days_Since_Last_Purchase,
    ISNULL(Discount_Usage_Rate, 0) AS Discount_Usage_Rate,
    ISNULL(Returns_Rate, 0) AS Returns_Rate,
    ISNULL(Email_Open_Rate, 0) AS Email_Open_Rate,

    ISNULL(Customer_Service_Calls, 0) AS Customer_Service_Calls,
    ISNULL(Product_Reviews_Written, 0) AS Product_Reviews_Written,
    ISNULL(Social_Media_Engagement_Score, 0) AS Social_Media_Engagement_Score,

    ISNULL(Mobile_App_Usage, 0) AS Mobile_App_Usage,
    ISNULL(Payment_Method_Diversity, 0) AS Payment_Method_Diversity,

    ISNULL(Lifetime_Value, 0) AS Lifetime_Value,
    ISNULL(Credit_Balance, 0) AS Credit_Balance,

    Churned,
    Signup_Quarter

FROM ecommerce_customer_churn_datase$
WHERE Age IS NOT NULL;

-- Checking the view
SELECT *
FROM cleaned_ecommerce

-- Calculating the total revenue
SELECT ROUND(SUM(Total_Purchases * Average_Order_Value),0) AS Total_Revenue
FROM cleaned_ecommerce;

-- Total Lifetime Value (Profit Proxy)
SELECT ROUND(SUM(Lifetime_Value),0) AS Total_Lifetime_Value
FROM cleaned_ecommerce;

-- Checking the country performance
SELECT 
    Country,
    ROUND(SUM(Total_Purchases * Average_Order_Value),0) AS Revenue,
    ROUND(SUM(Lifetime_Value),0) AS Lifetime_Value
FROM cleaned_ecommerce
GROUP BY Country
ORDER BY Revenue DESC;

-- Signup Quarter Performance
SELECT 
Signup_Quarter,
COUNT(*) AS Customers,
ROUND(SUM(Lifetime_Value),0) AS Lifetime_Value
FROM cleaned_ecommerce
GROUP BY Signup_Quarter
ORDER BY 
    CASE Signup_Quarter
    WHEN 'Q1' THEN 1
    WHEN 'Q2' THEN 2
    WHEN 'Q3' THEN 3
    WHEN 'Q4' THEN 4
END;

-- Checking the Top 10 High-Value Customers
SELECT TOP 10
    City,
    Country,
    ROUND(Lifetime_Value,0) AS Lifetime_Value,
    Total_Purchases
FROM cleaned_ecommerce
ORDER BY Lifetime_Value DESC;

-- Calculating the repeat purchase rate
SELECT 
    CAST(
        ROUND(
            COUNT(CASE WHEN Total_Purchases > 1 THEN 1 END) * 100.0 / COUNT(*), 
            2
        ) 
    AS DECIMAL(5,2)) AS Repeat_Rate_Percentage
FROM cleaned_ecommerce;

-- Revenue by Membership Years
SELECT
    ROUND(Membership_Years,0) AS Membership_Years_Group,
    ROUND(SUM(Total_Purchases * Average_Order_Value),0) AS Revenue
FROM cleaned_ecommerce
GROUP BY ROUND(Membership_Years,0)
ORDER BY Membership_Years_Group;

-- Discount Impact on Revenue
SELECT
    CASE 
        WHEN Discount_Usage_Rate > 50 THEN 'High Discount Users'
        ELSE 'Low Discount Users'
    END AS Discount_Group,
    ROUND(AVG(Lifetime_Value),0) AS Avg_Lifetime_Value,
    ROUND(AVG(Total_Purchases * Average_Order_Value),0) AS Avg_Revenue
FROM cleaned_ecommerce
GROUP BY 
    CASE 
        WHEN Discount_Usage_Rate > 50 THEN 'High Discount Users'
        ELSE 'Low Discount Users'
    END;

-- Calculating Revenue Contribution Percentage
SELECT
    Country,
    ROUND(SUM(Total_Purchases * Average_Order_Value) * 100.0 /
    (SELECT SUM(Total_Purchases * Average_Order_Value) FROM cleaned_ecommerce),2)
    AS Revenue_Contribution_Percentage
FROM cleaned_ecommerce
GROUP BY Country
ORDER BY Revenue_Contribution_Percentage DESC;

-- Loss Making/High Risk Segments
SELECT
    Country,
    ROUND(AVG(Cart_Abandonment_Rate),1) AS Avg_Abandonment,
    ROUND(AVG(Days_Since_Last_Purchase),0) AS Avg_Days_Inactive,
    CAST(ROUND(SUM(CASE WHEN Churned = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
AS DECIMAL(5,2)) AS Churn_Rate
FROM cleaned_ecommerce
GROUP BY Country
HAVING SUM(CASE WHEN Churned = 1 THEN 1 ELSE 0 END) > 0
ORDER BY Churn_Rate DESC;

SELECT *
FROM cleaned_ecommerce

