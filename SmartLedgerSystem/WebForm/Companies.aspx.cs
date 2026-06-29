using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SmartLedgerSystem.WebForm
{
    public partial class Companies : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["SmartLedgerConn"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null) Response.Redirect("Login.aspx");
            if (!IsPostBack) LoadCompanies();
        }

        protected void txtSearch_TextChanged(object sender, EventArgs e)
        {
            LoadCompanies(txtSearch.Text.Trim());
            ScriptManager.RegisterStartupScript(this, GetType(), "focus", "document.getElementById('txtSearch').focus();", true);
        }

        private void LoadCompanies(string searchTerm = "")
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string sql = "SELECT id, name, currency, fiscal_year_start, fiscal_year_end, is_active FROM companies";
                if (!string.IsNullOrEmpty(searchTerm))
                    sql += " WHERE name LIKE @search OR currency LIKE @search";

                sql += " ORDER BY id DESC";

                SqlCommand cmd = new SqlCommand(sql, conn);
                if (!string.IsNullOrEmpty(searchTerm))
                    cmd.Parameters.AddWithValue("@search", "%" + searchTerm + "%");

                SqlDataAdapter adapter = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                adapter.Fill(dt);
                gvCompanies.DataSource = dt;
                gvCompanies.DataBind();
            }
        }

        protected void btnOpenAdd_Click(object sender, EventArgs e)
        {
            ViewState["EditCompanyId"] = null;
            ClearFields();
            litModalTitle.Text = "إضافة شركة جديدة";
            hfShowModal.Value = "1";
        }

        protected void btnEdit_Click(object sender, EventArgs e)
        {
            string id = ((LinkButton)sender).CommandArgument;
            ViewState["EditCompanyId"] = id;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                SqlCommand cmd = new SqlCommand("SELECT * FROM companies WHERE id=@id", conn);
                cmd.Parameters.AddWithValue("@id", id);
                conn.Open();
                SqlDataReader dr = cmd.ExecuteReader();
                if (dr.Read())
                {
                    txtCompName.Text = dr["name"].ToString();
                    ddlCurrency.SelectedValue = dr["currency"].ToString();
                    txtFiscalStart.Text = Convert.ToDateTime(dr["fiscal_year_start"]).ToString("yyyy-MM-dd");
                    txtFiscalEnd.Text = Convert.ToDateTime(dr["fiscal_year_end"]).ToString("yyyy-MM-dd");
                    litModalTitle.Text = "تعديل: " + dr["name"];
                    hfShowModal.Value = "1";
                }
            }
        }

        protected void btnSaveCompany_Click(object sender, EventArgs e)
        {
            string msg = ViewState["EditCompanyId"] == null ? "تمت الإضافة بنجاح" : "تم التعديل بنجاح";
            try
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string sql = ViewState["EditCompanyId"] == null
                        ? "INSERT INTO companies (name, currency, fiscal_year_start, fiscal_year_end, is_active) VALUES (@name, @curr, @start, @end, 1)"
                        : "UPDATE companies SET name=@name, currency=@curr, fiscal_year_start=@start, fiscal_year_end=@end WHERE id=@id";

                    SqlCommand cmd = new SqlCommand(sql, conn);
                    cmd.Parameters.AddWithValue("@name", txtCompName.Text);
                    cmd.Parameters.AddWithValue("@curr", ddlCurrency.SelectedValue);
                    cmd.Parameters.AddWithValue("@start", txtFiscalStart.Text);
                    cmd.Parameters.AddWithValue("@end", txtFiscalEnd.Text);
                    if (ViewState["EditCompanyId"] != null) cmd.Parameters.AddWithValue("@id", ViewState["EditCompanyId"]);

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
                LoadCompanies();
                ClearFields();
                ScriptManager.RegisterStartupScript(this, GetType(), "success", $"showToast('{msg}');", true);
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "error", $"showToast('خطأ: {ex.Message}', 'error');", true);
            }
        }

        protected void btnToggleStatus_Click(object sender, EventArgs e)
        {
            string id = ((LinkButton)sender).CommandArgument;
            using (SqlConnection conn = new SqlConnection(connString))
            {
                SqlCommand cmd = new SqlCommand("UPDATE companies SET is_active = ~is_active WHERE id = @id", conn);
                cmd.Parameters.AddWithValue("@id", id);
                conn.Open();
                cmd.ExecuteNonQuery();
            }
            LoadCompanies();
            ScriptManager.RegisterStartupScript(this, GetType(), "status", "showToast('تم تحديث الحالة', 'info');", true);
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            string id = ((LinkButton)sender).CommandArgument;
            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                SqlCommand checkCmd = new SqlCommand("SELECT COUNT(*) FROM accounts WHERE company_id = @id", conn);
                checkCmd.Parameters.AddWithValue("@id", id);
                int relatedData = (int)checkCmd.ExecuteScalar();

                if (relatedData > 0)
                {
                    new SqlCommand($"UPDATE companies SET is_active = 0 WHERE id = @id", conn).Parameters.AddWithValue("@id", id);
                    ScriptManager.RegisterStartupScript(this, GetType(), "warn", "Swal.fire('تنبيه', 'لا يمكن حذفها لوجود حسابات مرتبطة، تم تجميدها.', 'warning');", true);
                }
                else
                {
                    SqlCommand delCmd = new SqlCommand("DELETE FROM companies WHERE id = @id", conn);
                    delCmd.Parameters.AddWithValue("@id", id);
                    delCmd.ExecuteNonQuery();
                    ScriptManager.RegisterStartupScript(this, GetType(), "del", "showToast('تم الحذف النهائي');", true);
                }
            }
            LoadCompanies();
        }

        private void ClearFields()
        {
            txtCompName.Text = txtFiscalStart.Text = txtFiscalEnd.Text = "";
        }
    }
}