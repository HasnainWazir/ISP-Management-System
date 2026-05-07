--Query 1:Create a Subscription
INSERT INTO Subscriptions (customer_id, package_id, start_date)
VALUES (1, 2, CURRENT_DATE);

-- View the newly created subscription
SELECT s.subscription_id, c.customer_name, p.internet_speed,
		p.price, s.start_date
FROM Subscriptions s
JOIN Customers c ON s.customer_id = c.customer_id
JOIN Packages p ON s.package_id = p.package_id
WHERE s.subscription_id = (SELECT MAX(subscription_id) FROM
Subscriptions);


--Query 2:Generate a Bill from a Subscription
INSERT INTO Bills (customer_id, billed_amount, due_date, status)
SELECT s.customer_id, 
       p.price AS billed_amount, 
       CURRENT_DATE + INTERVAL '30 days' AS due_date, 
       'Unpaid' AS status
FROM Subscriptions s
JOIN Packages p ON s.package_id = p.package_id
WHERE s.subscription_id = 1;

-- Confirm the generated bill
SELECT b.bill_id, c.customer_name, b.billed_amount,
		b.due_date, b.status
FROM Bills b
JOIN Customers c ON b.customer_id = c.customer_id
WHERE b.customer_id = 1
ORDER BY b.bill_id DESC
LIMIT 1;



--Query 3:View All Unpaid Bills
SELECT b.bill_id,
       c.customer_name,
       c.phone_number,
       b.billed_amount,
       b.due_date,
       b.status,
       CURRENT_DATE - b.due_date AS days_overdue
FROM Bills b
JOIN Customers c ON b.customer_id = c.customer_id
WHERE b.status IN ('Unpaid', 'Overdue')
ORDER BY b.due_date ASC;


--Query 4:Record a Payment
-- Step 1: Insert the payment
INSERT INTO Payments (bill_id, paid_amount, payment_date, method, status)
VALUES (3, 1500.00, CURRENT_DATE, 'Cash', 'Completed');

-- Step 2: Update bill status based on payment
UPDATE Bills
SET status = CASE
               WHEN billed_amount <= (
                   SELECT SUM(paid_amount)
                   FROM Payments
                   WHERE bill_id = 3
                     AND status = 'Completed'
               ) THEN 'Paid'
               ELSE status
             END
WHERE bill_id = 3;



--Query 5:Track Complaint Status
SELECT co.complain_id,
       c.customer_name,
       co.description,
       co.status AS complaint_status,
       t.technician_name,
       a.assigned_date
FROM Complaints co
JOIN Customers c ON co.customer_id = c.customer_id
LEFT JOIN Assignments a ON co.complain_id = a.complain_id
LEFT JOIN Technicians t ON a.technician_id = t.technician_id
ORDER BY
  CASE co.status
    WHEN 'Open' THEN 1
    WHEN 'In Progress' THEN 2
    WHEN 'Resolved' THEN 3
    WHEN 'Closed' THEN 4
  END,
  co.complain_id DESC;

--Query 6: Assign a Technician to a Complaint
-- Step 1: Assign technician
INSERT INTO Assignments (complain_id, technician_id, assigned_date)
VALUES (5, 2, CURRENT_DATE);

-- Step 2: Update complaint status
UPDATE Complaints
SET status = 'In Progress'
WHERE complain_id = 5;

-- Verify assignment
SELECT a.assignment_id,
       co.description AS complaint,
       co.status,
       t.technician_name,
       a.assigned_date
FROM Assignments a
JOIN Complaints co ON a.complain_id = co.complain_id
JOIN Technicians t ON a.technician_id = t.technician_id
WHERE a.complain_id = 5;


--Query 7: Full Customer Billing History
SELECT c.customer_name,
       c.phone_number,
       a.area_name,
       p.internet_speed,
       p.price AS package_price,
       s.start_date AS subscription_start,
       b.bill_id,
       b.billed_amount,
       b.due_date,
       b.status AS bill_status,
       py.payment_id,
       py.paid_amount,
       py.payment_date,
       py.method AS payment_method,
       py.status AS payment_status
FROM Customers c
JOIN Areas a ON c.area_id = a.area_id
JOIN Subscriptions s ON c.customer_id = s.customer_id
JOIN Packages p ON s.package_id = p.package_id
JOIN Bills b ON c.customer_id = b.customer_id
LEFT JOIN Payments py ON b.bill_id = py.bill_id
WHERE c.customer_id = 1
ORDER BY b.due_date DESC, py.payment_date DESC;


--Query 8: Subscription → Bill → Payment Lifecycle Summary
SELECT c.customer_name,
       p.internet_speed,
       s.start_date AS subscribed_since,
       COUNT(DISTINCT b.bill_id) AS total_bills,
       COALESCE(SUM(b.billed_amount), 0) AS total_billed,
       COALESCE(SUM(py.paid_amount), 0) AS total_paid,
       COALESCE(SUM(b.billed_amount), 0) - COALESCE(SUM(py.paid_amount), 0) AS outstanding_balance
FROM Customers c
JOIN Subscriptions s ON c.customer_id = s.customer_id
JOIN Packages p ON s.package_id = p.package_id
LEFT JOIN Bills b ON c.customer_id = b.customer_id
LEFT JOIN Payments py ON b.bill_id = py.bill_id AND py.status = 'Completed'
GROUP BY c.customer_name, p.internet_speed, s.start_date
ORDER BY outstanding_balance DESC;


--Query 9: Mark Overdue Bills
UPDATE Bills
SET status = 'Overdue'
WHERE status = 'Unpaid'
  AND due_date < CURRENT_DATE;

-- View newly overdue bills
SELECT b.bill_id, c.customer_name, b.billed_amount,
       b.due_date,
       CURRENT_DATE - b.due_date AS days_overdue
FROM Bills b
JOIN Customers c ON b.customer_id = c.customer_id
WHERE b.status = 'Overdue'
ORDER BY days_overdue DESC;



--Query 10: Close Resolved Complaints
UPDATE Complaints
SET status = 'Closed'
WHERE status = 'Resolved';

-- Confirm closure with technician info
SELECT co.complain_id,
       c.customer_name,
       co.description,
       co.status,
       t.technician_name,
       a.assigned_date
FROM Complaints co
JOIN Customers c ON co.customer_id = c.customer_id
JOIN Assignments a ON co.complain_id = a.complain_id
JOIN Technicians t ON a.technician_id = t.technician_id
WHERE co.status = 'Closed'
ORDER BY a.assigned_date DESC;
