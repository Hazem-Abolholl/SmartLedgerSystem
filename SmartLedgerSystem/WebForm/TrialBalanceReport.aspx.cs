using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace SmartLedgerSystem.WebForm
{
    public partial class TrialBalanceReport : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["SmartLedgerConn"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtFromDate.Text = new DateTime(DateTime.Now.Year, 1, 1).ToString("yyyy-MM-dd");
                txtToDate.Text = DateTime.Now.ToString("yyyy-MM-dd");

                ExecuteReport();
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            ExecuteReport();
        }

       
        private void ExecuteReport()
        {
            string companyId = Session["SelectedCompanyId"]?.ToString();
            if (string.IsNullOrEmpty(companyId)) { Response.Redirect("Dashboard.aspx"); return; }

            DateTime fromDate, toDate;

            if (!DateTime.TryParse(txtFromDate.Text, out fromDate))
            {
                fromDate = new DateTime(DateTime.Now.Year, 1, 1);
                txtFromDate.Text = fromDate.ToString("yyyy-MM-dd");
            }

            if (!DateTime.TryParse(txtToDate.Text, out toDate))
            {
                toDate = DateTime.Now;
                txtToDate.Text = toDate.ToString("yyyy-MM-dd");
            }

            LoadCompanyInfo(companyId);
            LoadTrialData(companyId, fromDate, toDate);

            litFrom.Text = fromDate.ToString("yyyy/MM/dd");
            litTo.Text = toDate.ToString("yyyy/MM/dd");
            litPrintTime.Text = DateTime.Now.ToString("yyyy/MM/dd HH:mm");
            litUser.Text = Session["UserName"]?.ToString() ?? "مسؤول النظام";
        }
        private void LoadCompanyInfo(string companyId)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string sql = "SELECT name FROM companies WHERE id = @CompId";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@CompId", companyId);
                conn.Open();
                object result = cmd.ExecuteScalar();
                if (result != null)
                {
                    litCompanyName.Text = result.ToString();
                }
                else
                {
                    litCompanyName.Text = "شركة غير معروفة";
                }
            }
        }

        private void LoadTrialData(string companyId, DateTime fromDate, DateTime toDate)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string sql = @"
                    SELECT 
                        a.code AS AccountCode, 
                        a.name AS AccountName,
                        a.account_type AS AccountType,
                        ISNULL(SUM(gl.debit), 0) AS TotalDebit,
                        ISNULL(SUM(gl.credit), 0) AS TotalCredit,
                        CASE 
                            WHEN a.normal_balance = 'D' THEN ISNULL(SUM(gl.debit - gl.credit), 0)
                            ELSE ISNULL(SUM(gl.credit - gl.debit), 0)
                        END AS FinalBalance
                    FROM accounts a
                    LEFT JOIN general_ledger gl ON a.id = gl.account_id 
                         AND gl.entry_date BETWEEN @FromDate AND @ToDate
                    WHERE a.company_id = @CompanyId AND a.is_postable = 1
                    GROUP BY a.code, a.name, a.account_type, a.normal_balance
                    HAVING SUM(gl.debit) <> 0 OR SUM(gl.credit) <> 0
                    ORDER BY a.code";

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@CompanyId", companyId);
                cmd.Parameters.AddWithValue("@FromDate", fromDate);
                cmd.Parameters.AddWithValue("@ToDate", toDate);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                rptTrialBalance.DataSource = dt;
                rptTrialBalance.DataBind();

                // حساب المجاميع النهائية للميزان
                decimal sumDebit = 0;
                decimal sumCredit = 0;
                foreach (DataRow row in dt.Rows)
                {
                    sumDebit += Convert.ToDecimal(row["TotalDebit"]);
                    sumCredit += Convert.ToDecimal(row["TotalCredit"]);
                }

                litSumDebit.Text = sumDebit.ToString("N2");
                litSumCredit.Text = sumCredit.ToString("N2");
            }
        }
    }
}