<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CostCenters.aspx.cs" Inherits="SmartLedger.CostCenters" %>

<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head runat="server">
    <title>إدارة مراكز التكلفة | المحاسب الذكي</title>
    <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@400;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.rtl.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        :root {
            --primary-color: #2563eb;
            --secondary-color: #64748b;
            --success-color: #22c55e;
            --danger-color: #ef4444;
            --bg-body: #f1f5f9;
        }

        body { 
            background-color: var(--bg-body); 
            font-family: 'Cairo', sans-serif;
            color: #1e293b;
        }

        .main-card {
            border: none;
            border-radius: 16px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.05);
            background: #fff;
            margin-top: 20px;
        }

        .card-header {
            background-color: #fff !important;
            border-bottom: 1px solid #e2e8f0 !important;
            padding: 20px 25px !important;
            border-radius: 16px 16px 0 0 !important;
        }

        .btn-modern {
            border-radius: 10px;
            padding: 8px 20px;
            font-weight: 600;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }
        
        .btn-back {
            background-color: #fff;
            color: var(--secondary-color);
            border: 1px solid #e2e8f0;
        }
        
        .btn-back:hover {
            background-color: #f8fafc;
            color: var(--primary-color);
        }

        .table thead th {
            background-color: #f8fafc;
            color: var(--secondary-color);
            font-weight: 700;
            font-size: 0.85rem;
            border-top: none;
            padding: 15px;
        }
        
        .table tbody td {
            padding: 15px;
            vertical-align: middle;
            border-bottom: 1px solid #f1f5f9;
        }

        .badge-status {
            padding: 6px 12px;
            border-radius: 8px;
            font-weight: 600;
            font-size: 0.75rem;
        }

        /* تنسيق الشجرة: الإزاحة بناءً على المستوى */
        .child-indent {
            padding-right: 35px !important;
            color: #475569;
            position: relative;
        }

        .child-indent::before {
            content: "∟";
            position: absolute;
            right: 15px;
            color: #2563eb;
            font-weight: bold;
        }

        .modal-content {
            border: none;
            border-radius: 20px;
            box-shadow: 0 25px 50px -12px rgba(0,0,0,0.25);
        }

        .form-label {
            font-weight: 600;
            color: var(--secondary-color);
            margin-bottom: 8px;
            font-size: 0.9rem;
        }

        .form-control, .form-select {
            border-radius: 10px;
            padding: 10px 15px;
            border: 1px solid #e2e8f0;
            background-color: #f8fafc;
        }

        .form-check-input { width: 3em !important; height: 1.5em !important; cursor: pointer; }

        .action-btn {
            width: 35px;
            height: 35px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 8px;
            margin: 0 2px;
            transition: all 0.2s;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        
        <div class="container py-5">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h3 class="fw-bold mb-0">إدارة مراكز التكلفة</h3>
                    <nav aria-label="breadcrumb">
                        <ol class="breadcrumb mb-0">
                            <li class="breadcrumb-item"><a href="Dashboard.aspx" class="text-decoration-none text-muted">لوحة التحكم</a></li>
                            <li class="breadcrumb-item active" aria-current="page">مراكز التكلفة</li>
                        </ol>
                    </nav>
                </div>
                <a href="Dashboard.aspx" class="btn btn-modern btn-back">
                    <i class="fas fa-arrow-right"></i> الرجوع للرئيسية
                </a>
            </div>

            <asp:UpdatePanel ID="MainUpdatePanel" runat="server">
                <ContentTemplate>
                    <div class="card main-card shadow-sm">
                        <div class="card-header d-flex justify-content-between align-items-center">
                            <div class="d-flex align-items-center">
                                <div class="bg-primary text-white rounded-3 p-2 me-3 d-flex align-items-center justify-content-center" style="width: 40px; height: 40px;">
                                    <i class="fas fa-sitemap"></i>
                                </div>
                                <h5 class="mb-0 fw-bold">هيكلية مراكز التكلفة</h5>
                            </div>
                            <asp:LinkButton ID="btnOpenAdd" runat="server" CssClass="btn btn-primary btn-modern" OnClick="btnOpenAdd_Click">
                                <i class="fas fa-plus"></i> إضافة مركز جديد
                            </asp:LinkButton>
                        </div>
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <asp:GridView ID="gvCostCenters" runat="server" AutoGenerateColumns="False" 
                                    CssClass="table table-hover align-middle" OnRowCommand="gvCostCenters_RowCommand" DataKeyNames="id" GridLines="None">
                                    <Columns>
                                        <asp:BoundField DataField="code" HeaderText="الكود" ItemStyle-CssClass="text-secondary fw-semibold" />
                                   <asp:TemplateField HeaderText="اسم مركز التكلفة">
    <ItemTemplate>
        <div style='<%# "padding-right:" + GetIndent(Eval("Level")) + "px;" %>'>
            <span class='<%# Convert.ToInt32(Eval("Level")) > 0 ? "text-secondary" : "fw-bold text-dark" %>'>
                <%# Convert.ToInt32(Eval("Level")) > 0 ? "<i class='fas fa-level-down-alt fa-rotate-180 me-1' style='color:#cbd5e1'></i> " : "" %>
                <%# Eval("name") %>
            </span>
        </div>
    </ItemTemplate>
</asp:TemplateField>
                                        <asp:BoundField DataField="manager_name" HeaderText="المسؤول" />
                                        <asp:TemplateField HeaderText="الحالة">
                                            <ItemTemplate>
                                                <span class='<%# Convert.ToBoolean(Eval("is_active")) ? "badge badge-status bg-success-subtle text-success" : "badge badge-status bg-secondary-subtle text-secondary" %>'>
                                                    <i class='<%# Convert.ToBoolean(Eval("is_active")) ? "fas fa-check-circle me-1" : "fas fa-archive me-1" %>'></i>
                                                    <%# Convert.ToBoolean(Eval("is_active")) ? "نشط" : "مؤرشف" %>
                                                </span>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="إجراءات">
                                            <ItemTemplate>
                                                <asp:LinkButton ID="lnkEdit" runat="server" CommandName="EditCenter" CommandArgument='<%# Eval("id") %>' CssClass="action-btn btn btn-outline-primary" ToolTip="تعديل"><i class="fas fa-pen-to-square"></i></asp:LinkButton>
                                                <asp:LinkButton ID="lnkArchive" runat="server" CommandName="ArchiveCenter" CommandArgument='<%# Eval("id") %>' CssClass="action-btn btn btn-outline-warning" ToolTip="تغيير الحالة"><i class="fas fa-box-archive"></i></asp:LinkButton>
                                                <asp:LinkButton ID="lnkDelete" runat="server" CommandName="DeleteCenter" CommandArgument='<%# Eval("id") %>' CssClass="action-btn btn btn-outline-danger" OnClientClick="return confirm('هل أنت متأكد من الحذف النهائي؟')" ToolTip="حذف"><i class="fas fa-trash-can"></i></asp:LinkButton>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                    <EmptyDataTemplate>
                                        <div class="p-5 text-center text-muted">
                                            <i class="fas fa-folder-open fa-3x mb-3 opacity-25"></i>
                                            <p>لا توجد بيانات متاحة لعرضها</p>
                                        </div>
                                    </EmptyDataTemplate>
                                </asp:GridView>
                            </div>
                        </div>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>

        <div class="modal fade" id="centerModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered modal-lg">
                <div class="modal-content border-0">
                    <div class="modal-header bg-light">
                        <h5 class="modal-title fw-bold"><i class="fas fa-edit me-2 text-primary"></i>بيانات مركز التكلفة</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <asp:UpdatePanel ID="ModalUpdatePanel" runat="server">
                        <ContentTemplate>
                            <div class="modal-body p-4">
                                <asp:HiddenField ID="hfCenterId" runat="server" Value="0" />
                                <div class="row g-4">
                                    <div class="col-md-4">
                                        <label class="form-label">كود المركز (تلقائي)</label>
                                        <asp:TextBox ID="txtCode" runat="server" CssClass="form-control fw-bold" ReadOnly="true" BackColor="#e9ecef"></asp:TextBox>
                                    </div>
                                    <div class="col-md-8">
                                        <label class="form-label">اسم مركز التكلفة</label>
                                        <asp:TextBox ID="txtName" runat="server" CssClass="form-control" placeholder="أدخل اسم المركز"></asp:TextBox>
                                    </div>
                                    <div class="col-md-12">
                                        <label class="form-label">يتبع للمركز الرئيسي</label>
                                        <asp:DropDownList ID="ddlParent" runat="server" CssClass="form-select"></asp:DropDownList>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label">اسم المسؤول المباشر</label>
                                        <asp:TextBox ID="txtManager" runat="server" CssClass="form-control" placeholder="المسؤول عن المركز"></asp:TextBox>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label">سقف الميزانية التقديرية</label>
                                        <div class="input-group">
                                            <asp:TextBox ID="txtBudget" runat="server" CssClass="form-control" TextMode="Number"></asp:TextBox>
                                            <span class="input-group-text bg-light">د.ل</span>
                                        </div>
                                    </div>
                                    <div class="col-12 mt-4">
                                        <div class="p-3 rounded-3 border bg-light d-flex justify-content-between align-items-center">
                                            <div>
                                                <h6 class="mb-0 fw-bold">حالة التنشيط</h6>
                                                <small class="text-muted">تحويل المركز إلى "مؤرشف" يمنع استخدامه في القيود الجديدة.</small>
                                            </div>
                                            <div class="form-check form-switch mb-0">
                                                <asp:CheckBox ID="chkActive" runat="server" Checked="true" CssClass="form-check-input" />
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="modal-footer bg-light p-3">
                                <button type="button" class="btn btn-modern btn-back" data-bs-dismiss="modal">إلغاء</button>
                                <asp:LinkButton ID="btnSave" runat="server" CssClass="btn btn-primary btn-modern" OnClick="btnSave_Click">
                                    <i class="fas fa-save"></i> حفظ التغييرات
                                </asp:LinkButton>
                            </div>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>
            </div>
        </div>
    </form>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function openModal() {
            var myModal = new bootstrap.Modal(document.getElementById('centerModal'));
            myModal.show();
        }
        function closeModal() {
            var container = document.getElementById('centerModal');
            var modal = bootstrap.Modal.getInstance(container);
            if (modal) modal.hide();
        }
    </script>
</body>
</html>