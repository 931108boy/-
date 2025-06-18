USE ColorGuessDB;

CREATE TABLE GameRecord (
    Id INT IDENTITY(1,1) PRIMARY KEY,          -- 遞增主鍵
    UserName NVARCHAR(50) NOT NULL,            -- 使用者名稱
    ColorCount INT NOT NULL,                   -- 顏色數量（難度）
    Attempts INT NOT NULL,                     -- 答題次數
    CreateTime DATETIME DEFAULT GETDATE()      -- 建立時間，自動填入當前時間
);

SELECT * FROM GameRecord