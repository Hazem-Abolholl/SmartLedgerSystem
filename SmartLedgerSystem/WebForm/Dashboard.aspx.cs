using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SmartLedgerSystem.WebForm
{
    public partial class Dashboard : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["SmartLedgerConn"].ConnectionString;

        public string ChartDataLabels = "";
        public string ChartDataValues = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                lblUserName.Text = Session["UserName"]?.ToString() ?? "مستخدم";
                LoadActiveCompanies();

                if (Session["SelectedCompanyId"] != null)
                {
                    ddlActiveCompanies.SelectedValue = Session["SelectedCompanyId"].ToString();

                }
                else
                {
                    ddlActiveCompanies.SelectedIndex = 1;
                    Session["SelectedCompanyId"] = ddlActiveCompanies.SelectedValue;
                    Session["SelectedCompanyName"] = ddlActiveCompanies.SelectedItem.Text;
                }
                
                RefreshDashboard();
            }
        }

        private void LoadActiveCompanies()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string sql = "SELECT id, name FROM companies WHERE is_active = 1 OR is_active IS NULL ORDER BY name";
                SqlDataAdapter da = new SqlDataAdapter(sql, conn);
                DataTable dt = new DataTable();
                try
                {
                    da.Fill(dt);
                    ddlActiveCompanies.DataSource = dt;
                    ddlActiveCompanies.DataTextField = "name";
                    ddlActiveCompanies.DataValueField = "id";
                    ddlActiveCompanies.DataBind();
                    ddlActiveCompanies.Items.Insert(0, new ListItem("-- اختر الشركة لبدء العمل --", "0"));
                }
                catch { }
            }
        }

        private void RefreshDashboard()
        {
            string selectedId = ddlActiveCompanies.SelectedValue;
            LoadStatistics(selectedId);
            LoadChartData(selectedId);
        }

        private void LoadStatistics(string selectedId)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = @"
                    SELECT 
                        (SELECT COUNT(*) FROM companies) as CoCount,
                        (SELECT COUNT(*) FROM accounts WHERE company_id = @cid OR @cid = '0') as AccCount,
                        (SELECT COUNT(*) FROM cost_centers WHERE company_id = @cid OR @cid = '0') as CostCount,
                        (SELECT COUNT(*) FROM journal_entries WHERE (company_id = @cid OR @cid = '0') AND posted = 0) as UnpostedCount,
                        (SELECT COUNT(*) FROM bank_accounts) as BankCount";

                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@cid", selectedId);

                try
                {
                    conn.Open();
                    SqlDataReader r = cmd.ExecuteReader();
                    if (r.Read())
                    {
                        lblCountCompanies.Text = r["CoCount"].ToString();
                        lblCountAccounts.Text = r["AccCount"].ToString();
                        lblCountCostCenters.Text = r["CostCount"].ToString();
                        lblUnpostedEntries.Text = r["UnpostedCount"].ToString();
                        lblBankAccountsCount.Text = r["BankCount"].ToString();
                    }
                }
                catch
                {
                    SetDefaultStats();
                }
            }
        }

        private void LoadChartData(string companyId)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string sql = @"
                    SELECT TOP 6 
                        FORMAT(entry_date, 'MMM yyyy', 'ar-EG') as MonthName, 
                        COUNT(id) as EntryCount,
                        MAX(entry_date) as SortDate
                    FROM journal_entries
                    WHERE (company_id = @cid OR @cid = '0')
                    GROUP BY FORMAT(entry_date, 'MMM yyyy', 'ar-EG')
                    ORDER BY SortDate DESC";

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@cid", companyId);

                List<string> labels = new List<string>();
                List<string> values = new List<string>();

                try
                {
                    conn.Open();
                    SqlDataReader r = cmd.ExecuteReader();
                    while (r.Read())
                    {
                        labels.Add("'" + r["MonthName"].ToString() + "'");
                        values.Add(r["EntryCount"].ToString());
                    }

                    labels.Reverse();
                    values.Reverse();

                    ChartDataLabels = string.Join(",", labels);
                    ChartDataValues = string.Join(",", values);
                }
                catch { }
            }
        }

        private void SetDefaultStats()
        {
            lblCountCompanies.Text = "0"; lblCountAccounts.Text = "0";
            lblCountCostCenters.Text = "0"; lblUnpostedEntries.Text = "0";
            lblBankAccountsCount.Text = "0";
        }

        protected void ddlActiveCompanies_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (ddlActiveCompanies.SelectedValue != "0")
            {
                Session["SelectedCompanyId"] = ddlActiveCompanies.SelectedValue;
                Session["SelectedCompanyName"] = ddlActiveCompanies.SelectedItem.Text;
            }
            else
            {
                Session["SelectedCompanyId"] = null;
            }
            RefreshDashboard();
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }
    }
}