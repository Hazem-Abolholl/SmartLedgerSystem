using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace SmartLedgerSystem.WebForm
{
    public partial class Login : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["SmartLedgerConn"].ConnectionString;

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string sql = "SELECT id, name FROM users WHERE email = @email AND password = @pass";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@email", txtEmail.Text.Trim());
                    cmd.Parameters.AddWithValue("@pass", txtPassword.Text.Trim());

                    try
                    {
                        conn.Open();
                        SqlDataReader reader = cmd.ExecuteReader();

                        if (reader.Read())
                        {
                            Session["UserId"] = reader["id"];
                            Session["UserName"] = reader["name"];

                            Response.Redirect("Dashboard.aspx");
                        }
                        else
                        {
                            lblError.Text = "بريد إلكتروني أو كلمة مرور خاطئة!";
                            lblError.Visible = true;
                        }
                    }
                    catch (Exception ex)
                    {
                        
                        pnlError.Visible = true;
                        lblError.Text = "بيانات الدخول غير صحيحة، يرجى التأكد والمحاولة مرة أخرى.";
                    }
                }
            }
        }
    }
}