<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="JournalEntries.aspx.cs" Inherits="SmartLedgerSystem.WebForm.JournalEntries" %>
<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head runat="server">
    <title>القيود اليومية | Smart Ledger</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.rtl.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" />
    <style>
        :root {
            --primary-dark: #1e293b;
            --accent-blue: #3b82f6;
            --bg-light: #f1f5f9;
        }
        body {
            background-color: var(--bg-light);
            font-family: 'Segoe UI', Tahoma, sans-serif;
        }
        .card {
            border: none;
            border-radius: 12px;
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
            transition: transform 0.2s;
        }
        .stat-card:hover {
            transform: translateY(-5px);
        }
        .icon-box {
            width: 48px;
            height: 48px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 12px;
            font-size: 1.25rem;
        }
        .bg-primary-light {
            background-color: rgba(59, 130, 246, 0.1);
            color: #3b82f6;
        }
        .bg-success-light {
            background-color: rgba(34, 197, 94, 0.1);
            color: #22c55e;
        }
        .bg-warning-light {
            background-color: rgba(245, 158, 11, 0.1);
            color: #f59e0b;
        }

        .table thead th {
            background-color: #f8fafc;
            color: #64748b;
            font-weight: 600;
            text-transform: uppercase;
            font-size: 0.8rem;
            border-bottom: 2px solid #edf2f7;
        }

        .table tbody td {
            padding: 1rem 0.75rem;
            vertical-align: middle;
        }
        .status-badge {
            padding: 5px 12px;
            border-radius: 8px;
            font-size: 0.75rem;
            font-weight: 600;
        }

        .badge-posted {
            background-color: #dcfce7;
            color: #15803d;
        }

        .badge-draft {
            background-color: #fef3c7;
            color: #92400e;
        }

        .btn-action {
            width: 35px;
            height: 35px;
            border-radius: 8px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            transition: 0.3s;
            border: 1px solid #e2e8f0;
            background: white;
            text-decoration: none;
        }

        .btn-action:hover {
            transform: scale(1.1);
        }
        
        .main-header {
            background: linear-gradient(135deg, var(--primary-dark) 0%, #0f172a 100%);
            padding: 1rem 2rem;
            margin-bottom: 2rem;
            box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1);
            border-bottom: 3px solid var(--accent-blue);
        }

        .company-name {
            color: #ffffff;
            font-weight: 700;
            font-size: 1.25rem;
            letter-spacing: 0.5px;
            display: flex;
            align-items: center;
        }

        .company-logo-icon {
            background: var(--accent-blue);
            width: 35px;
            height: 35px;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-left: 12px;
        }

        .user-profile {
            color: #94a3b8;
            font-size: 0.9rem;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>

        <header class="main-header shadow-sm border-bottom">
            <div class="container-fluid d-flex justify-content-between align-items-center text-white">
                <div class="company-name">
                    <div class="company-logo-icon">
                        <i class="fas fa-building text-white"></i>
                    </div>
                    <asp:Label ID="lblCompanyName" runat="server" Text="جاري التحميل..."></asp:Label>
                </div>

                <div class="d-flex align-items-center">
                    <div class="user-profile me-3 text-white-50">
                        <i class="fas fa-calendar-alt me-1"></i>
                        <span><%: DateTime.Now.ToString("yyyy-MM-dd") %></span>
                    </div>
                    <div class="vr mx-3 text-white-50"></div>
                    <a href="Dashboard.aspx" class="btn btn-outline-light btn-sm rounded-pill px-3 shadow-sm" style="transition: all 0.3s ease;">
                        <i class="fas fa-chart-line me-1"></i>لوحة التحكم
                    </a>
                </div>
            </div>
        </header>

        <div class="container-fluid py-4 px-lg-5">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h2 class="fw-bold text-dark mb-1">القيود اليومية</h2>
                    <nav aria-label="breadcrumb">
                        <ol class="breadcrumb mb-0">
                            <li class="breadcrumb-item"><a href="Dashboard.aspx" class="text-decoration-none">الرئيسية</a></li>
                            <li class="breadcrumb-item active">دفتر القيود</li>
                        </ol>
                    </nav>
                </div>
                <a href="NewJournalEntry.aspx" class="btn btn-primary px-4 py-2 rounded-3 shadow-sm">
                    <i class="fas fa-plus-circle me-2"></i>قيد محاسبي جديد
                </a>
            </div>

            <div class="row g-4 mb-4">
                <div class="col-md-4">
                    <div class="card stat-card p-3">
                        <div class="d-flex align-items-center">
                            <div class="icon-box bg-primary-light me-3"><i class="fas fa-book"></i></div>
                            <div>
                                <small class="text-muted d-block fw-semibold">إجمالي القيود</small>
                                <asp:Literal ID="litTotalEntries" runat="server" />
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card stat-card p-3">
                        <div class="d-flex align-items-center">
                            <div class="icon-box bg-success-light me-3"><i class="fas fa-check-double"></i></div>
                            <div>
                                <small class="text-muted d-block fw-semibold">العمليات المُرحلة</small>
                                <asp:Literal ID="litPostedEntries" runat="server" />
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card stat-card p-3">
                        <div class="d-flex align-items-center">
                            <div class="icon-box bg-warning-light me-3"><i class="fas fa-file-signature"></i></div>
                            <div>
                                <small class="text-muted d-block fw-semibold">مسودات (غير مُرحل)</small>
                                <asp:Literal ID="litDraftEntries" runat="server" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="card overflow-hidden">
                <div class="card-header bg-white py-3 border-bottom">
                    <div class="row align-items-center">
                        <div class="col">
                            <h5 class="mb-0 fw-bold"><i class="fas fa-filter text-primary me-2"></i>فلترة القيود</h5>
                        </div>
                        <div class="col-auto">
                            <div class="input-group" style="width: 300px;">
                                <span class="input-group-text bg-light border-end-0"><i class="fas fa-search text-muted"></i></span>
                                <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control bg-light border-start-0"
                                    placeholder="رقم القيد أو البيان..." OnTextChanged="txtSearch_TextChanged" AutoPostBack="true" />
                            </div>
                        </div>
                        <div class="col-auto">
                            <asp:DropDownList ID="ddlEntryTypes" runat="server" CssClass="form-select bg-light shadow-sm" 
                                AutoPostBack="true" OnSelectedIndexChanged="ddlEntryTypes_SelectedIndexChanged">
                            </asp:DropDownList>
                        </div>
                    </div>
                </div>

                <div class="card-body p-0">
                    <asp:UpdatePanel ID="upJournal" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="true">
                        <ContentTemplate>
                            <asp:GridView ID="gvJournalEntries" runat="server" CssClass="table table-hover align-middle mb-0"
                                AutoGenerateColumns="False" GridLines="None" DataKeyNames="id" OnRowCommand="gvJournalEntries_RowCommand">
                                <Columns>
                                    <asp:BoundField DataField="id" HeaderText="الرقم" ItemStyle-CssClass="fw-bold text-dark ps-4" HeaderStyle-CssClass="ps-4" />
                                    <asp:TemplateField HeaderText="نوع القيد">
                                        <ItemTemplate>
                                            <span class="badge bg-light text-dark border shadow-sm" style="font-size: 0.75rem;">
                                                <i class="fas fa-tag me-1 text-primary"></i>
                                                <%# Eval("type_name_ar") %>
                                            </span>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="entry_date" HeaderText="تاريخ القيد" DataFormatString="{0:yyyy-MM-dd}" />

                                    <asp:TemplateField HeaderText="البيان (الوصف)">
                                        <ItemTemplate>
                                            <span class="text-muted small"><%# Eval("description") %></span>
                                        </ItemTemplate>
                                    </asp:TemplateField>

                                    <asp:TemplateField HeaderText="الحالة">
                                        <ItemTemplate>
                                            <span class='<%# Convert.ToBoolean(Eval("posted")) ? "status-badge badge-posted" : "status-badge badge-draft" %>'>
                                                <i class='<%# Convert.ToBoolean(Eval("posted")) ? "fas fa-check-circle" : "fas fa-clock" %> me-1'></i>
                                                <%# Convert.ToBoolean(Eval("posted")) ? "مُرحل" : "مسودة" %>
                                            </span>
                                        </ItemTemplate>
                                    </asp:TemplateField>

                                    <asp:TemplateField HeaderText="خيارات التحكم" ItemStyle-CssClass="text-end pe-4" HeaderStyle-CssClass="text-end pe-4">
                                        <ItemTemplate>
                                            <a href='JournalEntryReport.aspx?id=<%# Eval("id") %>' target="_blank" 
                                               class="btn-action text-secondary" title="طباعة التقرير">
                                                <i class="fas fa-print"></i>
                                            </a>

                                            <asp:LinkButton ID="btnView" runat="server" CommandName="ViewEntry" CommandArgument='<%# Eval("id") %>'
                                                CssClass="btn-action text-info" ToolTip="عرض التفاصيل">
                                                <i class="fas fa-eye"></i>
                                            </asp:LinkButton>

                                            <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditEntry" CommandArgument='<%# Eval("id") %>'
                                                CssClass="btn-action text-primary" Visible='<%# !Convert.ToBoolean(Eval("posted")) %>' ToolTip="تعديل">
                                                <i class="fas fa-pen-to-square"></i>
                                            </asp:LinkButton>

                                            <asp:LinkButton ID="btnPost" runat="server" CommandName="PostEntry" CommandArgument='<%# Eval("id") %>'
                                                Visible='<%# !Convert.ToBoolean(Eval("posted")) %>'
                                                OnClientClick='<%# "return confirmPost(this, " + Eval("id") + ");" %>' ToolTip="ترحيل القيد"
                                                CssClass="btn-action text-success">
                                                <i class="fas fa-share-from-square"></i>
                                            </asp:LinkButton>

                                            <asp:LinkButton ID="btnDelete" runat="server" CommandName="DeleteEntry" CommandArgument='<%# Eval("id") %>'
                                                Visible='<%# !Convert.ToBoolean(Eval("posted")) %>'
                                                OnClientClick='<%# "return confirmDelete(this, " + Eval("id") + ");" %>' ToolTip="حذف"
                                                CssClass="btn-action text-danger">
                                                <i class="fas fa-trash-can"></i>
                                            </asp:LinkButton>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                                <EmptyDataTemplate>
                                    <div class="text-center py-5">
                                        <img src="https://cdn-icons-png.flaticon.com/512/7486/7486744.png" width="80" class="mb-3 opacity-25" />
                                        <p class="text-muted fw-bold">لا توجد قيود يومية مسجلة حالياً بهذا الفلتر</p>
                                    </div>
                                </EmptyDataTemplate>
                            </asp:GridView>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>
            </div>
        </div>
    </form>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script>
        function pageLoad() {
            window.showNotification = function (msg, icon) {
                Swal.fire({
                    title: icon === 'success' ? 'عملية ناجحة' : 'تنبيه!',
                    text: msg,
                    icon: icon,
                    confirmButtonText: 'موافق',
                    customClass: { confirmButton: 'btn btn-primary px-4' }
                });
            };
        }

        var confirmed = false;

        function confirmDelete(btn, id) {
            if (confirmed) { confirmed = false; return true; }
            Swal.fire({
                title: 'هل تريد حذف القيد؟',
                text: "سيتم حذف كافة تفاصيل القيد رقم (" + id + ")",
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#ef4444',
                confirmButtonText: 'نعم، احذفه',
                cancelButtonText: 'إلغاء'
            }).then((result) => {
                if (result.isConfirmed) { confirmed = true; btn.click(); }
            });
            return false;
        }

        function confirmPost(btn, id) {
            if (confirmed) { confirmed = false; return true; }
            Swal.fire({
                title: 'تأكيد الترحيل؟',
                text: "القيد رقم (" + id + ") سيتم ترحيله للحسابات",
                icon: 'question',
                showCancelButton: true,
                confirmButtonColor: '#22c55e',
                confirmButtonText: 'نعم، قم بالترحيل',
                cancelButtonText: 'إلغاء'
            }).then((result) => {
                if (result.isConfirmed) { confirmed = true; btn.click(); }
            });
            return false;
        }
    </script>
</body>
</html>