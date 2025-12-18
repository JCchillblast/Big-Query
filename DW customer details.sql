WITH OrderTotals AS (
    SELECT
        OrderNumber,
        CustomerAccountNumber,

        -- Order Value
        SUM(LineSell + CarriageSell + OtherSell - ISNULL(Vouchers,0)) AS OrderValue,

        -- Gross Profit
        SUM(
            (LineSell - LineCost)
            + (CarriageSell - CarriageCost)
            + (OtherSell - OtherCost)
            - ISNULL(VoucherCost,0)
        ) AS OrderGP,

        -- Units
        SUM(Quantity) AS Units
    FROM dbo.OpenOrders
    WHERE CAST(OrderDate AS DATE) = '2025-12-17'
    GROUP BY OrderNumber, CustomerAccountNumber
),

CustomerAgg AS (
    SELECT
        CustomerAccountNumber,

        COUNT(*) AS TotalOrders,
        SUM(OrderValue) AS TotalRevenue,
        SUM(OrderGP) AS TotalGP,
        SUM(Units) AS TotalUnits,

        AVG(OrderValue) AS AvgOrderValue,
        AVG(OrderGP) AS AvgOrderGP,
        AVG(Units) AS AvgUnits
    FROM OrderTotals
    GROUP BY CustomerAccountNumber
)

SELECT
    ca.CustomerAccountNumber AS CustomerNo,

    c.Company,
    c.FullName,
    c.CustomerType,
    c.IsB2B,

    c.AddressCity,
    c.AddressCounty,
    c.AddressPostcode,
    c.AddressCountry,

    c.Email,
    c.Email_OptIn,
    c.SMS_OptIn,
    c.Post_OptIn,

    c.DateRegged,
    c.PBI_DateRegged_Year,
    c.PBI_DateRegged_MonthYear,

    ca.TotalOrders,
    ca.TotalRevenue,
    ca.TotalGP,
    ca.TotalUnits,
    ca.AvgOrderValue,
    ca.AvgOrderGP,
    ca.AvgUnits

FROM CustomerAgg ca
LEFT JOIN [db-datawarehouse-tg].[dbo].[Customers] c
    ON ca.CustomerAccountNumber = c.CustomerNo
ORDER BY ca.TotalRevenue DESC;
