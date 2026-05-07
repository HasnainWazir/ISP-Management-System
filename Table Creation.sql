-- 1. Areas (Having no dependencies, create first)
CREATE TABLE Areas (
    area_id SERIAL PRIMARY KEY,
    area_name VARCHAR(100) NOT NULL UNIQUE
);

-- 2. Packages ( Having no dependencies)
CREATE TABLE Packages (
    package_id SERIAL PRIMARY KEY,
    internet_speed VARCHAR(50),
    price NUMERIC(10, 2) NOT NULL,
    data_limit VARCHAR(50)
);

-- 3. Technicians (Having no dependencies)
CREATE TABLE Technicians (
    technician_id SERIAL PRIMARY KEY,
    technician_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20)
);

-- 4. Users (Having no dependencies)
CREATE TABLE Users (
    user_id SERIAL PRIMARY KEY,
    role VARCHAR(50) CHECK (role IN ('Admin', 'Staff', 'Technician', 'Customer')),
    username VARCHAR(50) NOT NULL UNIQUE,
    passwords VARCHAR(255) NOT NULL
);

-- 5. Customers (depends on Areas)
CREATE TABLE Customers (
    customer_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20),
    address TEXT,
    area_id INT REFERENCES Areas(area_id) ON DELETE SET NULL
);

-- 6. Subscriptions (depends on Customers, Packages)
CREATE TABLE Subscriptions (
    subscription_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES Customers(customer_id) ON DELETE CASCADE,
    package_id INT NOT NULL REFERENCES Packages(package_id) ON DELETE RESTRICT,
    start_date DATE NOT NULL
);

-- 7. Bills (depends on Customers)
CREATE TABLE Bills (
    bill_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES Customers(customer_id) ON DELETE CASCADE,
    billed_amount NUMERIC(10, 2) NOT NULL,
    due_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'Unpaid' CHECK (status IN ('Paid', 'Unpaid', 'Overdue'))
);

-- 8. Payments (depends on Bills)
CREATE TABLE Payments (
    payment_id SERIAL PRIMARY KEY,
    bill_id INT NOT NULL REFERENCES Bills(bill_id) ON DELETE CASCADE,
    paid_amount NUMERIC(10, 2) NOT NULL,
    payment_date DATE NOT NULL DEFAULT CURRENT_DATE,
    method VARCHAR(50) CHECK (method IN ('Cash', 'Card', 'Online', 'Bank Transfer')),
    status VARCHAR(20) DEFAULT 'Pending' CHECK (status IN ('Pending', 'Completed', 'Failed'))
);

-- 9. Complaints (depends on Customers)
CREATE TABLE Complaints (
    complain_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES Customers(customer_id) ON DELETE CASCADE,
    description TEXT,
    status VARCHAR(20) DEFAULT 'Open' CHECK (status IN ('Open', 'In Progress', 'Resolved', 'Closed'))
);

-- 10. Assignments (depends on Complaints, Technicians)
CREATE TABLE Assignments (
    assignment_id SERIAL PRIMARY KEY,
    complain_id INT NOT NULL REFERENCES Complaints(complain_id) ON DELETE CASCADE,
    technician_id INT NOT NULL REFERENCES Technicians(technician_id) ON DELETE RESTRICT,
    assigned_date DATE NOT NULL DEFAULT CURRENT_DATE
);