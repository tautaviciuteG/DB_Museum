CREATE DATABASE museum;

CREATE SCHEMA museum_data;


-- _________________________________TABLES______________________________________

CREATE TABLE IF NOT EXISTS museum_data.author
(	
	author_id SERIAL PRIMARY KEY,
	first_name VARCHAR(100) NOT NULL,
	last_name VARCHAR(100) NOT NULL,
	full_name VARCHAR(201) GENERATED ALWAYS AS (first_name || ' ' || last_name) STORED,
	dob DATE NOT NULL,
	created_at TIMESTAMP NOT NULL DEFAULT NOW()
);


CREATE TABLE IF NOT EXISTS museum_data.collection
(
	item_id BIGSERIAL PRIMARY KEY,
	item_name VARCHAR(100) NOT NULL,
	type VARCHAR(100) NOT NULL,
	creation_year SMALLINT NOT NULL,
	value DECIMAL(10, 2) NOT NULL,
	storage_location VARCHAR(100) NOT NULL,
	date_acquired DATE NOT NULL,
	hold_until DATE,
	created_at TIMESTAMP NOT NULL DEFAULT NOW()
);


CREATE TABLE IF NOT EXISTS museum_data.staff
(
	staff_id SERIAL PRIMARY KEY,
	first_name VARCHAR(100) NOT NULL,
	last_name VARCHAR(100) NOT NULL,
	dob DATE NOT NULL,
	role VARCHAR(100) NOT NULL,
	valid_from DATE NOT NULL,
	valid_to DATE NOT NULL,
	created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS museum_data.visitor
(
	visitor_id BIGSERIAL PRIMARY KEY,
	visitor_type VARCHAR(50) NOT NULL,
	visitor_email VARCHAR(100),
	created_at TIMESTAMP NOT NULL DEFAULT NOW()
);


CREATE TABLE IF NOT EXISTS museum_data.exhibition
(
	exhibition_id SERIAL PRIMARY KEY,
	name VARCHAR(100) NOT NULL,
	type VARCHAR(100) NOT NULL,
	staff_id INTEGER REFERENCES museum_data.staff(staff_id),
	start_date DATE NOT NULL,
	end_date DATE NOT NULL,
	created_at TIMESTAMP NOT NULL DEFAULT NOW()
);



CREATE TABLE IF NOT EXISTS museum_data.ticket
(
	ticket_id BIGSERIAL PRIMARY KEY,
	visitor_id BIGINT REFERENCES museum_data.visitor(visitor_id),
	exhibition_id INT REFERENCES museum_data.exhibition(exhibition_id),
	staff_id INT REFERENCES museum_data.staff(staff_id),
	price DECIMAL(10, 2) NOT NULL,
	purchase_date TIMESTAMP NOT NULL,
	created_at TIMESTAMP NOT NULL DEFAULT NOW()
);


CREATE TABLE IF NOT EXISTS museum_data.collection_author
(
	item_id BIGINT REFERENCES museum_data.collection (item_id),
	author_id INT REFERENCES museum_data.author(author_id),
	
	CONSTRAINT collection_author_pk PRIMARY KEY (item_id, author_id)
);


CREATE TABLE IF NOT EXISTS museum_data.exhibition_items
(
	exhibition_id INT REFERENCES museum_data.exhibition(exhibition_id),
	item_id BIGINT REFERENCES museum_data.collection(item_id),

	CONSTRAINT exhibition_items_pk PRIMARY KEY (exhibition_id, item_id)
);


-- _________________________________CONSTRAINTS (ALTER TABLE) ______________________________________
ALTER TABLE museum_data.author 
ADD CONSTRAINT uq_author_identity
UNIQUE (first_name, last_name, dob);

ALTER TABLE museum_data.collection 
ADD CONSTRAINT uq_collection_identity UNIQUE (item_name, creation_year);

ALTER TABLE museum_data.collection 
ADD CONSTRAINT ck_collection_type_list 
CHECK (type IN ('painting', 'sculpture', 'photography'));


ALTER TABLE museum_data.collection 
ADD CONSTRAINT ck_collection_year_positive 
CHECK (creation_year > 0);

ALTER TABLE museum_data.collection 
ADD CONSTRAINT ck_collection_value_non_negative 
CHECK (value >= 0);

ALTER TABLE museum_data.collection 
ADD CONSTRAINT ck_collection_valid_storage 
CHECK (storage_location IN ('Main Vault', 'Archive Room', 'Off-site Warehouse', 'Restoration Lab', 'Gallery Display'));

ALTER TABLE museum_data.collection
ADD CONSTRAINT ck_collection_dates_logical
CHECK (hold_until IS NULL OR hold_until > date_acquired);

ALTER TABLE museum_data.staff 
ADD CONSTRAINT uq_staff_identity UNIQUE (first_name, last_name, dob);

ALTER TABLE museum_data.staff 
ADD CONSTRAINT ck_staff_dates_logical 
CHECK (valid_to > valid_from);

ALTER TABLE museum_data.staff 
ADD CONSTRAINT ck_staff_valid_from_2026 
CHECK (valid_from > '2026-01-01');

ALTER TABLE museum_data.visitor
ADD CONSTRAINT ck_visitor_type_enum 
CHECK (visitor_type IN ('Standard', 'Discounted', 'Child'));

ALTER TABLE museum_data.visitor
ADD CONSTRAINT uq_visitor_email
UNIQUE (visitor_email);

ALTER TABLE museum_data.exhibition
ADD CONSTRAINT uq_exhibition UNIQUE (name, start_date);

ALTER TABLE museum_data.exhibition
ADD CONSTRAINT ck_start_date
CHECK (start_date > '2026-01-01');

ALTER TABLE museum_data.exhibition
ADD CONSTRAINT ck_exhibition_type_enum 
CHECK (type IN ('Online', 'On-site'));


ALTER TABLE museum_data.ticket
ADD CONSTRAINT ck_price_value_non_negative
CHECK (price >= 0);

ALTER TABLE museum_data.ticket
ADD CONSTRAINT ck_ticket_purchase_date
CHECK (purchase_date > '2026-01-01');

-- _________________________________INSERTING INTO TABLES ______________________________________

INSERT INTO museum_data.author (first_name, last_name, dob)
VALUES 
    ('Michelangelo', 'Caravaggio', '1571-09-29'),
    ('Gian Lorenzo', 'Bernini', '1598-12-07'),
    ('Hieronymus', 'Bosch', '1450-01-01'),
    ('Auguste', 'Rodin', '1840-11-12'),
    ('Ansel', 'Adams', '1902-02-20'),
    ('Henri', 'Cartier-Bresson', '1908-08-22')
ON CONFLICT (first_name, last_name, dob) DO NOTHING;



INSERT INTO museum_data.collection (item_name, type, creation_year, value, storage_location, date_acquired)
VALUES
	('The Calling of Saint Matthew', 'painting', 1600, 15000000.00, 'Gallery Display', DATE '2026-02-15'),
    ('Apollo and Daphne', 'sculpture', 1625, 2000000.00, 'Gallery Display', DATE '2026-02-15'),
    ('The Garden of Earthly Delights', 'painting', 1500, 25000000.00, 'Main Vault', DATE '2026-02-20'),
    ('The Thinker', 'sculpture', 1904, 5000000.00,  'Gallery Display', DATE '2026-02-20'),
    ('America In Passing', 'photography', 1940, 150000.00, 'Archive Room', DATE '2026-02-01'),
    ('The Decisive Moment', 'photography', 1952, 85000.00, 'Archive Room', DATE '2026-02-01')
ON CONFLICT (item_name, creation_year) DO NOTHING;



INSERT INTO museum_data.staff (first_name, last_name, dob, role, valid_from, valid_to)
VALUES
	('James', 'Cunningham', DATE '1980-05-15', 'Curator', DATE '2026-02-05', DATE '2999-01-01'),
    ('Eleanor', 'Rigby', DATE '1992-11-24', 'Guide', DATE '2026-02-02', DATE '2999-01-01'),
    ('Arthur', 'Shelby', DATE '1975-03-10', 'Security', DATE '2026-03-02', DATE '2999-01-01'),
    ('Margaret', 'Thatcher', DATE '1965-10-13', 'Manager', DATE '2026-02-05', DATE '2999-01-01'),
    ('William', 'Blackwood', DATE '1988-07-02', 'Restorer', DATE '2026-03-23', DATE '2999-01-01'),
    ('Rose', 'Dawson', DATE '1995-04-06', 'Ticket Agent', DATE '2026-02-05', DATE '2999-01-01')
ON CONFLICT (first_name, last_name, dob) DO NOTHING;



INSERT INTO museum_data.visitor (visitor_type, visitor_email)
VALUES
	('Standard', 'm.that@gmail.com'),
	('Child', 'young.rigby@school.uk'),
	('Discounted', NULL),
	('Standard', NULL),
	('Standard', NULL),
	('Child', NULL)
ON CONFLICT (visitor_email) DO NOTHING;


-- NOTE: New records each time the script is run. This reflects a real-world scenario 
-- where anonymous visitors at the ticket office are treated as unique individuals.
-- Without identifying data (e.g., name, surname, or DOB), rerunability for anonymous records is challenging.

INSERT INTO museum_data.exhibition (name, type, staff_id, start_date, end_date)
SELECT x.name, x.type, s.staff_id, x.start_date, x.end_date
FROM (
    VALUES
        ('Baroque Masterpieces', 'On-site', 'Cunningham', DATE '2026-02-02', DATE '2026-04-30'),
        ('The Surreal World', 'Online', 'Cunningham', DATE '2026-02-10', DATE '2026-05-10'),
        ('Modern Photography', 'On-site', 'Cunningham', DATE '2026-02-20', DATE '2026-04-20'),
        ('Renaissance Echoes', 'On-site', 'Cunningham', DATE '2026-03-01', DATE '2026-05-31'),
        ('The Golden Age of Art', 'Online', 'Cunningham', DATE '2026-03-15', DATE '2027-06-15'),
        ('Abstract Impressions', 'On-site', 'Cunningham', DATE '2026-04-01', DATE '2027-07-01'),
        ('Security & Preservation', 'On-site', 'Cunningham', DATE '2026-04-10', DATE '2029-12-31')
) AS x(name, type, s_last, start_date, end_date)
JOIN museum_data.staff s ON s.last_name = x.s_last
    AND s.valid_to = '2999-01-01'
ON CONFLICT (name, start_date) DO NOTHING;



INSERT INTO museum_data.exhibition_items (exhibition_id, item_id)
SELECT e.exhibition_id, c.item_id
FROM (
    VALUES 
        ('Baroque Masterpieces', 'The Calling of Saint Matthew'),
        ('Baroque Masterpieces', 'Apollo and Daphne'),
        ('The Surreal World', 'The Garden of Earthly Delights'),
        ('Modern Photography', 'America In Passing'),
        ('Modern Photography', 'The Decisive Moment'),
        ('Renaissance Echoes', 'The Calling of Saint Matthew'), -- Same item, different exhibition
        ('The Golden Age of Art', 'The Thinker')
) AS l(ex_name, item_name)
JOIN museum_data.exhibition e ON e.name = l.ex_name
JOIN museum_data.collection c ON c.item_name = l.item_name
ON CONFLICT DO NOTHING;



INSERT INTO museum_data.collection_author (item_id, author_id)
SELECT c.item_id, a.author_id
FROM (
    VALUES 
        ('The Calling of Saint Matthew', 'Caravaggio'),
        ('Apollo and Daphne', 'Bernini'),
        ('The Garden of Earthly Delights', 'Bosch'),
        ('America In Passing', 'Adams'),
        ('The Decisive Moment', 'Cartier-Bresson'),
        ('The Thinker', 'Rodin')
) AS l(i_name, a_last)
JOIN museum_data.collection c ON c.item_name = l.i_name
JOIN museum_data.author a ON a.last_name = l.a_last
ON CONFLICT DO NOTHING;




INSERT INTO museum_data.ticket (visitor_id, exhibition_id, staff_id, purchase_date, price)
SELECT t.v_id, e.exhibition_id, s.staff_id, t.p_date,
       CASE 
         WHEN v.visitor_type = 'Standard'   THEN 20.00
         WHEN v.visitor_type = 'Discounted' THEN 12.00
         WHEN v.visitor_type = 'Child'      THEN  7.00
       END
FROM (
    VALUES 
        (1, 'Baroque Masterpieces', TIMESTAMP '2026-02-05 10:30:00'),
        (2, 'The Surreal World', TIMESTAMP '2026-02-18 14:15:00'),
        (3, 'Modern Photography', TIMESTAMP '2026-03-07 09:00:00'),
        (4, 'Baroque Masterpieces', TIMESTAMP '2026-03-22 16:45:00'),
        (5, 'Renaissance Echoes', TIMESTAMP '2026-04-10 11:20:00'),
        (6, 'The Golden Age of Art', TIMESTAMP '2026-04-21 13:10:00')
) AS t(v_id, t_name, p_date)
JOIN museum_data.exhibition e ON e.name = t.t_name
JOIN museum_data.visitor    v ON v.visitor_id = t.v_id
JOIN museum_data.staff      s ON UPPER(s.first_name) = 'ROSE'
                              AND UPPER(s.last_name)  = 'DAWSON'
                              AND UPPER(s.role)        = 'TICKET AGENT'
                              AND s.valid_to = '2999-01-01'
WHERE NOT EXISTS (
    SELECT 1 FROM museum_data.ticket tk
    WHERE tk.visitor_id    = t.v_id
      AND tk.exhibition_id = e.exhibition_id
      AND tk.purchase_date = t.p_date
);


-- _________________________________FUNCTIONS______________________________________

/*
5.1 Create a function that updates data in one of your tables.
This function should take the following input arguments:
The primary key value of the row you want to update
The name of the column you want to update
The new value you want to set for the specified column

This function should be designed to modify the specified row in the table,
updating the specified column with the new value.
*/

CREATE OR REPLACE FUNCTION museum_data.update_collection(
    p_item_id BIGINT, 
    p_name TEXT, 
    p_new_value TEXT
)
RETURNS SETOF museum_data.collection
LANGUAGE plpgsql
AS $$
BEGIN

    IF p_name = 'item_name' THEN
        UPDATE museum_data.collection SET item_name = p_new_value WHERE item_id = p_item_id;
    ELSIF p_name = 'type' THEN
        UPDATE museum_data.collection SET type = p_new_value WHERE item_id = p_item_id;
    ELSIF p_name = 'creation_year' THEN
        UPDATE museum_data.collection SET creation_year = p_new_value::int2 WHERE item_id = p_item_id;
    ELSIF p_name = 'value' THEN
        UPDATE museum_data.collection SET value = p_new_value::numeric(10,2) WHERE item_id = p_item_id;
    ELSIF p_name = 'storage_location' THEN
        UPDATE museum_data.collection SET storage_location = p_new_value WHERE item_id = p_item_id;
	ELSIF p_name = 'date_acquired' THEN
    	UPDATE museum_data.collection SET date_acquired = p_new_value::DATE WHERE item_id = p_item_id;
	ELSIF p_name = 'hold_until' THEN
    	UPDATE museum_data.collection SET hold_until = p_new_value::DATE WHERE item_id = p_item_id;
	
	ELSE
		RAISE EXCEPTION 'Update rejected: unknown column "%" .', p_name;
	
    END IF;

	IF NOT FOUND THEN
	        RAISE EXCEPTION 'Update failed: item with ID % not found.', p_item_id;
	END IF;

    RETURN QUERY SELECT * FROM museum_data.collection WHERE item_id = p_item_id;
END;
$$;

-- CHECK -------------------------------------------------------------------------------
-- change storage location
SELECT * FROM museum_data.update_collection(1, 'storage_location', 'Gallery Display');

-- change value
SELECT * FROM museum_data.update_collection(1, 'value', '17000000.00');

-- change creation_year
SELECT * FROM museum_data.update_collection(1, 'creation_year', '1789');


-- exceptions check
SELECT * FROM museum_data.update_collection(1, 'location', 'Gallery Display'); -- ERROR: Update rejected: unknown column "location" .

SELECT * FROM museum_data.update_collection(124, 'storage_location', 'Gallery Display'); -- ERROR: Update failed: item with ID 124 not found.




/* 5.2 Create a function that adds a new transaction to your transaction table. 
You can define the input arguments and output format. 
Make sure all transaction attributes can be set with the function (via their natural keys). 
The function does not need to return a value but should confirm the successful insertion of the new transaction. */

CREATE OR REPLACE FUNCTION museum_data.add_ticket(
	p_exhibition_name TEXT,
	p_staff_last_name TEXT,
	p_visitor_type VARCHAR(50) DEFAULT 'Standard'
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$

DECLARE
	v_visitor_id BIGINT;
	v_exhibition_id INTEGER;
	v_staff_id INTEGER;
	v_price DECIMAL;

BEGIN	
	
	INSERT INTO museum_data.visitor (visitor_type)
	VALUES (p_visitor_type)
	RETURNING visitor_id INTO v_visitor_id;


	SELECT exhibition_id INTO v_exhibition_id
	FROM museum_data.exhibition
	WHERE UPPER(name) = UPPER(p_exhibition_name);
	
	IF v_exhibition_id IS NULL THEN
		RAISE EXCEPTION 'Exhibition "%" not found.', p_exhibition_name;
	END IF;


	SELECT staff_id INTO v_staff_id
	FROM museum_data.staff
	WHERE UPPER(last_name) = UPPER(p_staff_last_name)
		AND valid_to = '2999-01-01';

	IF v_staff_id IS NULL THEN
		RAISE EXCEPTION 'Staff member "%" not found.', p_staff_last_name;
	END IF;

    v_price := CASE p_visitor_type
        WHEN 'Standard'   THEN 20.00
        WHEN 'Discounted' THEN 12.00
        WHEN 'Child'      THEN  7.00
    END;

	INSERT INTO museum_data.ticket
	(
		visitor_id,
		exhibition_id,
		staff_id,
		price,
		purchase_date
	)
	
	VALUES
	(
		v_visitor_id,
		v_exhibition_id,
		v_staff_id,
		v_price,
		NOW()
	);

	RETURN 'Success: Ticket added';

END;
$$;

-- CHECK -------------------------------------------------------------------------------
SELECT museum_data.add_ticket('Baroque Masterpieces', 'Dawson');
SELECT museum_data.add_ticket('Modern Photography', 'Dawson', 'Child');


-- exceptions check
SELECT museum_data.add_ticket('Fake', 'Dawson'); -- SQL Error [P0001]: ERROR: Exhibition "Fake" not found.

SELECT museum_data.add_ticket('Baroque Masterpieces', 'Smith'); -- SQL Error [P0001]: ERROR: Staff member "Smith" not found.
SELECT museum_data.add_ticket('Baroque Masterpieces', 'Dawson', 'VIP'); -- SQL Error [23514]: ERROR: new row for relation "visitor" violates check constraint "ck_visitor_type_enum"



/* 6. Create a view that presents analytics for the most recently added quarter in your database.
Ensure that the result excludes irrelevant fields such as surrogate keys and duplicate entries. */


CREATE OR REPLACE VIEW museum_data.sales_revenue AS
SELECT
    EXTRACT(YEAR FROM t.purchase_date) || '-Q' || EXTRACT(QUARTER FROM t.purchase_date) AS current_quarter,
    v.visitor_type,
    COUNT(t.ticket_id) AS visitor_count,
    SUM(t.price) AS total_sales
FROM museum_data.ticket t
JOIN museum_data.visitor v ON t.visitor_id = v.visitor_id
WHERE (EXTRACT(YEAR FROM t.purchase_date), EXTRACT(QUARTER FROM t.purchase_date)) =
(
    SELECT 
        EXTRACT(YEAR FROM MAX(purchase_date)),
        EXTRACT(QUARTER FROM MAX(purchase_date))
    FROM museum_data.ticket
)
GROUP BY current_quarter, v.visitor_type;


-- CHECK -------------------------------------------------------------------------------
SELECT * FROM museum_data.sales_revenue;


/*  7. Create a read-only role for the manager.
 This role should have permission to perform
 SELECT queries on the database tables, and also be able to log in.
 
 Please ensure that you adhere to best practices for database security when defining this role. */

-- 1. Create a group role
CREATE ROLE manager;

-- Create a specific user for Margaret with a password
CREATE USER manager_margaret_t WITH PASSWORD 'pswrd1875!';

-- Allow the manager role to connect to the museum database 
GRANT CONNECT ON DATABASE museum TO manager;

-- Grant access to the museum_data schema
GRANT USAGE ON SCHEMA museum_data TO manager;

-- Grant read-only access to the database tables 
GRANT SELECT ON ALL TABLES IN SCHEMA museum_data TO manager;

-- Assign the manager role (and all its permissions) to Margaret
GRANT manager TO manager_margaret_t;


-- CHECK -------------------------------------------------------------------------------
SET ROLE manager_margaret_t;

SELECT * FROM museum_data.author;
SELECT * FROM museum_data.ticket;


RESET ROLE;
