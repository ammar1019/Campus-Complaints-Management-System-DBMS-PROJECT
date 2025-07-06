CREATE DATABASE CampusComplaintsDB;
USE CampusComplaintsDB;

CREATE TABLE Category (
    CategoryID INT PRIMARY KEY AUTO_INCREMENT,
    CategoryName VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Student (
    StudentID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Phone VARCHAR(15),
    Department VARCHAR(50),
    Year INT,
    Hostel VARCHAR(50),
    PasswordHash VARCHAR(255) NOT NULL
);

CREATE TABLE AdminStaff (
    StaffID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Phone VARCHAR(15),
    Role VARCHAR(50),
    PasswordHash VARCHAR(255) NOT NULL
);

CREATE TABLE Complaint (
    ComplaintID INT PRIMARY KEY AUTO_INCREMENT,
    StudentID INT,
    CategoryID INT,
    Description TEXT NOT NULL,
    DateSubmitted DATETIME DEFAULT CURRENT_TIMESTAMP,
    Status ENUM('Submitted', 'In Progress', 'Resolved', 'Reopened') DEFAULT 'Submitted',
    Priority ENUM('Low', 'Medium', 'High') DEFAULT 'Low',
    IsAnonymous BOOLEAN DEFAULT FALSE,
    ResolutionRemarks TEXT,
    DateResolved DATETIME,
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID) ON DELETE SET NULL,
    FOREIGN KEY (CategoryID) REFERENCES Category(CategoryID) ON DELETE SET NULL
);

CREATE TABLE ComplaintAssignment (
    AssignmentID INT PRIMARY KEY AUTO_INCREMENT,
    ComplaintID INT,
    StaffID INT,
    DateAssigned DATETIME DEFAULT CURRENT_TIMESTAMP,
    DateAcknowledged DATETIME,
    FOREIGN KEY (ComplaintID) REFERENCES Complaint(ComplaintID) ON DELETE CASCADE,
    FOREIGN KEY (StaffID) REFERENCES AdminStaff(StaffID) ON DELETE CASCADE
);

CREATE TABLE ComplaintStatusHistory (
    StatusID INT PRIMARY KEY AUTO_INCREMENT,
    ComplaintID INT,
    OldStatus ENUM('Submitted', 'In Progress', 'Resolved', 'Reopened'),
    NewStatus ENUM('Submitted', 'In Progress', 'Resolved', 'Reopened'),
    ChangedOn DATETIME DEFAULT CURRENT_TIMESTAMP,
    ChangedBy INT,
    FOREIGN KEY (ComplaintID) REFERENCES Complaint(ComplaintID) ON DELETE CASCADE,
    FOREIGN KEY (ChangedBy) REFERENCES AdminStaff(StaffID) ON DELETE SET NULL
);

CREATE TABLE Feedback (
    FeedbackID INT PRIMARY KEY AUTO_INCREMENT,
    ComplaintID INT,
    StudentID INT,
    Rating INT CHECK (Rating BETWEEN 1 AND 5),
    Comments TEXT,
    DateSubmitted DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ComplaintID) REFERENCES Complaint(ComplaintID) ON DELETE CASCADE,
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID) ON DELETE CASCADE
);

DELIMITER //
CREATE TRIGGER trg_log_status_change
BEFORE UPDATE ON Complaint
FOR EACH ROW
BEGIN
    IF OLD.Status <> NEW.Status THEN
        INSERT INTO ComplaintStatusHistory (ComplaintID, OldStatus, NewStatus, ChangedOn, ChangedBy)
        VALUES (OLD.ComplaintID, OLD.Status, NEW.Status, NOW(), NULL);
    END IF;
END;
//
DELIMITER ;

INSERT INTO Category (CategoryName) VALUES
('Hostel'),
('Academic'),
('Maintenance'),
('Safety'),
('Harassment');

INSERT INTO Student (Name, Email, Phone, Department, Year, Hostel, PasswordHash) VALUES
('Anjali Sharma', 'anjali@college.edu', '9876543210', 'CSE', 2, 'Hostel A', 'hashedpass1'),
('Rahul Verma', 'rahul@college.edu', '9876543211', 'ECE', 3, 'Hostel B', 'hashedpass2');

INSERT INTO AdminStaff (Name, Email, Phone, Role, PasswordHash) VALUES
('Maintenance Staff', 'maint@college.edu', '9876543212', 'Maintenance', 'hashedpass3'),
('Warden', 'warden@college.edu', '9876543213', 'Warden', 'hashedpass4');

INSERT INTO Complaint (StudentID, CategoryID, Description, Priority, IsAnonymous)
VALUES (1, 3, 'Light not working in hostel room.', 'Medium', FALSE);

INSERT INTO ComplaintAssignment (ComplaintID, StaffID) VALUES (1, 1);

INSERT INTO Feedback (ComplaintID, StudentID, Rating, Comments)
VALUES (1, 1, 4, 'Resolved quickly, thank you.');

UPDATE Complaint SET Status = 'In Progress' WHERE ComplaintID = 1;
UPDATE Complaint SET Status = 'Resolved', DateResolved = NOW(), ResolutionRemarks = 'Replaced the light.' WHERE ComplaintID = 1;

SELECT c.ComplaintID, s.Name AS StudentName, cat.CategoryName, c.Description, c.Status, c.Priority, c.DateSubmitted
FROM Complaint c
LEFT JOIN Student s ON c.StudentID = s.StudentID
LEFT JOIN Category cat ON c.CategoryID = cat.CategoryID;

SELECT * FROM Complaint WHERE Status <> 'Resolved';

SELECT * FROM ComplaintStatusHistory WHERE ComplaintID = 1;

SELECT ca.AssignmentID, c.Description, c.Status, ca.DateAssigned
FROM ComplaintAssignment ca
JOIN Complaint c ON ca.ComplaintID = c.ComplaintID
WHERE ca.StaffID = 1;

SELECT f.FeedbackID, s.Name, f.Rating, f.Comments, f.DateSubmitted
FROM Feedback f
JOIN Student s ON f.StudentID = s.StudentID;
