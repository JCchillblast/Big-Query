SELECT DISTINCT 
    (CASE
        WHEN o.Company = 'MendIt' THEN 'MendIt'
        WHEN Channel = 'W' AND IsB2B = 1 THEN 'Web B2B'
        WHEN Channel = 'W' THEN 'Web'
        WHEN Channel = 'A' THEN 'Amazon'
        WHEN Channel = 'E' THEN 'EBay'
        WHEN Channel IN ('B', 'B2B Team', 'B2B', 'Trade') THEN 'B2B'
        WHEN Channel = 'M' THEN 'Web'
        WHEN Channel = 'R' THEN 'Return'
        ELSE 'Web'
    END) AS 'Channel',
    o.[Company],
    o.[SKU],
    [GroupCategoryName],
    [IsCredit],
    [OrderNumber],
    [OrderDate],
    CONVERT(VARCHAR(10), [OrderDate], 111) AS [ODate],
    [InvoiceNumber],
    [InvoiceDate],
    CONVERT(VARCHAR(10), [InvoiceDate], 111) AS [IDate],
    [OrderStatus],
    [LineStatus],
    [Quantity],
    [LineCost],
    [LineSell],
    [LineSOA],
    [CarriageSell],
    [CarriageCost],
    [OtherSell],
    [OtherCost],
    [PlatformFee],
    [Vouchers],
    ([LineSell] + [CarriageSell] + [OtherSell] - ISNULL([Vouchers],0)) AS 'Revenue',
    ((LineSell - ISNULL(Vouchers,0)) - (LineCost + LineSOA)) AS 'Margin',
    ([LineSell] + [CarriageSell] + [OtherSell] - ISNULL([Vouchers],0)) - 
        ([LineCost] + [CarriageCost] + [OtherCost] + [PlatformFee] + [LineSOA]) AS 'GrossProfit',
    [WebRef],
    [CustomerAccountNumber],
    [IsB2B]

FROM [dbo].[OpenOrders] o WITH (NOLOCK)

LEFT JOIN [dbo].[Customers] c ON o.[CustomerAccountNumber] = c.[CustomerNo]
LEFT JOIN [Product] P ON o.[sku] = p.[sku]
LEFT JOIN CCL_ProductCategoryMapping avante_cats
    ON p.productGroup = avante_cats.AvanteCategoryID
LEFT JOIN Group_ProductCategories group_cats
    ON avante_cats.GroupCategoryID = group_cats.GroupCategoryID

WHERE 1=1
-- Filter for company CCL
AND o.Company = 'CCL'
-- Filter for last week (01/12 to 07/12/2025)
AND [OrderDate] >= '2025-12-01'                                                                                    --change date
AND [OrderDate] < '2025-12-08'
AND [InvoiceDate] >= '2025-12-01'
AND [InvoiceDate] < '2025-12-08'
-- Exclude returns
AND [Channel] != 'R'
-- Only include specific orders
AND [OrderNumber] IN (
    '5045426','5045429','5045445','5045446','5045459','5045479','5045493','5045506','5045540','5045577',               --change skus
    '5045644','5045655','5045676','5045744','5045767','5045788','5045796','5045836','5045871','5045929',
    '5045957','5045963','5045964','5045979','5046004','5046005','5046015','5046025','5046032','5046036',
    '5046048','5046061','5046063','5046069','5046077','5046079','5046088','5046092','5046093','5046107',
    '5046115','5046117','5046140','5046167','5046179','5046191','5046194','5046230','5046247','5046249',
    '5046267','5046268','5046275','5046309','5046322','5046333','5046342','5046350','5046448','5046449',
    '5046461','5046475','5046484','5046548','5046549','5046571','5046578','5046582','5046583','5046588',
    '5046598','5046670','5046673','5046694','5046727','5046739','5046741','5046752','5046759','5046880',
    '5046897','5046911','5047025','5047031','5047073','5047079','5047085','5047113','5047129','5047133',
    '5047198','5047199','5047210','5047274','5047285','5047311','5047324','5047333','5047340','5047351',
    '5047376','5047403','5047413','5047453','5047463','5047493','5047525','5047547','5047580','5047581',
    '5047609','5047620','5047634','5047644','5047653','5047657','5047675','5047678','5047714','5047722',
    '5047745','5047756','5047761','5047778','5047780','5047812','5047885','5047893','5047896','5047901',
    '5047925','5047985','5047995','5048015','5048052','5048123','5048234','5048295','5048313','5048359',
    '5048363','5048431','5048530','5048539','5048582','5048636','5048746','5048749','5048816','5048839',
    '5048872','5048881','5048923','5048943','5048970','5048994','5049000','5049017','5049019','5049041',
    '5049084','5049125','5049126','5049132','5049138','5049178','5049237','5049267','5049268','5049322',
    '5049324','5049345','5049366','5049406','5049408','5049414','5049432','5049435','5049461','5049531',
    '5049541','5049556','5049571'
)
