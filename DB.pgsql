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

    start_date_time TIMESTAMP NOT NULL,
    end_date_time TIMESTAMP NOT NULL,

    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,

    event_type VARCHAR(50) CHECK (event_type IN ('club', 'class')),

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

//-- Dummy data for PROFIL table
//INSERT INTO PROFIL (profil_id, first_name, last_name, email, password, profil_type)
//VALUES
//    (1, 'John', 'Doe', 'john.doe@example.com', 'password123', 'student'),
//    (2, 'Jane', 'Smith', 'jane.smith@example.com', 'password456', 'staff'),
//    (3, 'Michael', 'Johnson', 'michael.johnson@example.com', 'password789', 'professor'),
//    (4, 'Emily', 'Brown', 'emily.brown@example.com', 'passwordabc', 'guest');

INSERT INTO profil(profil_id, first_name, last_name, email, password, profil_type) 
VALUES
(157755, 'niema', 'alaoui mdaghri', 'n.alaouimdaghri@aui.ma', '123', 'student');

-- Dummy data for STUDENT table
INSERT INTO STUDENT (profil_id, major)
VALUES
    (1, 'Computer Science');

-- Dummy data for CLUB table
INSERT INTO CLUB (advisor_id, name)
VALUES
    (2, 'Computer Club'),
    (3, 'Chess Club');

-- Dummy data for MEMBER table
INSERT INTO MEMBER (student_id, club_id)
VALUES
    (1, 1),
    (1, 2);

-- Dummy data for BOARD table
INSERT INTO BOARD (student_id, club_id)
VALUES
    (1, 1);

-- Dummy data for STAFF table
INSERT INTO STAFF (profil_id, job_title)
VALUES
    (2, 'Administrator');

-- Dummy data for PROFESSOR table
INSERT INTO PROFESSOR (profil_id, office, phone)
VALUES
    (3, 101, 123456789);

-- Dummy data for COURSE table
INSERT INTO COURSE (course_code, school, name)
VALUES
    ('CS101', 'Computer Science', 'Introduction to Computer Science'),
    ('MATH101', 'Mathematics', 'Algebra');

-- Dummy data for CLASS table
INSERT INTO CLASS (professor_id, course_code)
VALUES
    (3, 'CS101'),
    (3, 'MATH101');

-- Dummy data for GUEST table
INSERT INTO GUEST (profil_id, phone)
VALUES
    (4, 987654321);

-- Dummy data for EVENT table
//INSERT INTO EVENT (profil_id, start_date_time, end_date_time, name, description, event_type)
//VALUES
//    (1, '2024-05-10 10:00:00', '2024-05-10 12:00:00', 'Computer Club Meeting', 'Regular meeting of the Computer Club', 'club'),
//    (3, '2024-05-15 13:00:00', '2024-05-15 15:00:00', 'CS101 Lecture', 'Introduction to Computer Science lecture', 'class');

INSERT INTO event(profil_id, start_date_time, end_date_time, name, description, event_type, room_number, building_number) 
VALUES 
(157755, '2024-05-20 10:00:00', '2024-05-20 12:00:00', 'event1', 'decsrption for event 1', 'club', '102', '8B');

-- Dummy data for CLUB_EVENT table
INSERT INTO CLUB_EVENT (event_id, club_id)
VALUES
    (1, 1);

-- Dummy data for CLASS_EVENT table
INSERT INTO CLASS_EVENT (event_id, course_code)
VALUES
    (2, 'CS101');

-- Dummy data for NOTIFICATION table
INSERT INTO NOTIFICATION (profil_id, event_id, message)
VALUES
    (1, 1, 'Reminder: Computer Club meeting tomorrow.');

-- Dummy data for BUILDING table
INSERT INTO BUILDING (building_number, floors)
VALUES
    ('B1', 3),
    ('B2', 4);

-- Dummy data for ROOM table
INSERT INTO ROOM (room_number, building_number, capacity)
VALUES
    (101, 'B1', 30),
    (102, 'B1', 25),
    (201, 'B2', 35),
    (202, 'B2', 40);

-- Dummy data for EQUIPMENT table
INSERT INTO EQUIPMENT (name)
VALUES
    ('Projector'),
    ('Whiteboard'),
    ('Microphone');

-- Dummy data for EQUIPED table
INSERT INTO EQUIPED (equipment_id, room_number, building_number, quantity)
VALUES
    (1, 101, 'B1', 1),
    (2, 101, 'B1', 2),
    (3, 202, 'B2', 1);

-- Dummy data for BOOK table
INSERT INTO BOOK (event_id, room_number, building_number)
VALUES
    (1, 101, 'B1');

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

CREATE OR REPLACE FUNCTION overlapping_events()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM EVENT 
        WHERE NEW.start_date_time < end_date_time
        AND NEW.end_date_time > start_date_time
    ) AND EXISTS (
        SELECT 1
        FROM BOOK 
        WHERE room_number = NEW.room_number 
        AND building_number = NEW.building_number
    ) THEN
        RAISE EXCEPTION 'Time conflict.';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER check_overlapping_events
BEFORE INSERT OR UPDATE ON BOOK
FOR EACH ROW
EXECUTE FUNCTION overlapping_events();
