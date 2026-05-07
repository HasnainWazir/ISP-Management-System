
--ISP MANAGEMENT SYSTEM — MEMBER 3 QUERIES
 




 --SECTION 1 — AGGREGATE & GROUP BY QUERIES


----------------------------------------------------------------
 --1.1  TOTAL REVENUE
----------------------------------------------------------------
SELECT SUM(paid_amount) AS total_revenue
FROM Payments
WHERE status = 'Completed';

--Explanation:
--Adds up the paid_amount column from the Payments table.
--Only rows where status = 'Completed' are included, so
--failed or pending payments are excluded. The result is
--a single value showing the total money the ISP has
--successfully collected from all customers.--
----------------------------------------------------------------
 --1.2  MONTHLY REVENUE REPORT
----------------------------------------------------------------
SELECT
    TO_CHAR(payment_date, 'Month') AS month,
    EXTRACT(YEAR FROM payment_date) AS year,
    SUM(paid_amount) AS monthly_revenue,
    COUNT(payment_id) AS total_transactions
FROM Payments
WHERE status = 'Completed'
GROUP BY EXTRACT(YEAR  FROM payment_date),
         EXTRACT(MONTH FROM payment_date),
         TO_CHAR(payment_date, 'Month')
ORDER BY year, EXTRACT(MONTH FROM payment_date);

--Explanation:
--Breaks down revenue by month and year. TO_CHAR converts
--the payment date into a readable month name like 'January'.
--EXTRACT pulls the numeric year and month for correct
--chronological sorting. GROUP BY groups all payments in the
--same month and year together. SUM gives total revenue per
--month and COUNT shows how many transactions occurred.
--Results are ordered in correct calendar sequence.--
----------------------------------------------------------------
 -- 1.3  UNPAID BILLS COUNT
----------------------------------------------------------------
SELECT
    COUNT(bill_id) AS unpaid_bills,
    SUM(billed_amount) AS total_unpaid_amount
FROM Bills
WHERE status = 'Unpaid';

--Explanation:
--Filters only bills with status = 'Unpaid'. COUNT(bill_id)
--counts how many individual unpaid bills exist. SUM gives
--the total outstanding money customers still owe. This query
--helps admin monitor financial risk and decide which customers
--to follow up with for payment collection.

----------------------------------------------------------------
 --1.4  MOST USED PACKAGE
----------------------------------------------------------------
SELECT
    p.package_id,
    p.internet_speed,
    p.price,
    COUNT(s.subscription_id)  AS total_subscriptions
FROM Packages p
JOIN Subscriptions s ON p.package_id = s.package_id
GROUP BY p.package_id, p.internet_speed, p.price
ORDER BY total_subscriptions DESC
LIMIT 1;

--Explanation:
--JOINs Packages with Subscriptions using the shared
--package_id. GROUP BY groups all subscriptions under the
--same package. COUNT measures how many customers subscribed
--to each package. ORDER BY DESC + LIMIT 1 returns only the
--single most popular package. Helps the ISP understand which
--plan is most in demand.

----------------------------------------------------------------
 --1.5  MOST ACTIVE AREA
----------------------------------------------------------------
SELECT
    a.area_id,
    a.area_name,
    COUNT(c.customer_id)  AS total_customers
FROM Areas a
JOIN Customers c ON a.area_id = c.area_id
GROUP BY a.area_id, a.area_name
ORDER BY total_customers DESC
LIMIT 1;

--Explanation:
--JOINs Areas and Customers on the area_id foreign key.
--GROUP BY groups all customers belonging to the same area.
--COUNT counts customers per area. ORDER BY DESC + LIMIT 1
--returns only the area with the highest customer count.
--Helps the ISP identify its most densely served location.

----------------------------------------------------------------
 --1.6  CUSTOMER DISTRIBUTION PER AREA
----------------------------------------------------------------
SELECT
    a.area_name,
    COUNT(c.customer_id) AS total_customers
FROM Areas a
LEFT JOIN Customers c ON a.area_id = c.area_id
GROUP BY a.area_name
ORDER BY total_customers DESC;

--Explanation:
--LEFT JOIN is used so that areas with zero customers are
--still included in the results — a regular JOIN would hide
--them. GROUP BY groups customers by area name. COUNT returns
--0 for areas with no customers. ORDER BY DESC shows the most
--populated areas first. Useful for geographic coverage
--analysis across the entire network.
--
----------------------------------------------------------------
 --1.7  REVENUE PER PAYMENT METHOD
----------------------------------------------------------------
SELECT
    method,
    COUNT(payment_id) AS total_payments,
    SUM(paid_amount) AS total_collected
FROM Payments
WHERE status = 'Completed'
GROUP BY method
ORDER BY total_collected DESC;

--Explanation:
--Groups all completed payments by their payment method
--(Cash, Card, Online, Bank Transfer). COUNT shows how many
--transactions used each method. SUM shows how much revenue
--each method generated. Helps the ISP understand which
--payment channels customers prefer most.


 --SECTION 2 — TECHNICIAN QUERIES


----------------------------------------------------------------
 --2.1  COMPLAINTS PER TECHNICIAN
----------------------------------------------------------------
SELECT
    t.technician_id,
    t.technician_name,
    COUNT(a.assignment_id) AS total_complaints_handled
FROM Technicians t
LEFT JOIN Assignments a ON t.technician_id = a.technician_id
GROUP BY t.technician_id, t.technician_name
ORDER BY total_complaints_handled DESC;

--Explanation:
--LEFT JOIN ensures technicians with zero assignments still
--appear in results with a count of 0. COUNT measures how
--many complaints each technician has been assigned overall.
--GROUP BY groups all assignments under each technician.
--ORDER BY DESC puts the most experienced technicians at the
--top. Useful for reviewing overall workload history.

----------------------------------------------------------------
 --2.2  TECHNICIAN WORKLOAD (ACTIVE ONLY)
----------------------------------------------------------------
SELECT
    t.technician_id,
    t.technician_name,
    COUNT(a.assignment_id) AS active_assignments
FROM Technicians t
JOIN Assignments a ON t.technician_id = a.technician_id
JOIN Complaints  c ON a.complain_id   = c.complain_id
WHERE c.status IN ('Open', 'In Progress')
GROUP BY t.technician_id, t.technician_name
ORDER BY active_assignments DESC;

--Explanation:
--Uses two JOINs to link Technicians with Assignments and
--then Assignments with Complaints. WHERE filters only
--currently active unresolved complaints (Open or In
--Progress), so resolved cases are excluded. COUNT shows
--real-time workload per technician. Helps managers decide
--whether to reassign tasks or hire more staff.

----------------------------------------------------------------
 --2.3  BEST PERFORMING TECHNICIAN
----------------------------------------------------------------
SELECT
    t.technician_id,
    t.technician_name,
    COUNT(a.assignment_id) AS resolved_complaints
FROM Technicians t
JOIN Assignments a ON t.technician_id = a.technician_id
JOIN Complaints  c ON a.complain_id   = c.complain_id
WHERE c.status = 'Resolved'
GROUP BY t.technician_id, t.technician_name
ORDER BY resolved_complaints DESC
LIMIT 1;

--Explanation:
--WHERE filters only successfully closed complaints.
--COUNT measures how many complaints each technician has
--resolved. ORDER BY DESC + LIMIT 1 picks the single
--technician with the highest resolved count. Useful for
--performance reviews, recognition, or identifying top
--performers in the team.
--
----------------------------------------------------------------
 --2.4  TECHNICIAN PERFORMANCE SUMMARY
----------------------------------------------------------------
SELECT
    t.technician_id,
    t.technician_name,
    COUNT(a.assignment_id) AS resolved_count,
    MIN(a.assigned_date) AS first_assignment,
    MAX(a.assigned_date) AS last_assignment
FROM Technicians t
JOIN Assignments a ON t.technician_id = a.technician_id
JOIN Complaints  c ON a.complain_id   = c.complain_id
WHERE c.status = 'Resolved'
GROUP BY t.technician_id, t.technician_name
ORDER BY resolved_count DESC;

--Explanation:
--The original query subtracted complain_id (an integer) from
--assigned_date (a DATE), which caused a type mismatch error.
--This fixed version counts total resolved complaints per
--technician and shows their earliest and latest assignment
--dates. MIN and MAX of assigned_date give a useful activity
--range. WHERE ensures only resolved cases are counted,
--reflecting actual completed work.

----------------------------------------------------------------
 --2.5  AVERAGE ASSIGNMENTS PER TECHNICIAN
----------------------------------------------------------------
SELECT
    ROUND(AVG(assignment_count), 2) AS avg_assignments_per_technician
FROM (
    SELECT
        t.technician_id,
        COUNT(a.assignment_id)  AS assignment_count
    FROM Technicians t
    LEFT JOIN Assignments a ON t.technician_id = a.technician_id
    GROUP BY t.technician_id
) AS tech_counts;

--Explanation:
--The inner subquery calculates the total assignment count
--for every technician individually using LEFT JOIN and
--GROUP BY. The outer query then takes the average of all
--those counts using AVG. ROUND formats the result to 2
--decimal places. This gives management a benchmark to
--compare individual technician workloads against the team
--average.



 --SECTION 3 — SUBQUERIES


----------------------------------------------------------------
 --3.1  CUSTOMER WITH HIGHEST TOTAL BILLS
----------------------------------------------------------------
SELECT
    customer_id,
    customer_name
FROM Customers
WHERE customer_id = (
    SELECT customer_id
    FROM Bills
    GROUP BY customer_id
    ORDER BY SUM(billed_amount) DESC
    LIMIT 1
);

--Explanation:
--The inner subquery groups all bills by customer_id and
--calculates total billed amount per customer. ORDER BY
--SUM(billed_amount) DESC + LIMIT 1 picks the customer_id
--with the highest total. The outer query uses that ID to
--fetch the customer name. This two-step approach cleanly
--separates find-the-id logic from fetch-the-details logic.

----------------------------------------------------------------
 --3.2  PACKAGES NEVER SUBSCRIBED TO
----------------------------------------------------------------
SELECT
    package_id,
    internet_speed,
    price
FROM Packages
WHERE package_id NOT IN (
    SELECT DISTINCT package_id
    FROM Subscriptions
);

--Explanation:
--The inner subquery collects all package_ids that appear in
--the Subscriptions table. DISTINCT ensures each ID appears
--only once. NOT IN in the outer query returns only packages
--whose ID does not appear there — meaning zero customers
--have ever subscribed to them. Helps identify inactive or
--unappealing packages that may need repricing or removal.

----------------------------------------------------------------
--3.3  CUSTOMERS WITH UNPAID BILLS
----------------------------------------------------------------
SELECT
    customer_id,
    customer_name,
    phone_number
FROM Customers
WHERE customer_id IN (
    SELECT DISTINCT customer_id
    FROM Bills
    WHERE status = 'Unpaid'
);

--Explanation:
--The inner subquery finds all customer_ids from Bills where
--the bill status is 'Unpaid'. DISTINCT prevents duplicates
--in case a customer has multiple unpaid bills. The outer
--query retrieves the name and phone number of those
--customers. The result can be used by the billing team to
--directly contact customers who have outstanding payments.

----------------------------------------------------------------
 --3.4  TECHNICIANS WITH NO ASSIGNMENTS
----------------------------------------------------------------
SELECT
    technician_id,
    technician_name,
    phone_number
FROM Technicians
WHERE technician_id NOT IN (
    SELECT DISTINCT technician_id
    FROM Assignments
);

--Explanation:
--The inner subquery collects all technician_ids that appear
--at least once in the Assignments table. NOT IN returns only
--technicians whose ID does not appear there — meaning they
--have never been assigned any complaint. Helps managers
--identify idle or newly added technicians and balance
--workloads by assigning them to pending complaints.

----------------------------------------------------------------
 --3.5  AREAS ABOVE AVERAGE CUSTOMER COUNT
----------------------------------------------------------------
SELECT
    a.area_name,
    COUNT(c.customer_id)  AS total_customers
FROM Areas a
JOIN Customers c ON a.area_id = c.area_id
GROUP BY a.area_name
HAVING COUNT(c.customer_id) > (
    SELECT AVG(customer_count)
    FROM (
        SELECT COUNT(customer_id) AS customer_count
        FROM Customers
        GROUP BY area_id
    ) AS area_avg
);

--Explanation:
--The innermost subquery counts customers per area_id. The
--middle subquery takes the average of those counts. HAVING
--filters the outer query to only return areas whose customer
--count is above that average. This identifies which areas
--have more customers than the typical area — useful for
--planning infrastructure investment and staff allocation.



 --SECTION 4 — DASHBOARD & PERFORMANCE QUERIES


----------------------------------------------------------------
 --4.1  FULL ADMIN DASHBOARD
----------------------------------------------------------------
SELECT
    (SELECT COUNT(*) FROM Customers) AS total_customers,
    (SELECT COUNT(*) FROM Subscriptions) AS total_subscriptions,
    (SELECT COUNT(*) FROM Technicians) AS total_technicians,
    (SELECT SUM(paid_amount) FROM Payments   WHERE status = 'Completed') AS total_revenue,
    (SELECT COUNT(*) FROM Bills      WHERE status = 'Unpaid') AS unpaid_bills,
    (SELECT COUNT(*) FROM Bills      WHERE status = 'Overdue') AS overdue_bills,
    (SELECT COUNT(*) FROM Complaints WHERE status = 'Open') AS open_complaints,
    (SELECT COUNT(*) FROM Complaints WHERE status = 'In Progress') AS inprogress_complaints,
    (SELECT COUNT(*) FROM Complaints WHERE status = 'Resolved') AS resolved_complaints;

--Explanation:
--Each scalar subquery runs independently and returns exactly
--one value, producing a single summary row with 9 columns.
--total_customers counts all registered customers.
--total_revenue sums only completed payments for actual money
--collected. unpaid_bills and overdue_bills show financial
--exposure. open_complaints vs resolved_complaints shows the
--current support load. This single query is perfect for
--populating all cards on an admin dashboard at once.

----------------------------------------------------------------
 --4.2  COLLECTION EFFICIENCY (BILLED VS COLLECTED)
----------------------------------------------------------------
SELECT
    SUM(b.billed_amount) AS total_billed,
    COALESCE(SUM(p.paid_amount), 0) AS total_collected,
    SUM(b.billed_amount) - COALESCE(SUM(p.paid_amount), 0) AS outstanding_amount,
    ROUND(
        COALESCE(SUM(p.paid_amount), 0) /
        NULLIF(SUM(b.billed_amount), 0) * 100
    , 2) AS collection_percentage
FROM Bills b
LEFT JOIN Payments p
       ON b.bill_id  = p.bill_id
      AND p.status   = 'Completed';

--Explanation:
--LEFT JOIN includes bills that have no payment yet.
--SUM(billed_amount) totals everything charged to customers.
--SUM(paid_amount) totals everything actually collected.
--outstanding_amount = total billed minus total collected.
--collection_percentage shows efficiency as a 0-100 value.
--COALESCE prevents NULL errors when no payments exist.
--NULLIF prevents division-by-zero if nothing was billed.
--A percentage near 100 means the ISP is recovering almost
--all of its billed revenue successfully.

----------------------------------------------------------------
 --4.3  COMPLAINT STATUS BREAKDOWN
----------------------------------------------------------------
SELECT
    status,
    COUNT(complain_id) AS total,
    ROUND(COUNT(complain_id) * 100.0 /
        NULLIF((SELECT COUNT(*) FROM Complaints), 0), 2) AS percentage
FROM Complaints
GROUP BY status
ORDER BY total DESC;

--Explanation:
--GROUP BY status separates complaints into Open, In Progress,
--Resolved, and Closed groups. COUNT counts complaints in each
--group. The inner subquery gets the total complaint count.
--Dividing group count by total and multiplying by 100 gives
--the percentage share of each status. NULLIF prevents a
--division-by-zero crash if the table is empty. Helps
--management see at a glance whether complaints are being
--resolved or building up.

----------------------------------------------------------------
 --4.4  BILLS SUMMARY PER CUSTOMER
----------------------------------------------------------------
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(b.bill_id) AS total_bills,
    SUM(b.billed_amount) AS total_billed,
    SUM(CASE WHEN b.status = 'Paid'
        THEN b.billed_amount ELSE 0 END) AS total_paid_bills,
    SUM(CASE WHEN b.status = 'Unpaid'
        THEN b.billed_amount ELSE 0 END) AS total_unpaid_bills
FROM Customers c
LEFT JOIN Bills b ON c.customer_id = b.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_billed DESC;

--Explanation:
--LEFT JOIN includes customers who have no bills yet.
--COUNT(bill_id) counts total bills per customer. SUM of
--billed_amount gives the total amount ever charged. The two
--CASE WHEN expressions conditionally sum amounts only for
--bills with a specific status — Paid or Unpaid — giving a
--financial breakdown per customer in a single row. ORDER BY
--total_billed DESC puts the highest-value customers first,
--useful for prioritizing billing follow-ups.





 --END OF FILE

