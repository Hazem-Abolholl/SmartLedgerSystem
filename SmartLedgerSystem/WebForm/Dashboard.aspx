<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="SmartLedgerSystem.WebForm.Dashboard" %>

<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head runat="server">
    <title>لوحة التحكم | Smart Ledger</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.rtl.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" />
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        :root {
            --primary-dark: #0f172a;
            --accent-blue: #2563eb;
            --sidebar-hover: #1e293b;
            --card-shadow: 0 10px 25px -5px rgba(0,0,0,0.05);
        }
        body { background-color: #f8fafc; font-family: 'Segoe UI', Tahoma, sans-serif; margin: 0; }
        .wrapper { display: flex; width: 100%; align-items: stretch; }
        
        #sidebar { min-width: 270px; max-width: 270px; background: var(--primary-dark); color: #fff; min-height: 100vh; position: sticky; top: 0; box-shadow: 4px 0 15px rgba(0,0,0,0.1); z-index: 1000; }
        #sidebar .sidebar-header { padding: 30px 20px; background: #1e293b; text-align: center; border-bottom: 1px solid #334155; }
        #sidebar ul li a { padding: 14px 25px; display: block; color: #94a3b8; text-decoration: none; transition: 0.3s; font-size: 0.95rem; border-right: 4px solid transparent; }
        #sidebar ul li a:hover { background: var(--sidebar-hover); color: #fff; border-right-color: var(--accent-blue); padding-right: 30px; }
        #sidebar ul li a i { margin-left: 12px; width: 20px; text-align: center; }
        
        #content { width: 100%; padding: 35px; }
        .welcome-box { 
            background: white; padding: 30px; border-radius: 20px; 
            box-shadow: var(--card-shadow); margin-bottom: 30px; 
            border-right: 8px solid var(--accent-blue);
        }

        .stat-card { border: none; border-radius: 20px; transition: all 0.4s ease; position: relative; overflow: hidden; color: white; padding: 25px; height: 100%; }
        .stat-card:hover { transform: translateY(-8px); box-shadow: 0 15px 30px rgba(0,0,0,0.15); }
        .card-icon { font-size: 3.5rem; opacity: 0.25; position: absolute; left: -10px; bottom: -10px; transform: rotate(-15deg); }
        
        .quick-action-btn { 
            background: white; border: 1px solid #e2e8f0; border-radius: 18px; padding: 20px 10px; 
            transition: all 0.3s ease; text-decoration: none !important; color: #1e293b; 
            text-align: center; display: flex; flex-direction: column; align-items: center; justify-content: center;
            height: 100%;
        }
        .quick-action-btn i { font-size: 2rem; margin-bottom: 12px; }
        .quick-action-btn:hover { border-color: var(--accent-blue); transform: translateY(-5px); box-shadow: 0 8px 15px rgba(0,0,0,0.05); color: var(--accent-blue); }

        .report-card { background: #fdfdfd; border-right: 4px solid #f59e0b !important; }
        .collapse.show { background: #0a0f1d; }
        .section-title { font-size: 1.1rem; font-weight: 700; color: #334155; margin-bottom: 20px; display: flex; align-items: center; }
        .section-title i { margin-left: 10px; }
        .chart-card { background: white; border-radius: 24px; padding: 25px; box-shadow: var(--card-shadow); margin-bottom: 30px; border: 1px solid #edf2f7; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="wrapper">
            <nav id="sidebar">
                <div class="sidebar-header">
                    <h4 class="mb-0 fw-bold"><i class="fas fa-calculator me-2 text-primary"></i> المحاسب الذكي</h4>
                    <small class="text-muted">Smart Ledger v3.0</small>
                </div>
                <ul class="list-unstyled components mt-3">
                    <li><a href="Dashboard.aspx"><i class="fas fa-th-large"></i> الرئيسية</a></li>
                    <li><a href="AccountsTree.aspx"><i class="fas fa-sitemap"></i> شجرة الحسابات</a></li>
                    <li><a href="Companies.aspx"><i class="fas fa-building"></i> إدارة الشركات</a></li>
                    <li><a href="JournalTypes.aspx"><i class="fas fa-tags"></i> إدارة أنواع القيود</a></li>
                    <li><a href="CostCenters.aspx"><i class="fas fa-chart-pie"></i> مراكز التكلفة</a></li>
                    <li><a href="BankManagement.aspx"><i class="fas fa-university"></i> إدارة البنوك</a></li>
                    <li><a href="JournalEntries.aspx"><i class="fas fa-exchange-alt"></i> القيود اليومية</a></li>
                    <li><a href="FiscalPeriods.aspx"><i class="fas fa-calendar-alt"></i> الفترات المالية</a></li>
                    
                    <li class="nav-item">
                        <a href="#reportsSubmenu" data-bs-toggle="collapse" aria-expanded="false" class="dropdown-toggle">
                            <i class="fas fa-chart-line"></i> التقارير المالية
                        </a>
                        <ul class="collapse list-unstyled" id="reportsSubmenu">
                            <li><a href="AccountStatement.aspx" class="ps-5 small text-warning fw-bold"><i class="fas fa-file-invoice-dollar me-2"></i>كشف حساب تفصيلي</a></li>
                            <li><a href="IncomeStatement.aspx" class="ps-5 small"><i class="fas fa-chart-bar me-2"></i>تقرير قائمة الدخل</a></li>
                            <li><a href="TrialBalanceReport.aspx" class="ps-5 small text-info fw-bold"><i class="fas fa-balance-scale me-2"></i>ميزان المراجعة</a></li>
                            <li><a href="AuditTrailReport.aspx" class="ps-5 small text-success"><i class="fas fa-history me-2"></i>سجل العمليات</a></li>
                        </ul>
                    </li>
                    
                    <li class="mt-5">
                        <asp:LinkButton ID="btnLogout" runat="server" OnClick="btnLogout_Click" CssClass="text-danger ps-4">
                            <i class="fas fa-power-off"></i> تسجيل الخروج
                        </asp:LinkButton>
                    </li>
                </ul>
            </nav>

            <div id="content">
                <div class="welcome-box">
                    <div class="row align-items-center">
                        <div class="col-md-7">
                            <h3 class="fw-bold text-dark">أهلاً بك، <asp:Label ID="lblUserName" runat="server"></asp:Label> 👋</h3>
                            <p class="text-muted mb-0">نظام المحاسبة الذكي - ابدأ باختيار الشركة التي تود العمل عليها.</p>
                        </div>
                        <div class="col-md-5 mt-3 mt-md-0">
                            <div class="p-3 bg-light rounded-4 border shadow-sm">
                                <label class="small fw-bold mb-2 d-block text-primary"><i class="fas fa-check-circle"></i> الشركة النشطة حالياً:</label>
                                <asp:DropDownList ID="ddlActiveCompanies" runat="server" CssClass="form-select border-0 bg-transparent fw-bold" AutoPostBack="true" OnSelectedIndexChanged="ddlActiveCompanies_SelectedIndexChanged">
                                </asp:DropDownList>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row g-4 mb-4">
                    <div class="col-md-2">
                        <div class="stat-card shadow-sm" style="background: linear-gradient(135deg, #4f46e5, #3730a3);">
                            <h6 class="text-uppercase small opacity-75">الشركات</h6>
                            <h2 class="fw-bold mb-0"><asp:Label ID="lblCountCompanies" runat="server" Text="0"></asp:Label></h2>
                            <i class="fas fa-city card-icon"></i>
                        </div>
                    </div>
                    <div class="col-md-2">
                        <div class="stat-card shadow-sm" style="background: linear-gradient(135deg, #10b981, #065f46);">
                            <h6 class="text-uppercase small opacity-75">الحسابات</h6>
                            <h2 class="fw-bold mb-0"><asp:Label ID="lblCountAccounts" runat="server" Text="0"></asp:Label></h2>
                            <i class="fas fa-network-wired card-icon"></i>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card shadow-sm" style="background: linear-gradient(135deg, #f59e0b, #b45309);">
                            <h6 class="text-uppercase small opacity-75 fw-bold text-dark">البنوك المربوطة</h6>
                            <h2 class="fw-bold mb-0 text-dark"><asp:Label ID="lblBankAccountsCount" runat="server" Text="0"></asp:Label></h2>
                            <i class="fas fa-university card-icon"></i>
                        </div>
                    </div>
                    <div class="col-md-2">
                        <div class="stat-card shadow-sm" style="background: linear-gradient(135deg, #ef4444, #991b1b);">
                            <h6 class="text-uppercase small opacity-75">مراكز التكلفة</h6>
                            <h2 class="fw-bold mb-0"><asp:Label ID="lblCountCostCenters" runat="server" Text="0"></asp:Label></h2>
                            <i class="fas fa-layer-group card-icon"></i>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card shadow-sm" style="background: linear-gradient(135deg, #1e293b, #0f172a);">
                            <h6 class="text-uppercase small opacity-75">قيود معلقة</h6>
                            <h2 class="fw-bold mb-0"><asp:Label ID="lblUnpostedEntries" runat="server" Text="0"></asp:Label></h2>
                            <i class="fas fa-file-invoice card-icon"></i>
                        </div>
                    </div>
                </div>

               <%-- <div class="chart-card">
                    <div class="section-title"><i class="fas fa-chart-area text-primary"></i> تحليل نشاط القيود والعمليات</div>
                    <div style="height: 250px; position: relative;">
                        <canvas id="myChart"></canvas>
                    </div>
                </div>--%>

                <div class="row g-4">
                    <div class="col-lg-7">
                        <div class="card border-0 shadow-sm p-4 h-100" style="border-radius:24px;">
                            <div class="section-title"><i class="fas fa-bolt text-warning"></i> إجراءات النظام</div>
                            <div class="row g-3">
                                <div class="col-md-4">
                                    <a href="AccountsTree.aspx" class="quick-action-btn">
                                        <i class="fas fa-folder-plus text-primary"></i>
                                        <span class="fw-bold small">دليل الحسابات</span>
                                    </a>
                                </div>
                                <div class="col-md-4">
                                    <a href="JournalEntries.aspx" class="quick-action-btn">
                                        <i class="fas fa-tasks text-success"></i>
                                        <span class="fw-bold small">إدارة القيود</span>
                                    </a>
                                </div>
                                <div class="col-md-4">
                                    <a href="BankManagement.aspx" class="quick-action-btn">
                                        <i class="fas fa-university text-warning"></i>
                                        <span class="fw-bold small">إدارة البنوك</span>
                                    </a>
                                </div>
                                <div class="col-md-4">
                                    <a href="CostCenters.aspx" class="quick-action-btn">
                                        <i class="fas fa-chart-pie text-danger"></i>
                                        <span class="fw-bold small">مراكز التكلفة</span>
                                    </a>
                                </div>
                                <div class="col-md-4">
                                    <a href="FiscalPeriods.aspx" class="quick-action-btn">
                                        <i class="fas fa-clock-rotate-left text-info"></i>
                                        <span class="fw-bold small">إغلاق الفترات</span>
                                    </a>
                                </div>
                                <div class="col-md-4">
                                    <a href="Companies.aspx" class="quick-action-btn">
                                        <i class="fas fa-building text-secondary"></i>
                                        <span class="fw-bold small">الشركات</span>
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-lg-5">
                        <div class="card border-0 shadow-sm p-4 h-100" style="border-radius:24px;">
                            <div class="section-title"><i class="fas fa-file-contract text-primary"></i> التقارير السريعة</div>
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <a href="TrialBalanceReport.aspx" class="quick-action-btn report-card">
                                        <i class="fas fa-balance-scale text-info"></i>
                                        <span class="fw-bold small">ميزان المراجعة</span>
                                    </a>
                                </div>
                                <div class="col-md-6">
                                    <a href="AccountStatement.aspx" class="quick-action-btn report-card">
                                        <i class="fas fa-file-invoice-dollar text-warning"></i>
                                        <span class="fw-bold small">كشف الحساب</span>
                                    </a>
                                </div>
                                <div class="col-md-6">
                                    <a href="IncomeStatement.aspx" class="quick-action-btn report-card">
                                        <i class="fas fa-chart-line text-primary"></i>
                                        <span class="fw-bold small">قائمة الدخل</span>
                                    </a>
                                </div>
                                <div class="col-md-6">
                                    <a href="AuditTrailReport.aspx" class="quick-action-btn report-card">
                                        <i class="fas fa-shield-alt text-success"></i>
                                        <span class="fw-bold small">سجل العمليات</span>
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>

    <%--<script>
        document.addEventListener('DOMContentLoaded', function () {
            const ctx = document.getElementById('myChart').getContext('2d');

            // جلب البيانات من السيرفر
            const labels = [<%= ChartDataLabels %>];
            const dataValues = [<%= ChartDataValues %>];

            const myChart = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: labels.length > 0 ? labels : ['لا توجد بيانات'],
                    datasets: [{
                        label: 'عدد القيود اليومية',
                        data: dataValues.length > 0 ? dataValues : [0],
                        backgroundColor: 'rgba(37, 99, 235, 0.1)',
                        borderColor: '#2563eb',
                        borderWidth: 3,
                        tension: 0.4,
                        fill: true,
                        pointBackgroundColor: '#fff',
                        pointBorderColor: '#2563eb',
                        pointBorderWidth: 2,
                        pointRadius: 5
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { display: false }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            ticks: { stepSize: 1 },
                            grid: { borderDash: [5, 5], color: '#e2e8f0' }
                        },
                        x: {
                            grid: { display: false }
                        }
                    }
                }
            });
        });
    </script>--%>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>