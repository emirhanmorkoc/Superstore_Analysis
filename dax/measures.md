# DAX Measures

This file documents the DAX measures used in the Superstore Power BI report.

---

## Page 1. Superstore Overview

### Overview KPIs

```DAX
Overview Sales = 
SUM('01_overview'[sales])
```

```DAX
Overview Profit = 
SUM('01_overview'[profit])
```

```DAX
Overview Margin = 
DIVIDE(
    [Overview Profit],
    [Overview Sales]
)
```

```DAX
Overview Orders = 
DISTINCTCOUNT('01_overview'[order_id])
```

---

## Page 2. Profit Leakage

### Returns page

```DAX
Order Lines = 
SUM('04_returns_hotspots'[order_lines_cnt])
```

```DAX
Returned Lines = 
SUM('04_returns_hotspots'[returned_lines_cnt])
```

```DAX
Return Rate = 
DIVIDE(
    [Returned Lines],
    [Order Lines]
)
```

```DAX
Returned Sales = 
SUM('04_returns_hotspots'[returned_sales_total])
```

```DAX
Returns Page Sales = 
SUM('04_returns_hotspots'[sales_total])
```

```DAX
Returned Profit Exposure = 
SUM('04_returns_hotspots'[profit_on_returned_lines_proxy])
```

```DAX
Returned Profit Share = 
DIVIDE(
    [Returned Profit Exposure],
    CALCULATE(
        [Returned Profit Exposure],
        REMOVEFILTERS('04_returns_hotspots'[product_name])
    )
)
```

### Discount analysis

```DAX
Discount Sales = 
SUM('05_discounts_vs_profit'[sales_total])
```

```DAX
Discount Profit = 
SUM('05_discounts_vs_profit'[profit_total])
```

```DAX
Discount Margin = 
DIVIDE(
    [Discount Profit],
    [Discount Sales]
)
```

```DAX
20%+ Discount Sales Share = 
DIVIDE(
    CALCULATE(
        SUM('05_discounts_vs_profit'[sales_total]),
        KEEPFILTERS(
            '05_discounts_vs_profit'[discount_bucket] IN {"20-30%", "30-50%", "50%+"}
        )
    ),
    CALCULATE(
        SUM('05_discounts_vs_profit'[sales_total]),
        REMOVEFILTERS('05_discounts_vs_profit'[discount_bucket])
    )
)
```

```DAX
Discount Bucket Sales Share = 
VAR CurrentBucket =
    SELECTEDVALUE('05_discounts_vs_profit'[discount_bucket])
VAR BucketSales =
    CALCULATE(
        SUM('05_discounts_vs_profit'[sales_total]),
        FILTER(
            ALLSELECTED('05_discounts_vs_profit'),
            '05_discounts_vs_profit'[discount_bucket] = CurrentBucket
        )
    )
VAR TotalSales =
    CALCULATE(
        SUM('05_discounts_vs_profit'[sales_total]),
        ALLSELECTED('05_discounts_vs_profit')
    )
RETURN
    DIVIDE(BucketSales, TotalSales)
```

---

## Page 3. Customer Value & Concentration

### Base measures

```DAX
Customer Sales = 
SUM('02_customer_concentration'[sales_total])
```

```DAX
Customer Profit = 
SUM('02_customer_concentration'[profit_total])
```

```DAX
Customer Margin = 
DIVIDE(
    [Customer Profit],
    [Customer Sales]
)
```

```DAX
Customers = 
DISTINCTCOUNT('02_customer_concentration'[customer_id])
```

### Share measures

```DAX
Customer Sales Share = 
DIVIDE(
    [Customer Sales],
    CALCULATE(
        [Customer Sales],
        ALLSELECTED('02_customer_concentration')
    )
)
```

```DAX
Customer Profit Share = 
DIVIDE(
    [Customer Profit],
    CALCULATE(
        [Customer Profit],
        ALLSELECTED('02_customer_concentration')
    )
)
```

### Customer quality

```DAX
Loss-making Customers = 
CALCULATE(
    DISTINCTCOUNT('02_customer_concentration'[customer_id]),
    FILTER(
        ALLSELECTED('02_customer_concentration'),
        '02_customer_concentration'[profit_total] < 0
    )
)
```

```DAX
Loss-making Customers % = 
DIVIDE(
    [Loss-making Customers],
    CALCULATE(
        DISTINCTCOUNT('02_customer_concentration'[customer_id]),
        ALLSELECTED('02_customer_concentration')
    )
)
```

### Customer concentration

```DAX
Top 10 Profit Customers Profit = 
SUMX(
    TOPN(
        10,
        ALLSELECTED('02_customer_concentration'),
        '02_customer_concentration'[profit_total],
        DESC
    ),
    '02_customer_concentration'[profit_total]
)
```

```DAX
Top 10 Profit Customers Profit Share = 
DIVIDE(
    [Top 10 Customer Profit],
    CALCULATE(
        [Customer Profit],
        ALLSELECTED('02_customer_concentration')
    )
)
```

```DAX
Top 10 Profit Customers Sales = 
VAR Top10ProfitCustomers =
    TOPN(
        10,
        ALLSELECTED('02_customer_concentration'),
        '02_customer_concentration'[profit_total],
        DESC
    )
RETURN
    SUMX(
        Top10ProfitCustomers,
        '02_customer_concentration'[sales_total]
    )
```

```DAX
Top 10 Profit Customers Sales Share = 
DIVIDE(
    [Top 10 Profit Customers Sales],
    CALCULATE(
        [Customer Sales],
        ALLSELECTED('02_customer_concentration')
    )
)
```

> Note: the sales-share measure above uses the **same top 10 customers ranked by profit**, not a separate top 10 ranked by sales. This keeps the cohort consistent.

---

## Page 4. Product Profitability & Risk

### Base measures

```DAX
Product Sales = 
SUM('03_product_portfolio'[sales_total])
```

```DAX
Product Profit = 
SUM('03_product_portfolio'[profit_total])
```

```DAX
Product Margin = 
DIVIDE(
    [Product Profit],
    [Product Sales]
)
```

```DAX
Products = 
DISTINCTCOUNT('03_product_portfolio'[product_id])
```

### Share measures

```DAX
Product Sales Share = 
DIVIDE(
    [Product Sales],
    CALCULATE(
        [Product Sales],
        REMOVEFILTERS(
            '03_product_portfolio'[product_id],
            '03_product_portfolio'[product_name]
        )
    )
)
```

```DAX
Product Profit Share = 
DIVIDE(
    [Product Profit],
    CALCULATE(
        [Product Profit],
        REMOVEFILTERS(
            '03_product_portfolio'[product_id],
            '03_product_portfolio'[product_name]
        )
    )
)
```

```DAX
Scope Sales Share = 
VAR Scoped =
    ISFILTERED('03_product_portfolio'[category]) ||
    ISFILTERED('03_product_portfolio'[sub_category])
RETURN
IF(
    Scoped,
    DIVIDE(
        [Product Sales],
        CALCULATE(
            [Product Sales],
            REMOVEFILTERS(
                '03_product_portfolio'[category],
                '03_product_portfolio'[sub_category]
            )
        )
    )
)
```

```DAX
Scope Profit Share = 
VAR Scoped =
    ISFILTERED('03_product_portfolio'[category]) ||
    ISFILTERED('03_product_portfolio'[sub_category])
RETURN
IF(
    Scoped,
    DIVIDE(
        [Product Profit],
        CALCULATE(
            [Product Profit],
            REMOVEFILTERS(
                '03_product_portfolio'[category],
                '03_product_portfolio'[sub_category]
            )
        )
    )
)
```

### Loss-making products

```DAX
Loss-making Products = 
COUNTROWS(
    FILTER(
        VALUES('03_product_portfolio'[product_id]),
        [Product Profit] < 0
    )
)
```

```DAX
Loss-making Products % = 
DIVIDE(
    [Loss-making Products],
    [Products]
)
```

### Top / Worst product concentration

```DAX
Top 10 Product Profit = 
VAR Top10Products =
    TOPN(
        10,
        VALUES('03_product_portfolio'[product_id]),
        [Product Profit],
        DESC
    )
RETURN
    SUMX(Top10Products, [Product Profit])
```

```DAX
Top 10 Product Profit Share = 
DIVIDE(
    [Top 10 Product Profit],
    CALCULATE(
        [Product Profit],
        REMOVEFILTERS(
            '03_product_portfolio'[product_id],
            '03_product_portfolio'[product_name]
        )
    )
)
```

```DAX
Top 10 Product Sales = 
VAR Top10Products =
    TOPN(
        10,
        VALUES('03_product_portfolio'[product_id]),
        [Product Profit],
        DESC
    )
RETURN
    SUMX(Top10Products, [Product Sales])
```

```DAX
Top 10 Product Sales Share = 
DIVIDE(
    [Top 10 Product Sales],
    CALCULATE(
        [Product Sales],
        REMOVEFILTERS(
            '03_product_portfolio'[product_id],
            '03_product_portfolio'[product_name]
        )
    )
)
```

```DAX
Worst 10 Product Profit Share = 
VAR Worst10Products =
    TOPN(
        10,
        VALUES('03_product_portfolio'[product_id]),
        [Product Profit],
        ASC
    )
VAR Worst10Profit =
    SUMX(Worst10Products, [Product Profit])
RETURN
    DIVIDE(Worst10Profit, [Product Profit])
```

```DAX
Worst 10 Product Sales Share = 
VAR Worst10Products =
    TOPN(
        10,
        VALUES('03_product_portfolio'[product_id]),
        [Product Profit],
        ASC
    )
VAR Worst10Sales =
    SUMX(Worst10Products, [Product Sales])
RETURN
    DIVIDE(Worst10Sales, [Product Sales])
```
