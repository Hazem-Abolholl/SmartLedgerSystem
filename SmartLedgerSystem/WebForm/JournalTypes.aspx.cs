using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SmartLedgerSystem.WebForm
{
    public partial class JournalTypes : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["SmartLedgerConn"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadData();
            }
        }

        private void LoadData()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string sql = "SELECT id, name_ar, name_en, prefix FROM journal_types ORDER BY id DESC";
                SqlDataAdapter da = new SqlDataAdapter(sql, conn);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvJournalTypes.DataSource = dt;
                gvJournalTypes.DataBind();
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string sql;
                if (hfId.Value == "0" || string.IsNullOrEmpty(hfId.Value))
                {
                    sql = "INSERT INTO journal_types (name_ar, name_en, prefix) VALUES (@ar, @en, @pre)";
                }
                else
                {
                    sql = "UPDATE journal_types SET name_ar=@ar, name_en=@en, prefix=@pre WHERE id=@id";
                }

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@ar", txtNameAr.Text.Trim());
                cmd.Parameters.AddWithValue("@en", txtNameEn.Text.Trim());
                cmd.Parameters.AddWithValue("@pre", txtPrefix.Text.Trim().ToUpper());

                if (hfId.Value != "0" && !string.IsNullOrEmpty(hfId.Value))
                {
                    cmd.Parameters.AddWithValue("@id", hfId.Value);
                }

                conn.Open();
                cmd.ExecuteNonQuery();
                conn.Close();
            }

            txtNameAr.Text = txtNameEn.Text = txtPrefix.Text = "";
            hfId.Value = "0";
            LoadData();

            ScriptManager.RegisterStartupScript(this, GetType(), "closeModal", "bootstrap.Modal.getInstance(document.getElementById('typeModal')).hide();", true);
        }

        protected void gvJournalTypes_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int id = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "EditRow")
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    SqlCommand cmd = new SqlCommand("SELECT * FROM journal_types WHERE id=@id", conn);
                    cmd.Parameters.AddWithValue("@id", id);
                    conn.Open();
                    SqlDataReader dr = cmd.ExecuteReader();
                    if (dr.Read())
                    {
                        hfId.Value = dr["id"].ToString();
                        txtNameAr.Text = dr["name_ar"].ToString();
                        txtNameEn.Text = dr["name_en"].ToString();
                        txtPrefix.Text = dr["prefix"].ToString();

                        ScriptManager.RegisterStartupScript(this, GetType(), "showEditModal",
                            "document.getElementById('modalTitle').innerText='تعديل نوع القيد'; var myModal = new bootstrap.Modal(document.getElementById('typeModal')); myModal.show();", true);
                    }
                    conn.Close();
                }
            }
            else if (e.CommandName == "DeleteRow")
            {
                DeleteRow(id);
            }
        }

        private void DeleteRow(int id)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("DELETE FROM journal_types WHERE id=@id", conn);
                    cmd.Parameters.AddWithValue("@id", id);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                    LoadData();
                }
                catch (Exception)
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "error", "alert('لا يمكن حذف هذا النوع لأنه مستخدم في قيود سابقة');", true);
                }
            }
        }
    }
}