<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="IncomeStatement.aspx.cs" Inherits="SmartLedgerSystem.WebForm.IncomeStatement" %>

<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head runat="server">
    <title>قائمة الدخل | Smart Ledger</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.rtl.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" />
    <style>
        :root { --primary-color: #0f172a; --accent-color: #3b82f6; --revenue-color: #10b981; --expense-color: #ef4444; --border-color: #e2e8f0; }
        body { background-color: #f1f5f9; font-family: 'Segoe UI', Tahoma, sans-serif; font-size: 0.85rem; }
        
        .report-card { 
            background: #fff; padding: 40px; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); 
            margin: 20px auto; max-width: 1000px; border: 1px solid var(--border-color);
        }
        .header-line { border-top: 4px solid var(--primary-color); padding-top: 20px; margin-bottom: 25px; }
        .filter-box { background: #fff; border-radius: 10px; padding: 20px; border: 1px solid var(--border-color); }
        
        .section-header { 
            display: flex; justify-content: space-between; align-items: center;
            background: #f8fafc; padding: 12px 20px; border-radius: 8px; margin-bottom: 15px; border-right: 4px solid var(--primary-color);
        }
        
        .amount-cell { font-family: 'Consolas', monospace; font-weight: 700; font-size: 1.1rem; }
        
        /* صندوق صافي الربح المودرن */
        .net-profit-box { 
            background: var(--primary-color); color: white; border-radius: 12px; padding: 25px;
            margin-top: 30px; display: flex; justify-content: space-between; align-items: center;
            transition: 0.3s;
        }
        .net-profit-box:hover { transform: scale(1.01); box-shadow: 0 10px 15px -3px rgba(0,0,0,0.2); }

        .table td { padding: 12px; vertical-align: middle; border-bottom: 1px solid #f1f5f9; }
        
        @media print { .no-print { display: none !important; } .report-card { box-shadow: none; border: none; margin: 0; padding: 20px; width: 100%; } }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container no-print mt-4">
            <div class="filter-box shadow-sm mb-4">
                <div class="row g-3 align-items-end">
                    <div class="col-md-3">
                        <label class="small fw-bold">من تاريخ:</label>
                        <asp:TextBox ID="txtFromDate" runat="server" TextMode="Date" CssClass="form-control form-control-sm"></asp:TextBox>
                    </div>
                    <div class="col-md-3">
                        <label class="small fw-bold">إلى تاريخ:</label>
                        <asp:TextBox ID="txtToDate" runat="server" TextMode="Date" CssClass="form-control form-control-sm"></asp:TextBox>
                    </div>
                    <div class="col-md-6 text-md-start">
                        <asp:LinkButton ID="btnRefresh" runat="server" CssClass="btn btn-sm btn-primary px-4" OnClick="btnRefresh_Click">
                            <i class="fas fa-sync-alt me-1"></i> تحديث القائمة
                        </asp:LinkButton>
                        <button type="button" class="btn btn-sm btn-dark px-4" onclick="window.print();">
                            <i class="fas fa-print me-1"></i> طباعة
                        </button>
                        <asp:HyperLink NavigateUrl="Dashboard.aspx" runat="server" CssClass="btn btn-sm btn-outline-secondary">إغلاق</asp:HyperLink>
                    </div>
                </div>
            </div>
        </div>

        <div class="report-card">
            <div class="header-line">
                <div class="row align-items-center">
                    <div class="col-md-6">
                        <h4 class="fw-bold mb-0 text-primary"><asp:Literal ID="litCompanyName" runat="server" /></h4>
                        <p class="text-muted mb-0">تقرير قائمة الدخل (الأرباح والخسائر)</p>
                    </div>
                    <div class="col-md-6 text-md-start">
                        <div class="badge bg-primary fs-6">الفترة: <asp:Literal ID="litFrom" runat="server" /> - <asp:Literal ID="litTo" runat="server" /></div>
                    </div>
                </div>
            </div>

            <div class="section-header mt-4" style="border-right-color: var(--revenue-color);">
                <h6 class="text-success fw-bold mb-0"><i class="fas fa-chart-line me-2"></i> الإيرادات (Revenues)</h6>
            </div>
            <div class="table-responsive">
                <table class="table table-hover mb-4">
                    <tbody>
                        <asp:Repeater ID="rptRevenues" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td class="text-muted small" style="width: 15%"><%# Eval("code") %></td>
                                    <td class="fw-semibold"><%# Eval("name") %></td>
                                    <td class="text-start amount-cell text-success"><%# Eval("TotalAmount", "{0:N2}") %></td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
            </div>

            <div class="section-header mt-4" style="border-right-color: var(--expense-color);">
                <h6 class="text-danger fw-bold mb-0"><i class="fas fa-file-invoice-dollar me-2"></i> المصروفات (Expenses)</h6>
            </div>
            <div class="table-responsive">
                <table class="table table-hover mb-4">
                    <tbody>
                        <asp:Repeater ID="rptExpenses" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td class="text-muted small" style="width: 15%"><%# Eval("code") %></td>
                                    <td class="fw-semibold"><%# Eval("name") %></td>
                                    <td class="text-start amount-cell text-danger">(<%# Eval("TotalAmount", "{0:N2}") %>)</td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
            </div>

            <div class="net-profit-box shadow-sm">
                <div>
                    <h4 class="mb-0 fw-bold">صافي الربح / الخسارة</h4>
                    <span class="opacity-75 small">Net Income / Loss Analysis</span>
                </div>
                <div class="text-start">
                    <h2 class="mb-0 fw-bold amount-cell">
                        <asp:Literal ID="litNetProfit" runat="server" />
                    </h2>
                    <span class="badge bg-white text-dark mt-2"><asp:Literal ID="litCurrency" runat="server" Text="SAR / ج.م" /></span>
                </div>
            </div>

            <div class="mt-5 pt-4 border-top">
                <div class="row text-center small text-muted fw-bold">
                    <div class="col-4 border-start">توقيع المحاسب</div>
                    <div class="col-4 border-start">المدير المالي</div>
                    <div class="col-4">ختم الشركة</div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>