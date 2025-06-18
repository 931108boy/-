using System;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Web.Services;
using System.Web.Script.Services;

// ✅ 定義輸入格式（userName）
public class RankRequest
{
    public string userName { get; set; }
}

public partial class ColorGuess : System.Web.UI.Page
{
    // ✅ 寫入遊戲紀錄
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static string SaveGameRecord(string userName, int colorCount, int attempts)
    {
        string connStr = "Data Source=localhost\\SQLEXPRESS;Initial Catalog=ColorGuessDB;Integrated Security=True";

        using (SqlConnection conn = new SqlConnection(connStr))
        {
            conn.Open();
            string sql = "INSERT INTO GameRecord (UserName, ColorCount, Attempts) VALUES (@UserName, @ColorCount, @Attempts)";
            SqlCommand cmd = new SqlCommand(sql, conn);
            cmd.Parameters.AddWithValue("@UserName", userName);
            cmd.Parameters.AddWithValue("@ColorCount", colorCount);
            cmd.Parameters.AddWithValue("@Attempts", attempts);
            cmd.ExecuteNonQuery();
        }
        return "success";
    }

    // ✅ 查詢排行榜
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static object GetRankData(RankRequest input)
    {
        string userName = input.userName ?? "未命名";
        string connStr = "Data Source=localhost\\SQLEXPRESS;Initial Catalog=ColorGuessDB;Integrated Security=True";

        // ✅ 注意：用 string 當 key 避免序列化錯誤
        Dictionary<string, int> myBest = new Dictionary<string, int>();
        Dictionary<string, int> allBest = new Dictionary<string, int>();

        try
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // 我的最佳成績
                string sqlMine = @"
                    SELECT ColorCount, MIN(Attempts) AS BestTry
                    FROM GameRecord
                    WHERE UserName = @UserName
                    GROUP BY ColorCount";

                using (SqlCommand cmd = new SqlCommand(sqlMine, conn))
                {
                    cmd.Parameters.AddWithValue("@UserName", userName);
                    var reader = cmd.ExecuteReader();
                    while (reader.Read())
                    {
                        if (!reader.IsDBNull(0) && !reader.IsDBNull(1))
                            myBest[reader["ColorCount"].ToString()] = (int)reader["BestTry"];
                    }
                    reader.Close();
                }

                // 所有人最佳成績
                string sqlAll = @"
                    SELECT ColorCount, MIN(Attempts) AS BestTry
                    FROM GameRecord
                    GROUP BY ColorCount";

                using (SqlCommand cmd = new SqlCommand(sqlAll, conn))
                {
                    var reader = cmd.ExecuteReader();
                    while (reader.Read())
                    {
                        if (!reader.IsDBNull(0) && !reader.IsDBNull(1))
                            allBest[reader["ColorCount"].ToString()] = (int)reader["BestTry"];
                    }
                    reader.Close();
                }
            }

            // ✅ 回傳 JSON 結果（前端：result.mine、result.all）
            return new { mine = myBest, all = allBest };
        }
        catch (Exception ex)
        {
            throw new Exception("讀取排行榜失敗：" + ex.Message);
        }
    }
}
