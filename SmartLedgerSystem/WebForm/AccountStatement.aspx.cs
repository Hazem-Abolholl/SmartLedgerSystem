using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace SmartLedgerSystem.WebForm
{
    public partial class AccountStatement : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["SmartLedgerConn"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtFromDate.Text = new DateTime(DateTime.Now.Year, 1, 1).ToString("yyyy-MM-dd");
                txtToDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                LoadAccounts();

                if (Session["SelectedCompanyId"] != null) LoadCompanyInfo(Session["SelectedCompanyId"].ToString());
            }
        }

        private void LoadAccounts()
        {
            string companyId = Session["SelectedCompanyId"]?.ToString() ?? "1";
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string sql = "SELECT id, code + ' - ' + name as AccountDisplayName FROM accounts WHERE company_id = @CompId AND is_postable = 1 ORDER BY code";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@CompId", companyId);
                conn.Open();
                ddlAccounts.DataSource = cmd.ExecuteReader();
                ddlAccounts.DataTextField = "AccountDisplayName";
                ddlAccounts.DataValueField = "id";
                ddlAccounts.DataBind();
                ddlAccounts.Items.Insert(0, new ListItem("-- اختر الحساب --", ""));
            }
        }

        private void LoadCompanyInfo(string companyId)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                SqlCommand cmd = new SqlCommand("SELECT name FROM companies WHERE id = @id", conn);
                cmd.Parameters.AddWithValue("@id", companyId);
                conn.Open();
                litCompanyName.Text = cmd.ExecuteScalar()?.ToString() ?? "منظومة المحاسب الذكي";
            }
        }

        protected void btnViewReport_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(ddlAccounts.SelectedValue)) return;

            string accountId = ddlAccounts.SelectedValue;
            string companyId = Session["SelectedCompanyId"].ToString();
            DateTime fromDate, toDate;

            if (!DateTime.TryParse(txtFromDate.Text, out fromDate)) fromDate = new DateTime(DateTime.Now.Year, 1, 1);
            if (!DateTime.TryParse(txtToDate.Text, out toDate)) toDate = DateTime.Now;

            litAccountName.Text = ddlAccounts.SelectedItem.Text;
            litPrintTime.Text = DateTime.Now.ToString("yyyy/MM/dd HH:mm");
            litUser.Text = Session["UserName"]?.ToString() ?? "مدير النظام";

            BindReport(accountId, companyId, fromDate, toDate);
        }

        private void BindReport(string accountId, string companyId, DateTime fromDate, DateTime toDate)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string sql = @"
                    SELECT 
                        gl.entry_date, 
                        gl.journal_entry_id, 
                        je.description, 
                        gl.debit, 
                        gl.credit,
                        SUM(gl.debit - gl.credit) OVER (ORDER BY gl.entry_date, gl.id) AS CumulativeBalance
                    FROM general_ledger gl
                    JOIN journal_entries je ON gl.journal_line_id IN (SELECT id FROM journal_lines WHERE journal_entry_id = je.id)
                    WHERE gl.account_id = @AccId 
                      AND gl.company_id = @CompId
                      AND gl.entry_date BETWEEN @From AND @To
                    ORDER BY gl.entry_date, gl.id";

                sql = @"
                    SELECT 
                        gl.entry_date, 
                        je.id as journal_entry_id, 
                        je.description, 
                        gl.debit, 
                        gl.credit,
                        SUM(gl.debit - gl.credit) OVER (ORDER BY gl.entry_date, gl.id) AS CumulativeBalance
                    FROM general_ledger gl
                    INNER JOIN journal_lines jl ON gl.journal_line_id = jl.id
                    INNER JOIN journal_entries je ON jl.journal_entry_id = je.id
                    WHERE gl.account_id = @AccId 
                      AND gl.company_id = @CompId
                      AND gl.entry_date BETWEEN @From AND @To
                    ORDER BY gl.entry_date, gl.id";

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@AccId", accountId);
                cmd.Parameters.AddWithValue("@CompId", companyId);
                cmd.Parameters.AddWithValue("@From", fromDate);
                cmd.Parameters.AddWithValue("@To", toDate);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                rptDetails.DataSource = dt;
                rptDetails.DataBind();
            }
        }
    }
}