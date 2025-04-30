CREATE DATABASE IF NOT EXISTS usat_match;

USE usat_match;

-- ****************************
-- EMAIL LIST
-- ****************************
DROP TABLE IF EXISTS usat_match.email_021525;

CREATE TABLE IF NOT EXISTS email_021525 (
    created_at_date_profiles DATE,
    id_profiles INT PRIMARY KEY,
    email_users VARCHAR(255),
    first_name_profiles VARCHAR(500),
    date_of_birth_profiles DATE,
    count_profile_id INT
);

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/data/usat_match_project/email_021525.csv"
INTO TABLE email_021525
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@created_at_date_profiles, @id_profiles, @email_users, @first_name_profiles, @date_of_birth_profiles, @count_profile_id)
SET 
    created_at_date_profiles = STR_TO_DATE(@created_at_date_profiles, '%Y-%m-%d'),
    id_profiles = NULLIF(@id_profiles, ''),
    email_users = NULLIF(TRIM(LOWER(@email_users)), ''),  
    first_name_profiles = LEFT(NULLIF(TRIM(@first_name_profiles), ''), 500),  -- Truncate long names to 500 characters
    date_of_birth_profiles = STR_TO_DATE(@date_of_birth_profiles, '%Y-%m-%d'),
    count_profile_id = NULLIF(@count_profile_id, '')
;

ALTER TABLE email_021525 
ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

SELECT * FROM usat_match.email_021525 ORDER BY created_at_date_profiles ASC LIMIT 10;
SELECT COUNT(*) FROM usat_match.email_021525 ORDER BY created_at_date_profiles ASC LIMIT 10;

-- ****************************
-- EVENT LIST
-- ****************************
DROP TABLE IF EXISTS usat_match.events_021525;

CREATE TABLE IF NOT EXISTS usat_match.events_021525 (
    id_events INT PRIMARY KEY,
    id_sanctioning_events VARCHAR(255),
    created_at_events DATE,
    id_count_events INT
);

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/data/usat_match_project/event_id_021525.csv"
INTO TABLE usat_match.events_021525
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id_events, id_sanctioning_events, @created_at_events, id_count_events)
SET created_at_events = STR_TO_DATE(@created_at_events, '%Y-%m-%d %H:%i:%s');

ALTER TABLE events_021525
ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

SELECT * FROM usat_match.events_021525 ORDER BY created_at_events ASC LIMIT 10;
SELECT COUNT(*) FROM usat_match.events_021525 ORDER BY created_at_events ASC LIMIT 10;

-- ****************************
-- MEMBERSHIP PERIOD SALES
-- ****************************
DROP TABLE IF EXISTS usat_match.membership_periods_021525;

CREATE TABLE usat_match.membership_periods_021525 (
    created_at_mp DATETIME,
    id_events INT NULL,
    starts_mp DATE NULL,
    ends_mp DATE NULL,
    id_membership_periods_sa INT PRIMARY KEY,
    member_number_members_sa INT NULL,
    id_profiles INT NULL,
    id_membership_count INT NULL
);

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/data/usat_match_project/mp_created_060124_forward.csv"
INTO TABLE usat_match.membership_periods_021525
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'  -- Change to '\n' if using Linux/Mac
IGNORE 1 ROWS
(@created_at_mp, @id_events, @starts_mp, @ends_mp, @id_membership_periods_sa, @member_number_members_sa, @id_profiles, id_membership_count)
SET 
    created_at_mp = STR_TO_DATE(@created_at_mp, '%m/%d/%Y %H:%i:%s'),
    id_events = NULLIF(@id_events, ''),
    starts_mp = STR_TO_DATE(@starts_mp, '%m/%d/%Y'),
    ends_mp = STR_TO_DATE(@ends_mp, '%m/%d/%Y'),
    id_membership_periods_sa = NULLIF(@id_membership_periods_sa, ''),
    -- Ensure member_number_members_sa is numeric, remove special characters if needed
    member_number_members_sa = NULLIF(REGEXP_REPLACE(@member_number_members_sa, '[^0-9]', ''), ''),
    id_profiles = NULLIF(@id_profiles, '')
;

ALTER TABLE membership_periods_021525
ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

SELECT * FROM usat_match.membership_periods_021525 ORDER BY created_at_mp ASC LIMIT 10;
SELECT COUNT(*) FROM usat_match.membership_periods_021525 ORDER BY created_at_mp ASC LIMIT 10;

-- ****************************
-- TICKET SOCKET DATA
-- ****************************
DROP TABLE IF EXISTS usat_match.ticket_socket_021525;

CREATE TABLE usat_match.ticket_socket_021525 (
    group_id INT,
    ticket_id INT,
    amount DECIMAL(10,2) NULL,
    membership_type VARCHAR(50) NULL,
    ts_event_id INT NULL,
    usat_event_id INT NULL,
    event_name VARCHAR(255) NULL,
    usat_id TEXT NULL,
    email_address VARCHAR(255) NOT NULL,
    purchase_date DATETIME NOT NULL,
    first_name TEXT NULL,
    last_name TEXT NULL,
    dob DATE NULL,
    address VARCHAR(255) NULL,
    city VARCHAR(100) NULL,
    state VARCHAR(50) NULL,
    zip VARCHAR(20) NULL,
    gender VARCHAR(10) NULL
);

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/data/usat_match_project/REVISION2_IM_USAT_Ticket_Data-2024-06-15-thru-2025-02-13.csv"
INTO TABLE usat_match.ticket_socket_021525
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'  -- Change to '\n' if using Linux/Mac
IGNORE 1 ROWS
(@group_id, @ticket_id, @amount, @ticket_id_dup, @membership_type, @ts_event_id, @usat_event_id, @event_name, 
 @usat_id, email_address, @purchase_date, @first_name, @last_name, @dob, @address, @city, @state, @zip, @gender)
SET 
    group_id = NULLIF(@group_id, ''),
    ticket_id = NULLIF(@ticket_id, ''),
    amount = NULLIF(@amount, ''),
    membership_type = NULLIF(@membership_type, ''),
    ts_event_id = NULLIF(@ts_event_id, ''),
    usat_event_id = NULLIF(@usat_event_id, ''),
    event_name = NULLIF(@event_name, ''),
    usat_id = NULLIF(@usat_id, ''),
    purchase_date = CASE 
        WHEN @purchase_date LIKE '%EST' THEN STR_TO_DATE(SUBSTRING_INDEX(@purchase_date, ' ', 2), '%Y-%m-%d %H:%i:%s')
        WHEN @purchase_date IN ('', '0-0-0') THEN NULL
        ELSE STR_TO_DATE(@purchase_date, '%Y-%m-%d %H:%i:%s') 
    END,
    first_name = NULLIF(@first_name, ''),
    last_name = NULLIF(@last_name, ''),
    dob = CASE 
        WHEN @dob IN ('', '0-0-0', '0000-00-00') THEN NULL  -- Convert bad dates to NULL
        WHEN @dob REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN STR_TO_DATE(@dob, '%Y-%m-%d')  -- YYYY-MM-DD format
        WHEN @dob REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$' THEN STR_TO_DATE(@dob, '%m/%d/%Y')  -- MM/DD/YYYY format
        ELSE NULL  -- Any other invalid formats get set to NULL
    END,
    address = NULLIF(@address, ''),
    city = NULLIF(@city, ''),
    state = NULLIF(@state, ''),
    zip = NULLIF(@zip, ''),
    gender = NULLIF(@gender, '')
;

ALTER TABLE usat_match.ticket_socket_021525
ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

SELECT * FROM usat_match.ticket_socket_021525 LIMIT 10;
SELECT COUNT(*) FROM usat_match.ticket_socket_021525 ORDER BY created_at_mp ASC LIMIT 10;
