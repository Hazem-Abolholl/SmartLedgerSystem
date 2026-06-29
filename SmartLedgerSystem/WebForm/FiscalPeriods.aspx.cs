using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;
using System.Web.UI;

namespace SmartLedgerSystem.WebForm
{
    public partial class FiscalPeriods : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["SmartLedgerConn"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null) { Response.Redirect("Login.aspx"); return; }
            if (Session["SelectedCompanyId"] == null) { Response.Redirect("Dashboard.aspx?msg=select_company"); return; }

            if (!IsPostBack)
            {
                LoadPeriods();
            }
        }

        private void LoadPeriods()
        {
            string companyId = Session["SelectedCompanyID"]?.ToString() ?? "1";
            UpdateOpenPeriodsCount(companyId);
            UpdateLastClosedDate(companyId);
            UpdateFiscalYearLabel(companyId);
            UpdateCompanyHeader(companyId);

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT id, start_date, end_date, is_closed FROM fiscal_periods WHERE company_id = @companyId ORDER BY start_date DESC";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@companyId", companyId);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                rptPeriods.DataSource = dt;
                rptPeriods.DataBind();
            }
        }

        protected void btnSavePeriod_Click(object sender, EventArgs e)
        {
            try
            {
                string companyId = Session["SelectedCompanyID"]?.ToString() ?? "1";
                DateTime startDate = DateTime.Parse(txtStartDate.Text);
                DateTime endDate = DateTime.Parse(txtEndDate.Text);
                string editId = ViewState["EditPeriodId"]?.ToString();

                if (endDate <= startDate)
                {
                    ShowAlert("خطأ: تاريخ الانتهاء يجب أن يكون بعد تاريخ البدء");
                    return;
                }

                using (SqlConnection conn = new SqlConnection(connString))
                {
                    conn.Open();
                    // فحص التداخل
                    string overlapQuery = "SELECT COUNT(*) FROM fiscal_periods WHERE company_id = @companyId AND id <> @currentId AND (@startDate <= end_date AND @endDate >= start_date)";
                    SqlCommand checkCmd = new SqlCommand(overlapQuery, conn);
                    checkCmd.Parameters.AddWithValue("@companyId", companyId);
                    checkCmd.Parameters.AddWithValue("@currentId", editId ?? "0");
                    checkCmd.Parameters.AddWithValue("@startDate", startDate);
                    checkCmd.Parameters.AddWithValue("@endDate", endDate);

                    if ((int)checkCmd.ExecuteScalar() > 0)
                    {
                        ShowAlert("خطأ: التواريخ تتداخل مع فترة موجودة!");
                        return;
                    }

                    string query = (editId == null)
                        ? "INSERT INTO fiscal_periods (company_id, start_date, end_date, is_closed) VALUES (@companyId, @startDate, @endDate, 0)"
                        : "UPDATE fiscal_periods SET start_date=@startDate, end_date=@endDate WHERE id=@id";

                    SqlCommand cmd = new SqlCommand(query, conn);
                    cmd.Parameters.AddWithValue("@startDate", startDate);
                    cmd.Parameters.AddWithValue("@endDate", endDate);
                    cmd.Parameters.AddWithValue("@companyId", companyId);
                    if (editId != null) cmd.Parameters.AddWithValue("@id", editId);
                    cmd.ExecuteNonQuery();
                }

                // تنظيف وإغلاق
                ViewState["EditPeriodId"] = null;
                txtStartDate.Text = txtEndDate.Text = "";
                LoadPeriods();

                string script = "closeModal(); alert('تمت العملية بنجاح');";
                //ScriptManager.RegisterStartupScript(upPeriods, upPeriods.GetType(), "hideModal", script, true);

                hfShowModal.Value = "0"; 
                ScriptManager.RegisterStartupScript(upPeriods, upPeriods.GetType(), "hideM", "closeModal();", true);
            }
            catch (Exception ex) { ShowAlert("خطأ: " + ex.Message); }
        }

        protected void btnEdit_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            string periodId = btn.CommandArgument;
            ViewState["EditPeriodId"] = periodId;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT start_date, end_date FROM fiscal_periods WHERE id = @id";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@id", periodId);
                conn.Open();
                SqlDataReader dr = cmd.ExecuteReader();
                if (dr.Read())
                {
                    txtStartDate.Text = Convert.ToDateTime(dr["start_date"]).ToString("yyyy-MM-dd");
                    txtEndDate.Text = Convert.ToDateTime(dr["end_date"]).ToString("yyyy-MM-dd");
                    btnSavePeriod.Text = "تحديث البيانات";
                    hfShowModal.Value = "1";
                }
            }
        }

        protected void btnAddNew_Click(object sender, EventArgs e)
        {
            ViewState["EditPeriodId"] = null;
            txtStartDate.Text = "";
            txtEndDate.Text = "";
            btnSavePeriod.Text = "تأكيد الإنشاء";

            hfShowModal.Value = "1";
        }


        private void ShowAlert(string msg)
        {
            ScriptManager.RegisterStartupScript(upPeriods, upPeriods.GetType(), "alert", $"alert('{msg}');", true);
        }

        protected void btnToggleStatus_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            long periodId = Convert.ToInt64(btn.CommandArgument);
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "UPDATE fiscal_periods SET is_closed = CASE WHEN is_closed = 1 THEN 0 ELSE 1 END WHERE id = @id";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@id", periodId);
                conn.Open(); cmd.ExecuteNonQuery();
            }
            LoadPeriods();
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            string periodId = btn.CommandArgument;
            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                string checkQuery = "SELECT COUNT(*) FROM journal_entries WHERE id = @id";
                SqlCommand checkCmd = new SqlCommand(checkQuery, conn);
                checkCmd.Parameters.AddWithValue("@id", periodId);
                if ((int)checkCmd.ExecuteScalar() > 0)
                {
                    ShowAlert("لا يمكن حذف الفترة لوجود قيود محاسبية!");
                    return;
                }
                string deleteQuery = "DELETE FROM fiscal_periods WHERE id = @id";
                SqlCommand delCmd = new SqlCommand(deleteQuery, conn);
                delCmd.Parameters.AddWithValue("@id", periodId);
                delCmd.ExecuteNonQuery();
            }
            LoadPeriods();
        }

        private void UpdateFiscalYearLabel(string companyId)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT YEAR(fiscal_year_start) FROM companies WHERE id = @companyId";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@companyId", companyId);
                conn.Open();
                object result = cmd.ExecuteScalar();
                if (result != null && result != DBNull.Value) lblFiscalYear.Text = result.ToString();
            }
        }

        private void UpdateCompanyHeader(string companyId)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT name FROM companies WHERE id = @companyId";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@companyId", companyId);
                conn.Open();
                object result = cmd.ExecuteScalar();
                if (result != null) lblCompanyName.Text = result.ToString();
            }
        }

        private void UpdateLastClosedDate(string companyId)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT TOP 1 end_date FROM fiscal_periods WHERE company_id = @companyId AND is_closed = 1 ORDER BY end_date DESC";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@companyId", companyId);
                conn.Open();
                object result = cmd.ExecuteScalar();
                lblLastClosedDate.Text = (result != null && result != DBNull.Value) ? Convert.ToDateTime(result).ToString("yyyy/MM/dd") : "لا يوجد إغلاق";
            }
        }

        private void UpdateOpenPeriodsCount(string companyId)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT COUNT(*) FROM fiscal_periods WHERE company_id = @companyId AND is_closed = 0";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@companyId", companyId);
                conn.Open();
                lblOpenPeriodsCount.Text = ((int)cmd.ExecuteScalar()).ToString("D2");
            }
        }
    }
}