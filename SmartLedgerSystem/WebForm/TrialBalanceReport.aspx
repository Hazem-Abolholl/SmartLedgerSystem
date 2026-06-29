<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TrialBalanceReport.aspx.cs" Inherits="SmartLedgerSystem.WebForm.TrialBalanceReport" %>

<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head runat="server">
    <title>ميزان المراجعة | Smart Ledger</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.rtl.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" />
    <style>
        :root { --primary-color: #0f172a; --accent-color: #3b82f6; --border-color: #e2e8f0; }
        body { background-color: #f1f5f9; font-family: 'Segoe UI', Tahoma, sans-serif; font-size: 0.85rem; }
        
        
        .report-card { 
            background: #fff; padding: 35px; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); 
            margin: 20px auto; max-width: 1200px; border: 1px solid var(--border-color);
        }
        .header-line { border-top: 4px solid var(--primary-color); padding-top: 20px; margin-bottom: 25px; }
        .filter-box { background: #fff; border-radius: 10px; padding: 20px; border: 1px solid var(--border-color); }
        
        .table thead th { background: #f8fafc; color: var(--primary-color); border-bottom: 2px solid #cbd5e1; padding: 12px; }
        .table tbody td { vertical-align: middle; padding: 10px; }
        
        .total-row { background-color: #f8fafc; font-weight: bold; border-top: 2px solid var(--primary-color) !important; }
        .balance-cell { background-color: #f0f7ff; font-weight: bold; }

        @media print { 
            .no-print { display: none !important; } 
            .report-card { box-shadow: none; border: none; margin: 0; padding: 0; } 
        }
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
                        <asp:LinkButton ID="btnSearch" runat="server" CssClass="btn btn-sm btn-primary px-4" OnClick="btnSearch_Click">
                            <i class="fas fa-sync-alt me-1"></i> تحديث الميزان
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
                        <p class="text-muted mb-0 small">تقرير ميزان المراجعة بالمجاميع والأرصدة</p>
                    </div>
                    <div class="col-md-6 text-md-start">
                        <div class="badge bg-primary fs-6">الفترة: <asp:Literal ID="litFrom" runat="server" /> - <asp:Literal ID="litTo" runat="server" /></div>
                    </div>
                </div>
            </div>

            <div class="table-responsive">
                <table class="table table-bordered table-hover text-center">
                    <thead>
                        <tr>
                            <th class="text-start">كود الحساب</th>
                            <th class="text-start">اسم الحساب</th>
                            <th>نوع الحساب</th>
                            <th>إجمالي المدين (+)</th>
                            <th>إجمالي الدائن (-)</th>
                            <th class="balance-cell">الرصيد النهائي</th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="rptTrialBalance" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td class="text-start fw-bold text-secondary"><%# Eval("AccountCode") %></td>
                                    <td class="text-start"><%# Eval("AccountName") %></td>
                                    <td><span class="badge bg-light text-dark border"><%# Eval("AccountType") %></span></td>
                                    <td class="text-primary fw-bold"><%# Eval("TotalDebit", "{0:N2}") %></td>
                                    <td class="text-danger fw-bold"><%# Eval("TotalCredit", "{0:N2}") %></td>
                                    <td class="balance-cell"><%# Eval("FinalBalance", "{0:N2}") %></td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                    <tfoot>
                        <tr class="total-row">
                            <td colspan="3" class="text-start py-3">إجمالي الحركات والأرصدة</td>
                            <td class="text-primary"><asp:Literal ID="litSumDebit" runat="server" /></td>
                            <td class="text-danger"><asp:Literal ID="litSumCredit" runat="server" /></td>
                            <td class="balance-cell text-dark"><asp:Literal ID="litSumFinal" runat="server" /></td>
                        </tr>
                    </tfoot>
                </table>
            </div>
            
            <div class="mt-4 pt-3 border-top d-flex justify-content-between text-muted small">
                <span>تاريخ الاستخراج: <asp:Literal ID="litPrintTime" runat="server" /></span>
                <span>المستخدم: <asp:Literal ID="litUser" runat="server" /></span>
            </div>
        </div>
    </form>
</body>
</html>