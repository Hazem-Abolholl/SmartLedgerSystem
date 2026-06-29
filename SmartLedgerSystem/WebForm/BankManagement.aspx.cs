using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;

namespace SmartLedgerSystem.WebForm
{
    public partial class BankManagement : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["SmartLedgerConn"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadAccounts(); 
                LoadBankGrid();
            }
        }

        private void LoadAccounts()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string sql = @"SELECT id, code + ' - ' + name as DisplayName FROM accounts 
                               WHERE account_type = 'ASSET' AND is_postable = 1 
                               AND id NOT IN (SELECT account_id FROM bank_accounts)
                               AND company_id = @coId";

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@coId", Session["SelectedCompanyId"] ?? 1);
                conn.Open();
                ddlAccounts.DataSource = cmd.ExecuteReader();
                ddlAccounts.DataTextField = "DisplayName";
                ddlAccounts.DataValueField = "id";
                ddlAccounts.DataBind();
                ddlAccounts.Items.Insert(0, new ListItem("-- اختر حساب من الدليل --", ""));
            }
        }

        private void LoadBankGrid()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string sql = @"SELECT b.*, a.name as account_name, a.code 
                               FROM bank_accounts b 
                               JOIN accounts a ON b.account_id = a.id 
                               WHERE a.company_id = @coId";

                SqlDataAdapter da = new SqlDataAdapter(sql, conn);
                da.SelectCommand.Parameters.AddWithValue("@coId", Session["SelectedCompanyId"] ?? 1);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvBanks.DataSource = dt;
                gvBanks.DataBind();
                lblCount.Text = dt.Rows.Count.ToString();
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(ddlAccounts.SelectedValue)) return;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string sql = @"INSERT INTO bank_accounts (account_id, bank_name, account_number, iban, branch_name) 
                               VALUES (@accId, @name, @num, @iban, @branch)";

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@accId", ddlAccounts.SelectedValue);
                cmd.Parameters.AddWithValue("@name", txtBankName.Text);
                cmd.Parameters.AddWithValue("@num", txtAccNumber.Text);
                cmd.Parameters.AddWithValue("@iban", txtIBAN.Text);
                cmd.Parameters.AddWithValue("@branch", txtBranch.Text);

                conn.Open();
                cmd.ExecuteNonQuery();
            }
            ClearFields();
            LoadAccounts();
            LoadBankGrid();
        }

        protected void gvBanks_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            long id = Convert.ToInt64(gvBanks.DataKeys[e.RowIndex].Value);
            using (SqlConnection conn = new SqlConnection(connString))
            {
                SqlCommand cmd = new SqlCommand("DELETE FROM bank_accounts WHERE id = @id", conn);
                cmd.Parameters.AddWithValue("@id", id);
                conn.Open();
                cmd.ExecuteNonQuery();
            }
            LoadAccounts();
            LoadBankGrid();
        }

        private void ClearFields()
        {
            txtBankName.Text = txtAccNumber.Text = txtIBAN.Text = txtBranch.Text = "";
        }
    }
}