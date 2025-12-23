SET NOCOUNT ON;

-- Configuration
DECLARE @TargetUserCount INT = 20;
DECLARE @PasswordHash NVARCHAR(MAX) = 'scrypt:32768:8:1$DWFICo1VKdi1teB5$217088a6fd45f7e100ad5001c2d1d51820980aafdea84fd4de0678db0349a2eeb41f0c99062cf5241067c7d04fc104d03d2'; -- password123

PRINT 'Starting User Population via SQL...';

DECLARE @i INT = 1;
DECLARE @UsersCreated INT = 0;

WHILE @i <= @TargetUserCount
BEGIN
    DECLARE @Username NVARCHAR(50) = 'user_' + CAST(@i AS NVARCHAR(10));
    DECLARE @Email NVARCHAR(100) = 'user' + CAST(@i AS NVARCHAR(10)) + '@example.com';

    IF NOT EXISTS (SELECT 1 FROM Users WHERE Username = @Username)
    BEGIN
        INSERT INTO Users (Username, PasswordHash, Email, Role)
        VALUES (@Username, @PasswordHash, @Email, 'User');
        
        SET @UsersCreated = @UsersCreated + 1;
    END

    SET @i = @i + 1;
END

PRINT 'User Population Complete.';
PRINT 'Users Created: ' + CAST(@UsersCreated AS NVARCHAR(10));
