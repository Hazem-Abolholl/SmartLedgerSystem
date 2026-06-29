<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Companies.aspx.cs" Inherits="SmartLedgerSystem.WebForm.Companies" %>

<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head runat="server">
    <title>إدارة الشركات | Smart Ledger</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.rtl.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" />
    <style>
        :root {
            --primary-color: #2563eb;
            --secondary-color: #64748b;
            --success-color: #22c55e;
            --danger-color: #ef4444;
            --warning-color: #f59e0b;
            --bg-body: #f8fafc;
        }

        body { 
            background-color: var(--bg-body); 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            color: #1e293b;
        }

        /* تحسين الكارد الرئيسي */
        .main-card { 
            border: none; 
            border-radius: 16px; 
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1), 0 2px 4px -1px rgba(0,0,0,0.06); 
            background: white; 
            padding: 25px;
            margin-bottom: 2rem;
        }

        /* تحسين الهيدر */
        .page-header {
            border-bottom: 2px solid #f1f5f9;
            padding-bottom: 15px;
            margin-bottom: 25px;
        }

        /* تحسين الجدول */
        .table { margin-bottom: 0; vertical-align: middle; }
        .table thead { background-color: #f1f5f9; }
        .table thead th { 
            border: none; 
            color: var(--secondary-color); 
            font-weight: 600; 
            text-transform: uppercase; 
            font-size: 0.85rem;
            padding: 15px;
        }
        .table tbody td { padding: 15px; border-bottom: 1px solid #f1f5f9; font-size: 0.95rem; }
        .table tbody tr:hover { background-color: #f8fafc; transition: 0.2s; }

        /* الأزرار المودرن */
        .btn-modern {
            border-radius: 10px;
            font-weight: 500;
            padding: 8px 20px;
            transition: all 0.3s ease;
        }
        .btn-primary-modern {
            background-color: var(--primary-color);
            border: none;
            color: white;
        }
        .btn-primary-modern:hover {
            background-color: #1d4ed8;
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(37, 99, 235, 0.2);
        }

        /* شارات الحالة */
        .status-badge {
            padding: 6px 14px;
            border-radius: 8px;
            font-size: 0.75rem;
            font-weight: 600;
            display: inline-block;
        }
        .badge-active { background-color: #dcfce7; color: #15803d; }
        .badge-inactive { background-color: #fee2e2; color: #b91c1c; }

        /* صندوق البحث */
        .search-container .input-group {
            background: #f1f5f9;
            border-radius: 12px;
            padding: 2px 5px;
            border: 1px solid #e2e8f0;
        }
        .search-container .form-control {
            background: transparent;
            border: none;
            box-shadow: none;
        }
        .search-container .form-control:focus { background: transparent; }

        /* المودال */
        .modal-content { border-radius: 20px; border: none; }
        .modal-header { border-bottom: 1px solid #f1f5f9; padding: 20px 25px; }
        .modal-body { padding: 25px; }
        .form-label { font-weight: 500; color: var(--secondary-color); margin-bottom: 8px; }
        .form-control, .form-select {
            border-radius: 10px;
            padding: 10px 15px;
            border: 1px solid #e2e8f0;
        }
        .form-control:focus { border-color: var(--primary-color); box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1); }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>

        <div class="container-fluid py-4 px-lg-5">
            <div class="row">
                <div class="col-xl-2 col-lg-3">
                    <div class="main-card p-3">
                        <a href="Dashboard.aspx" class="btn btn-light w-100 mb-2 btn-modern text-start">
                            <i class="fas fa-th-large me-2 text-primary"></i> لوحة التحكم
                        </a>
                        <div class="border-top my-3"></div>
                        <p class="small text-muted px-2 mb-2">الإعدادات</p>
                        <a href="#" class="btn btn-primary-modern w-100 btn-modern text-start mb-2">
                            <i class="fas fa-building me-2"></i> الشركات
                        </a>
                    </div>
                </div>

                <div class="col-xl-10 col-lg-9">
                    <asp:UpdatePanel ID="upCompanies" runat="server" UpdateMode="Conditional">
                        <ContentTemplate>
                            <asp:HiddenField ID="hfShowModal" runat="server" Value="0" />

                            <div class="main-card">
                                <div class="page-header d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3">
                                    <div>
                                        <h3 class="fw-bold mb-1">إدارة الشركات</h3>
                                        <p class="text-muted mb-0 small"><i class="fas fa-info-circle me-1"></i> يمكنك إضافة، تعديل وتصفية بيانات الشركات والسنوات المالية.</p>
                                    </div>
                                    <div class="d-flex gap-3 search-container">
                                        <div class="input-group" style="min-width: 280px;">
                                            <span class="input-group-text bg-transparent border-0"><i class="fas fa-search text-muted"></i></span>
                                            <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" 
                                                placeholder="بحث باسم الشركة أو العملة..." AutoPostBack="true" ClientIDMode="Static"
                                                onkeyup="delaySearch();" OnTextChanged="txtSearch_TextChanged"></asp:TextBox>
                                        </div>
                                        <asp:LinkButton ID="btnOpenAdd" runat="server" CssClass="btn btn-primary-modern btn-modern" OnClick="btnOpenAdd_Click">
                                            <i class="fas fa-plus-circle me-1"></i> إضافة شركة
                                        </asp:LinkButton>
                                    </div>
                                </div>

                                <div class="table-responsive">
                                    <asp:GridView ID="gvCompanies" runat="server" CssClass="table" AutoGenerateColumns="False" GridLines="None" DataKeyNames="id">
                                        <Columns>
                                            <asp:BoundField DataField="id" HeaderText="#" ItemStyle-CssClass="text-muted small" />
                                            <asp:TemplateField HeaderText="الشركة">
                                                <ItemTemplate>
                                                    <div class="d-flex align-items-center">
                                                        <div class="bg-light rounded-circle p-2 me-3 text-primary">
                                                            <i class="fas fa-building fa-fw"></i>
                                                        </div>
                                                        <span class="fw-bold"><%# Eval("name") %></span>
                                                    </div>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="العملة">
                                                <ItemTemplate>
                                                    <span class="badge bg-light text-dark border"><i class="fas fa-coins me-1 text-warning"></i> <%# Eval("currency") %></span>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="الفترة المالية">
                                                <ItemTemplate>
                                                    <div class="small">
                                                        <div class="text-success"><i class="fas fa-calendar-check fa-fw"></i> <%# Eval("fiscal_year_start", "{0:yyyy/MM/dd}") %></div>
                                                        <div class="text-danger"><i class="fas fa-calendar-times fa-fw"></i> <%# Eval("fiscal_year_end", "{0:yyyy/MM/dd}") %></div>
                                                    </div>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="الحالة">
                                                <ItemTemplate>
                                                    <span class='<%# (Convert.ToBoolean(Eval("is_active")) ? "status-badge badge-active" : "status-badge badge-inactive") %>'>
                                                        <i class='<%# (Convert.ToBoolean(Eval("is_active")) ? "fas fa-check-circle me-1" : "fas fa-pause-circle me-1") %>'></i>
                                                        <%# (Convert.ToBoolean(Eval("is_active")) ? "نشط" : "مجمد") %>
                                                    </span>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="الإجراءات">
                                                <ItemTemplate>
                                                    <div class="d-flex gap-1">
                                                        <asp:LinkButton ID="btnEdit" runat="server" CommandArgument='<%# Eval("id") %>' OnClick="btnEdit_Click" 
                                                            CssClass="btn btn-sm btn-outline-primary border-0" title="تعديل">
                                                            <i class="fas fa-edit"></i>
                                                        </asp:LinkButton>
                                                        <asp:LinkButton ID="btnToggle" runat="server" CommandArgument='<%# Eval("id") %>' OnClick="btnToggleStatus_Click" 
                                                            CssClass="btn btn-sm btn-outline-warning border-0" title="تغيير الحالة">
                                                            <i class="fas fa-sync-alt"></i>
                                                        </asp:LinkButton>
                                                        <asp:LinkButton ID="btnDelete" runat="server" CommandArgument='<%# Eval("id") %>'
                                                            OnClick="btnDelete_Click" 
                                                            OnClientClick='<%# "return confirmDelete(\"" + ((Control)Container).FindControl("btnDelete").UniqueID + "\");" %>'
                                                            CssClass="btn btn-sm btn-outline-danger border-0" title="حذف">
                                                            <i class="fas fa-trash"></i>
                                                        </asp:LinkButton>
                                                    </div>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                        <EmptyDataTemplate>
                                            <div class="text-center py-5">
                                                <i class="fas fa-folder-open fa-3x text-light mb-3"></i>
                                                <p class="text-muted">لم يتم العثور على شركات تطابق بحثك!</p>
                                            </div>
                                        </EmptyDataTemplate>
                                    </asp:GridView>
                                </div>
                            </div>
                        </ContentTemplate>
                        <Triggers>
                            <asp:AsyncPostBackTrigger ControlID="txtSearch" EventName="TextChanged" />
                        </Triggers>
                    </asp:UpdatePanel>
                </div>
            </div>
        </div>

        <div class="modal fade" id="companyModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content shadow-lg">
                    <asp:UpdatePanel ID="upModal" runat="server">
                        <ContentTemplate>
                            <div class="modal-header bg-light">
                                <h5 class="modal-title fw-bold">
                                    <i class="fas fa-edit text-primary me-2"></i>
                                    <asp:Literal ID="litModalTitle" runat="server" Text="إضافة شركة"></asp:Literal>
                                </h5>
                                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                            </div>
                            <div class="modal-body p-4">
                                <div class="mb-4">
                                    <label class="form-label"><i class="fas fa-signature me-1"></i> اسم الشركة</label>
                                    <asp:TextBox ID="txtCompName" runat="server" CssClass="form-control" placeholder="أدخل اسم الشركة بالكامل"></asp:TextBox>
                                </div>
                                <div class="row g-3">
                                    <div class="col-md-12 mb-2">
                                        <label class="form-label"><i class="fas fa-money-bill-wave me-1"></i> عملة التقارير</label>
                                        <asp:DropDownList ID="ddlCurrency" runat="server" CssClass="form-select">
                                            <asp:ListItem Value="USD">الدولار الأمريكي ($)</asp:ListItem>
                                            <asp:ListItem Value="SAR">الريال السعودي (SR)</asp:ListItem>
                                            <asp:ListItem Value="LYD">الدينار الليبي (LD)</asp:ListItem>
                                            <asp:ListItem Value="EGP">الجنيه المصري (EGP)</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label"><i class="fas fa-calendar-plus me-1"></i> بداية السنة</label>
                                        <asp:TextBox ID="txtFiscalStart" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label"><i class="fas fa-calendar-minus me-1"></i> نهاية السنة</label>
                                        <asp:TextBox ID="txtFiscalEnd" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="modal-footer border-top-0 px-4 pb-4">
                                <button type="button" class="btn btn-light btn-modern text-muted" data-bs-dismiss="modal">إغلاق</button>
                                <asp:Button ID="btnSaveCompany" runat="server" Text="حفظ البيانات" CssClass="btn btn-primary-modern btn-modern px-4" OnClick="btnSaveCompany_Click" />
                            </div>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>
            </div>
        </div>
    </form>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script>
        function showToast(msg, icon = 'success') {
            const Toast = Swal.mixin({
                toast: true,
                position: 'top-end',
                showConfirmButton: false,
                timer: 3000,
                timerProgressBar: true
            });
            Toast.fire({ icon: icon, title: msg });
            
            var modalEl = document.getElementById('companyModal');
            var modal = bootstrap.Modal.getInstance(modalEl);
            if (modal) modal.hide();
        }

        function confirmDelete(uniqueID) {
            Swal.fire({
                title: 'تأكيد الحذف؟',
                text: "لن تتمكن من استعادة بيانات هذه الشركة بعد الحذف!",
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#ef4444',
                cancelButtonColor: '#64748b',
                confirmButtonText: 'نعم، احذف الآن',
                cancelButtonText: 'إلغاء',
                customClass: {
                    popup: 'border-radius-20'
                }
            }).then((result) => {
                if (result.isConfirmed) __doPostBack(uniqueID, '');
            });
            return false;
        }

        var timer;
        function delaySearch() {
            clearTimeout(timer);
            timer = setTimeout(function () { 
                __doPostBack('txtSearch', ''); 
            }, 600);
        }

        function manageModal() {
            var hf = document.getElementById('<%= hfShowModal.ClientID %>');
            if (hf && hf.value === "1") {
                var myModal = new bootstrap.Modal(document.getElementById('companyModal'));
                myModal.show();
                hf.value = "0";
            }
        }

        // إعادة تهيئة المودال بعد كل UpdatePanel Refresh
        Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function () {
            manageModal();
            // استعادة التركيز للبحث إذا كان هناك نص
            var searchBox = document.getElementById('txtSearch');
            if (searchBox.value !== "") {
                searchBox.focus();
                searchBox.setSelectionRange(searchBox.value.length, searchBox.value.length);
            }
        });
    </script>
</body>
</html>