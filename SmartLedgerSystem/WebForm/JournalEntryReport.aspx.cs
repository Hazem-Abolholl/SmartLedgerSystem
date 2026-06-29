using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace SmartLedgerSystem.WebForm
{
    public partial class JournalEntryReport : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["SmartLedgerConn"].ConnectionString;
        decimal totalDebit = 0;
        decimal totalCredit = 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string entryId = Request.QueryString["id"];
                if (!string.IsNullOrEmpty(entryId))
                {
                    LoadReportData(entryId);

                    string currencyName = " دينار ليبي";
                    litTotalText.Text = ToWord.ConvertToArabic(totalDebit) + " " + currencyName + " فقط لا غير";
                    litPrintTime.Text = DateTime.Now.ToString("yyyy/MM/dd HH:mm");
                }
            }
        }

        private void LoadReportData(string entryId)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();

                string headerSql = @"
                    SELECT 
                        j.*, 
                        c.name as CompanyName, 
                        c.currency, 
                        t.name_ar as TypeName,
                        u.name as CreatorName  -- جلب اسم المستخدم من جدول users
                    FROM journal_entries j
                    LEFT JOIN companies c ON j.company_id = c.id
                    LEFT JOIN journal_types t ON j.journal_type_id = t.id
                    LEFT JOIN users u ON j.created_by = u.id  -- الربط مع جدول المستخدمين
                    WHERE j.id = @id";

                SqlCommand cmdHeader = new SqlCommand(headerSql, conn);
                cmdHeader.Parameters.AddWithValue("@id", entryId);
                SqlDataReader dr = cmdHeader.ExecuteReader();

                if (dr.Read())
                {
                    litCompanyName.Text = dr["CompanyName"]?.ToString() ?? "الشركة العالمية";
                    litCurrency.Text = dr["currency"]?.ToString() ?? "دينار";
                    litTypeName.Text = dr["TypeName"]?.ToString() ?? "قيد عام";
                    litEntryId.Text = dr["id"].ToString();
                    litEntryDate.Text = Convert.ToDateTime(dr["entry_date"]).ToString("yyyy/MM/dd");
                    litReference.Text = dr["reference"]?.ToString();
                    litDescription.Text = dr["description"]?.ToString();

                    bool isPosted = Convert.ToBoolean(dr["posted"]);
                    litStatus.Text = isPosted ? "مرحل" : "غير مرحل";
                    stampPosted.Visible = isPosted;

                    string userName = dr["CreatorName"]?.ToString() ?? "غير محدد";
                    litCreatedBy.Text = userName;  // حقل "المستخدم" في شبكة البيانات
                    Literal1.Text = userName;      // حقل "طبع بواسطة" في أسفل الصفحة
                }
                dr.Close();

                string linesSql = @"
                    SELECT 
                        l.debit, 
                        l.credit, 
                        l.line_description,
                        a.code as AccountCode, 
                        a.name as AccountName, 
                        cc.name as CostCenterName
                    FROM journal_lines l
                    INNER JOIN accounts a ON l.account_id = a.id
                    LEFT JOIN cost_centers cc ON l.cost_center_id = cc.id
                    WHERE l.journal_entry_id = @id
                    ORDER BY l.line_index";

                SqlDataAdapter da = new SqlDataAdapter(linesSql, conn);
                da.SelectCommand.Parameters.AddWithValue("@id", entryId);
                DataTable dtLines = new DataTable();
                da.Fill(dtLines);

                // ربط البيانات بالـ Repeater
                rptLines.DataSource = dtLines;
                rptLines.DataBind();

                // 3. حساب الإجماليات
                totalDebit = 0;
                totalCredit = 0;
                foreach (DataRow row in dtLines.Rows)
                {
                    totalDebit += Convert.ToDecimal(row["debit"]);
                    totalCredit += Convert.ToDecimal(row["credit"]);
                }

                litTotalDebit.Text = totalDebit.ToString("N2");
                litTotalCredit.Text = totalCredit.ToString("N2");
            }
        }

        public static class ToWord
        {
            private static string[] ones = { "", "واحد", "اثنان", "ثلاثة", "أربعة", "خمسة", "ستة", "سبعة", "ثمانية", "تسعة" };
            private static string[] tens = { "", "عشرة", "عشرون", "ثلاثون", "أربعون", "خمسون", "ستون", "سبعون", "ثمانون", "تسعون" };
            private static string[] hundreds = { "", "مائة", "مائتان", "ثلاثمائة", "أربعمائة", "خمسمائة", "ستمائة", "سبعمائة", "ثمانمائة", "تسعمائة" };

            public static string ConvertToArabic(decimal number)
            {
                if (number == 0) return "صفر";
                if (number < 0) return "سالب " + ConvertToArabic(Math.Abs(number));

                string word = "";
                long intPart = (long)number;
                int fraction = (int)((number - intPart) * 100);

                if (intPart > 0) word = ProcessGroup(intPart);

                if (fraction > 0)
                {
                    word += " و " + ProcessGroup(fraction) + " قرشاً";
                }

                return word;
            }

            private static string ProcessGroup(long n)
            {
                if (n == 0) return "";
                if (n < 10) return ones[n];
                if (n < 20)
                {
                    if (n == 10) return "عشرة";
                    if (n == 11) return "أحد عشر";
                    if (n == 12) return "اثنا عشر";
                    return ones[n % 10] + " عشر";
                }
                if (n < 100) return tens[n / 10] + (n % 10 != 0 ? " و " + ones[n % 10] : "");
                if (n < 1000) return hundreds[n / 100] + (n % 100 != 0 ? " و " + ProcessGroup(n % 100) : "");
                if (n < 1000000) return ProcessGroup(n / 1000) + " ألف" + (n % 1000 != 0 ? " و " + ProcessGroup(n % 1000) : "");

                return n.ToString();
            }
        }
    }
}