using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

namespace SmartLedgerSystem.WebForm
{
    public partial class ViewJournalEntry : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["SmartLedgerConn"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Request.QueryString["id"] != null)
                {
                    LoadEntryDetails(long.Parse(Request.QueryString["id"]));
                }
                else
                {
                    Response.Redirect("JournalEntries.aspx");
                }
            }
        }

        private void LoadEntryDetails(long id)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string sqlHead = @"SELECT je.*, u.name as CreatorName 
                                  FROM journal_entries je 
                                  LEFT JOIN users u ON je.created_by = u.id 
                                  WHERE je.id = @id";

                SqlCommand cmdHead = new SqlCommand(sqlHead, conn);
                cmdHead.Parameters.AddWithValue("@id", id);
                conn.Open();

                SqlDataReader dr = cmdHead.ExecuteReader();
                if (dr.Read())
                {
                    litEntryId.Text = dr["id"].ToString();
                    litDate.Text = Convert.ToDateTime(dr["entry_date"]).ToString("yyyy-MM-dd");
                    litDescription.Text = dr["description"].ToString();
                    litRef.Text = dr["reference"].ToString();
                    litCreatedBy.Text = dr["CreatorName"].ToString();

                    bool posted = Convert.ToBoolean(dr["posted"]);
                    lblStatus.Text = posted ? "<i class='fas fa-check-double me-1'></i> مُرحل نهائي" : "<i class='fas fa-clock me-1'></i> قيد مسودة";
                    lblStatus.CssClass = posted ? "status-badge bg-success text-white" : "status-badge bg-warning text-dark";
                    btnEdit.Visible = !posted;
                }
                dr.Close();

                string sqlLines = @"SELECT jl.*, a.name as AccountName, a.code as AccountCode, 
                                          cc.name as CostCenterName
                                   FROM journal_lines jl 
                                   JOIN accounts a ON jl.account_id = a.id 
                                   LEFT JOIN cost_centers cc ON jl.cost_center_id = cc.id
                                   WHERE jl.journal_entry_id = @id
                                   ORDER BY jl.line_index ASC";

                SqlDataAdapter da = new SqlDataAdapter(sqlLines, conn);
                da.SelectCommand.Parameters.AddWithValue("@id", id);
                DataTable dt = new DataTable();
                da.Fill(dt);

                gvLines.DataSource = dt;
                gvLines.DataBind();

                decimal totalD = 0, totalC = 0;
                foreach (DataRow row in dt.Rows)
                {
                    totalD += row["debit"] != DBNull.Value ? Convert.ToDecimal(row["debit"]) : 0;
                    totalC += row["credit"] != DBNull.Value ? Convert.ToDecimal(row["credit"]) : 0;
                }
                litTotalDebit.Text = totalD.ToString("N2");
                litTotalCredit.Text = totalC.ToString("N2");
            }
        }

        protected void btnEdit_Click(object sender, EventArgs e)
        {
            Response.Redirect("NewJournalEntry.aspx?id=" + Request.QueryString["id"]);
        }
    }
}