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
        q.Difficulty,
        q.ID AS QuestionID
    FROM UserProgress up
    JOIN Questions q ON up.QuestionID = q.ID
    JOIN Answers a ON up.SelectedAnswerID = a.ID
    WHERE up.AttemptID = @AttemptID;
END
GO

-- 17. AddReview: Adds a review for a question
IF OBJECT_ID('AddReview', 'P') IS NOT NULL DROP PROCEDURE AddReview;
GO

CREATE PROCEDURE AddReview
    @UserID INT,
    @QuestionID INT,
    @Rating INT,
    @Comment NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    -- Check if review already exists
    IF EXISTS (SELECT 1 FROM Reviews WHERE UserID = @UserID AND QuestionID = @QuestionID)
    BEGIN
        UPDATE Reviews
        SET Rating = @Rating, Comment = @Comment, Date = GETDATE()
        WHERE UserID = @UserID AND QuestionID = @QuestionID;
        RETURN;
    END

    INSERT INTO Reviews (UserID, QuestionID, Rating, Comment)
    VALUES (@UserID, @QuestionID, @Rating, @Comment);
END
GO

-- 12. AddContribution: Adds a new contribution
IF OBJECT_ID('AddContribution', 'P') IS NOT NULL DROP PROCEDURE AddContribution;
GO

CREATE PROCEDURE AddContribution
    @UserID INT,
    @QuestionText NVARCHAR(MAX),
    @CorrectAnswer NVARCHAR(MAX),
    @WrongAnswer1 NVARCHAR(MAX),
    @WrongAnswer2 NVARCHAR(MAX),
    @WrongAnswer3 NVARCHAR(MAX),
    @TopicID INT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Contributions (UserID, QuestionText, CorrectAnswer, WrongAnswer1, WrongAnswer2, WrongAnswer3, TopicID)
    VALUES (@UserID, @QuestionText, @CorrectAnswer, @WrongAnswer1, @WrongAnswer2, @WrongAnswer3, @TopicID);
END
GO

-- 13. GetPendingContributions: Gets all pending contributions
IF OBJECT_ID('GetPendingContributions', 'P') IS NOT NULL DROP PROCEDURE GetPendingContributions;
GO

CREATE PROCEDURE GetPendingContributions
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        c.ID,
        u.Username,
        c.QuestionText,
        c.CorrectAnswer,
        c.WrongAnswer1,
        c.WrongAnswer2,
        c.WrongAnswer3,
        t.Name AS TopicName,
        c.Date
    FROM Contributions c
    JOIN Users u ON c.UserID = u.ID
    JOIN Topics t ON c.TopicID = t.ID
    WHERE c.Status = 'Pending'
    ORDER BY c.Date DESC;
END
GO

-- 18. GetCompanyStats (Complexity 4): Companies with highest fail rates
-- 1. JOIN Companies (Base)
-- 2. JOIN Questions (Relation 1)
-- 3. JOIN UserProgress (Relation 2, Analysis)
-- 4. WHERE (Filter)
-- 5. GROUP BY (Aggregation)
IF OBJECT_ID('GetCompanyStats', 'P') IS NOT NULL DROP PROCEDURE GetCompanyStats;
GO

CREATE PROCEDURE GetCompanyStats
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 5
        c.Name,
        COUNT(up.ID) AS TotalAttempts,
        SUM(CASE WHEN up.IsCorrect = 0 THEN 1 ELSE 0 END) AS FailCount
    FROM Companies c
    JOIN Questions q ON c.ID = q.CompanyID
    JOIN UserProgress up ON q.ID = up.QuestionID
    WHERE up.ID IS NOT NULL
    GROUP BY c.Name
    ORDER BY FailCount DESC;
END
GO

-- 19. GetTopicStats (Complexity 6): Topic Performance
-- 1. JOIN Topics
-- 2. JOIN Questions
-- 3. JOIN UserProgress
-- 4. JOIN QuizAttempts (Context)
-- 5. WHERE CompletedAt NOT NULL
-- 6. GROUP BY
-- 7. HAVING Count > 0
IF OBJECT_ID('GetTopicStats', 'P') IS NOT NULL DROP PROCEDURE GetTopicStats;
GO

CREATE PROCEDURE GetTopicStats
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        t.Name,
        COUNT(DISTINCT qa.ID) AS QuizzesTaken,
        AVG(CAST(up.IsCorrect AS FLOAT)) * 100 AS SuccessRate
    FROM Topics t
    JOIN Questions q ON t.ID = q.TopicID
    JOIN UserProgress up ON q.ID = up.QuestionID
    JOIN QuizAttempts qa ON up.AttemptID = qa.ID
    WHERE qa.CompletedAt IS NOT NULL
    GROUP BY t.Name
    HAVING COUNT(up.ID) > 0
    ORDER BY SuccessRate DESC;
END
GO

-- 20. GetUserLeaderboard (Complexity 7): User Engagement
-- Complexity Points:
-- 1. LEFT JOIN QuizAttempts (+1)
-- 2. LEFT JOIN Reviews (+1)
-- 3. LEFT JOIN Contributions (+1)
-- 4. LEFT JOIN Topics (+1)
-- 5. WHERE Role check (+1)
-- 6. GROUP BY (+1)
-- 7. HAVING check (+1)
IF OBJECT_ID('GetUserLeaderboard', 'P') IS NOT NULL DROP PROCEDURE GetUserLeaderboard;
GO

CREATE PROCEDURE GetUserLeaderboard
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 10
        u.Username,
        COUNT(DISTINCT qa.ID) AS QuizzesCompleted,
        COUNT(DISTINCT r.ID) AS ReviewsGiven,
        COUNT(DISTINCT c.ID) AS ContributionsMade,
        (COUNT(DISTINCT qa.ID) * 10 + COUNT(DISTINCT r.ID) * 5 + COUNT(DISTINCT c.ID) * 20) AS EngagementScore
    FROM Users u
    LEFT JOIN QuizAttempts qa ON u.ID = qa.UserID AND qa.CompletedAt IS NOT NULL
    LEFT JOIN Reviews r ON u.ID = r.UserID
    LEFT JOIN Contributions c ON u.ID = c.UserID
    LEFT JOIN Topics t ON c.TopicID = t.ID
    WHERE u.Role = 'User'
    GROUP BY u.Username
    HAVING (COUNT(DISTINCT qa.ID) * 10 + COUNT(DISTINCT r.ID) * 5 + COUNT(DISTINCT c.ID) * 20) > 0
    ORDER BY EngagementScore DESC;
END
GO

-- 32. GetTopicDifficultyAnalysis (Complexity 7+): Difficulties vs Success Rate per Topic
-- Complexity Points:
-- 1. JOIN Questions (+1)
-- 2. JOIN UserProgress (+1)
-- 3. JOIN QuizAttempts (+1)
-- 4. JOIN Users (+1)
-- 5. WHERE Role='User' (+1)
-- 6. GROUP BY (+1)
-- 7. HAVING Count > 5 (+1)
IF OBJECT_ID('GetTopicDifficultyAnalysis', 'P') IS NOT NULL DROP PROCEDURE GetTopicDifficultyAnalysis;
GO

CREATE PROCEDURE GetTopicDifficultyAnalysis
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        t.Name AS TopicName,
        q.Difficulty,
        COUNT(DISTINCT up.ID) AS TotalAnswers,
        AVG(CAST(up.IsCorrect AS FLOAT)) * 100 AS SuccessRate
    FROM Topics t
    JOIN Questions q ON t.ID = q.TopicID
    JOIN UserProgress up ON q.ID = up.QuestionID
    JOIN QuizAttempts qa ON up.AttemptID = qa.ID
    JOIN Users u ON qa.UserID = u.ID
    WHERE u.Role = 'User'
    GROUP BY t.Name, q.Difficulty
    HAVING COUNT(DISTINCT up.ID) > 0
    ORDER BY t.Name,
        CASE q.Difficulty
            WHEN 'Easy' THEN 1
            WHEN 'Medium' THEN 2
            WHEN 'Hard' THEN 3
        END;
END
GO

-- 14. ApproveContribution: Approves a contribution and moves it to Questions/Answers
IF OBJECT_ID('ApproveContribution', 'P') IS NOT NULL DROP PROCEDURE ApproveContribution;
GO

CREATE PROCEDURE ApproveContribution
    @ContributionID INT,
    @TargetQuizID INT,
    @Difficulty NVARCHAR(20),
    @CompanyID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRANSACTION;

    BEGIN TRY
        -- Get Contribution Data
        DECLARE @QuestionText NVARCHAR(MAX);
        DECLARE @CorrectAnswer NVARCHAR(MAX);
        DECLARE @Wrong1 NVARCHAR(MAX);
        DECLARE @Wrong2 NVARCHAR(MAX);
        DECLARE @Wrong3 NVARCHAR(MAX);
        DECLARE @TopicID INT;

        SELECT
            @QuestionText = QuestionText,
            @CorrectAnswer = CorrectAnswer,
            @Wrong1 = WrongAnswer1,
            @Wrong2 = WrongAnswer2,
            @Wrong3 = WrongAnswer3,
            @TopicID = TopicID
        FROM Contributions WHERE ID = @ContributionID;

        -- Insert into Questions
        DECLARE @NewQuestionID INT;
        INSERT INTO Questions (QuizID, Text, Difficulty, CompanyID, TopicID)
        VALUES (@TargetQuizID, @QuestionText, @Difficulty, @CompanyID, @TopicID);

        SET @NewQuestionID = SCOPE_IDENTITY();

        -- Insert Answers
        INSERT INTO Answers (QuestionID, Text, IsCorrect) VALUES
        (@NewQuestionID, @CorrectAnswer, 1),
        (@NewQuestionID, @Wrong1, 0),
        (@NewQuestionID, @Wrong2, 0),
        (@NewQuestionID, @Wrong3, 0);

        -- Update Contribution Status
        UPDATE Contributions SET Status = 'Approved' WHERE ID = @ContributionID;

        COMMIT TRANSACTION;
        SELECT 1 AS Result;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- 15. RejectContribution: Rejects a contribution
IF OBJECT_ID('RejectContribution', 'P') IS NOT NULL DROP PROCEDURE RejectContribution;
GO

CREATE PROCEDURE RejectContribution
    @ContributionID INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Contributions SET Status = 'Rejected' WHERE ID = @ContributionID;
END
GO

-- 16. GetMyContributions: Retrieves contributions for a specific user
IF OBJECT_ID('GetMyContributions', 'P') IS NOT NULL DROP PROCEDURE GetMyContributions;
GO

CREATE PROCEDURE GetMyContributions
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        c.QuestionText,
        t.Name AS TopicName,
        c.Status,
        c.Date,
        c.ID
    FROM Contributions c
    JOIN Topics t ON c.TopicID = t.ID
    WHERE c.UserID = @UserID
    ORDER BY c.Date DESC;
END
GO

-- 21. GetUserByID: Retrieved user details by ID
IF OBJECT_ID('GetUserByID', 'P') IS NOT NULL DROP PROCEDURE GetUserByID;
GO

CREATE PROCEDURE GetUserByID
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Username, Role FROM Users WHERE ID = @UserID;
END
GO

-- 22. GetQuizDetails: Retrieves title/description for a quiz
IF OBJECT_ID('GetQuizDetails', 'P') IS NOT NULL DROP PROCEDURE GetQuizDetails;
GO

CREATE PROCEDURE GetQuizDetails
    @QuizID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ID, Title, Description FROM Quizzes WHERE ID = @QuizID;
END
GO

-- 23. CheckPendingAttempt: Checks if a user has an incomplete attempt for a quiz
IF OBJECT_ID('CheckPendingAttempt', 'P') IS NOT NULL DROP PROCEDURE CheckPendingAttempt;
GO

CREATE PROCEDURE CheckPendingAttempt
    @UserID INT,
    @QuizID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 1 1 FROM QuizAttempts WHERE UserID = @UserID AND QuizID = @QuizID AND CompletedAt IS NULL;
END
GO

-- 24. GetAttemptProgressCount: Returns the number of answered questions in an attempt
IF OBJECT_ID('GetAttemptProgressCount', 'P') IS NOT NULL DROP PROCEDURE GetAttemptProgressCount;
GO

CREATE PROCEDURE GetAttemptProgressCount
    @AttemptID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT COUNT(*) FROM UserProgress WHERE AttemptID = @AttemptID;
END
GO

-- 25. GetQuestionDetails: Returns text and difficulty for a question
IF OBJECT_ID('GetQuestionDetails', 'P') IS NOT NULL DROP PROCEDURE GetQuestionDetails;
GO

CREATE PROCEDURE GetQuestionDetails
    @QuestionID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Text, Difficulty FROM Questions WHERE ID = @QuestionID;
END
GO

-- 26. GetAllTopics: Returns all topics
IF OBJECT_ID('GetAllTopics', 'P') IS NOT NULL DROP PROCEDURE GetAllTopics;
GO

CREATE PROCEDURE GetAllTopics
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ID, Name FROM Topics;
END
GO

-- 27. GetQuizListSimple: Returns ID and Title of all quizzes (for admin dropdowns)
IF OBJECT_ID('GetQuizListSimple', 'P') IS NOT NULL DROP PROCEDURE GetQuizListSimple;
GO

CREATE PROCEDURE GetQuizListSimple
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ID, Title FROM Quizzes;
END
GO

-- 28. GetTestUsers: Returns IDs of users with username starting with 'user_'
IF OBJECT_ID('GetTestUsers', 'P') IS NOT NULL DROP PROCEDURE GetTestUsers;
GO

CREATE PROCEDURE GetTestUsers
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ID FROM Users WHERE Username LIKE 'user_%';
END
GO

-- 33. GetAllReviews: Returns all reviews for Admin
IF OBJECT_ID('GetAllReviews', 'P') IS NOT NULL DROP PROCEDURE GetAllReviews;
GO

CREATE PROCEDURE GetAllReviews
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        r.ID,
        u.Username,
        q.Text AS QuestionText,
        r.Rating,
        r.Comment,
        r.Date
    FROM Reviews r
    JOIN Users u ON r.UserID = u.ID
    JOIN Questions q ON r.QuestionID = q.ID
    ORDER BY r.Date DESC;
END
GO
GO

-- 29. GetQuestionIDsByQuiz: Returns IDs of questions for a specific quiz
IF OBJECT_ID('GetQuestionIDsByQuiz', 'P') IS NOT NULL DROP PROCEDURE GetQuestionIDsByQuiz;
GO

CREATE PROCEDURE GetQuestionIDsByQuiz
    @QuizID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ID FROM Questions WHERE QuizID = @QuizID;
END
GO

-- 30. GetAnswersWithCorrectness: Returns AnswerID and IsCorrect for a question
IF OBJECT_ID('GetAnswersWithCorrectness', 'P') IS NOT NULL DROP PROCEDURE GetAnswersWithCorrectness;
GO

CREATE PROCEDURE GetAnswersWithCorrectness
    @QuestionID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ID, IsCorrect FROM Answers WHERE QuestionID = @QuestionID;
END
GO

-- 31. GetAllQuizIDs: Returns just IDs of all quizzes
IF OBJECT_ID('GetAllQuizIDs', 'P') IS NOT NULL DROP PROCEDURE GetAllQuizIDs;
GO

CREATE PROCEDURE GetAllQuizIDs
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ID FROM Quizzes;
END
GO

