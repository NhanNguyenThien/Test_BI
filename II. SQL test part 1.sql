-- a.Liệt kê 10 đơn hàng gần nhất cùng với tên khách hàng và ngày đặt hàng.
SELECT 
    o.orderID,
    c.companyName,
    c.contactName,
    DATE(o.orderDate) AS orderDate
FROM orders o
JOIN customers c ON o.customerID = c.customerID
ORDER BY o.orderDate DESC
LIMIT 10;

-- b.Tính tổng số đơn hàng của mỗi khách hàng, sắp xếp từ cao xuống thấp.
SELECT 
    c.customerID,
    c.companyName,
    COUNT(o.orderID) AS total_orders
FROM customers c
LEFT JOIN orders o ON c.customerID = o.customerID
GROUP BY c.customerID, c.companyName
ORDER BY total_orders DESC;

-- c. Tính tổng doanh thu theo từng sản phẩm.
SELECT 
    p.productName,
    ROUND(SUM(od.unitPrice * od.quantity * (1 - od.discount)), 2) AS total_revenue
FROM order_details od
JOIN products p ON od.productID = p.productID
GROUP BY p.productID, p.productName
ORDER BY total_revenue DESC;

-- d.	Tính doanh thu theo từng category sản phẩm.
SELECT 
    cat.categoryName,
    ROUND(SUM(od.unitPrice * od.quantity * (1 - od.discount)), 2) AS total_revenue
FROM order_details od
JOIN products p ON od.productID = p.productID
JOIN categories cat ON p.categoryID = cat.categoryID
GROUP BY cat.categoryID, cat.categoryName
ORDER BY total_revenue DESC;

-- e. Tìm sản phẩm bán chạy nhất trong mỗi category.
WITH product_sales AS (
    SELECT 
        p.categoryID,
        p.productID,
        p.productName,
        SUM(od.quantity) AS total_qty,
        ROUND(SUM(od.unitPrice * od.quantity * (1 - od.discount)), 2) AS total_revenue
    FROM order_details od
    JOIN products p ON od.productID = p.productID
    GROUP BY p.categoryID, p.productID, p.productName
),
ranked AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY categoryID ORDER BY total_qty DESC) AS rn
    FROM product_sales
)
SELECT 
    cat.categoryName,
    r.productName,
    r.total_qty,
    r.total_revenue
FROM ranked r
JOIN categories cat ON r.categoryID = cat.categoryID
WHERE r.rn = 1
ORDER BY r.total_revenue DESC;
