using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace SmartLedgerSystem.App_Code
{
    public class JournalManager
    {
        string connString = ConfigurationManager.ConnectionStrings["SmartLedgerConn"].ConnectionString;

        public string PostJournalEntry(long entryId, long userId)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_post_journal_entry", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@journal_entry_id", entryId);
                    cmd.Parameters.AddWithValue("@user_id", userId);

                    try
                    {
                        conn.Open();
                        cmd.ExecuteNonQuery();
                        return "Success: تم ترحيل القيد بنجاح";
                    }
                    catch (SqlException ex)
                    {
                        // إرجاع رسالة الخطأ القادمة من SQL (مثل "القيد غير متوازن")
                        return "Error: " + ex.Message;
                    }
                }
            }
        }
    }
}
