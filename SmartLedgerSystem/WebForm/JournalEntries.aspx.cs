using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;
using System.Web.UI;

namespace SmartLedgerSystem.WebForm
{
    public partial class JournalEntries : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["SmartLedgerConn"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["SelectedCompanyId"] == null) { Response.Redirect("Dashboard.aspx"); return; }

            if (!IsPostBack)
            {
                LoadEntryTypes();

                GetCompanyInfo(); 
                LoadStats();
                LoadJournalEntries();
            }
        }

        private void LoadEntryTypes()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string sql = "SELECT id, name_ar FROM journal_types";
                SqlCommand cmd = new SqlCommand(sql, conn);
                conn.Open();
                ddlEntryTypes.DataSource = cmd.ExecuteReader();
                ddlEntryTypes.DataTextField = "name_ar";
                ddlEntryTypes.DataValueField = "id";
                ddlEntryTypes.DataBind();
                ddlEntryTypes.Items.Insert(0, new ListItem("كل أنواع القيود", "0"));
            }
        }

        protected void ddlEntryTypes_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadJournalEntries(txtSearch.Text.Trim());
        }
        private void GetCompanyInfo()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string sql = "SELECT name, currency FROM companies WHERE id = @coId";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@coId", Session["SelectedCompanyId"]);

                try
                {
                    conn.Open();
                    SqlDataReader dr = cmd.ExecuteReader();
                    if (dr.Read())
                    {
                        lblCompanyName.Text = dr["name"].ToString();

                        // lblCurrency.Text = dr["currency"].ToString();
                    }
                }
                catch (Exception ex)
                {
                    lblCompanyName.Text = "نظام المحاسبة الذكي";
                }
            }
        }
        private void LoadStats()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string sql = @"SELECT 
                                COUNT(*) as Total,
                                SUM(CASE WHEN posted = 1 THEN 1 ELSE 0 END) as Posted,
                                SUM(CASE WHEN posted = 0 THEN 1 ELSE 0 END) as Draft
                               FROM journal_entries WHERE company_id = @coId";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@coId", Session["SelectedCompanyId"]);
                conn.Open();
                SqlDataReader dr = cmd.ExecuteReader();
                if (dr.Read())
                {
                    litTotalEntries.Text = "<h3 class='fw-bold mb-0'>" + (dr["Total"] == DBNull.Value ? "0" : dr["Total"].ToString()) + "</h3>";
                    litPostedEntries.Text = "<h3 class='fw-bold mb-0 text-success'>" + (dr["Posted"] == DBNull.Value ? "0" : dr["Posted"].ToString()) + "</h3>";
                    litDraftEntries.Text = "<h3 class='fw-bold mb-0 text-warning'>" + (dr["Draft"] == DBNull.Value ? "0" : dr["Draft"].ToString()) + "</h3>";
                }
            }
        }



        private void LoadJournalEntries(string search = "")
        {

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string sql = @"SELECT je.id, je.entry_date, je.description, je.posted, 
                               ISNULL(jt.name_ar, N'قيد عام') as type_name_ar 
                        FROM journal_entries je
                        LEFT JOIN journal_types jt ON je.journal_type_id = jt.id
                        WHERE je.company_id = @coId";
                if (ddlEntryTypes.SelectedValue != "0")
                {
                    sql += " AND je.journal_type_id = " + ddlEntryTypes.SelectedValue;
                }
                if (!string.IsNullOrEmpty(search))
                    sql += " AND (je.id LIKE @search OR je.description LIKE @search)";

                sql += " ORDER BY je.id DESC";

                SqlDataAdapter da = new SqlDataAdapter(sql, conn);
                da.SelectCommand.Parameters.AddWithValue("@coId", Session["SelectedCompanyId"]);
                da.SelectCommand.Parameters.AddWithValue("@search", "%" + search + "%");

                DataTable dt = new DataTable();
                da.Fill(dt);
                gvJournalEntries.DataSource = dt;
                gvJournalEntries.DataBind();
            }
        }
    
        protected void txtSearch_TextChanged(object sender, EventArgs e)
        {
            LoadJournalEntries(txtSearch.Text.Trim());
        }

        protected void gvJournalEntries_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            string entryId = e.CommandArgument.ToString();

            switch (e.CommandName)
            {
                case "ViewEntry":
                    Response.Redirect("ViewJournalEntry.aspx?id=" + entryId);
                    break;
                case "EditEntry":
                    Response.Redirect("NewJournalEntry.aspx?id=" + entryId);
                    break;
                case "PostEntry":
                    PostJournalEntry(entryId);
                    break;
                case "DeleteEntry":
                    DeleteJournalEntry(entryId);
                    break;
            }
        }

        private void PostJournalEntry(string entryId)
        {
            long userId = Session["UserId"] != null ? Convert.ToInt64(Session["UserId"]) : 1;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                SqlCommand cmd = new SqlCommand("sp_post_journal_entry", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@journal_entry_id", Convert.ToInt64(entryId));
                cmd.Parameters.AddWithValue("@user_id", userId);

                try
                {
                    conn.Open();
                    cmd.ExecuteNonQuery();
                    ShowAlert("تم ترحيل القيد بنجاح وتحديث الحسابات الختامية.", "success");

                    LoadJournalEntries();
                    LoadStats();
                }
                catch (SqlException ex)
                {
                    ShowAlert("عذراً، لم يكتمل الترحيل: " + ex.Message, "error");
                }
                catch (Exception ex)
                {
                    ShowAlert("حدث خطأ تقني: " + ex.Message, "error");
                }
            }
        }

        private void DeleteJournalEntry(string id)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string sql = "DELETE FROM journal_entries WHERE id = @id AND posted = 0";
                    SqlCommand cmd = new SqlCommand(sql, conn);
                    cmd.Parameters.AddWithValue("@id", id);
                    conn.Open();
                    int rows = cmd.ExecuteNonQuery();

                    if (rows > 0)
                    {
                        ShowAlert("تم حذف القيد بالكامل بنجاح.", "success");
                        LoadStats();
                        LoadJournalEntries();
                    }
                }
            }
            catch (Exception ex)
            {
                ShowAlert("لا يمكن حذف القيد لوجود بيانات مرتبطة به.", "error");
            }
        }

        private void ShowAlert(string msg, string type)
        {
            string script = $"showNotification('{msg.Replace("'", "")}', '{type}');";
            ScriptManager.RegisterStartupScript(upJournal, upJournal.GetType(), Guid.NewGuid().ToString(), script, true);
        }
        protected override void Render(HtmlTextWriter writer)
        {
            foreach (GridViewRow row in gvJournalEntries.Rows)
            {
                if (row.RowType == DataControlRowType.DataRow)
                {
                    var btnPost = row.FindControl("btnPost");
                    var btnDelete = row.FindControl("btnDelete");
                    if (btnPost != null) Page.ClientScript.RegisterForEventValidation(btnPost.UniqueID);
                    if (btnDelete != null) Page.ClientScript.RegisterForEventValidation(btnDelete.UniqueID);
                }
            }
            base.Render(writer);
        }

    }
}