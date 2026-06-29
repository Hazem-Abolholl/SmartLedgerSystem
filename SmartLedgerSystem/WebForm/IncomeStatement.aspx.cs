using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Linq;

namespace SmartLedgerSystem.WebForm
{
    public partial class IncomeStatement : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["SmartLedgerConn"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtFromDate.Text = new DateTime(DateTime.Now.Year, 1, 1).ToString("yyyy-MM-dd");
                txtToDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                LoadIncomeStatement();
            }
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            LoadIncomeStatement();
        }

        private void LoadIncomeStatement()
        {

            if (Session["SelectedCompanyId"] == null)
            {
                Response.Redirect("Dashboard.aspx");
                return;
            }
            string companyId = Session["SelectedCompanyId"]?.ToString() ?? "1";
            DateTime fromDate = DateTime.Parse(txtFromDate.Text);
            DateTime toDate = DateTime.Parse(txtToDate.Text);

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string companySql = "SELECT name, currency FROM companies WHERE id = @CompId";
                SqlCommand compCmd = new SqlCommand(companySql, conn);
                compCmd.Parameters.AddWithValue("@CompId", companyId);

                conn.Open();
                SqlDataReader dr = compCmd.ExecuteReader();
                if (dr.Read())
                {
                    litCompanyName.Text = dr["name"].ToString();
                    litCurrency.Text = dr["currency"].ToString();
                }
                dr.Close();

                string sql = @"
                    SELECT 
                        a.account_type, 
                        a.code, 
                        a.name,
                        CASE 
                            WHEN a.account_type = 'REVENUE' THEN ISNULL(SUM(gl.credit - gl.debit), 0)
                            WHEN a.account_type = 'EXPENSE' THEN ISNULL(SUM(gl.debit - gl.credit), 0)
                        END AS TotalAmount
                    FROM accounts a
                    JOIN general_ledger gl ON a.id = gl.account_id
                    WHERE a.company_id = @CompanyId 
                      AND a.is_postable = 1
                      AND gl.entry_date BETWEEN @FromDate AND @ToDate
                      AND a.account_type IN ('REVENUE', 'EXPENSE')
                    GROUP BY a.account_type, a.code, a.name
                    HAVING SUM(gl.debit) <> 0 OR SUM(gl.credit) <> 0";

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@CompanyId", companyId);
                cmd.Parameters.AddWithValue("@FromDate", fromDate);
                cmd.Parameters.AddWithValue("@ToDate", toDate);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                var revRows = dt.AsEnumerable().Where(r => r.Field<string>("account_type") == "REVENUE");
                var expRows = dt.AsEnumerable().Where(r => r.Field<string>("account_type") == "EXPENSE");

                // الإيرادات
                if (revRows.Any())
                {
                    rptRevenues.DataSource = revRows.CopyToDataTable();
                    rptRevenues.DataBind();
                }
                else
                {
                    rptRevenues.DataSource = null;
                    rptRevenues.DataBind();
                }

                // المصروفات
                if (expRows.Any())
                {
                    rptExpenses.DataSource = expRows.CopyToDataTable();
                    rptExpenses.DataBind();
                }
                else
                {
                    rptExpenses.DataSource = null;
                    rptExpenses.DataBind();
                }

                decimal totalRevenue = revRows.Any() ? revRows.Sum(r => r.Field<decimal>("TotalAmount")) : 0;
                decimal totalExpenses = expRows.Any() ? expRows.Sum(r => r.Field<decimal>("TotalAmount")) : 0;
                decimal netProfit = totalRevenue - totalExpenses;

                litNetProfit.Text = netProfit.ToString("N2");
                litFrom.Text = fromDate.ToString("yyyy/MM/dd");
                litTo.Text = toDate.ToString("yyyy/MM/dd");

                if (netProfit < 0)
                {
                    litNetProfit.Text = "<span style='color:#ff4d4d'>" + netProfit.ToString("N2") + "</span>";
                }
            }
        }
    }
}