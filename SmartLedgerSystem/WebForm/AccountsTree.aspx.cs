using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SmartLedgerSystem.WebForm
{
    public partial class AccountsTree : System.Web.UI.Page
    {
        private string connString = ConfigurationManager.ConnectionStrings["SmartLedgerConn"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null) { Response.Redirect("Login.aspx"); return; }
            if (Session["SelectedCompanyId"] == null) { Response.Redirect("Dashboard.aspx?msg=select_company"); return; }

            if (!IsPostBack)
            {
                LoadAccountTree();
                LoadParentCombo();
            }
        }

        // تحميل الشجرة
        private void LoadAccountTree()
        {
            DataTable dt = GetAccountsFromDB();
            tvAccounts.Nodes.Clear();
            foreach (DataRow row in dt.Rows)
            {
                if (row["parent_id"] == DBNull.Value || string.IsNullOrEmpty(row["parent_id"].ToString()))
                {
                    TreeNode node = CreateNode(row);
                    AddChildNodes(node, dt);
                    tvAccounts.Nodes.Add(node);
                }
            }
        }

        private TreeNode CreateNode(DataRow row)
        {
            bool archived = row["is_archived"] != DBNull.Value && Convert.ToBoolean(row["is_archived"]);
            string displayName = row["code"].ToString() + " - " + row["name"].ToString();
            TreeNode node = new TreeNode(displayName, row["id"].ToString());
            if (archived)
            {
                node.Text = $"<span class='archived-node'>{displayName} [مؤرشف]</span>";
            }
            return node;
        }

        private void AddChildNodes(TreeNode parentNode, DataTable dt)
        {
            foreach (DataRow row in dt.Rows)
            {
                if (row["parent_id"] != DBNull.Value && row["parent_id"].ToString() == parentNode.Value)
                {
                    TreeNode childNode = CreateNode(row);
                    AddChildNodes(childNode, dt);
                    parentNode.ChildNodes.Add(childNode);
                }
            }
        }

        // تحميل قائمة الآباء (الكمبو بوكس)
        private void LoadParentCombo()
        {
            ddlParent.Items.Clear();
            ddlParent.Items.Add(new ListItem("-- حساب رئيسي (لا يوجد أب) --", "0"));

            DataTable dt = GetAccountsFromDB();
            foreach (DataRow row in dt.Rows)
            {
                if (hfSelectedAccountId.Value != row["id"].ToString())
                {
                    string indent = "";
                    int level = row["level"] != DBNull.Value ? Convert.ToInt32(row["level"]) : 0;
                    for (int i = 0; i < level; i++) indent += "--- ";

                    ddlParent.Items.Add(new ListItem(indent + row["code"] + " - " + row["name"], row["id"].ToString()));
                }
            }
        }

        protected void tvAccounts_SelectedNodeChanged(object sender, EventArgs e)
        {
            TreeNode selectedNode = tvAccounts.SelectedNode;
            if (selectedNode != null)
            {
                hfSelectedAccountId.Value = selectedNode.Value;
                LoadAccountDetails(selectedNode.Value);

                LoadParentCombo();

                SetParentInCombo(selectedNode.Value);

                btnUpdate.Visible = true;
                btnDeleteTrigger.Visible = true;
                btnArchive.Visible = true;
                btnSave.Text = "إضافة فرعي";
                ShowStatus("تم تحميل بيانات الحساب للتعديل", System.Drawing.Color.Blue);
            }
        }

        private void SetParentInCombo(string accountId)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                SqlCommand cmd = new SqlCommand("SELECT parent_id FROM accounts WHERE id = @id", conn);
                cmd.Parameters.AddWithValue("@id", accountId);
                conn.Open();
                object pId = cmd.ExecuteScalar();
                if (pId != null && pId != DBNull.Value)
                    ddlParent.SelectedValue = pId.ToString();
                else
                    ddlParent.SelectedValue = "0";
            }
        }

        private void LoadAccountDetails(string id)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string sql = "SELECT code, name, account_type, is_postable, is_archived, normal_balance FROM accounts WHERE id = @id";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@id", id);
                conn.Open();
                SqlDataReader dr = cmd.ExecuteReader();
                if (dr.Read())
                {
                    txtCode.Text = dr["code"].ToString();
                    txtName.Text = dr["name"].ToString();
                    ddlType.SelectedValue = dr["account_type"].ToString();
                    chkIsPostable.Checked = Convert.ToBoolean(dr["is_postable"]);
                    if (dr["normal_balance"] != DBNull.Value)
                        ddlNormalBalance.SelectedValue = dr["normal_balance"].ToString();
                }
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (ddlParent.SelectedValue != "0")
                GenerateNextSubAccountCode(ddlParent.SelectedValue);
            else
                GenerateMainAccountCode();

            ExecuteDbCommand("INSERT");
        }

        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            ExecuteDbCommand("UPDATE");
        }

        private void ExecuteDbCommand(string type)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                string sql = "";
                if (type == "INSERT")
                {
                    sql = @"INSERT INTO accounts (company_id, code, name, parent_id, account_type, is_postable, level, is_archived, normal_balance) 
                            VALUES (@coId, @code, @name, @pId, @type, @post, @lvl, 0, @nb)";
                }
                else
                {
                    sql = @"UPDATE accounts SET code=@code, name=@name, account_type=@type, 
                            is_postable=@post, normal_balance=@nb, parent_id=@pId WHERE id=@id";
                }

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@coId", Session["SelectedCompanyId"]);
                cmd.Parameters.AddWithValue("@code", txtCode.Text);
                cmd.Parameters.AddWithValue("@name", txtName.Text);
                cmd.Parameters.AddWithValue("@type", ddlType.SelectedValue);
                cmd.Parameters.AddWithValue("@post", chkIsPostable.Checked);
                cmd.Parameters.AddWithValue("@nb", ddlNormalBalance.SelectedValue);

                string parentVal = ddlParent.SelectedValue;
                cmd.Parameters.AddWithValue("@pId", parentVal == "0" ? (object)DBNull.Value : parentVal);

                if (type == "INSERT")
                {
                    int level = 0;
                    if (parentVal != "0")
                    {
                        SqlCommand cmdLvl = new SqlCommand("SELECT level + 1 FROM accounts WHERE id = @pid", conn);
                        cmdLvl.Parameters.AddWithValue("@pid", parentVal);
                        level = Convert.ToInt32(cmdLvl.ExecuteScalar());
                    }
                    cmd.Parameters.AddWithValue("@lvl", level);
                }
                else
                {
                    cmd.Parameters.AddWithValue("@id", hfSelectedAccountId.Value);
                }

                cmd.ExecuteNonQuery();
                ShowStatus("تمت العملية بنجاح ✅", System.Drawing.Color.Green);
                ResetForm();
                LoadAccountTree();
                LoadParentCombo();
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                string sql = "DELETE FROM accounts WHERE id = @id AND NOT EXISTS (SELECT 1 FROM journal_lines WHERE account_id = @id)";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@id", hfSelectedAccountId.Value);
                int rows = cmd.ExecuteNonQuery();
                if (rows > 0) ShowStatus("تم الحذف بنجاح", System.Drawing.Color.Green);
                else ShowStatus("لا يمكن الحذف لارتباطه بقيود مالية", System.Drawing.Color.Red);
                ResetForm(); LoadAccountTree(); LoadParentCombo();
            }
        }

        protected void btnArchive_Click(object sender, EventArgs e)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string sql = "UPDATE accounts SET is_archived = ~is_archived WHERE id = @id";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@id", hfSelectedAccountId.Value);
                conn.Open();
                cmd.ExecuteNonQuery();
                ResetForm(); LoadAccountTree();
            }
        }

        private void GenerateNextSubAccountCode(string parentId)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string sql = @"SELECT MAX(CAST(code AS BIGINT)) FROM accounts WHERE parent_id = @pId";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@pId", parentId);
                conn.Open();
                object result = cmd.ExecuteScalar();
                if (result != DBNull.Value && result != null)
                    txtCode.Text = (Convert.ToInt64(result) + 1).ToString();
                else
                {
                    SqlCommand cmdP = new SqlCommand("SELECT code FROM accounts WHERE id = @id", conn);
                    cmdP.Parameters.AddWithValue("@id", parentId);
                    txtCode.Text = cmdP.ExecuteScalar().ToString() + "01";
                }
            }
        }

        private void GenerateMainAccountCode()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string sql = @"SELECT MAX(CAST(code AS BIGINT)) FROM accounts WHERE parent_id IS NULL";
                SqlCommand cmd = new SqlCommand(sql, conn);
                conn.Open();
                object result = cmd.ExecuteScalar();
                txtCode.Text = (result != DBNull.Value && result != null) ? (Convert.ToInt64(result) + 1).ToString() : "1";
            }
        }

        private void ResetForm()
        {
            txtCode.Text = ""; txtName.Text = ""; hfSelectedAccountId.Value = "";
            btnUpdate.Visible = false; btnDeleteTrigger.Visible = false; btnArchive.Visible = false;
            btnSave.Text = "إضافة جديد";
            ddlParent.SelectedValue = "0";
            chkIsPostable.Checked = false;
        }

        private void ShowStatus(string msg, System.Drawing.Color color)
        {
            lblStatus.Text = msg; lblStatus.BackColor = color; lblStatus.ForeColor = System.Drawing.Color.White;
        }

        protected void btnClear_Clear(object sender, EventArgs e) { ResetForm(); LoadParentCombo(); }

        private DataTable GetAccountsFromDB()
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT id, code, name, parent_id, account_type, is_postable, is_archived, normal_balance, level FROM accounts WHERE company_id = @coId ORDER BY code";
                SqlDataAdapter adapter = new SqlDataAdapter(query, conn);
                adapter.SelectCommand.Parameters.AddWithValue("@coId", Session["SelectedCompanyId"]);
                adapter.Fill(dt);
            }
            return dt;
        }
    }
}