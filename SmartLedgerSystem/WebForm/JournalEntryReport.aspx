<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="JournalEntryReport.aspx.cs" Inherits="SmartLedgerSystem.WebForm.JournalEntryReport" %>

<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head runat="server">
    <title>تقرير قيد يومي | Smart Ledger</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.rtl.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" />
    <style>
        :root {
            --primary-color: #0f172a;
            --secondary-color: #64748b;
            --accent-blue: #2563eb;
            --accent-red: #dc2626;
            --light-bg: #f8fafc;
            --border-color: #e2e8f0;
        }

        body { 
            background-color: #f1f5f9; 
            font-family: 'Segoe UI', Tahoma, sans-serif; 
            color: #1e293b;
            font-size: 0.85rem; 
        }

        .report-container { 
            background: #fff; 
            padding: 40px; 
            border-radius: 8px; 
            box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1); 
            margin: 30px auto; 
            max-width: 1050px; 
            position: relative;
            border: 1px solid var(--border-color);
        }

        /* ختم الحالة */
        .posted-stamp {
            position: absolute;
            top: 100px;
            left: 60px;
            border: 3px solid #10b981;
            color: #10b981;
            padding: 4px 15px;
            font-size: 18px;
            font-weight: 800;
            transform: rotate(-12deg);
            border-radius: 8px;
            opacity: 0.25;
            z-index: 10;
        }

        /* الهيدر */
        .header-top { border-bottom: 2px solid var(--primary-color); padding-bottom: 15px; margin-bottom: 20px; }
        .company-name { font-size: 1.4rem; font-weight: 800; color: var(--primary-color); }
        
        .report-badge {
            background: var(--primary-color);
            color: white;
            padding: 8px 20px;
            border-radius: 4px;
            font-weight: 600;
        }

        /* شبكة البيانات - نمط السطر الواحد */
        .info-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 10px 20px;
            margin-bottom: 25px;
            background: var(--light-bg);
            padding: 15px;
            border-radius: 6px;
            border: 1px solid var(--border-color);
        }

        .info-item { 
            display: flex; 
            align-items: center; 
            gap: 8px; /* مسافة بين العنوان والقيمة */
        }
        
        .info-label { 
            font-size: 0.8rem; 
            color: var(--secondary-color); 
            font-weight: bold;
            white-space: nowrap;
        }
        
        .info-label::after { content: ":"; } /* إضافة النقطتين آلياً */

        .info-value { 
            font-size: 0.85rem; 
            font-weight: 600; 
            color: var(--primary-color); 
        }

        /* الجدول */
        .ledger-table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        .ledger-table thead th {
            background-color: #f8fafc;
            color: var(--primary-color);
            padding: 10px;
            font-size: 0.8rem;
            font-weight: 700;
            border-bottom: 2px solid var(--primary-color);
            border-top: 1px solid var(--border-color);
        }

        .ledger-table tbody td {
            padding: 10px 12px;
            border-bottom: 1px solid var(--border-color);
            font-size: 0.85rem;
        }

        /* دمج الكود مع الحساب */
        .account-cell {
            display: flex;
            align-items: center;
            gap: 5px;
        }
        .acc-code { color: var(--accent-blue); font-weight: bold; }
        .acc-separator { color: #cbd5e1; }

        .amount-cell {
            font-family: 'Consolas', monospace;
            font-weight: 700;
            width: 120px;
        }

        /* الإجماليات */
        .summary-wrapper {
            display: flex;
            justify-content: flex-end;
            gap: 15px;
            margin-top: 25px;
        }

        .summary-card {
            background: white;
            border: 1px solid var(--border-color);
            border-radius: 6px;
            padding: 10px 20px;
            min-width: 180px;
            text-align: center;
        }
        
        .debit-card { border-top: 4px solid var(--accent-blue); }
        .credit-card { border-top: 4px solid var(--accent-red); }

        .summary-card .label { font-size: 0.75rem; font-weight: bold; color: var(--secondary-color); margin-bottom: 5px; display: block; }
        .summary-card .value { font-size: 1.2rem; font-weight: 800; font-family: 'Consolas', monospace; }

        .amount-text-box {
            margin-top: 15px;
            padding: 10px;
            border-right: 3px solid var(--primary-color);
            background: #fdfdfd;
        }

        .signatures { 
            margin-top: 40px; 
            display: grid; 
            grid-template-columns: repeat(3, 1fr); 
            gap: 30px; 
        }

        .sig-box {
            border-top: 1px dashed var(--secondary-color);
            text-align: center;
            padding-top: 8px;
            font-size: 0.8rem;
            color: var(--secondary-color);
        }

        @media print {
            body { background: white; }
            .report-container { box-shadow: none; border: none; padding: 0; width: 100%; max-width: 100%; }
            .no-print { display: none !important; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container no-print mt-3">
            <div class="d-flex justify-content-between align-items-center p-2 bg-white rounded shadow-sm border">
                <div>
                    <button type="button" class="btn btn-sm btn-dark px-3" onclick="window.print();">
                        <i class="fas fa-print me-1"></i> طباعة القيد
                    </button>
                </div>
                <asp:HyperLink NavigateUrl="JournalEntries.aspx" runat="server" CssClass="btn btn-sm btn-link text-muted text-decoration-none">
                    <i class="fas fa-times me-1"></i> إغلاق
                </asp:HyperLink>
            </div>
        </div>

        <div class="report-container">
            <div class="posted-stamp" id="stampPosted" runat="server">مُرحل</div>

            <div class="header-top">
                <div class="row align-items-center">
                    <div class="col-6">
                        <div class="company-name"><asp:Literal ID="litCompanyName" runat="server" /></div>
                        <div class="text-muted small">نظام المحاسب الذكي - Smart Ledger</div>
                    </div>
                    <div class="col-6 text-start">
                        <span class="report-badge">قيد يومية - <asp:Literal ID="litTypeName" runat="server" /></span>
                    </div>
                </div>
            </div>

            <div class="info-grid">
                <div class="info-item">
                    <span class="info-label">رقم القيد</span>
                    <span class="info-value"><asp:Literal ID="litEntryId" runat="server" /></span>
                </div>
                <div class="info-item">
                    <span class="info-label">التاريخ</span>
                    <span class="info-value"><asp:Literal ID="litEntryDate" runat="server" /></span>
                </div>
                <div class="info-item">
                    <span class="info-label">المرجع</span>
                    <span class="info-value"><asp:Literal ID="litReference" runat="server" /></span>
                </div>
                <div class="info-item">
                    <span class="info-label">حالة القيد</span>
                    <span class="info-value text-primary"><asp:Literal ID="litStatus" runat="server" /></span>
                </div>
                <div class="info-item">
                    <span class="info-label">المستخدم</span>
                    <span class="info-value"><asp:Literal ID="litCreatedBy" runat="server" /></span>
                </div>
                <div class="info-item">
                    <span class="info-label">العملة</span>
                    <span class="info-value"><asp:Literal ID="litCurrency" runat="server" /></span>
                </div>
                <div class="info-item" style="grid-column: span 3; border-top: 1px solid #eee; padding-top: 8px;">
                    <span class="info-label">البيان العام</span>
                    <span class="info-value"><asp:Literal ID="litDescription" runat="server" /></span>
                </div>
            </div>

            <div class="table-responsive">
                <table class="ledger-table table-hover">
                    <thead>
                        <tr class="text-center">
                            <th class="text-start" style="width: 40%;">الحساب المالي</th>
                            <th class="text-center" style="width: 15%;">مدين</th>
                            <th class="text-center" style="width: 15%;">دائن</th>
                            <th class="text-start" style="width: 30%;">شرح السطر</th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="rptLines" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td class="text-start">
                                        <div class="account-cell">
                                            <span class="acc-code"><%# Eval("AccountCode") %></span>
                                            <span class="acc-separator">-</span>
                                            <span class="fw-bold"><%# Eval("AccountName") %></span>
                                        </div>
                                    </td>
                                    <td class="amount-cell text-center text-primary"><%# Eval("debit", "{0:N2}") %></td>
                                    <td class="amount-cell text-center text-danger"><%# Eval("credit", "{0:N2}") %></td>
                                    <td class="text-end text-muted small"><%# Eval("line_description") %></td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
            </div>

            <div class="summary-wrapper">
                <div class="summary-card debit-card">
                    <span class="label">إجمالي المدين</span>
                    <span class="value text-primary"><asp:Literal ID="litTotalDebit" runat="server">0.00</asp:Literal></span>
                </div>
                <div class="summary-card credit-card">
                    <span class="label">إجمالي الدائن</span>
                    <span class="value text-danger"><asp:Literal ID="litTotalCredit" runat="server">0.00</asp:Literal></span>
                </div>
            </div>

            <div class="amount-text-box">
                <span class="small fw-bold text-muted">فقط وقدره:</span>
                <span class="ms-1 fw-bold text-dark"><asp:Literal ID="litTotalText" runat="server" /></span>
            </div>

            <div class="signatures">
                <div class="sig-box">توقيع المحاسب</div>
                <div class="sig-box">المراجعة</div>
                <div class="sig-box">الاعتماد المالي</div>
            </div>

            <div class="mt-4 pt-3 border-top d-flex justify-content-between text-muted" style="font-size: 0.7rem;">
                <span>طبع بواسطة: <asp:Literal ID="Literal1" runat="server" /></span>
                <span>وقت الطباعة: <asp:Literal ID="litPrintTime" runat="server" /></span>
            </div>
        </div>
    </form>
</body>
</html>