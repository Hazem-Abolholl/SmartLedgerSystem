<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="BankManagement.aspx.cs" Inherits="SmartLedgerSystem.WebForm.BankManagement" %>
<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head runat="server">
    <title>إدارة البنوك | المحاسب الذكي</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.rtl.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" />
    <style>
        :root { --primary: #0f172a; --accent: #3b82f6; --bg: #f8fafc; }
        body { background-color: var(--bg); font-family: 'Segoe UI', Tahoma, sans-serif; }
        
        .glass-header { background: rgba(15, 23, 42, 0.9); backdrop-filter: blur(10px); color: white; padding: 15px 0; border-bottom: 4px solid var(--accent); }
        
        /* Card Style */
        .bank-card { border: none; border-radius: 15px; transition: all 0.3s ease; background: #fff; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); }
        .bank-card:hover { transform: translateY(-5px); box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1); }
        
        /* Modern Table */
        .table-custom { background: white; border-radius: 15px; overflow: hidden; border: none; }
        .table-custom thead { background: var(--primary); color: white; }
        
        .btn-modern { border-radius: 10px; padding: 10px 20px; font-weight: 600; transition: 0.3s; }
        .badge-bank { background: #dbeafe; color: #1e40af; padding: 5px 12px; border-radius: 8px; font-size: 0.8rem; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <header class="glass-header shadow-sm mb-4">
            <div class="container d-flex justify-content-between align-items-center">
                <div class="d-flex align-items-center">
                    <div class="bg-primary p-2 rounded-3 me-3"><i class="fas fa-university text-white"></i></div>
                    <h4 class="mb-0 fw-bold">إدارة الحسابات المصرفية</h4>
                </div>
                <a href="Dashboard.aspx" class="btn btn-outline-light btn-sm rounded-pill px-4">
                    <i class="fas fa-arrow-right ms-2"></i>العودة للوحة التحكم
                </a>
            </div>
        </header>

        <div class="container">
            <div class="card bank-card mb-4">
                <div class="card-body p-4">
                    <h5 class="fw-bold mb-4 text-primary"><i class="fas fa-plus-circle me-2"></i>ربط حساب مصرفي جديد</h5>
                    <div class="row g-3">
                        <div class="col-md-4">
                            <label class="form-label fw-semibold">الحساب المحاسبي (من الدليل)</label>
                            <asp:DropDownList ID="ddlAccounts" runat="server" CssClass="form-select"></asp:DropDownList>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-semibold">اسم المصرف (تجاري)</label>
                            <asp:TextBox ID="txtBankName" runat="server" CssClass="form-control" placeholder="مثلاً: مصرف الوحدة - فرع الرئيسي"></asp:TextBox>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-semibold">رقم الحساب المصرفي</label>
                            <asp:TextBox ID="txtAccNumber" runat="server" CssClass="form-control" placeholder="0000-0000-0000"></asp:TextBox>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">رقم الـ IBAN</label>
                            <asp:TextBox ID="txtIBAN" runat="server" CssClass="form-control" placeholder="LY000..."></asp:TextBox>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-semibold">اسم الفرع</label>
                            <asp:TextBox ID="txtBranch" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="col-md-2 d-flex align-items-end">
                            <asp:LinkButton ID="btnSave" runat="server" CssClass="btn btn-primary w-100 btn-modern" OnClick="btnSave_Click">
                                <i class="fas fa-save me-1"></i> حفظ
                            </asp:LinkButton>
                        </div>
                    </div>
                </div>
            </div>

            <div class="card bank-card">
                <div class="card-body p-0">
                    <div class="p-4 border-bottom d-flex justify-content-between align-items-center">
                        <h5 class="fw-bold mb-0 text-dark">الحسابات المصرفية النشطة</h5>
                        <span class="badge badge-bank"><asp:Label ID="lblCount" runat="server" Text="0"></asp:Label> حسابات</span>
                    </div>
                    <div class="table-responsive">
                        <asp:GridView ID="gvBanks" runat="server" AutoGenerateColumns="False" 
                            CssClass="table table-custom mb-0" GridLines="None" OnRowDeleting="gvBanks_RowDeleting" DataKeyNames="id">
                            <Columns>
                                <asp:BoundField DataField="code" HeaderText="كود الحساب" ItemStyle-CssClass="fw-bold text-secondary" />
                                <asp:BoundField DataField="account_name" HeaderText="الاسم في الدليل" />
                                <asp:TemplateField HeaderText="بيانات المصرف">
                                    <ItemTemplate>
                                        <div class="fw-bold text-primary"><%# Eval("bank_name") %></div>
                                        <small class="text-muted"><%# Eval("account_number") %></small>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="branch_name" HeaderText="الفرع" />
                                <asp:TemplateField HeaderText="التحكم" ItemStyle-Width="100px">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btnDelete" runat="server" CommandName="Delete" CssClass="btn btn-sm btn-outline-danger border-0" 
                                            OnClientClick="return confirm('هل تريد إزالة ربط هذا البنك؟');">
                                            <i class="fas fa-trash"></i>
                                        </asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                            <EmptyDataTemplate>
                                <div class="p-5 text-center text-muted">
                                    <i class="fas fa-info-circle fa-3x mb-3"></i>
                                    <p>لا يوجد حسابات مصرفية مربوطة حالياً</p>
                                </div>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>