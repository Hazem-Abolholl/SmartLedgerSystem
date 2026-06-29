using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;
using System.Web.UI;

namespace SmartLedger
{
    public partial class CostCenters : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["SmartLedgerConn"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadData();
                LoadParentDropdown();
            }
        }


        DataTable dtOrdered;

        private void LoadData()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = @"
            WITH Tree AS (
                -- الجذور (المراكز الرئيسية)
                SELECT *, 0 AS Level, CAST(code AS VARCHAR(MAX)) AS SortPath
                FROM cost_centers
                WHERE (parent_id IS NULL OR parent_id = 0) AND company_id = @CoId

                UNION ALL

                -- الأبناء (الربط المتسلسل)
                SELECT c.*, t.Level + 1, t.SortPath + '-' + CAST(c.code AS VARCHAR(MAX))
                FROM cost_centers c
                INNER JOIN Tree t ON c.parent_id = t.id
                WHERE c.company_id = @CoId
            )
            SELECT * FROM Tree ORDER BY SortPath";

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@CoId", Session["SelectedCompanyId"] ?? 1);

                try
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    // إذا فشل الاستعلام الشجري لأي سبب تقني، جلب عادي لضمان عدم اختفاء البيانات
                    if (dt.Rows.Count == 0)
                    {
                        cmd.CommandText = "SELECT *, 0 as Level FROM cost_centers WHERE company_id = @CoId ORDER BY code";
                        da.Fill(dt);
                    }

                    gvCostCenters.DataSource = dt;
                    gvCostCenters.DataBind();
                }
                catch
                {
                    SqlDataAdapter daFallback = new SqlDataAdapter("SELECT *, 0 as Level FROM cost_centers WHERE company_id = @CoId", conn);
                    daFallback.SelectCommand.Parameters.AddWithValue("@CoId", Session["SelectedCompanyId"] ?? 1);
                    DataTable dtFallback = new DataTable();
                    daFallback.Fill(dtFallback);
                    gvCostCenters.DataSource = dtFallback;
                    gvCostCenters.DataBind();
                }
            }
        }

        public int GetIndent(object level)
        {
            int l = (level == DBNull.Value) ? 0 : Convert.ToInt32(level);
            return l * 30; // 30 بكسل لكل مستوى
        }
 
        private string GetNextAutoCode()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = "SELECT ISNULL(MAX(CAST(code AS INT)), 100) FROM cost_centers WHERE company_id = @CoId";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@CoId", Session["SelectedCompanyId"] ?? 1);
                conn.Open();
                object result = cmd.ExecuteScalar();
                return (Convert.ToInt32(result) + 1).ToString();
            }
        }

        private void LoadParentDropdown()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = "SELECT id, name FROM cost_centers WHERE company_id = @CoId AND is_active = 1";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@CoId", Session["SelectedCompanyId"] ?? 1);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                ddlParent.DataSource = dt;
                ddlParent.DataTextField = "name";
                ddlParent.DataValueField = "id";
                ddlParent.DataBind();
                ddlParent.Items.Insert(0, new ListItem("-- مركز رئيسي --", "0"));
            }
        }

        protected void btnOpenAdd_Click(object sender, EventArgs e)
        {
            hfCenterId.Value = "0";
            txtCode.Text = GetNextAutoCode();
            txtName.Text = "";
            txtManager.Text = "";
            txtBudget.Text = "0";
            chkActive.Checked = true;
            ddlParent.SelectedIndex = 0;
            ScriptManager.RegisterStartupScript(this, GetType(), "ShowModal", "openModal();", true);
        }

        protected void gvCostCenters_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "EditCenter" || e.CommandName == "ArchiveCenter" || e.CommandName == "DeleteCenter")
            {
                int id = Convert.ToInt32(e.CommandArgument);
                if (e.CommandName == "EditCenter")
                {
                    FillData(id);
                    ScriptManager.RegisterStartupScript(this, GetType(), "ShowModal", "openModal();", true);
                }
                else if (e.CommandName == "ArchiveCenter")
                {
                    ToggleArchive(id);
                }
                else if (e.CommandName == "DeleteCenter")
                {
                    DeleteCenter(id);
                }
            }
        }

        private void FillData(int id)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                SqlCommand cmd = new SqlCommand("SELECT * FROM cost_centers WHERE id=@id", conn);
                cmd.Parameters.AddWithValue("@id", id);
                conn.Open();
                SqlDataReader dr = cmd.ExecuteReader();
                if (dr.Read())
                {
                    hfCenterId.Value = dr["id"].ToString();
                    txtCode.Text = dr["code"].ToString();
                    txtName.Text = dr["name"].ToString();
                    txtManager.Text = dr["manager_name"].ToString();
                    txtBudget.Text = dr["budget_limit"].ToString();
                    chkActive.Checked = Convert.ToBoolean(dr["is_active"]);

                    ddlParent.ClearSelection();
                    string pId = dr["parent_id"].ToString();
                    if (!string.IsNullOrEmpty(pId))
                    {
                        ListItem item = ddlParent.Items.FindByValue(pId);
                        if (item != null) item.Selected = true;
                    }
                }
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            int centerId = int.Parse(hfCenterId.Value);
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = centerId == 0
                    ? "INSERT INTO cost_centers (company_id, name, code, parent_id, budget_limit, manager_name, is_active) VALUES (@CoId, @name, @code, @parent, @budget, @manager, @active)"
                    : "UPDATE cost_centers SET name=@name, code=@code, parent_id=@parent, budget_limit=@budget, manager_name=@manager, is_active=@active WHERE id=@id";

                SqlCommand cmd = new SqlCommand(sql, conn);
                if (centerId != 0) cmd.Parameters.AddWithValue("@id", centerId);
                cmd.Parameters.AddWithValue("@CoId", Session["SelectedCompanyId"] ?? 1);
                cmd.Parameters.AddWithValue("@name", txtName.Text.Trim());
                cmd.Parameters.AddWithValue("@code", txtCode.Text.Trim());
                cmd.Parameters.AddWithValue("@manager", txtManager.Text.Trim());
                cmd.Parameters.AddWithValue("@active", chkActive.Checked);
                cmd.Parameters.AddWithValue("@budget", string.IsNullOrEmpty(txtBudget.Text) ? 0 : decimal.Parse(txtBudget.Text));

                object parentVal = (ddlParent.SelectedValue == "0" || string.IsNullOrEmpty(ddlParent.SelectedValue))
                                    ? (object)DBNull.Value : ddlParent.SelectedValue;
                cmd.Parameters.AddWithValue("@parent", parentVal);

                conn.Open();
                cmd.ExecuteNonQuery();
            }

            LoadData();
            LoadParentDropdown();
            ScriptManager.RegisterStartupScript(this, GetType(), "HideModal", "closeModal();", true);
        }

        private void ToggleArchive(int id)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                SqlCommand cmd = new SqlCommand("UPDATE cost_centers SET is_active = CASE WHEN is_active = 1 THEN 0 ELSE 1 END WHERE id = @id", conn);
                cmd.Parameters.AddWithValue("@id", id);
                conn.Open();
                cmd.ExecuteNonQuery();
            }
            LoadData();
        }

        private void DeleteCenter(int id)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                SqlCommand cmd = new SqlCommand("DELETE FROM cost_centers WHERE id = @id", conn);
                cmd.Parameters.AddWithValue("@id", id);
                conn.Open();
                try { cmd.ExecuteNonQuery(); } catch { }
            }
            LoadData();
        }

      
    }
}