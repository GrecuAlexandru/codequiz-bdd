SET NOCOUNT ON;
GO

-- Seed Companies
INSERT INTO Companies (Name, Description) VALUES 
('Google', 'Search and AI giant'),
('Microsoft', 'Software and Cloud'),
('Amazon', 'E-commerce and Cloud');
GO

-- Seed Topics
INSERT INTO Topics (Name, Description) VALUES 
('Systems Programming', 'Low-level details, OS, Concurrency'),
('Software Architecture', 'Design Patterns, System Design, Scalability'),
('Database Design', 'Normalization, Indexing, SQL Optimization');
GO

-- Seed Quizzes FIRST (so we have IDs to reference)
INSERT INTO Quizzes (Title, Description) VALUES
('OS Fundamentals', 'Test your knowledge on Operating Systems.'),
('System Design & Databases', 'Concepts for backend engineering interviews.'),
('Full Stack Mix', 'A mix of various topics.');
GO

-- Seed Questions (Now with QuizID)
-- Quiz 1: OS Fundamentals (ID 1)
INSERT INTO Questions (QuizID, Text, Difficulty, CompanyID, TopicID) VALUES 
(1, 'What is the difference between a Process and a Thread?', 'Easy', 2, 1),
(1, 'Explain the concept of Virtual Memory.', 'Medium', 1, 1),
(1, 'What is a Deadlock?', 'Easy', 3, 1);
GO

-- Quiz 2: System Design & Databases (ID 2)
INSERT INTO Questions (QuizID, Text, Difficulty, CompanyID, TopicID) VALUES
(2, 'What is the Singleton Pattern?', 'Easy', 2, 2),
(2, 'Explain Microservices vs Monolith.', 'Medium', 3, 2),
(2, 'What is the 3rd Normal Form (3NF)?', 'Medium', 2, 3),
(2, 'What is a Clustered Index?', 'Medium', 2, 3);
GO

-- Quiz 3: Full Stack Mix (ID 3)
INSERT INTO Questions (QuizID, Text, Difficulty, CompanyID, TopicID) VALUES
(3, 'What is the difference between a Process and a Thread?', 'Easy', 2, 1),
(3, 'Explain Microservices vs Monolith.', 'Medium', 3, 2),
(3, 'What is a Clustered Index?', 'Medium', 2, 3);
GO

-- Seed Answers
-- Q1: Process vs Thread (appears in Quiz 1 and Quiz 3, so we'll have duplicates)
INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES
(1, 'Threads share the same memory space, processes do not.', 1),
(1, 'Processes share the same memory space, threads do not.', 0),
(1, 'There is no difference.', 0);
GO

-- Q2: Virtual Memory
INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES
(2, 'A technique that maps memory addresses used by a program into physical addresses in computer memory.', 1),
(2, 'RAM memory that is downloaded from the internet.', 0),
(2, 'A type of GPU memory.', 0);
GO

-- Q3: Deadlock
INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES
(3, 'A situation where two or more processes are unable to proceed because each is waiting for the other to release a resource.', 1),
(3, 'When a computer runs out of battery.', 0),
(3, 'A security mechanism in SQL Server.', 0);
GO

-- Q4: Singleton
INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES
(4, 'A pattern that restricts the instantiation of a class to one "single" instance.', 1),
(4, 'A game mode in Call of Duty.', 0);
GO

-- Q5: Microservices (appears in Quiz 2 and Quiz 3)
INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES
(5, 'An architectural style that structures an application as a collection of services.', 1),
(5, 'A small computer.', 0);
GO

-- Q6: 3NF
INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES
(6, 'A database schema design where non-primary key attributes depend only on the primary key.', 1),
(6, 'A backup strategy.', 0),
(6, 'A type of JOIN operation.', 0);
GO

-- Q7: Clustered Index (appears in Quiz 2 and Quiz 3)
INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES
(7, 'An index that determines the physical order of data in a table.', 1),
(7, 'A separate file that points to data.', 0),
(7, 'An index used only for clusters.', 0);
GO

-- Duplicates for Quiz 3 (Q8, Q9, Q10 are duplicates of Q1, Q5, Q7)
INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES
(8, 'Threads share the same memory space, processes do not.', 1),
(8, 'Processes share the same memory space, threads do not.', 0),
(8, 'There is no difference.', 0);
GO

INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES
(9, 'An architectural style that structures an application as a collection of services.', 1),
(9, 'A small computer.', 0);
GO

INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES
(10, 'An index that determines the physical order of data in a table.', 1),
(10, 'A separate file that points to data.', 0),
(10, 'An index used only for clusters.', 0);
GO
