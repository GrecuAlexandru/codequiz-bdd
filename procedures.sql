-- 1. RegisterUser: Registers a new user
IF OBJECT_ID('RegisterUser', 'P') IS NOT NULL DROP PROCEDURE RegisterUser;
GO

CREATE PROCEDURE RegisterUser
    @Username NVARCHAR(50),
    @PasswordHash NVARCHAR(255),
    @Email NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (SELECT 1 FROM Users WHERE Username = @Username OR Email = @Email)
    BEGIN
        SELECT -1 AS Result, 'Username or Email already exists' AS Message;
        RETURN;
    END

    INSERT INTO Users (Username, PasswordHash, Email)
    VALUES (@Username, @PasswordHash, @Email);

    SELECT 1 AS Result, 'User registered successfully' AS Message, SCOPE_IDENTITY() AS UserID;
END
GO

-- 2. LoginUser: Authenticates a user
IF OBJECT_ID('LoginUser', 'P') IS NOT NULL DROP PROCEDURE LoginUser;
GO

CREATE PROCEDURE LoginUser
    @Username NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ID, Username, PasswordHash, Role, Email
    FROM Users 
    WHERE Username = @Username;
END
GO


-- 3. GetQuizzes: Retrieves all available quizzes
IF OBJECT_ID('GetQuizzes', 'P') IS NOT NULL DROP PROCEDURE GetQuizzes;
GO

CREATE PROCEDURE GetQuizzes
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        q.ID, 
        q.Title, 
        q.Description, 
        (SELECT COUNT(*) FROM Questions WHERE QuizID = q.ID) as QuestionCount
    FROM Quizzes q;
END
GO

-- 4. GetQuestionsByQuiz: Retrieves questions for a specific quiz
IF OBJECT_ID('GetQuestionsByQuiz', 'P') IS NOT NULL DROP PROCEDURE GetQuestionsByQuiz;
GO

CREATE PROCEDURE GetQuestionsByQuiz
    @QuizID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ID, Text, Difficulty
    FROM Questions
    WHERE QuizID = @QuizID
    ORDER BY ID;
END
GO

-- 5. GetAnswersByQuestion: Retrieves answers for a specific question
IF OBJECT_ID('GetAnswersByQuestion', 'P') IS NOT NULL DROP PROCEDURE GetAnswersByQuestion;
GO

CREATE PROCEDURE GetAnswersByQuestion
    @QuestionID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ID, Text
    FROM Answers
    WHERE QuestionID = @QuestionID;
END
GO

-- 6. RecordAttempt: Records a user's answer to a question
IF OBJECT_ID('RecordAttempt', 'P') IS NOT NULL DROP PROCEDURE RecordAttempt;
GO

CREATE PROCEDURE RecordAttempt
    @AttemptID INT,
    @QuestionID INT,
    @AnswerID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @IsCorrect BIT;
    SELECT @IsCorrect = IsCorrect FROM Answers WHERE ID = @AnswerID;
    
    -- Check if already answered in this attempt
    IF EXISTS (SELECT 1 FROM UserProgress WHERE AttemptID = @AttemptID AND QuestionID = @QuestionID)
    BEGIN
        UPDATE UserProgress 
        SET SelectedAnswerID = @AnswerID, IsCorrect = @IsCorrect, AttemptDate = GETDATE()
        WHERE AttemptID = @AttemptID AND QuestionID = @QuestionID;
    END
    ELSE
    BEGIN
        INSERT INTO UserProgress (AttemptID, QuestionID, SelectedAnswerID, IsCorrect)
        VALUES (@AttemptID, @QuestionID, @AnswerID, @IsCorrect);
    END
    
    SELECT @IsCorrect AS IsCorrect;
END
GO

-- 7. StartQuizAttempt: Starts a new quiz attempt or resumes an existing one
IF OBJECT_ID('StartQuizAttempt', 'P') IS NOT NULL DROP PROCEDURE StartQuizAttempt;
GO

CREATE PROCEDURE StartQuizAttempt
    @UserID INT,
    @QuizID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check for an existing INCOMPLETE attempt
    DECLARE @ExistingAttemptID INT;
    SELECT TOP 1 @ExistingAttemptID = ID 
    FROM QuizAttempts 
    WHERE UserID = @UserID AND QuizID = @QuizID AND CompletedAt IS NULL
    ORDER BY StartedAt DESC;
    
    IF @ExistingAttemptID IS NOT NULL
    BEGIN
        -- Resume existing attempt
        SELECT @ExistingAttemptID AS AttemptID, 0 AS IsNew;
    END
    ELSE
    BEGIN
        -- Create new attempt
        INSERT INTO QuizAttempts (UserID, QuizID)
        VALUES (@UserID, @QuizID);
        
        SELECT SCOPE_IDENTITY() AS AttemptID, 1 AS IsNew;
    END
END
GO

-- 8. CompleteQuizAttempt: Finalizes a quiz attempt and calculates the score
IF OBJECT_ID('CompleteQuizAttempt', 'P') IS NOT NULL DROP PROCEDURE CompleteQuizAttempt;
GO

CREATE PROCEDURE CompleteQuizAttempt
    @AttemptID INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Calculate Score
    DECLARE @Score INT;
    SELECT @Score = COUNT(*) FROM UserProgress WHERE AttemptID = @AttemptID AND IsCorrect = 1;

    UPDATE QuizAttempts
    SET CompletedAt = GETDATE(), Score = @Score
    WHERE ID = @AttemptID;
    
    SELECT @Score AS Score;
END
GO

-- 9. GetQuizHistory: Retrieves completed quiz attempts for a user
IF OBJECT_ID('GetQuizHistory', 'P') IS NOT NULL DROP PROCEDURE GetQuizHistory;
GO

CREATE PROCEDURE GetQuizHistory
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        qa.ID, 
        q.Title AS QuizTitle, 
        qa.Score, 
        qa.CompletedAt,
        (SELECT COUNT(*) FROM Questions WHERE QuizID = q.ID) as TotalQuestions
    FROM QuizAttempts qa
    JOIN Quizzes q ON qa.QuizID = q.ID
    WHERE qa.UserID = @UserID AND qa.CompletedAt IS NOT NULL
    ORDER BY qa.CompletedAt DESC;
END
GO

-- 10. GetPendingQuizzes: Retrieves incomplete quiz attempts for a user
IF OBJECT_ID('GetPendingQuizzes', 'P') IS NOT NULL DROP PROCEDURE GetPendingQuizzes;
GO

CREATE PROCEDURE GetPendingQuizzes
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        qa.ID, 
        q.Title AS QuizTitle,
        q.ID AS QuizID,
        qa.StartedAt,
        (SELECT COUNT(*) FROM UserProgress WHERE AttemptID = qa.ID) as AnsweredCount,
        (SELECT COUNT(*) FROM Questions WHERE QuizID = q.ID) as TotalQuestions
    FROM QuizAttempts qa
    JOIN Quizzes q ON qa.QuizID = q.ID
    WHERE qa.UserID = @UserID AND qa.CompletedAt IS NULL
    ORDER BY qa.StartedAt DESC;
END
GO

-- 11. GetQuizAttemptDetails: Retrieves detailed results for a specific attempt
IF OBJECT_ID('GetQuizAttemptDetails', 'P') IS NOT NULL DROP PROCEDURE GetQuizAttemptDetails;
GO

CREATE PROCEDURE GetQuizAttemptDetails
    @AttemptID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        q.Text AS QuestionText,
        a.Text AS SelectedAnswer,
        a.IsCorrect,
        q.Difficulty
    FROM UserProgress up
    JOIN Questions q ON up.QuestionID = q.ID
    JOIN Answers a ON up.SelectedAnswerID = a.ID
    WHERE up.AttemptID = @AttemptID;
END
GO
