<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AccountsTree.aspx.cs" Inherits="SmartLedgerSystem.WebForm.AccountsTree" %>

<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head runat="server">
    <title>دليل الحسابات المحاسبي | Smart Ledger</title>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.rtl.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" />
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <style>
        :root {
            --primary-color: #1e293b;
            --accent-color: #3b82f6;
            --success-color: #10b981;
            --bg-body: #f8fafc;
        }

        body { 
            background-color: var(--bg-body); 
            font-family: 'Segoe UI', Tahoma, sans-serif; 
            color: #334155;
        }

        .main-header {
            background: linear-gradient(135deg, var(--primary-color) 0%, #0f172a 100%);
            padding: 1rem 2rem;
            border-bottom: 4px solid var(--accent-color);
            margin-bottom: 30px;
        }

        .header-title { color: white; font-weight: 700; font-size: 1.25rem; }

        .tree-card, .form-card { 
            background: white; 
            border-radius: 16px; 
            border: none; 
            box-shadow: 0 10px 25px rgba(0,0,0,0.03); 
            height: 100%;
        }

        .card-header-custom {
            padding: 1.2rem;
            border-bottom: 1px solid #f1f5f9;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .tree-container { 
            padding: 20px; 
            height: 600px; 
            overflow-y: auto; 
        }

        .tv-style a { 
            text-decoration: none !important; 
            color: #475569; 
            padding: 4px 10px; 
            border-radius: 6px; 
            display: inline-block;
            font-size: 0.95rem;
        }
        .tv-selected { background: #eff6ff !important; color: var(--accent-color) !important; font-weight: 600; }

        .form-label { color: #64748b; font-weight: 600; font-size: 0.85rem; margin-bottom: 6px; }
        .form-control, .form-select {
            border-radius: 10px;
            padding: 10px;
            border: 1px solid #e2e8f0;
        }
        
        .parent-selector-box {
            background-color: #f1f5f9;
            padding: 15px;
            border-radius: 12px;
            margin-bottom: 20px;
            border: 1px dashed #cbd5e1;
        }

        .btn-custom {
            border-radius: 10px;
            padding: 10px 20px;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: 0.3s;
        }

        .archived-node { opacity: 0.5; text-decoration: line-through; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <header class="main-header shadow">
            <div class="container-fluid d-flex justify-content-between align-items-center">
                <div class="header-title">
                    <i class="fas fa-sitemap me-2 text-info"></i> دليل الحسابات الذكي
                </div>
                <div class="d-flex gap-3">
                    <a href="Dashboard.aspx" class="btn btn-outline-light btn-sm rounded-pill px-4">
                        <i class="fas fa-home"></i> لوحة التحكم
                    </a>
                </div>
            </div>
        </header>

        <div class="container-fluid px-4">
            <div class="row g-4">
                <div class="col-lg-4">
                    <div class="card tree-card">
                        <div class="card-header-custom">
                            <h5 class="mb-0 fw-bold"><i class="fas fa-network-wired text-primary me-2"></i>هيكل الحسابات</h5>
                        </div>
                        <div class="tree-container tv-style">
                            <asp:TreeView ID="tvAccounts" runat="server" OnSelectedNodeChanged="tvAccounts_SelectedNodeChanged"
                                ExpandDepth="1" ImageSet="Arrows" NodeIndent="25">
                                <SelectedNodeStyle CssClass="tv-selected" />
                                <NodeStyle VerticalPadding="4px" />
                            </asp:TreeView>
                        </div>
                    </div>
                </div>

                <div class="col-lg-8">
                    <div class="card form-card">
                        <div class="card-header-custom bg-light">
                            <h5 class="mb-0 fw-bold"><i class="fas fa-edit text-primary me-2"></i>بيانات الحساب المختاره</h5>
                            <asp:Label ID="lblStatus" runat="server" CssClass="badge p-2" />
                        </div>
                        <div class="card-body p-4">
                            
                            <div class="parent-selector-box">
                                <label class="form-label text-primary"><i class="fas fa-level-up-alt"></i> يتبع للحساب (الحساب الأب)</label>
                                <asp:DropDownList ID="ddlParent" runat="server" CssClass="form-select fw-bold border-primary shadow-sm">
                                </asp:DropDownList>
                                <small class="text-muted">اختر "حساب رئيسي" إذا كان الحساب في أعلى الشجرة.</small>
                            </div>

                            <div class="row g-4">
                                <div class="col-md-3">
                                    <label class="form-label">كود الحساب</label>
                                    <asp:TextBox ID="txtCode" runat="server" CssClass="form-control" placeholder="تلقائي" />
                                </div>
                                <div class="col-md-9">
                                    <label class="form-label">اسم الحساب</label>
                                    <asp:TextBox ID="txtName" runat="server" CssClass="form-control fw-bold" placeholder="أدخل اسم الحساب..." />
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label">نوع الحساب</label>
                                    <asp:DropDownList ID="ddlType" runat="server" CssClass="form-select">
                                        <asp:ListItem Value="ASSET">أصول (Asset)</asp:ListItem>
                                        <asp:ListItem Value="LIABILITY">خصوم (Liability)</asp:ListItem>
                                        <asp:ListItem Value="EQUITY">حقوق ملكية (Equity)</asp:ListItem>
                                        <asp:ListItem Value="REVENUE">إيرادات (Revenue)</asp:ListItem>
                                        <asp:ListItem Value="EXPENSE">مصروفات (Expense)</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">طبيعة الحساب</label>
                                    <asp:DropDownList ID="ddlNormalBalance" runat="server" CssClass="form-select">
                                        <asp:ListItem Value="D">مدين (Debit)</asp:ListItem>
                                        <asp:ListItem Value="C">دائن (Credit)</asp:ListItem>
                                    </asp:DropDownList>
                                </div>

                                <div class="col-12">
                                    <div class="p-3 border rounded bg-light">
                                        <div class="form-check form-switch d-flex align-items-center">
                                            <input type="checkbox" runat="server" id="chkIsPostable" class="form-check-input ms-3" style="width: 40px; height: 20px;" />
                                            <label class="form-check-label fw-bold" for="<%= chkIsPostable.ClientID %>">
                                                حساب حركة (يسمح بالترحيل المباشر)
                                            </label>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-12 pt-4 border-top">
                                    <div class="d-flex gap-2 flex-wrap">
                                        <asp:LinkButton ID="btnSave" runat="server" CssClass="btn btn-primary btn-custom" OnClick="btnSave_Click">
                                            <i class="fas fa-plus-circle"></i> إضافة جديد
                                        </asp:LinkButton>
                                        
                                        <asp:LinkButton ID="btnUpdate" runat="server" CssClass="btn btn-success btn-custom" OnClick="btnUpdate_Click" Visible="false">
                                            <i class="fas fa-save"></i> حفظ التعديلات
                                        </asp:LinkButton>
                                        
                                        <asp:LinkButton ID="btnArchive" runat="server" CssClass="btn btn-warning btn-custom text-white" OnClick="btnArchive_Click" Visible="false">
                                            <i class="fas fa-archive"></i> أرشفة
                                        </asp:LinkButton>

                                        <asp:LinkButton ID="btnDeleteTrigger" runat="server" CssClass="btn btn-danger btn-custom" 
                                            OnClientClick="showDeleteModal(); return false;" Visible="false">
                                            <i class="fas fa-trash"></i> حذف
                                        </asp:LinkButton>

                                        <asp:LinkButton ID="btnClear" runat="server" CssClass="btn btn-outline-secondary btn-custom" OnClick="btnClear_Clear">
                                            <i class="fas fa-eraser"></i> تفريغ
                                        </asp:LinkButton>
                                    </div>
                                </div>
                            </div>
                            <asp:HiddenField ID="hfSelectedAccountId" runat="server" />
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="modal fade" id="deleteConfirmModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content" style="border-radius: 15px;">
                    <div class="modal-body text-center p-5">
                        <i class="fas fa-exclamation-triangle text-danger fa-4x mb-3"></i>
                        <h4 class="fw-bold">هل أنت متأكد من الحذف؟</h4>
                        <p class="text-muted">لا يمكن التراجع عن هذه العملية.</p>
                        <div class="d-flex justify-content-center gap-2 mt-4">
                            <button type="button" class="btn btn-light px-4" data-bs-dismiss="modal">إلغاء</button>
                            <asp:Button ID="btnConfirmDelete" runat="server" Text="نعم، احذف" CssClass="btn btn-danger px-4" OnClick="btnDelete_Click" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>

    <script>
        function showDeleteModal() {
            var myModal = new bootstrap.Modal(document.getElementById('deleteConfirmModal'));
            myModal.show();
        }
    </script>
</body>
</html>