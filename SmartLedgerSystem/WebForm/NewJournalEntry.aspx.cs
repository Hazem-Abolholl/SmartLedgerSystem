using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.Script.Serialization;
using System.Web.UI;

namespace SmartLedgerSystem.WebForm
{
    public partial class NewJournalEntry : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["SmartLedgerConn"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                LoadAccounts();
                LoadCostCenters();
                LoadJournalTypes();
                GetCompanyInfo();
                if (Request.QueryString["id"] != null)
                {
                    LoadEntryForEdit(long.Parse(Request.QueryString["id"]));
                }
            }
        }

        private void LoadCostCenters()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string sql = "SELECT id, name FROM cost_centers WHERE is_active = 1 AND company_id = @coId";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@coId", Session["SelectedCompanyId"] ?? 1);
                conn.Open();
                SqlDataReader dr = cmd.ExecuteReader();
                string options = "<option value=''>-- بلا مركز تكلفة --</option>";
                while (dr.Read()) { options += $"<option value='{dr["id"]}'>{dr["name"]}</option>"; }
                hfCostCentersOptions.Value = options;
            }
        }

        private void LoadAccounts()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string sql = "SELECT id, code + ' - ' + name as DisplayName FROM accounts WHERE is_postable = 1 AND company_id = @coId";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@coId", Session["SelectedCompanyId"] ?? 1);
                conn.Open();
                SqlDataReader dr = cmd.ExecuteReader();
                string options = "<option value=''>-- اختر الحساب --</option>";
                while (dr.Read()) { options += $"<option value='{dr["id"]}'>{dr["DisplayName"]}</option>"; }
                hfAccountsOptions.Value = options;
            }
        }

        private void LoadEntryForEdit(long id)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                SqlCommand cmdHead = new SqlCommand("SELECT * FROM journal_entries WHERE id = @id", conn);
                cmdHead.Parameters.AddWithValue("@id", id);
                SqlDataReader dr = cmdHead.ExecuteReader();
                if (dr.Read())
                {
                    if (Convert.ToBoolean(dr["posted"])) Response.Redirect("JournalEntries.aspx?msg=posted_error");
                    txtDate.Text = Convert.ToDateTime(dr["entry_date"]).ToString("yyyy-MM-dd");
                    txtDescription.Text = dr["description"].ToString();
                    txtRef.Text = dr["reference"].ToString();
                    ddlEntryType.SelectedValue = dr["journal_type_id"].ToString();
                }
                dr.Close();

                string sqlLines = "SELECT account_id as accId, cost_center_id as ccId, debit as d, credit as c, line_description as lineDesc, bank_reference as bankRef FROM journal_lines WHERE journal_entry_id = @id ORDER BY line_index ASC";
                SqlDataAdapter da = new SqlDataAdapter(sqlLines, conn);
                da.SelectCommand.Parameters.AddWithValue("@id", id);
                DataTable dt = new DataTable();
                da.Fill(dt);

                List<Dictionary<string, object>> rows = new List<Dictionary<string, object>>();
                foreach (DataRow drRow in dt.Rows)
                {
                    rows.Add(new Dictionary<string, object> {
                        { "accId", drRow["accId"] },
                        { "ccId", drRow["ccId"] == DBNull.Value ? "" : drRow["ccId"] },
                        { "d", drRow["d"].ToString() },
                        { "c", drRow["c"].ToString() },
                        { "lineDesc", drRow["lineDesc"].ToString() },
                        { "bankRef", drRow["bankRef"].ToString() } // جلب رقم الصك
                    });
                }
                hfLinesData.Value = new JavaScriptSerializer().Serialize(rows);
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(hfLinesData.Value) || hfLinesData.Value == "[]") return;

            var serializer = new JavaScriptSerializer();
            List<JournalLineData> lines = serializer.Deserialize<List<JournalLineData>>(hfLinesData.Value);

            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                SqlTransaction trans = conn.BeginTransaction();
                try
                {
                    long coId = Session["SelectedCompanyId"] != null ? Convert.ToInt64(Session["SelectedCompanyId"]) : 1;
                    long userId = Session["UserId"] != null ? Convert.ToInt64(Session["UserId"]) : 1;
                    long entryId;
                    bool isEdit = Request.QueryString["id"] != null;

                    if (isEdit)
                    {
                        entryId = long.Parse(Request.QueryString["id"]);
                        string sqlUpdate = "UPDATE journal_entries SET entry_date=@dt, description=@desc, reference=@ref, journal_type_id=@type WHERE id=@id AND posted=0";
                        SqlCommand cmdUp = new SqlCommand(sqlUpdate, conn, trans);
                        cmdUp.Parameters.AddWithValue("@dt", txtDate.Text);
                        cmdUp.Parameters.AddWithValue("@desc", txtDescription.Text);
                        cmdUp.Parameters.AddWithValue("@ref", txtRef.Text);
                        cmdUp.Parameters.AddWithValue("@type", ddlEntryType.SelectedValue);
                        cmdUp.Parameters.AddWithValue("@id", entryId);
                        cmdUp.ExecuteNonQuery();

                        new SqlCommand($"DELETE FROM journal_lines WHERE journal_entry_id = {entryId}", conn, trans).ExecuteNonQuery();
                    }
                    else
                    {
                        string sqlIns = "INSERT INTO journal_entries (company_id, entry_date, description, reference, journal_type_id, posted, created_by, created_at) OUTPUT INSERTED.id VALUES (@coId,@dt,@desc,@ref,@type,0,@user,GETDATE())";
                        SqlCommand cmdHead = new SqlCommand(sqlIns, conn, trans);
                        cmdHead.Parameters.AddWithValue("@coId", coId);
                        cmdHead.Parameters.AddWithValue("@dt", txtDate.Text);
                        cmdHead.Parameters.AddWithValue("@desc", txtDescription.Text);
                        cmdHead.Parameters.AddWithValue("@ref", txtRef.Text);
                        cmdHead.Parameters.AddWithValue("@type", ddlEntryType.SelectedValue);
                        cmdHead.Parameters.AddWithValue("@user", userId);
                        entryId = Convert.ToInt64(cmdHead.ExecuteScalar());
                    }

                    foreach (var line in lines)
                    {
                        decimal d = 0, c = 0;
                        decimal.TryParse(line.d, out d);
                        decimal.TryParse(line.c, out c);
                        if (d == 0 && c == 0) continue;

                        // تم إضافة bank_reference في جملة الـ Insert
                        string sqlLine = @"INSERT INTO journal_lines (journal_entry_id, account_id, debit, credit, cost_center_id, line_index, line_description, bank_reference) 
                                           VALUES (@entryId, @accId, @d, @c, @ccId, @idx, @lineDesc, @bankRef)";
                        SqlCommand cmdLine = new SqlCommand(sqlLine, conn, trans);
                        cmdLine.Parameters.AddWithValue("@entryId", entryId);
                        cmdLine.Parameters.AddWithValue("@accId", line.accId);
                        cmdLine.Parameters.AddWithValue("@d", d);
                        cmdLine.Parameters.AddWithValue("@c", c);
                        cmdLine.Parameters.AddWithValue("@ccId", string.IsNullOrEmpty(line.ccId) ? (object)DBNull.Value : line.ccId);
                        cmdLine.Parameters.AddWithValue("@idx", line.idx);
                        cmdLine.Parameters.AddWithValue("@lineDesc", string.IsNullOrEmpty(line.lineDesc) ? (object)DBNull.Value : line.lineDesc);
                        cmdLine.Parameters.AddWithValue("@bankRef", string.IsNullOrEmpty(line.bankRef) ? (object)DBNull.Value : line.bankRef);
                        cmdLine.ExecuteNonQuery();
                    }

                    trans.Commit();
                    Response.Redirect("JournalEntries.aspx?msg=" + (isEdit ? "updated" : "success"), false);
                }
                catch (Exception ex)
                {
                    if (trans != null) trans.Rollback();
                    ScriptManager.RegisterStartupScript(this, GetType(), "error", $"alert('خطأ: {ex.Message.Replace("'", "")}');", true);
                }
            }
        }

        public class JournalLineData
        {
            public string accId { get; set; }
            public string ccId { get; set; }
            public string d { get; set; }
            public string c { get; set; }
            public string lineDesc { get; set; }
            public string bankRef { get; set; } 
            public int idx { get; set; }
        }

        private void LoadJournalTypes()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                SqlDataAdapter da = new SqlDataAdapter("SELECT id, name_ar FROM journal_types", conn);
                DataTable dt = new DataTable();
                da.Fill(dt);
                ddlEntryType.DataSource = dt;
                ddlEntryType.DataTextField = "name_ar";
                ddlEntryType.DataValueField = "id";
                ddlEntryType.DataBind();
            }
        }

        private void GetCompanyInfo()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                SqlCommand cmd = new SqlCommand("SELECT name FROM companies WHERE id = @id", conn);
                cmd.Parameters.AddWithValue("@id", Session["SelectedCompanyId"] ?? 1);
                conn.Open();
                object n = cmd.ExecuteScalar();
                if (n != null) lblCompanyName.Text = n.ToString();
            }
        }
    }
}