SET NOCOUNT ON;
GO

-- 1. SEED COMPANIES

PRINT 'Seeding Companies...';

IF NOT EXISTS (SELECT 1 FROM Companies WHERE Name = 'Google')
    INSERT INTO Companies (Name, Description) VALUES ('Google', 'Search and AI giant');
IF NOT EXISTS (SELECT 1 FROM Companies WHERE Name = 'Microsoft')
    INSERT INTO Companies (Name, Description) VALUES ('Microsoft', 'Software and Cloud');
IF NOT EXISTS (SELECT 1 FROM Companies WHERE Name = 'Amazon')
    INSERT INTO Companies (Name, Description) VALUES ('Amazon', 'E-commerce and Cloud');
IF NOT EXISTS (SELECT 1 FROM Companies WHERE Name = 'Meta')
    INSERT INTO Companies (Name, Description) VALUES ('Meta', 'Social Media and VR');
IF NOT EXISTS (SELECT 1 FROM Companies WHERE Name = 'Apple')
    INSERT INTO Companies (Name, Description) VALUES ('Apple', 'Hardware and Software');
GO


-- 2. SEED TOPICS

PRINT 'Seeding Topics...';

IF NOT EXISTS (SELECT 1 FROM Topics WHERE Name = 'Systems Programming')
    INSERT INTO Topics (Name, Description) VALUES ('Systems Programming', 'Low-level details, OS, Concurrency');
IF NOT EXISTS (SELECT 1 FROM Topics WHERE Name = 'Software Architecture')
    INSERT INTO Topics (Name, Description) VALUES ('Software Architecture', 'Design Patterns, System Design, Scalability');
IF NOT EXISTS (SELECT 1 FROM Topics WHERE Name = 'Database Design')
    INSERT INTO Topics (Name, Description) VALUES ('Database Design', 'Normalization, Indexing, SQL Optimization');
IF NOT EXISTS (SELECT 1 FROM Topics WHERE Name = 'Web Development')
    INSERT INTO Topics (Name, Description) VALUES ('Web Development', 'Frontend, Backend, APIs');
IF NOT EXISTS (SELECT 1 FROM Topics WHERE Name = 'Algorithms')
    INSERT INTO Topics (Name, Description) VALUES ('Algorithms', 'Data Structures, Complexity, Problem Solving');
GO


-- 3. SEED USERS (1 Admin + 10 Regular Users)
-- Password for all users: password123
-- Password hash generated with werkzeug.security.generate_password_hash

PRINT 'Seeding Users...';

DECLARE @PasswordHash NVARCHAR(255) = 'scrypt:32768:8:1$DWFICo1VKdi1teB5$217088a6fd45f7e100ad5001c2d1d51820980aafdea84fd4de0678db0349a2eeb41f0c99062cf5241067c7d04fc104d03d2';
DECLARE @AdminHash NVARCHAR(255) = 'scrypt:32768:8:1$xlyf7fxHRJOnxt0Y$685eeecb2f705642685dbeb7a8ba0600049b5e8f8eeb27e6a0898ab18a7186ae3fbb1078e0cf49c2b5b0df288c0b5e5ea372a02bdf9636c000049fabe3daa292';

-- Admin user (admin/admin123)
IF NOT EXISTS (SELECT 1 FROM Users WHERE Username = 'admin')
    INSERT INTO Users (Username, PasswordHash, Email, Role) VALUES ('admin', @AdminHash, 'admin@codequiz.com', 'Admin');

-- Regular users (user_X/password123)
IF NOT EXISTS (SELECT 1 FROM Users WHERE Username = 'user_1')
    INSERT INTO Users (Username, PasswordHash, Email, Role) VALUES ('user_1', @PasswordHash, 'user1@example.com', 'User');
IF NOT EXISTS (SELECT 1 FROM Users WHERE Username = 'user_2')
    INSERT INTO Users (Username, PasswordHash, Email, Role) VALUES ('user_2', @PasswordHash, 'user2@example.com', 'User');
IF NOT EXISTS (SELECT 1 FROM Users WHERE Username = 'user_3')
    INSERT INTO Users (Username, PasswordHash, Email, Role) VALUES ('user_3', @PasswordHash, 'user3@example.com', 'User');
IF NOT EXISTS (SELECT 1 FROM Users WHERE Username = 'user_4')
    INSERT INTO Users (Username, PasswordHash, Email, Role) VALUES ('user_4', @PasswordHash, 'user4@example.com', 'User');
IF NOT EXISTS (SELECT 1 FROM Users WHERE Username = 'user_5')
    INSERT INTO Users (Username, PasswordHash, Email, Role) VALUES ('user_5', @PasswordHash, 'user5@example.com', 'User');
IF NOT EXISTS (SELECT 1 FROM Users WHERE Username = 'user_6')
    INSERT INTO Users (Username, PasswordHash, Email, Role) VALUES ('user_6', @PasswordHash, 'user6@example.com', 'User');
IF NOT EXISTS (SELECT 1 FROM Users WHERE Username = 'user_7')
    INSERT INTO Users (Username, PasswordHash, Email, Role) VALUES ('user_7', @PasswordHash, 'user7@example.com', 'User');
IF NOT EXISTS (SELECT 1 FROM Users WHERE Username = 'user_8')
    INSERT INTO Users (Username, PasswordHash, Email, Role) VALUES ('user_8', @PasswordHash, 'user8@example.com', 'User');
IF NOT EXISTS (SELECT 1 FROM Users WHERE Username = 'user_9')
    INSERT INTO Users (Username, PasswordHash, Email, Role) VALUES ('user_9', @PasswordHash, 'user9@example.com', 'User');
IF NOT EXISTS (SELECT 1 FROM Users WHERE Username = 'user_10')
    INSERT INTO Users (Username, PasswordHash, Email, Role) VALUES ('user_10', @PasswordHash, 'user10@example.com', 'User');
GO


-- 4. SEED QUIZZES

PRINT 'Seeding Quizzes...';

IF NOT EXISTS (SELECT 1 FROM Quizzes WHERE Title = 'OS Fundamentals')
    INSERT INTO Quizzes (Title, Description) VALUES ('OS Fundamentals', 'Test your knowledge on Operating Systems.');
IF NOT EXISTS (SELECT 1 FROM Quizzes WHERE Title = 'System Design & Databases')
    INSERT INTO Quizzes (Title, Description) VALUES ('System Design & Databases', 'Concepts for backend engineering interviews.');
IF NOT EXISTS (SELECT 1 FROM Quizzes WHERE Title = 'Full Stack Mix')
    INSERT INTO Quizzes (Title, Description) VALUES ('Full Stack Mix', 'A mix of various topics.');
IF NOT EXISTS (SELECT 1 FROM Quizzes WHERE Title = 'Algorithms Challenge')
    INSERT INTO Quizzes (Title, Description) VALUES ('Algorithms Challenge', 'Can you solve these algorithmic puzzles?');
IF NOT EXISTS (SELECT 1 FROM Quizzes WHERE Title = 'Web Dev Essentials')
    INSERT INTO Quizzes (Title, Description) VALUES ('Web Dev Essentials', 'HTML, CSS, JavaScript and more.');
GO


-- 5. SEED QUESTIONS AND ANSWERS

PRINT 'Seeding Questions and Answers...';

-- Get IDs for reference
DECLARE @Quiz1 INT = (SELECT ID FROM Quizzes WHERE Title = 'OS Fundamentals');
DECLARE @Quiz2 INT = (SELECT ID FROM Quizzes WHERE Title = 'System Design & Databases');
DECLARE @Quiz3 INT = (SELECT ID FROM Quizzes WHERE Title = 'Full Stack Mix');
DECLARE @Quiz4 INT = (SELECT ID FROM Quizzes WHERE Title = 'Algorithms Challenge');
DECLARE @Quiz5 INT = (SELECT ID FROM Quizzes WHERE Title = 'Web Dev Essentials');

DECLARE @CompGoogle INT = (SELECT ID FROM Companies WHERE Name = 'Google');
DECLARE @CompMicrosoft INT = (SELECT ID FROM Companies WHERE Name = 'Microsoft');
DECLARE @CompAmazon INT = (SELECT ID FROM Companies WHERE Name = 'Amazon');
DECLARE @CompMeta INT = (SELECT ID FROM Companies WHERE Name = 'Meta');
DECLARE @CompApple INT = (SELECT ID FROM Companies WHERE Name = 'Apple');

DECLARE @TopicSys INT = (SELECT ID FROM Topics WHERE Name = 'Systems Programming');
DECLARE @TopicArch INT = (SELECT ID FROM Topics WHERE Name = 'Software Architecture');
DECLARE @TopicDB INT = (SELECT ID FROM Topics WHERE Name = 'Database Design');
DECLARE @TopicWeb INT = (SELECT ID FROM Topics WHERE Name = 'Web Development');
DECLARE @TopicAlgo INT = (SELECT ID FROM Topics WHERE Name = 'Algorithms');

DECLARE @QID INT;

-- QUIZ 1: OS Fundamentals
-- Q1
IF NOT EXISTS (SELECT 1 FROM Questions WHERE Text = 'What is the difference between a Process and a Thread?')
BEGIN
    INSERT INTO Questions (QuizID, Text, Difficulty, CompanyID, TopicID) VALUES (@Quiz1, 'What is the difference between a Process and a Thread?', 'Easy', @CompMicrosoft, @TopicSys);
    SET @QID = SCOPE_IDENTITY();
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'Threads share the same memory space, processes do not.', 1);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'Processes share the same memory space, threads do not.', 0);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'There is no difference.', 0);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'Threads are faster than processes.', 0);
END

-- Q2
IF NOT EXISTS (SELECT 1 FROM Questions WHERE Text = 'Explain the concept of Virtual Memory.')
BEGIN
    INSERT INTO Questions (QuizID, Text, Difficulty, CompanyID, TopicID) VALUES (@Quiz1, 'Explain the concept of Virtual Memory.', 'Medium', @CompGoogle, @TopicSys);
    SET @QID = SCOPE_IDENTITY();
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'A technique that maps memory addresses used by a program into physical addresses.', 1);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'RAM memory that is downloaded from the internet.', 0);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'A type of GPU memory.', 0);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'Memory used only by virtual machines.', 0);
END

-- Q3
IF NOT EXISTS (SELECT 1 FROM Questions WHERE Text = 'What is a Deadlock?')
BEGIN
    INSERT INTO Questions (QuizID, Text, Difficulty, CompanyID, TopicID) VALUES (@Quiz1, 'What is a Deadlock?', 'Easy', @CompAmazon, @TopicSys);
    SET @QID = SCOPE_IDENTITY();
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'A situation where two or more processes are unable to proceed because each is waiting for the other.', 1);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'When a computer runs out of battery.', 0);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'A security mechanism in SQL Server.', 0);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'A type of mutex lock.', 0);
END

-- Q4
IF NOT EXISTS (SELECT 1 FROM Questions WHERE Text = 'What is a semaphore?')
BEGIN
    INSERT INTO Questions (QuizID, Text, Difficulty, CompanyID, TopicID) VALUES (@Quiz1, 'What is a semaphore?', 'Medium', @CompMicrosoft, @TopicSys);
    SET @QID = SCOPE_IDENTITY();
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'A synchronization primitive used to control access to a common resource.', 1);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'A type of traffic light for cars.', 0);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'A data structure for sorting.', 0);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'A network protocol.', 0);
END

-- QUIZ 2: System Design & Databases
-- Q5
IF NOT EXISTS (SELECT 1 FROM Questions WHERE Text = 'What is the Singleton Pattern?')
BEGIN
    INSERT INTO Questions (QuizID, Text, Difficulty, CompanyID, TopicID) VALUES (@Quiz2, 'What is the Singleton Pattern?', 'Easy', @CompMicrosoft, @TopicArch);
    SET @QID = SCOPE_IDENTITY();
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'A pattern that restricts the instantiation of a class to one single instance.', 1);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'A game mode in Call of Duty.', 0);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'A database index type.', 0);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'A networking topology.', 0);
END

-- Q6
IF NOT EXISTS (SELECT 1 FROM Questions WHERE Text = 'Explain Microservices vs Monolith.')
BEGIN
    INSERT INTO Questions (QuizID, Text, Difficulty, CompanyID, TopicID) VALUES (@Quiz2, 'Explain Microservices vs Monolith.', 'Medium', @CompAmazon, @TopicArch);
    SET @QID = SCOPE_IDENTITY();
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'Microservices are an architectural style structuring an application as a collection of services.', 1);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'A small computer.', 0);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'They are the same thing.', 0);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'Monolith is always better.', 0);
END

-- Q7
IF NOT EXISTS (SELECT 1 FROM Questions WHERE Text = 'What is the 3rd Normal Form (3NF)?')
BEGIN
    INSERT INTO Questions (QuizID, Text, Difficulty, CompanyID, TopicID) VALUES (@Quiz2, 'What is the 3rd Normal Form (3NF)?', 'Medium', @CompMicrosoft, @TopicDB);
    SET @QID = SCOPE_IDENTITY();
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'A database schema design where non-primary key attributes depend only on the primary key.', 1);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'A backup strategy.', 0);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'A type of JOIN operation.', 0);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'A file format.', 0);
END

-- Q8
IF NOT EXISTS (SELECT 1 FROM Questions WHERE Text = 'What is a Clustered Index?')
BEGIN
    INSERT INTO Questions (QuizID, Text, Difficulty, CompanyID, TopicID) VALUES (@Quiz2, 'What is a Clustered Index?', 'Hard', @CompMicrosoft, @TopicDB);
    SET @QID = SCOPE_IDENTITY();
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'An index that determines the physical order of data in a table.', 1);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'A separate file that points to data.', 0);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'An index used only for clusters.', 0);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'A type of primary key.', 0);
END

-- Q9
IF NOT EXISTS (SELECT 1 FROM Questions WHERE Text = 'What is database sharding?')
BEGIN
    INSERT INTO Questions (QuizID, Text, Difficulty, CompanyID, TopicID) VALUES (@Quiz2, 'What is database sharding?', 'Hard', @CompAmazon, @TopicDB);
    SET @QID = SCOPE_IDENTITY();
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'Horizontal partitioning of data across multiple database instances.', 1);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'Breaking a database into pieces for deletion.', 0);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'A backup method.', 0);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'Compressing database files.', 0);
END

-- QUIZ 3: Full Stack Mix
-- Q10
IF NOT EXISTS (SELECT 1 FROM Questions WHERE Text = 'What does REST stand for?')
BEGIN
    INSERT INTO Questions (QuizID, Text, Difficulty, CompanyID, TopicID) VALUES (@Quiz3, 'What does REST stand for?', 'Easy', @CompGoogle, @TopicWeb);
    SET @QID = SCOPE_IDENTITY();
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'Representational State Transfer.', 1);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'Really Easy Server Technology.', 0);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'Remote Execution of Server Tasks.', 0);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'Reliable and Secure Transfer.', 0);
END

-- Q11
IF NOT EXISTS (SELECT 1 FROM Questions WHERE Text = 'What is the Big O notation of binary search?')
BEGIN
    INSERT INTO Questions (QuizID, Text, Difficulty, CompanyID, TopicID) VALUES (@Quiz3, 'What is the Big O notation of binary search?', 'Medium', @CompGoogle, @TopicAlgo);
    SET @QID = SCOPE_IDENTITY();
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'O(log n)', 1);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'O(n)', 0);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'O(n^2)', 0);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'O(1)', 0);
END

-- Q12
IF NOT EXISTS (SELECT 1 FROM Questions WHERE Text = 'What is a foreign key?')
BEGIN
    INSERT INTO Questions (QuizID, Text, Difficulty, CompanyID, TopicID) VALUES (@Quiz3, 'What is a foreign key?', 'Easy', @CompMicrosoft, @TopicDB);
    SET @QID = SCOPE_IDENTITY();
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'A field in one table that uniquely identifies a row of another table.', 1);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'A key used in foreign countries.', 0);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'An encryption key.', 0);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'A primary key in disguise.', 0);
END

-- QUIZ 4: Algorithms Challenge
-- Q13
IF NOT EXISTS (SELECT 1 FROM Questions WHERE Text = 'What is the time complexity of QuickSort (average case)?')
BEGIN
    INSERT INTO Questions (QuizID, Text, Difficulty, CompanyID, TopicID) VALUES (@Quiz4, 'What is the time complexity of QuickSort (average case)?', 'Medium', @CompGoogle, @TopicAlgo);
    SET @QID = SCOPE_IDENTITY();
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'O(n log n)', 1);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'O(n^2)', 0);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'O(n)', 0);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'O(log n)', 0);
END

-- Q14
IF NOT EXISTS (SELECT 1 FROM Questions WHERE Text = 'What data structure uses LIFO?')
BEGIN
    INSERT INTO Questions (QuizID, Text, Difficulty, CompanyID, TopicID) VALUES (@Quiz4, 'What data structure uses LIFO?', 'Easy', @CompMicrosoft, @TopicAlgo);
    SET @QID = SCOPE_IDENTITY();
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'Stack', 1);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'Queue', 0);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'Heap', 0);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'Tree', 0);
END

-- Q15
IF NOT EXISTS (SELECT 1 FROM Questions WHERE Text = 'What is Dynamic Programming?')
BEGIN
    INSERT INTO Questions (QuizID, Text, Difficulty, CompanyID, TopicID) VALUES (@Quiz4, 'What is Dynamic Programming?', 'Hard', @CompGoogle, @TopicAlgo);
    SET @QID = SCOPE_IDENTITY();
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'A method for solving complex problems by breaking them down into simpler subproblems.', 1);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'Programming that changes during runtime.', 0);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'A type of scripting language.', 0);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'Object-oriented programming.', 0);
END

-- Q16
IF NOT EXISTS (SELECT 1 FROM Questions WHERE Text = 'What is the space complexity of merge sort?')
BEGIN
    INSERT INTO Questions (QuizID, Text, Difficulty, CompanyID, TopicID) VALUES (@Quiz4, 'What is the space complexity of merge sort?', 'Hard', @CompAmazon, @TopicAlgo);
    SET @QID = SCOPE_IDENTITY();
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'O(n)', 1);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'O(1)', 0);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'O(log n)', 0);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'O(n^2)', 0);
END

-- QUIZ 5: Web Dev Essentials
-- Q17
IF NOT EXISTS (SELECT 1 FROM Questions WHERE Text = 'What does HTML stand for?')
BEGIN
    INSERT INTO Questions (QuizID, Text, Difficulty, CompanyID, TopicID) VALUES (@Quiz5, 'What does HTML stand for?', 'Easy', @CompMeta, @TopicWeb);
    SET @QID = SCOPE_IDENTITY();
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'HyperText Markup Language', 1);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'High Tech Modern Language', 0);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'Home Tool Markup Language', 0);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'Hyper Transfer Markup Language', 0);
END

-- Q18
IF NOT EXISTS (SELECT 1 FROM Questions WHERE Text = 'What is the CSS box model?')
BEGIN
    INSERT INTO Questions (QuizID, Text, Difficulty, CompanyID, TopicID) VALUES (@Quiz5, 'What is the CSS box model?', 'Medium', @CompMeta, @TopicWeb);
    SET @QID = SCOPE_IDENTITY();
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'A model describing content, padding, border, and margin of an element.', 1);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'A 3D rendering technique.', 0);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'A JavaScript framework.', 0);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'A database schema.', 0);
END

-- Q19
IF NOT EXISTS (SELECT 1 FROM Questions WHERE Text = 'What is the difference between == and === in JavaScript?')
BEGIN
    INSERT INTO Questions (QuizID, Text, Difficulty, CompanyID, TopicID) VALUES (@Quiz5, 'What is the difference between == and === in JavaScript?', 'Medium', @CompApple, @TopicWeb);
    SET @QID = SCOPE_IDENTITY();
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, '=== checks both value and type, == only checks value with type coercion.', 1);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'They are exactly the same.', 0);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, '=== is deprecated.', 0);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, '== is for strings, === is for numbers.', 0);
END

-- Q20
IF NOT EXISTS (SELECT 1 FROM Questions WHERE Text = 'What is CORS?')
BEGIN
    INSERT INTO Questions (QuizID, Text, Difficulty, CompanyID, TopicID) VALUES (@Quiz5, 'What is CORS?', 'Hard', @CompGoogle, @TopicWeb);
    SET @QID = SCOPE_IDENTITY();
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'Cross-Origin Resource Sharing, a security feature implemented by browsers.', 1);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'Core Object Resource System.', 0);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'A JavaScript library.', 0);
    INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES (@QID, 'A CSS framework.', 0);
END
GO


-- 6. SEED QUIZ ATTEMPTS AND USER PROGRESS
-- Simulates users taking quizzes

PRINT 'Seeding Quiz Attempts and User Progress...';

-- Get User IDs
DECLARE @User1 INT = (SELECT ID FROM Users WHERE Username = 'user_1');
DECLARE @User2 INT = (SELECT ID FROM Users WHERE Username = 'user_2');
DECLARE @User3 INT = (SELECT ID FROM Users WHERE Username = 'user_3');
DECLARE @User4 INT = (SELECT ID FROM Users WHERE Username = 'user_4');
DECLARE @User5 INT = (SELECT ID FROM Users WHERE Username = 'user_5');
DECLARE @User6 INT = (SELECT ID FROM Users WHERE Username = 'user_6');
DECLARE @User7 INT = (SELECT ID FROM Users WHERE Username = 'user_7');
DECLARE @User8 INT = (SELECT ID FROM Users WHERE Username = 'user_8');

-- Redeclare Quiz IDs
DECLARE @QuizOS INT = (SELECT ID FROM Quizzes WHERE Title = 'OS Fundamentals');
DECLARE @QuizSD INT = (SELECT ID FROM Quizzes WHERE Title = 'System Design & Databases');
DECLARE @QuizFS INT = (SELECT ID FROM Quizzes WHERE Title = 'Full Stack Mix');
DECLARE @QuizAlg INT = (SELECT ID FROM Quizzes WHERE Title = 'Algorithms Challenge');
DECLARE @QuizWeb INT = (SELECT ID FROM Quizzes WHERE Title = 'Web Dev Essentials');

DECLARE @AttemptID INT;
DECLARE @QuestionID INT;
DECLARE @CorrectAnswerID INT;
DECLARE @WrongAnswerID INT;

-- Helper: Get correct answer for a question
-- We'll manually simulate some attempts

-- USER 1: Takes OS Fundamentals (gets 3/4 correct)
IF NOT EXISTS (SELECT 1 FROM QuizAttempts WHERE UserID = @User1 AND QuizID = @QuizOS AND CompletedAt IS NOT NULL)
BEGIN
    INSERT INTO QuizAttempts (UserID, QuizID, Score, CompletedAt) VALUES (@User1, @QuizOS, 3, DATEADD(day, -5, GETDATE()));
    SET @AttemptID = SCOPE_IDENTITY();

    -- Q1: Correct
    SET @QuestionID = (SELECT ID FROM Questions WHERE Text = 'What is the difference between a Process and a Thread?');
    SET @CorrectAnswerID = (SELECT TOP 1 ID FROM Answers WHERE QuestionID = @QuestionID AND IsCorrect = 1);
    INSERT INTO UserProgress (AttemptID, QuestionID, SelectedAnswerID, IsCorrect) VALUES (@AttemptID, @QuestionID, @CorrectAnswerID, 1);

    -- Q2: Correct
    SET @QuestionID = (SELECT ID FROM Questions WHERE Text = 'Explain the concept of Virtual Memory.');
    SET @CorrectAnswerID = (SELECT TOP 1 ID FROM Answers WHERE QuestionID = @QuestionID AND IsCorrect = 1);
    INSERT INTO UserProgress (AttemptID, QuestionID, SelectedAnswerID, IsCorrect) VALUES (@AttemptID, @QuestionID, @CorrectAnswerID, 1);

    -- Q3: Wrong
    SET @QuestionID = (SELECT ID FROM Questions WHERE Text = 'What is a Deadlock?');
    SET @WrongAnswerID = (SELECT TOP 1 ID FROM Answers WHERE QuestionID = @QuestionID AND IsCorrect = 0);
    INSERT INTO UserProgress (AttemptID, QuestionID, SelectedAnswerID, IsCorrect) VALUES (@AttemptID, @QuestionID, @WrongAnswerID, 0);

    -- Q4: Correct
    SET @QuestionID = (SELECT ID FROM Questions WHERE Text = 'What is a semaphore?');
    SET @CorrectAnswerID = (SELECT TOP 1 ID FROM Answers WHERE QuestionID = @QuestionID AND IsCorrect = 1);
    INSERT INTO UserProgress (AttemptID, QuestionID, SelectedAnswerID, IsCorrect) VALUES (@AttemptID, @QuestionID, @CorrectAnswerID, 1);
END

-- USER 2: Takes System Design (gets 4/5 correct)
IF NOT EXISTS (SELECT 1 FROM QuizAttempts WHERE UserID = @User2 AND QuizID = @QuizSD AND CompletedAt IS NOT NULL)
BEGIN
    INSERT INTO QuizAttempts (UserID, QuizID, Score, CompletedAt) VALUES (@User2, @QuizSD, 4, DATEADD(day, -4, GETDATE()));
    SET @AttemptID = SCOPE_IDENTITY();

    SET @QuestionID = (SELECT ID FROM Questions WHERE Text = 'What is the Singleton Pattern?');
    SET @CorrectAnswerID = (SELECT TOP 1 ID FROM Answers WHERE QuestionID = @QuestionID AND IsCorrect = 1);
    INSERT INTO UserProgress (AttemptID, QuestionID, SelectedAnswerID, IsCorrect) VALUES (@AttemptID, @QuestionID, @CorrectAnswerID, 1);

    SET @QuestionID = (SELECT ID FROM Questions WHERE Text = 'Explain Microservices vs Monolith.');
    SET @CorrectAnswerID = (SELECT TOP 1 ID FROM Answers WHERE QuestionID = @QuestionID AND IsCorrect = 1);
    INSERT INTO UserProgress (AttemptID, QuestionID, SelectedAnswerID, IsCorrect) VALUES (@AttemptID, @QuestionID, @CorrectAnswerID, 1);

    SET @QuestionID = (SELECT ID FROM Questions WHERE Text = 'What is the 3rd Normal Form (3NF)?');
    SET @CorrectAnswerID = (SELECT TOP 1 ID FROM Answers WHERE QuestionID = @QuestionID AND IsCorrect = 1);
    INSERT INTO UserProgress (AttemptID, QuestionID, SelectedAnswerID, IsCorrect) VALUES (@AttemptID, @QuestionID, @CorrectAnswerID, 1);

    SET @QuestionID = (SELECT ID FROM Questions WHERE Text = 'What is a Clustered Index?');
    SET @WrongAnswerID = (SELECT TOP 1 ID FROM Answers WHERE QuestionID = @QuestionID AND IsCorrect = 0);
    INSERT INTO UserProgress (AttemptID, QuestionID, SelectedAnswerID, IsCorrect) VALUES (@AttemptID, @QuestionID, @WrongAnswerID, 0);

    SET @QuestionID = (SELECT ID FROM Questions WHERE Text = 'What is database sharding?');
    SET @CorrectAnswerID = (SELECT TOP 1 ID FROM Answers WHERE QuestionID = @QuestionID AND IsCorrect = 1);
    INSERT INTO UserProgress (AttemptID, QuestionID, SelectedAnswerID, IsCorrect) VALUES (@AttemptID, @QuestionID, @CorrectAnswerID, 1);
END

-- USER 3: Takes Algorithms (gets 2/4 correct)
IF NOT EXISTS (SELECT 1 FROM QuizAttempts WHERE UserID = @User3 AND QuizID = @QuizAlg AND CompletedAt IS NOT NULL)
BEGIN
    INSERT INTO QuizAttempts (UserID, QuizID, Score, CompletedAt) VALUES (@User3, @QuizAlg, 2, DATEADD(day, -3, GETDATE()));
    SET @AttemptID = SCOPE_IDENTITY();

    SET @QuestionID = (SELECT ID FROM Questions WHERE Text = 'What is the time complexity of QuickSort (average case)?');
    SET @CorrectAnswerID = (SELECT TOP 1 ID FROM Answers WHERE QuestionID = @QuestionID AND IsCorrect = 1);
    INSERT INTO UserProgress (AttemptID, QuestionID, SelectedAnswerID, IsCorrect) VALUES (@AttemptID, @QuestionID, @CorrectAnswerID, 1);

    SET @QuestionID = (SELECT ID FROM Questions WHERE Text = 'What data structure uses LIFO?');
    SET @WrongAnswerID = (SELECT TOP 1 ID FROM Answers WHERE QuestionID = @QuestionID AND IsCorrect = 0);
    INSERT INTO UserProgress (AttemptID, QuestionID, SelectedAnswerID, IsCorrect) VALUES (@AttemptID, @QuestionID, @WrongAnswerID, 0);

    SET @QuestionID = (SELECT ID FROM Questions WHERE Text = 'What is Dynamic Programming?');
    SET @CorrectAnswerID = (SELECT TOP 1 ID FROM Answers WHERE QuestionID = @QuestionID AND IsCorrect = 1);
    INSERT INTO UserProgress (AttemptID, QuestionID, SelectedAnswerID, IsCorrect) VALUES (@AttemptID, @QuestionID, @CorrectAnswerID, 1);

    SET @QuestionID = (SELECT ID FROM Questions WHERE Text = 'What is the space complexity of merge sort?');
    SET @WrongAnswerID = (SELECT TOP 1 ID FROM Answers WHERE QuestionID = @QuestionID AND IsCorrect = 0);
    INSERT INTO UserProgress (AttemptID, QuestionID, SelectedAnswerID, IsCorrect) VALUES (@AttemptID, @QuestionID, @WrongAnswerID, 0);
END

-- USER 4: Takes Web Dev (gets 4/4 correct - perfect score)
IF NOT EXISTS (SELECT 1 FROM QuizAttempts WHERE UserID = @User4 AND QuizID = @QuizWeb AND CompletedAt IS NOT NULL)
BEGIN
    INSERT INTO QuizAttempts (UserID, QuizID, Score, CompletedAt) VALUES (@User4, @QuizWeb, 4, DATEADD(day, -2, GETDATE()));
    SET @AttemptID = SCOPE_IDENTITY();

    SET @QuestionID = (SELECT ID FROM Questions WHERE Text = 'What does HTML stand for?');
    SET @CorrectAnswerID = (SELECT TOP 1 ID FROM Answers WHERE QuestionID = @QuestionID AND IsCorrect = 1);
    INSERT INTO UserProgress (AttemptID, QuestionID, SelectedAnswerID, IsCorrect) VALUES (@AttemptID, @QuestionID, @CorrectAnswerID, 1);

    SET @QuestionID = (SELECT ID FROM Questions WHERE Text = 'What is the CSS box model?');
    SET @CorrectAnswerID = (SELECT TOP 1 ID FROM Answers WHERE QuestionID = @QuestionID AND IsCorrect = 1);
    INSERT INTO UserProgress (AttemptID, QuestionID, SelectedAnswerID, IsCorrect) VALUES (@AttemptID, @QuestionID, @CorrectAnswerID, 1);

    SET @QuestionID = (SELECT ID FROM Questions WHERE Text = 'What is the difference between == and === in JavaScript?');
    SET @CorrectAnswerID = (SELECT TOP 1 ID FROM Answers WHERE QuestionID = @QuestionID AND IsCorrect = 1);
    INSERT INTO UserProgress (AttemptID, QuestionID, SelectedAnswerID, IsCorrect) VALUES (@AttemptID, @QuestionID, @CorrectAnswerID, 1);

    SET @QuestionID = (SELECT ID FROM Questions WHERE Text = 'What is CORS?');
    SET @CorrectAnswerID = (SELECT TOP 1 ID FROM Answers WHERE QuestionID = @QuestionID AND IsCorrect = 1);
    INSERT INTO UserProgress (AttemptID, QuestionID, SelectedAnswerID, IsCorrect) VALUES (@AttemptID, @QuestionID, @CorrectAnswerID, 1);
END

-- USER 5: Takes Full Stack Mix (gets 2/3 correct)
IF NOT EXISTS (SELECT 1 FROM QuizAttempts WHERE UserID = @User5 AND QuizID = @QuizFS AND CompletedAt IS NOT NULL)
BEGIN
    INSERT INTO QuizAttempts (UserID, QuizID, Score, CompletedAt) VALUES (@User5, @QuizFS, 2, DATEADD(day, -1, GETDATE()));
    SET @AttemptID = SCOPE_IDENTITY();

    SET @QuestionID = (SELECT ID FROM Questions WHERE Text = 'What does REST stand for?');
    SET @CorrectAnswerID = (SELECT TOP 1 ID FROM Answers WHERE QuestionID = @QuestionID AND IsCorrect = 1);
    INSERT INTO UserProgress (AttemptID, QuestionID, SelectedAnswerID, IsCorrect) VALUES (@AttemptID, @QuestionID, @CorrectAnswerID, 1);

    SET @QuestionID = (SELECT ID FROM Questions WHERE Text = 'What is the Big O notation of binary search?');
    SET @WrongAnswerID = (SELECT TOP 1 ID FROM Answers WHERE QuestionID = @QuestionID AND IsCorrect = 0);
    INSERT INTO UserProgress (AttemptID, QuestionID, SelectedAnswerID, IsCorrect) VALUES (@AttemptID, @QuestionID, @WrongAnswerID, 0);

    SET @QuestionID = (SELECT ID FROM Questions WHERE Text = 'What is a foreign key?');
    SET @CorrectAnswerID = (SELECT TOP 1 ID FROM Answers WHERE QuestionID = @QuestionID AND IsCorrect = 1);
    INSERT INTO UserProgress (AttemptID, QuestionID, SelectedAnswerID, IsCorrect) VALUES (@AttemptID, @QuestionID, @CorrectAnswerID, 1);
END

-- USER 6: Takes OS Fundamentals (gets 2/4 correct)
IF NOT EXISTS (SELECT 1 FROM QuizAttempts WHERE UserID = @User6 AND QuizID = @QuizOS AND CompletedAt IS NOT NULL)
BEGIN
    INSERT INTO QuizAttempts (UserID, QuizID, Score, CompletedAt) VALUES (@User6, @QuizOS, 2, DATEADD(day, -6, GETDATE()));
    SET @AttemptID = SCOPE_IDENTITY();

    SET @QuestionID = (SELECT ID FROM Questions WHERE Text = 'What is the difference between a Process and a Thread?');
    SET @WrongAnswerID = (SELECT TOP 1 ID FROM Answers WHERE QuestionID = @QuestionID AND IsCorrect = 0);
    INSERT INTO UserProgress (AttemptID, QuestionID, SelectedAnswerID, IsCorrect) VALUES (@AttemptID, @QuestionID, @WrongAnswerID, 0);

    SET @QuestionID = (SELECT ID FROM Questions WHERE Text = 'Explain the concept of Virtual Memory.');
    SET @CorrectAnswerID = (SELECT TOP 1 ID FROM Answers WHERE QuestionID = @QuestionID AND IsCorrect = 1);
    INSERT INTO UserProgress (AttemptID, QuestionID, SelectedAnswerID, IsCorrect) VALUES (@AttemptID, @QuestionID, @CorrectAnswerID, 1);

    SET @QuestionID = (SELECT ID FROM Questions WHERE Text = 'What is a Deadlock?');
    SET @CorrectAnswerID = (SELECT TOP 1 ID FROM Answers WHERE QuestionID = @QuestionID AND IsCorrect = 1);
    INSERT INTO UserProgress (AttemptID, QuestionID, SelectedAnswerID, IsCorrect) VALUES (@AttemptID, @QuestionID, @CorrectAnswerID, 1);

    SET @QuestionID = (SELECT ID FROM Questions WHERE Text = 'What is a semaphore?');
    SET @WrongAnswerID = (SELECT TOP 1 ID FROM Answers WHERE QuestionID = @QuestionID AND IsCorrect = 0);
    INSERT INTO UserProgress (AttemptID, QuestionID, SelectedAnswerID, IsCorrect) VALUES (@AttemptID, @QuestionID, @WrongAnswerID, 0);
END

-- USER 7: Takes System Design (gets 3/5 correct)
IF NOT EXISTS (SELECT 1 FROM QuizAttempts WHERE UserID = @User7 AND QuizID = @QuizSD AND CompletedAt IS NOT NULL)
BEGIN
    INSERT INTO QuizAttempts (UserID, QuizID, Score, CompletedAt) VALUES (@User7, @QuizSD, 3, DATEADD(day, -7, GETDATE()));
    SET @AttemptID = SCOPE_IDENTITY();

    SET @QuestionID = (SELECT ID FROM Questions WHERE Text = 'What is the Singleton Pattern?');
    SET @CorrectAnswerID = (SELECT TOP 1 ID FROM Answers WHERE QuestionID = @QuestionID AND IsCorrect = 1);
    INSERT INTO UserProgress (AttemptID, QuestionID, SelectedAnswerID, IsCorrect) VALUES (@AttemptID, @QuestionID, @CorrectAnswerID, 1);

    SET @QuestionID = (SELECT ID FROM Questions WHERE Text = 'Explain Microservices vs Monolith.');
    SET @WrongAnswerID = (SELECT TOP 1 ID FROM Answers WHERE QuestionID = @QuestionID AND IsCorrect = 0);
    INSERT INTO UserProgress (AttemptID, QuestionID, SelectedAnswerID, IsCorrect) VALUES (@AttemptID, @QuestionID, @WrongAnswerID, 0);

    SET @QuestionID = (SELECT ID FROM Questions WHERE Text = 'What is the 3rd Normal Form (3NF)?');
    SET @CorrectAnswerID = (SELECT TOP 1 ID FROM Answers WHERE QuestionID = @QuestionID AND IsCorrect = 1);
    INSERT INTO UserProgress (AttemptID, QuestionID, SelectedAnswerID, IsCorrect) VALUES (@AttemptID, @QuestionID, @CorrectAnswerID, 1);

    SET @QuestionID = (SELECT ID FROM Questions WHERE Text = 'What is a Clustered Index?');
    SET @WrongAnswerID = (SELECT TOP 1 ID FROM Answers WHERE QuestionID = @QuestionID AND IsCorrect = 0);
    INSERT INTO UserProgress (AttemptID, QuestionID, SelectedAnswerID, IsCorrect) VALUES (@AttemptID, @QuestionID, @WrongAnswerID, 0);

    SET @QuestionID = (SELECT ID FROM Questions WHERE Text = 'What is database sharding?');
    SET @CorrectAnswerID = (SELECT TOP 1 ID FROM Answers WHERE QuestionID = @QuestionID AND IsCorrect = 1);
    INSERT INTO UserProgress (AttemptID, QuestionID, SelectedAnswerID, IsCorrect) VALUES (@AttemptID, @QuestionID, @CorrectAnswerID, 1);
END

-- USER 8: Takes Web Dev (gets 3/4 correct)
IF NOT EXISTS (SELECT 1 FROM QuizAttempts WHERE UserID = @User8 AND QuizID = @QuizWeb AND CompletedAt IS NOT NULL)
BEGIN
    INSERT INTO QuizAttempts (UserID, QuizID, Score, CompletedAt) VALUES (@User8, @QuizWeb, 3, DATEADD(day, -8, GETDATE()));
    SET @AttemptID = SCOPE_IDENTITY();

    SET @QuestionID = (SELECT ID FROM Questions WHERE Text = 'What does HTML stand for?');
    SET @CorrectAnswerID = (SELECT TOP 1 ID FROM Answers WHERE QuestionID = @QuestionID AND IsCorrect = 1);
    INSERT INTO UserProgress (AttemptID, QuestionID, SelectedAnswerID, IsCorrect) VALUES (@AttemptID, @QuestionID, @CorrectAnswerID, 1);

    SET @QuestionID = (SELECT ID FROM Questions WHERE Text = 'What is the CSS box model?');
    SET @WrongAnswerID = (SELECT TOP 1 ID FROM Answers WHERE QuestionID = @QuestionID AND IsCorrect = 0);
    INSERT INTO UserProgress (AttemptID, QuestionID, SelectedAnswerID, IsCorrect) VALUES (@AttemptID, @QuestionID, @WrongAnswerID, 0);

    SET @QuestionID = (SELECT ID FROM Questions WHERE Text = 'What is the difference between == and === in JavaScript?');
    SET @CorrectAnswerID = (SELECT TOP 1 ID FROM Answers WHERE QuestionID = @QuestionID AND IsCorrect = 1);
    INSERT INTO UserProgress (AttemptID, QuestionID, SelectedAnswerID, IsCorrect) VALUES (@AttemptID, @QuestionID, @CorrectAnswerID, 1);

    SET @QuestionID = (SELECT ID FROM Questions WHERE Text = 'What is CORS?');
    SET @CorrectAnswerID = (SELECT TOP 1 ID FROM Answers WHERE QuestionID = @QuestionID AND IsCorrect = 1);
    INSERT INTO UserProgress (AttemptID, QuestionID, SelectedAnswerID, IsCorrect) VALUES (@AttemptID, @QuestionID, @CorrectAnswerID, 1);
END
GO


-- 7. SEED REVIEWS

PRINT 'Seeding Reviews...';

DECLARE @ReviewUser1 INT = (SELECT ID FROM Users WHERE Username = 'user_1');
DECLARE @ReviewUser2 INT = (SELECT ID FROM Users WHERE Username = 'user_2');
DECLARE @ReviewUser3 INT = (SELECT ID FROM Users WHERE Username = 'user_3');
DECLARE @ReviewUser4 INT = (SELECT ID FROM Users WHERE Username = 'user_4');

DECLARE @ReviewQ1 INT = (SELECT ID FROM Questions WHERE Text = 'What is the difference between a Process and a Thread?');
DECLARE @ReviewQ2 INT = (SELECT ID FROM Questions WHERE Text = 'What is the Singleton Pattern?');
DECLARE @ReviewQ3 INT = (SELECT ID FROM Questions WHERE Text = 'What is Dynamic Programming?');
DECLARE @ReviewQ4 INT = (SELECT ID FROM Questions WHERE Text = 'What is CORS?');
DECLARE @ReviewQ5 INT = (SELECT ID FROM Questions WHERE Text = 'What is a Clustered Index?');

IF NOT EXISTS (SELECT 1 FROM Reviews WHERE UserID = @ReviewUser1 AND QuestionID = @ReviewQ1)
    INSERT INTO Reviews (UserID, QuestionID, Rating, Comment) VALUES (@ReviewUser1, @ReviewQ1, 5, 'Great question, very clear!');

IF NOT EXISTS (SELECT 1 FROM Reviews WHERE UserID = @ReviewUser1 AND QuestionID = @ReviewQ2)
    INSERT INTO Reviews (UserID, QuestionID, Rating, Comment) VALUES (@ReviewUser1, @ReviewQ2, 4, 'Good for interview prep.');

IF NOT EXISTS (SELECT 1 FROM Reviews WHERE UserID = @ReviewUser2 AND QuestionID = @ReviewQ3)
    INSERT INTO Reviews (UserID, QuestionID, Rating, Comment) VALUES (@ReviewUser2, @ReviewQ3, 5, 'This was tricky but fair.');

IF NOT EXISTS (SELECT 1 FROM Reviews WHERE UserID = @ReviewUser2 AND QuestionID = @ReviewQ4)
    INSERT INTO Reviews (UserID, QuestionID, Rating, Comment) VALUES (@ReviewUser2, @ReviewQ4, 3, 'Could use more context.');

IF NOT EXISTS (SELECT 1 FROM Reviews WHERE UserID = @ReviewUser3 AND QuestionID = @ReviewQ5)
    INSERT INTO Reviews (UserID, QuestionID, Rating, Comment) VALUES (@ReviewUser3, @ReviewQ5, 4, 'Well written question.');

IF NOT EXISTS (SELECT 1 FROM Reviews WHERE UserID = @ReviewUser4 AND QuestionID = @ReviewQ1)
    INSERT INTO Reviews (UserID, QuestionID, Rating, Comment) VALUES (@ReviewUser4, @ReviewQ1, 5, 'Perfect for beginners!');

IF NOT EXISTS (SELECT 1 FROM Reviews WHERE UserID = @ReviewUser4 AND QuestionID = @ReviewQ3)
    INSERT INTO Reviews (UserID, QuestionID, Rating, Comment) VALUES (@ReviewUser4, @ReviewQ3, 4, NULL);
GO


-- 8. SEED CONTRIBUTIONS

PRINT 'Seeding Contributions...';

DECLARE @ContribUser1 INT = (SELECT ID FROM Users WHERE Username = 'user_1');
DECLARE @ContribUser2 INT = (SELECT ID FROM Users WHERE Username = 'user_2');
DECLARE @ContribUser3 INT = (SELECT ID FROM Users WHERE Username = 'user_5');

DECLARE @ContribTopicArch INT = (SELECT ID FROM Topics WHERE Name = 'Software Architecture');
DECLARE @ContribTopicWeb INT = (SELECT ID FROM Topics WHERE Name = 'Web Development');
DECLARE @ContribTopicSys INT = (SELECT ID FROM Topics WHERE Name = 'Systems Programming');

IF NOT EXISTS (SELECT 1 FROM Contributions WHERE QuestionText = 'What is polymorphism in OOP?')
    INSERT INTO Contributions (UserID, QuestionText, CorrectAnswer, WrongAnswer1, WrongAnswer2, WrongAnswer3, TopicID, Status)
    VALUES (@ContribUser1, 'What is polymorphism in OOP?', 'The ability of different classes to be treated as instances of the same class through inheritance.', 'A type of data encryption.', 'A sorting algorithm.', 'A database normalization form.', @ContribTopicArch, 'Pending');

IF NOT EXISTS (SELECT 1 FROM Contributions WHERE QuestionText = 'What is a closure in JavaScript?')
    INSERT INTO Contributions (UserID, QuestionText, CorrectAnswer, WrongAnswer1, WrongAnswer2, WrongAnswer3, TopicID, Status)
    VALUES (@ContribUser2, 'What is a closure in JavaScript?', 'A function that has access to its outer function scope.', 'A way to close browser windows.', 'A type of loop.', 'An HTML element.', @ContribTopicWeb, 'Approved');

IF NOT EXISTS (SELECT 1 FROM Contributions WHERE QuestionText = 'What is TCP/IP?')
    INSERT INTO Contributions (UserID, QuestionText, CorrectAnswer, WrongAnswer1, WrongAnswer2, WrongAnswer3, TopicID, Status)
    VALUES (@ContribUser3, 'What is TCP/IP?', 'A suite of communication protocols used to interconnect network devices.', 'A programming language.', 'A database system.', 'A JavaScript framework.', @ContribTopicSys, 'Pending');

IF NOT EXISTS (SELECT 1 FROM Contributions WHERE QuestionText = 'What is the Observer pattern?')
    INSERT INTO Contributions (UserID, QuestionText, CorrectAnswer, WrongAnswer1, WrongAnswer2, WrongAnswer3, TopicID, Status)
    VALUES (@ContribUser1, 'What is the Observer pattern?', 'A design pattern where an object maintains a list of dependents and notifies them of state changes.', 'A security monitoring tool.', 'A type of database trigger.', 'A JavaScript event.', @ContribTopicArch, 'Rejected');
GO


-- COMPLETE

PRINT 'Seeding Complete!';
PRINT 'Users: admin/admin123, user_1 to user_10/password123';
PRINT 'Quizzes: 5 quizzes with 20 questions total';
PRINT 'Quiz Attempts: 8 completed attempts from various users';
PRINT 'Reviews: 7 reviews from users';
PRINT 'Contributions: 4 contributions (pending, approved, rejected)';
GO
