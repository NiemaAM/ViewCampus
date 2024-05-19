DROP DATABASE ViewCampus;
CREATE DATABASE ViewCampus;

CREATE ROLE admin WITH LOGIN PASSWORD 'admin';
GRANT CONNECT ON DATABASE ViewCampus TO admin;
GRANT pg_read_all_data TO admin;
GRANT pg_write_all_data TO admin;

CREATE TABLE PROFIL (
    profil_id INT PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,

    email VARCHAR(255) UNIQUE CHECK (email LIKE '%@%') NOT NULL,
    password VARCHAR(255) NOT NULL,

    profil_type VARCHAR(50) CHECK (profil_type IN ('student','staff','professor','guest')) NOT NULL,

    CONSTRAINT check_name_characters 
    CHECK (first_name NOT LIKE '%[^0-9!@#$%^&*()-_=+{}|;:",<>?/\\~`\[\]]%' 
    AND last_name NOT LIKE '%[^0-9!@#$%^&*()-_=+{}|;:",<>?/\\~`\[\]]%')
);


CREATE TABLE STUDENT (
    profil_id INT PRIMARY KEY REFERENCES PROFIL(profil_id),
    major VARCHAR(255) NOT NULL
);

CREATE TABLE CLUB (
    club_id SERIAL PRIMARY KEY,
    advisor_id INT REFERENCES PROFIL(profil_id) NOT NULL,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE MEMBER (
    student_id INT REFERENCES PROFIL(profil_id) NOT NULL,
    club_id INTEGER REFERENCES CLUB(club_id) NOT NULL,
    PRIMARY KEY(student_id, club_id)
);

CREATE TABLE BOARD (
    student_id INT REFERENCES PROFIL(profil_id),
    club_id INT REFERENCES CLUB(club_id),
    PRIMARY KEY(student_id, club_id)
);

CREATE TABLE STAFF (
    profil_id INT PRIMARY KEY REFERENCES PROFIL(profil_id),
    job_title VARCHAR(255) NOT NULL
);

CREATE TABLE PROFESSOR (
    profil_id INT PRIMARY KEY REFERENCES PROFIL(profil_id),
    office INT NOT NULL,
    phone INT NOT NULL CHECK (phone >= 100000000 AND phone <= 999999999)
);

CREATE TABLE COURSE (
    course_code VARCHAR(255) PRIMARY KEY,
    school VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE CLASS (
    professor_id INT REFERENCES PROFIL(profil_id),
    course_code VARCHAR(255) REFERENCES COURSE(course_code),
    PRIMARY KEY(professor_id , course_code)
);

CREATE TABLE GUEST (
    profil_id INT PRIMARY KEY REFERENCES PROFIL(profil_id),
    phone INT NOT NULL CHECK (phone >= 100000000 AND phone <= 999999999)
);

CREATE TABLE EVENT (
    event_id SERIAL PRIMARY KEY,
    profil_id INT REFERENCES PROFIL(profil_id) NOT NULL,

    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,

    start_date_time TIMESTAMP NOT NULL,
    end_date_time TIMESTAMP NOT NULL,

    event_type VARCHAR(50) CHECK (event_type IN ('club', 'class')),

--for simplification of the app only
    room_number INT CHECK (BETWEEN(1, 200)),
    building_number VARCHAR(2) NOT NULL,

    CONSTRAINT check_end_after_start CHECK (end_date_time > start_date_time)
);


CREATE TABLE CLUB_EVENT (
    event_id INT PRIMARY KEY REFERENCES EVENT(event_id),
    club_id INT REFERENCES CLUB(club_id)
);

CREATE TABLE CLASS_EVENT (
    event_id INT PRIMARY KEY REFERENCES EVENT(event_id),
    course_code VARCHAR(255) REFERENCES COURSE(course_code)
);

CREATE TABLE NOTIFICATION (
    notification_id SERIAL PRIMARY KEY,
    profil_id INT REFERENCES PROFIL(profil_id) NOT NULL,
    event_id INT REFERENCES EVENT(event_id) NOT NULL,
    message TEXT
);

CREATE TABLE BUILDING (
    building_number VARCHAR(255) PRIMARY KEY,
    floors INT NOT NULL
);

CREATE TABLE ROOM (
    room_number INT,
    building_number VARCHAR(255) REFERENCES BUILDING(building_number) NOT NULL,
    capacity INT NOT NULL,
    PRIMARY KEY(room_number, building_number)
);

CREATE TABLE EQUIPMENT (
    equipment_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE EQUIPED (
    equipment_id INT REFERENCES EQUIPMENT(equipment_id) NOT NULL,
    room_number INT,
    building_number VARCHAR(255),
    quantity INT NOT NULL,
    PRIMARY KEY(equipment_id, room_number, building_number),
    FOREIGN KEY (room_number, building_number) REFERENCES ROOM(room_number, building_number)
);

CREATE TABLE BOOK (
    event_id INT REFERENCES EVENT(event_id) NOT NULL,
    room_number INT,
    building_number VARCHAR(255),
    PRIMARY KEY(event_id, room_number, building_number),
    FOREIGN KEY (room_number, building_number) REFERENCES ROOM(room_number, building_number)
);

INSERT INTO profil(profil_id, first_name, last_name, email, password, profil_type) 
VALUES
(157755, 'niema', 'alaoui mdaghri', 'n.alaouimdaghri@aui.ma', '123', 'student');

SELECT * FROM profil WHERE email = 'n.alaouimdaghri@aui.ma' AND password = '123';

INSERT INTO event(profil_id, start_date_time, end_date_time, name, description, event_type, room_number, building_number) 
VALUES 
(157755, '2024-05-20 10:00:00', '2024-05-20 12:00:00', 'event1', 'decsrption for event 1', 'club', '102', '8B');

DROP FUNCTION check_time();
DROP FUNCTION check_conflict();
DROP TRIGGER IF EXISTS trigger_time ON event;
DROP TRIGGER IF EXISTS trigger_conflict ON event;

-- Create the function check_time()
CREATE OR REPLACE FUNCTION check_time()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.start_date_time > NEW.end_date_time THEN
        RAISE EXCEPTION 'The event starting time must be before the event ending time!';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the trigger trigger_time
CREATE TRIGGER trigger_time
BEFORE INSERT OR UPDATE
ON event
FOR EACH ROW
EXECUTE PROCEDURE check_time();

CREATE OR REPLACE FUNCTION check_conflict()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM event 
        WHERE ((start_date_time <= NEW.start_date_time AND end_date_time >= NEW.start_date_time)
            OR (start_date_time <= NEW.end_date_time AND end_date_time >= NEW.end_date_time)
            OR (start_date_time >= NEW.start_date_time AND start_date_time <= NEW.end_date_time))
            AND room_number = NEW.room_number 
            AND building_number = NEW.building_number
            AND event_id != NEW.event_id
    ) THEN
        RAISE EXCEPTION 'There is a time conflict with an existing event!';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the trigger trigger_conflict
CREATE TRIGGER trigger_conflict
BEFORE INSERT OR UPDATE
ON event
FOR EACH ROW
EXECUTE PROCEDURE check_conflict();


CREATE OR REPLACE FUNCTION check_event_type_and_profile()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.profil_id IN (SELECT profil_id FROM STAFF) THEN
        RETURN NEW;
    END IF;
    IF NEW.event_type = 'class' THEN
        IF NOT EXISTS (
            SELECT 1
            FROM PROFESSOR
            WHERE profil_id = NEW.profil_id
        ) THEN
            RAISE EXCEPTION 'Only professors can create events of type "class".';
        END IF;
    END IF;
    
    IF NEW.event_type = 'club' THEN 
        IF NOT EXISTS (
            SELECT 1
            FROM BOARD
            WHERE profil_id = NEW.profil_id
        ) THEN
            RAISE EXCEPTION 'Only board members can create events of type "club".';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER check_event_type_and_profile_trigger
BEFORE INSERT ON EVENT
FOR EACH ROW
EXECUTE FUNCTION check_event_type_and_profile();

SELECT * FROM EVENT;

SELECT
    profil_id,
    COUNT(*) AS Number_Of_Bookings_per_week
FROM
    EVENT
WHERE
    start_date_time >= '2024-05-13'  
    AND start_date_time < '2024-05-20'  
GROUP BY
    profil_id;

SELECT
    name,
    description,
    start_date_time,
    end_date_time,
    room_number,
    building_number
FROM
    EVENT JOIN BOOK ON EVENT.event_id=BOOK.event_id
WHERE
    building_number = '8B'
ORDER BY   
   e.start_date_time DESC;
;  

CREATE VIEW List_of_Events AS (SELECT  name, description, start_date_time AS From, end_date_time AS To,
event_type AS Type, room_number AS Room, building_number AS Building FROM EVENT );



