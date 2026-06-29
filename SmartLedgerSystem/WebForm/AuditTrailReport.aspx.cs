using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;

namespace SmartLedgerSystem.WebForm
{
    public partial class AuditTrailReport : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["SmartLedgerConn"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtFromDate.Text = DateTime.Now.AddDays(-1).ToString("yyyy-MM-ddTHH:mm");
                txtToDate.Text = DateTime.Now.ToString("yyyy-MM-ddTHH:mm");
                LoadUsers();
                LoadLogs();
            }
        }

        private void LoadUsers()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string sql = "SELECT id, name FROM users";
                SqlDataAdapter da = new SqlDataAdapter(sql, conn);
                DataTable dt = new DataTable();
                da.Fill(dt);
                ddlUsers.DataSource = dt;
                ddlUsers.DataTextField = "name";
                ddlUsers.DataValueField = "id";
                ddlUsers.DataBind();
                ddlUsers.Items.Insert(0, new ListItem("-- كل المستخدمين --", "0"));
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            if (Session["SelectedCompanyId"] != null) LoadLogs();
        }

        private void LoadLogs()
        {
            string companyId = Session["SelectedCompanyId"]?.ToString();
            if (string.IsNullOrEmpty(companyId)) return;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string sql = @"
                    SELECT al.*, u.name as UserName 
                    FROM audit_logs al
                    LEFT JOIN users u ON al.user_id = u.id
                    WHERE al.company_id = @compId
                    AND al.created_at BETWEEN @from AND @to";

                if (ddlUsers.SelectedValue != "0")
                    sql += " AND al.user_id = @userId";

                sql += " ORDER BY al.created_at DESC";

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@compId", companyId);
                cmd.Parameters.AddWithValue("@from", DateTime.Parse(txtFromDate.Text));
                cmd.Parameters.AddWithValue("@to", DateTime.Parse(txtToDate.Text));
                if (ddlUsers.SelectedValue != "0")
                    cmd.Parameters.AddWithValue("@userId", ddlUsers.SelectedValue);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                rptLogs.DataSource = dt;
                rptLogs.DataBind();

                // جلب اسم الشركة
                cmd.CommandText = "SELECT name FROM companies WHERE id = @compId";
                conn.Open();
                litCompanyName.Text = cmd.ExecuteScalar()?.ToString();
            }
        }

        protected string GetActionClass(string action)
        {
            switch (action)
            {
                case "POST_ENTRY": return "action-badge bg-post";
                case "POST_ERROR": return "action-badge bg-error";
                case "BUDGET_WARNING": return "action-badge bg-warning";
                case "DELETE": return "action-badge bg-error";
                default: return "action-badge bg-light text-dark border";
            }
        }

        // دالة لجلب أيقونة معبرة عن العملية
        protected string GetActionIcon(string action)
        {
            switch (action)
            {
                case "POST_ENTRY": return "<i class='fas fa-check-circle'></i>";
                case "POST_ERROR": return "<i class='fas fa-times-circle'></i>";
                case "BUDGET_WARNING": return "<i class='fas fa-exclamation-triangle'></i>";
                default: return "<i class='fas fa-info-circle'></i>";
            }
        }
    }
}