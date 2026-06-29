<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ViewJournalEntry.aspx.cs" Inherits="SmartLedgerSystem.WebForm.ViewJournalEntry" %>

<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head runat="server">
    <title>تفاصيل القيد | Smart Ledger</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.rtl.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" />
    <style>
        :root { --primary-color: #1e293b; --accent-color: #3b82f6; --success-color: #10b981; --danger-color: #ef4444; }
        body { background-color: #f8fafc; font-family: 'Segoe UI', Tahoma, sans-serif; color: #334155; }
        
        .entry-card { border: none; border-radius: 16px; box-shadow: 0 4px 20px rgba(0,0,0,0.05); background: #fff; margin-bottom: 2rem; }
        
        /* الهيدر الأنيق */
        .entry-header { 
            background: var(--primary-color); 
            color: white; 
            padding: 2.5rem; 
            border-radius: 16px 16px 0 0;
            position: relative;
            overflow: hidden;
        }
        .entry-header::after {
            content: ""; position: absolute; top: 0; left: 0; right: 0; bottom: 0;
            background: linear-gradient(45deg, rgba(59, 130, 246, 0.1) 0%, transparent 100%);
        }

        /* الجدول المودرن */
        .table-custom { margin-bottom: 0; }
        .table-custom thead th { 
            background-color: #f1f5f9; 
            color: #64748b; 
            font-weight: 700; 
            text-transform: uppercase; 
            font-size: 0.8rem; 
            padding: 15px;
            border: none;
        }
        .table-custom tbody td { padding: 18px 15px; border-bottom: 1px solid #f1f5f9; vertical-align: middle; }
        
        /* الخلايا والأرقام */
        .amount-cell { font-family: 'JetBrains Mono', 'Consolas', monospace; font-weight: 700; font-size: 1rem; }
        .debit-text { color: var(--success-color); }
        .credit-text { color: var(--danger-color); }
        .cc-badge { background: #eff6ff; color: #2563eb; padding: 4px 10px; border-radius: 6px; font-size: 0.75rem; font-weight: 600; }
        .line-desc-text { color: #64748b; font-size: 0.85rem; display: block; margin-top: 4px; font-style: italic; }

        /* ملخص الإجماليات */
        .totals-section { background: #f8fafc; border-radius: 12px; padding: 20px; border: 1px solid #e2e8f0; }
        
        .status-badge { padding: 8px 20px; border-radius: 50px; font-size: 0.85rem; font-weight: 700; letter-spacing: 0.5px; }
        
        @media print {
            .no-print { display: none !important; }
            body { background: white; }
            .entry-card { box-shadow: none; border: 1px solid #eee; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container py-5">
            <div class="d-flex justify-content-between align-items-center mb-4 no-print">
                <a href="JournalEntries.aspx" class="btn btn-outline-secondary btn-sm px-3 rounded-pill">
                    <i class="fas fa-chevron-right me-2"></i>العودة للقيود
                </a>
                <div class="btn-group shadow-sm">
                    <button type="button" class="btn btn-white border px-4" onclick="window.print()">
                        <i class="fas fa-print me-2 text-primary"></i>طباعة القيد
                    </button>
                    <asp:LinkButton ID="btnEdit" runat="server" CssClass="btn btn-primary px-4" OnClick="btnEdit_Click">
                        <i class="fas fa-edit me-2"></i>تعديل
                    </asp:LinkButton>
                </div>
            </div>

            <div class="entry-card">
                <div class="entry-header">
                    <div class="row align-items-center">
                        <div class="col-md-7">
                            <span class="badge bg-info bg-opacity-25 text-info mb-2 px-3">سند قيد محاسبي</span>
                            <h2 class="mb-1 fw-bold text-white">رقم القيد: #<asp:Literal ID="litEntryId" runat="server" /></h2>
                            <div class="d-flex gap-4 mt-3 opacity-75">
                                <span><i class="far fa-calendar-alt me-1"></i> <asp:Literal ID="litDate" runat="server" /></span>
                                <span><i class="fas fa-hashtag me-1"></i> المرجع: <asp:Literal ID="litRef" runat="server" /></span>
                            </div>
                        </div>
                        <div class="col-md-5 text-md-end">
                            <asp:Label ID="lblStatus" runat="server" CssClass="status-badge" />
                        </div>
                    </div>
                </div>

                <div class="p-4 border-bottom">
                    <div class="row">
                        <div class="col-md-8">
                            <label class="text-muted small fw-bold text-uppercase d-block mb-1">البيان (الوصف العام)</label>
                            <h5 class="text-dark fw-semibold"><asp:Literal ID="litDescription" runat="server" /></h5>
                        </div>
                        <div class="col-md-4 text-md-end">
                            <label class="text-muted small fw-bold text-uppercase d-block mb-1">المحاسب المسؤول</label>
                            <span class="text-dark"><i class="fas fa-user-circle me-1 text-primary"></i> <asp:Literal ID="litCreatedBy" runat="server" /></span>
                        </div>
                    </div>
                </div>

                <div class="table-responsive">
                    <asp:GridView ID="gvLines" runat="server" CssClass="table table-custom align-middle" AutoGenerateColumns="False" GridLines="None">
                        <Columns>
                            <asp:TemplateField HeaderText="الحساب والوصف" HeaderStyle-CssClass="ps-4">
                                <ItemTemplate>
                                    <div class="ps-3">
                                        <div class="fw-bold text-dark"><%# Eval("AccountName") %></div>
                                        <div class="text-muted small"><%# Eval("AccountCode") %></div>
                                        <span class="line-desc-text"><%# Eval("line_description") %></span>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>
                            
                            <asp:TemplateField HeaderText="مركز التكلفة">
                                <ItemTemplate>
                                    <%# Eval("CostCenterName") != DBNull.Value ? 
                                        "<span class='cc-badge'><i class='fas fa-crosshairs me-1'></i>" + Eval("CostCenterName") + "</span>" : 
                                        "<span class='text-muted small'>---</span>" %>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="مدين" ItemStyle-CssClass="text-end">
                                <ItemTemplate>
                                    <span class='amount-cell <%# Convert.ToDecimal(Eval("debit")) > 0 ? "debit-text" : "text-muted opacity-25" %>'>
                                        <%# Eval("debit", "{0:N2}") %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="دائن" ItemStyle-CssClass="text-end pe-4">
                                <ItemTemplate>
                                    <span class='amount-cell <%# Convert.ToDecimal(Eval("credit")) > 0 ? "credit-text" : "text-muted opacity-25" %>'>
                                        <%# Eval("credit", "{0:N2}") %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>

                <div class="p-4 bg-light bg-opacity-50 rounded-bottom">
                    <div class="row align-items-center">
                        <div class="col-md-6">
                            <div class="small text-muted">
                                <i class="fas fa-info-circle me-1"></i> يتم عرض جميع المبالغ بالعملة المحلية للمنشأة.
                            </div>
                        </div>
                        <div class="col-md-5 offset-md-1">
                            <div class="totals-section shadow-sm">
                                <div class="d-flex justify-content-between mb-2">
                                    <span class="fw-bold text-secondary">إجمالي المدين</span>
                                    <span class="h5 mb-0 text-success fw-bold"><asp:Literal ID="litTotalDebit" runat="server" /></span>
                                </div>
                                <div class="d-flex justify-content-between">
                                    <span class="fw-bold text-secondary">إجمالي الدائن</span>
                                    <span class="h5 mb-0 text-danger fw-bold"><asp:Literal ID="litTotalCredit" runat="server" /></span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>