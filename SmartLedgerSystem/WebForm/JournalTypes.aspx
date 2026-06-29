<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="JournalTypes.aspx.cs" Inherits="SmartLedgerSystem.WebForm.JournalTypes" %>

<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head runat="server">
    <title>أنواع القيود | Smart Ledger</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.rtl.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" />
    <style>
        :root { --primary: #2563eb; --dark: #0f172a; --bg: #f8fafc; }
        body { background-color: var(--bg); font-family: 'Segoe UI', sans-serif; color: var(--dark); }
        
        .main-card { border: none; border-radius: 20px; box-shadow: 0 10px 25px rgba(0,0,0,0.05); background: #fff; overflow: hidden; }
        .page-header { background: linear-gradient(135deg, var(--dark) 0%, #1e293b 100%); padding: 40px; color: white; border-radius: 0 0 40px 40px; margin-bottom: -50px; }
        
        .table { margin-bottom: 0; }
        .table thead th { background: #f1f5f9; text-transform: uppercase; font-size: 0.85rem; letter-spacing: 1px; padding: 15px; border: none; }
        .table tbody tr { transition: 0.3s; border-bottom: 1px solid #f1f5f9; }
        .table tbody tr:hover { background-color: #f8faff; transform: scale(1.002); }
        .table td { vertical-align: middle; padding: 15px; border: none; }

        /* الأزرار واللمسات الجمالية */
        .btn-add { background: var(--primary); color: white; border-radius: 12px; padding: 12px 25px; border: none; transition: 0.3s; box-shadow: 0 4px 12px rgba(37, 99, 235, 0.2); }
        .btn-add:hover { background: #1d4ed8; color: white; transform: translateY(-2px); }
        
        .badge-prefix { background: #e0e7ff; color: #4338ca; padding: 6px 12px; border-radius: 8px; font-weight: 600; font-family: 'Courier New', monospace; }
        .action-icon { width: 35px; height: 35px; display: inline-flex; align-items: center; justify-content: center; border-radius: 10px; transition: 0.3s; border: none; background: #f1f5f9; margin: 0 2px; }
        .btn-edit:hover { background: #fef3c7; color: #d97706; }
        .btn-delete:hover { background: #fee2e2; color: #dc2626; }
        
        /* Modal Design */
        .modal-content { border: none; border-radius: 24px; box-shadow: 0 25px 50px -12px rgba(0,0,0,0.25); }
        .modal-header { border-bottom: 1px solid #f1f5f9; padding: 25px; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server" />

        <div class="page-header shadow">
            <div class="container d-flex justify-content-between align-items-center">
                <div>
                    <h2 class="fw-bold mb-1"><i class="fas fa-layer-group ms-2"></i> أنواع القيود</h2>
                    <p class="opacity-75 mb-0">تهيئة وتصنيف العمليات المحاسبية في نظام Smart Ledger</p>
                </div>
                <div class="d-flex gap-2">
            <a href="Dashboard.aspx" class="btn btn-outline-light rounded-3 px-4 fw-bold">
                <i class="fas fa-arrow-right ms-2"></i> لوحة التحكم
            </a>
            <button type="button" class="btn btn-add fw-bold" onclick="openModal()">
                <i class="fas fa-plus-circle ms-2"></i> إضافة نوع جديد
            </button>
        </div>
            </div>
        </div>

        <div class="container" style="margin-top: 20px;">
            <div class="main-card mb-5">
                <div class="p-4 bg-white border-bottom d-flex justify-content-between align-items-center">
                    <h5 class="fw-bold mb-0">قائمة التصنيفات الحالية</h5>
                    <div class="search-box">
                        <input type="text" class="form-control form-control-sm rounded-pill px-3" placeholder="بحث سريع..." onkeyup="filterTable(this)">
                    </div>
                </div>
                
                <div class="table-responsive">
                    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
                        <ContentTemplate>
                            <asp:GridView ID="gvJournalTypes" runat="server" CssClass="table" AutoGenerateColumns="False" 
                                DataKeyNames="id" OnRowCommand="gvJournalTypes_RowCommand" GridLines="None" ShowHeaderWhenEmpty="true">
                                <Columns>
                                    <asp:BoundField DataField="id" HeaderText="ID" ItemStyle-CssClass="text-muted small" />
                                    <asp:TemplateField HeaderText="الاسم بالعربية">
                                        <ItemTemplate>
                                            <span class="fw-bold text-dark"><%# Eval("name_ar") %></span>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="name_en" HeaderText="الاسم بالإنجليزية" />
                                    <asp:TemplateField HeaderText="البادئة (Prefix)">
                                        <ItemTemplate>
                                            <span class="badge-prefix"><%# Eval("prefix") %></span>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="التحكم">
                                        <ItemTemplate>
                                            <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditRow" CommandArgument='<%# Eval("id") %>' CssClass="action-icon btn-edit">
                                                <i class="fas fa-edit"></i>
                                            </asp:LinkButton>
                                            <asp:LinkButton ID="btnDelete" runat="server" CommandName="DeleteRow" CommandArgument='<%# Eval("id") %>' CssClass="action-icon btn-delete" OnClientClick="return confirm('هل أنت متأكد من حذف هذا التصنيف؟');">
                                                <i class="fas fa-trash-alt"></i>
                                            </asp:LinkButton>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                                <EmptyDataTemplate>
                                    <div class="p-5 text-center text-muted">
                                        <i class="fas fa-folder-open fa-3x mb-3"></i>
                                        <p>لا توجد بيانات مسجلة حالياً</p>
                                    </div>
                                </EmptyDataTemplate>
                            </asp:GridView>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>
            </div>
        </div>

        <div class="modal fade" id="typeModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content p-2">
                    <div class="modal-header">
                        <h5 class="fw-bold mb-0" id="modalTitle">إضافة نوع قيد</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <asp:HiddenField ID="hfId" runat="server" Value="0" />
                        <div class="row g-3">
                            <div class="col-12">
                                <label class="form-label fw-bold small">اسم النوع (عربي)</label>
                                <asp:TextBox ID="txtNameAr" runat="server" CssClass="form-control rounded-3 p-2" placeholder="مثلاً: قيد رواتب"></asp:TextBox>
                            </div>
                            <div class="col-12">
                                <label class="form-label fw-bold small">الاسم بالإنجليزية</label>
                                <asp:TextBox ID="txtNameEn" runat="server" CssClass="form-control rounded-3 p-2" placeholder="Salary Entry"></asp:TextBox>
                            </div>
                            <div class="col-12">
                                <label class="form-label fw-bold small">البادئة (Prefix)</label>
                                <asp:TextBox ID="txtPrefix" runat="server" CssClass="form-control rounded-3 p-2 text-uppercase" placeholder="SAL"></asp:TextBox>
                                <div class="form-text">تستخدم لترقيم القيود (مثلاً: SAL-001)</div>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer border-0">
                        <button type="button" class="btn btn-light rounded-3 px-4" data-bs-dismiss="modal">إلغاء</button>
                        <asp:Button ID="btnSave" runat="server" Text="حفظ البيانات" CssClass="btn btn-primary rounded-3 px-4 shadow-sm" OnClick="btnSave_Click" />
                    </div>
                </div>
            </div>
        </div>
    </form>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        var myModal = new bootstrap.Modal(document.getElementById('typeModal'));

        function openModal() {
            document.getElementById('<%= hfId.ClientID %>').value = "0";
            document.getElementById('modalTitle').innerText = "إضافة نوع قيد جديد";
            myModal.show();
        }

        function filterTable(input) {
            let filter = input.value.toUpperCase();
            let rows = document.querySelectorAll("#gvJournalTypes tr:not(:first-child)");
            rows.forEach(row => {
                row.style.display = row.innerText.toUpperCase().includes(filter) ? "" : "none";
            });
        }
    </script>
</body>
</html>