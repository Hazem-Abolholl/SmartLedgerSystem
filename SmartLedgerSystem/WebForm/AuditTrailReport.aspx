<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AuditTrailReport.aspx.cs" Inherits="SmartLedgerSystem.WebForm.AuditTrailReport" %>

<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head runat="server">
    <title>سجل العمليات | Smart Ledger</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.rtl.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" />
    <style>
        :root { --primary-color: #0f172a; --audit-accent: #6366f1; --border-color: #e2e8f0; }
        body { background-color: #f1f5f9; font-family: 'Segoe UI', Tahoma, sans-serif; font-size: 0.85rem; }
        
        .report-card { 
            background: #fff; padding: 35px; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); 
            margin: 20px auto; max-width: 1250px; border: 1px solid var(--border-color);
        }
        .header-line { border-top: 4px solid var(--audit-accent); padding-top: 20px; margin-bottom: 25px; }
        
        /* تلوين الصفوف بناءً على نوع العملية */
        .action-badge { padding: 5px 10px; border-radius: 6px; font-weight: 600; font-size: 0.75rem; }
        .bg-post { background-color: #dcfce7; color: #166534; } /* ترحيل */
        .bg-error { background-color: #fee2e2; color: #991b1b; } /* خطأ */
        .bg-warning { background-color: #fef9c3; color: #854d0e; } /* تنبيه ميزانية */
        
        .log-data { max-width: 300px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; cursor: help; }
        .table thead th { background: #f8fafc; color: var(--primary-color); border-bottom: 2px solid var(--audit-accent); }

        @media print { .no-print { display: none !important; } .report-card { box-shadow: none; border: none; margin: 0; padding: 10px; width: 100%; } }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container no-print mt-4">
            <div class="bg-white p-3 rounded shadow-sm mb-4 border">
                <div class="row g-2 align-items-end">
                    <div class="col-md-3">
                        <label class="small fw-bold">المستخدم:</label>
                        <asp:DropDownList ID="ddlUsers" runat="server" CssClass="form-select form-select-sm"></asp:DropDownList>
                    </div>
                    <div class="col-md-3">
                        <label class="small fw-bold">الفترة من:</label>
                        <asp:TextBox ID="txtFromDate" runat="server" TextMode="DateTimeLocal" CssClass="form-control form-control-sm"></asp:TextBox>
                    </div>
                    <div class="col-md-3">
                        <label class="small fw-bold">إلى:</label>
                        <asp:TextBox ID="txtToDate" runat="server" TextMode="DateTimeLocal" CssClass="form-control form-control-sm"></asp:TextBox>
                    </div>
                    <div class="col-md-3 text-start">
                        <asp:LinkButton ID="btnSearch" runat="server" CssClass="btn btn-sm btn-primary px-3" OnClick="btnSearch_Click">
                            <i class="fas fa-shield-alt me-1"></i> فحص السجلات
                        </asp:LinkButton>
                        <button type="button" class="btn btn-sm btn-dark" onclick="window.print();"><i class="fas fa-print"></i></button>
                    </div>
                </div>
            </div>
        </div>

        <div class="report-card">
            <div class="header-line">
                <div class="row align-items-center">
                    <div class="col-6">
                        <h4 class="fw-bold mb-0"><i class="fas fa-fingerprint text-accent me-2"></i>سجل الرقابة والعمليات</h4>
                        <p class="text-muted mb-0 small">Audit Trail - من فعل ماذا ومتى؟</p>
                    </div>
                    <div class="col-6 text-start">
                        <span class="text-muted small">شركة: </span>
                        <span class="fw-bold text-primary"><asp:Literal ID="litCompanyName" runat="server" /></span>
                    </div>
                </div>
            </div>

            <div class="table-responsive">
                <table class="table table-hover align-middle border">
                    <thead>
                        <tr>
                            <th>التوقيت</th>
                            <th>المستخدم</th>
                            <th>العملية</th>
                            <th>الجدول</th>
                            <th>رقم السجل</th>
                            <th>التفاصيل / رسالة النظام</th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="rptLogs" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td class="text-muted small fw-bold"><%# Eval("created_at", "{0:yyyy/MM/dd HH:mm:ss}") %></td>
                                    <td>
                                        <div class="d-flex align-items-center">
                                            <div class="rounded-circle bg-light p-2 me-2 text-center" style="width:30px; height:30px; line-height:15px;">
                                                <i class="fas fa-user small"></i>
                                            </div>
                                            <%# Eval("UserName") %>
                                        </div>
                                    </td>
                                    <td>
                                        <span class='<%# GetActionClass(Eval("action").ToString()) %>'>
                                            <%# GetActionIcon(Eval("action").ToString()) %> <%# Eval("action") %>
                                        </span>
                                    </td>
                                    <td class="text-secondary small font-monospace"><%# Eval("table_name") %></td>
                                    <td class="fw-bold">#<%# Eval("record_id") %></td>
                                    <td class="small text-muted">
                                        <div class="log-data" title='<%# Eval("new_data") %>'>
                                            <%# Eval("new_data") %>
                                        </div>
                                    </td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
            </div>
        </div>
    </form>
</body>
</html>