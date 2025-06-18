USE ColorGuessDB;

CREATE TABLE GameRecord (
    Id INT IDENTITY(1,1) PRIMARY KEY,          -- ���W�D��
    UserName NVARCHAR(50) NOT NULL,            -- �ϥΪ̦W��
    ColorCount INT NOT NULL,                   -- �C��ƶq�]���ס^
    Attempts INT NOT NULL,                     -- ���D����
    CreateTime DATETIME DEFAULT GETDATE()      -- �إ߮ɶ��A�۰ʶ�J��e�ɶ�
);

SELECT * FROM GameRecord