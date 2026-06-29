<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="FiscalPeriods.aspx.cs" Inherits="SmartLedgerSystem.WebForm.FiscalPeriods" %>

<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head runat="server">
    <title>إدارة الفترات المالية | Smart Ledger</title>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.rtl.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" />

    <style>
        :root { 
            --primary-gradient: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%);
            --glass-bg: rgba(255, 255, 255, 0.95);
            --card-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.04), 0 4px 6px -2px rgba(0, 0, 0, 0.02);
        }

        body { 
            background-color: #f1f5f9; 
            font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; 
            color: #334155;
            min-height: 100vh;
        }

        /* رأس الصفحة المطور */
        .page-header { 
            background: var(--glass-bg); 
            backdrop-filter: blur(12px); 
            padding: 1.25rem 0; 
            border-bottom: 1px solid #e2e8f0; 
            margin-bottom: 2.5rem; 
            position: sticky; 
            top: 0; 
            z-index: 1000;
            box-shadow: 0 1px 3px 0 rgba(0,0,0,0.05);
        }

        /* كروت الإحصائيات */
        .stat-card { 
            background: white; 
            border-radius: 20px; 
            padding: 1.5rem; 
            border: none; 
            box-shadow: var(--card-shadow); 
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
        }
        .stat-card:hover { transform: translateY(-5px); box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1); }
        .stat-card::after {
            content: ""; position: absolute; top: 0; right: 0; width: 4px; height: 100%;
        }
        .card-primary::after { background: #2563eb; }
        .card-success::after { background: #10b981; }
        .card-warning::after { background: #f59e0b; }

        /* الجداول */
        .table-container { 
            background: white; 
            border-radius: 20px; 
            border: none; 
            box-shadow: var(--card-shadow); 
            margin-bottom: 3rem;
        }
        .table { margin-bottom: 0; }
        .table thead th { 
            background-color: #f8fafc; 
            color: #64748b; 
            font-weight: 700; 
            font-size: 0.8rem; 
            text-transform: uppercase; 
            letter-spacing: 0.05em;
            padding: 1.25rem 1rem;
            border-bottom: 1px solid #f1f5f9;
        }
        .table tbody td { padding: 1.25rem 1rem; border-bottom: 1px solid #f8fafc; color: #475569; }

        /* الحالات (Badges) */
        .badge-open { 
            background: #f0fdf4; color: #166534; border: 1px solid #bbf7d0;
            padding: 0.6rem 1.2rem; border-radius: 12px; font-weight: 600; display: inline-flex; align-items: center; gap: 6px;
        }
        .badge-closed { 
            background: #fef2f2; color: #991b1b; border: 1px solid #fecaca;
            padding: 0.6rem 1.2rem; border-radius: 12px; font-weight: 600; display: inline-flex; align-items: center; gap: 6px;
        }

        /* الأزرار */
        .btn-modern { 
            border-radius: 12px; padding: 0.7rem 1.8rem; font-weight: 600; 
            transition: all 0.2s; display: inline-flex; align-items: center; gap: 8px;
        }
        .btn-primary-modern { background: var(--primary-gradient); border: none; color: white; }
        .btn-primary-modern:hover { opacity: 0.9; transform: scale(1.02); color: white; }
        
        .btn-action { 
            width: 38px; height: 38px; border-radius: 10px; display: inline-flex; 
            align-items: center; justify-content: center; transition: all 0.2s;
        }

        /* المودال */
        .modal-content { border-radius: 24px; border: none; overflow: hidden; }
        .modal-header { background: #f8fafc; border-bottom: 1px solid #f1f5f9; padding: 1.5rem 2rem; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        <asp:UpdatePanel ID="upPeriods" runat="server">
            <ContentTemplate>
                
                <div class="page-header shadow-sm">
                    <div class="container">
                        <div class="row align-items-center">
                            <div class="col-md-8">
                                <div class="d-flex align-items-center">
                                    <asp:HyperLink ID="btnBack" runat="server" NavigateUrl="Dashboard.aspx" CssClass="btn btn-light btn-action me-3 shadow-sm">
                                        <i class="fas fa-arrow-right"></i>
                                    </asp:HyperLink>
                                    <div>
                                        <div class="d-flex align-items-center gap-2 mb-1">
                                            <span class="badge bg-primary px-3 rounded-pill">منظومة المحاسب الذكي</span>
                                            <span class="text-primary fw-bold small">
                                                <i class="fas fa-building me-1"></i>
                                                <asp:Label ID="lblCompanyName" runat="server" Text="جاري التحميل..."></asp:Label>
                                            </span>
                                        </div>
                                        <h3 class="mb-0 fw-bold">إدارة الفترات المالية</h3>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-4 text-md-end mt-3 mt-md-0">
                                <asp:LinkButton ID="btnAddNew" runat="server" OnClick="btnAddNew_Click" CssClass="btn btn-primary-modern btn-modern shadow">
                                    <i class="fas fa-calendar-plus"></i> إنشاء فترة مالية
                                </asp:LinkButton>
                                <asp:HiddenField ID="hfShowModal" runat="server" Value="0" />
                            </div>
                        </div>
                    </div>
                </div>

                <div class="container">
                    <div class="row g-4 mb-5">
                        <div class="col-md-4">
                            <div class="stat-card card-primary">
                                <div class="d-flex justify-content-between">
                                    <div>
                                        <p class="text-muted small fw-bold mb-1">الفترات المفتوحة</p>
                                        <h2 class="mb-0 fw-bold text-primary"><asp:Label ID="lblOpenPeriodsCount" runat="server" Text="0"></asp:Label></h2>
                                    </div>
                                    <div class="bg-primary bg-opacity-10 p-3 rounded-4">
                                        <i class="fas fa-door-open text-primary fa-2x"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="stat-card card-success">
                                <div class="d-flex justify-content-between">
                                    <div>
                                        <p class="text-muted small fw-bold mb-1">تاريخ آخر إغلاق</p>
                                        <h2 class="mb-0 fw-bold text-success"><asp:Label ID="lblLastClosedDate" runat="server" Text="--/--/----"></asp:Label></h2>
                                    </div>
                                    <div class="bg-success bg-opacity-10 p-3 rounded-4">
                                        <i class="fas fa-shield-check text-success fa-2x"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="stat-card card-warning">
                                <div class="d-flex justify-content-between">
                                    <div>
                                        <p class="text-muted small fw-bold mb-1">السنة النشطة</p>
                                        <h2 class="mb-0 fw-bold text-warning"><asp:Label ID="lblFiscalYear" runat="server" Text="----"></asp:Label></h2>
                                    </div>
                                    <div class="bg-warning bg-opacity-10 p-3 rounded-4">
                                        <i class="fas fa-business-time text-warning fa-2x"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="table-container shadow-sm overflow-hidden">
                        <div class="p-4 bg-white border-bottom d-flex flex-wrap justify-content-between align-items-center gap-3">
                            <h5 class="mb-0 fw-bold text-dark"><i class="fas fa-list-ul me-2 text-primary"></i>سجل الفترات المتاحة</h5>
                            <div class="position-relative">
                                <i class="fas fa-search position-absolute top-50 start-0 translate-middle-y ms-3 text-muted"></i>
                                <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control ps-5" placeholder="بحث سريع..." style="width: 280px; background: #f8fafc;" />
                            </div>
                        </div>
                        <div class="table-responsive">
                            <table class="table table-hover align-middle">
                                <thead>
                                    <tr>
                                        <th><i class="far fa-calendar-alt me-2"></i>تاريخ البدء</th>
                                        <th><i class="far fa-calendar-check me-2"></i>تاريخ الانتهاء</th>
                                        <th><i class="fas fa-info-circle me-2"></i>حالة الفترة</th>
                                        <th class="text-center">الإجراءات</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <asp:Repeater ID="rptPeriods" runat="server">
                                        <ItemTemplate>
                                            <tr>
                                                <td class="fw-bold"><%# Eval("start_date", "{0:yyyy/MM/dd}") %></td>
                                                <td class="fw-bold"><%# Eval("end_date", "{0:yyyy/MM/dd}") %></td>
                                                <td>
                                                    <span class='<%# (bool)Eval("is_closed") ? "badge-closed" : "badge-open" %>'>
                                                        <i class='<%# (bool)Eval("is_closed") ? "fas fa-lock" : "fas fa-lock-open" %>'></i>
                                                        <%# (bool)Eval("is_closed") ? "مغلقة نهائياً" : "فترة مفتوحة" %>
                                                    </span>
                                                </td>
                                                <td>
                                                    <div class="d-flex justify-content-center gap-2">
                                                        <asp:LinkButton runat="server" CommandArgument='<%# Eval("id") %>' OnClick="btnToggleStatus_Click"
                                                            CssClass='<%# (bool)Eval("is_closed") ? "btn btn-outline-success btn-action" : "btn btn-outline-danger btn-action" %>'
                                                            ToolTip='<%# (bool)Eval("is_closed") ? "إعادة فتح" : "إغلاق الفترة" %>'>
                                                            <i class='<%# (bool)Eval("is_closed") ? "fas fa-unlock-alt" : "fas fa-power-off" %>'></i>
                                                        </asp:LinkButton>
                                                        <asp:LinkButton runat="server" CommandArgument='<%# Eval("id") %>' OnClick="btnEdit_Click"
                                                            CssClass="btn btn-outline-primary btn-action" ToolTip="تعديل">
                                                            <i class="fas fa-pen-to-square"></i>
                                                        </asp:LinkButton>
                                                        <asp:LinkButton runat="server" CommandArgument='<%# Eval("id") %>' OnClick="btnDelete_Click"
                                                            CssClass="btn btn-outline-danger btn-action" ToolTip="حذف"
                                                            OnClientClick="return confirm('هل أنت متأكد من حذف هذه الفترة؟');">
                                                            <i class="fas fa-trash-can"></i>
                                                        </asp:LinkButton>
                                                    </div>
                                                </td>
                                            </tr>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <div class="modal fade" id="newPeriodModal" tabindex="-1" aria-hidden="true" data-bs-backdrop="static">
                    <div class="modal-dialog modal-dialog-centered">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h5 class="fw-bold mb-0 text-primary"><i class="fas fa-edit me-2"></i>تفاصيل الفترة المالية</h5>
                                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                            </div>
                            <div class="modal-body p-4">
                                <div class="row g-4">
                                    <div class="col-12">
                                        <div class="form-group">
                                            <label class="form-label fw-bold small text-muted">تاريخ بدء الفترة</label>
                                            <div class="input-group">
                                                <span class="input-group-text bg-white"><i class="fas fa-calendar-day text-primary"></i></span>
                                                <asp:TextBox ID="txtStartDate" runat="server" TextMode="Date" CssClass="form-control border-start-0" />
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-12">
                                        <div class="form-group">
                                            <label class="form-label fw-bold small text-muted">تاريخ انتهاء الفترة</label>
                                            <div class="input-group">
                                                <span class="input-group-text bg-white"><i class="fas fa-calendar-check text-primary"></i></span>
                                                <asp:TextBox ID="txtEndDate" runat="server" TextMode="Date" CssClass="form-control border-start-0" />
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="modal-footer bg-light border-0 p-4">
                                <button type="button" class="btn btn-outline-secondary btn-modern border-0" data-bs-dismiss="modal">إلغاء</button>
                                <asp:Button ID="btnSavePeriod" runat="server" Text="حفظ البيانات" CssClass="btn btn-primary-modern btn-modern px-5 shadow" OnClick="btnSavePeriod_Click" />
                            </div>
                        </div>
                    </div>
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </form>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function manageModalState() {
            var hf = document.getElementById('<%= hfShowModal.ClientID %>');
            if (hf && hf.value === "1") {
                var myModal = new bootstrap.Modal(document.getElementById('newPeriodModal'));
                myModal.show();
                hf.value = "0";
            }
        }

        document.addEventListener("DOMContentLoaded", manageModalState);

        var prm = Sys.WebForms.PageRequestManager.getInstance();
        prm.add_endRequest(function () {
            manageModalState();
            // تنظيف الباك دروب في حال حدوث مشكلة بـ UpdatePanel
            if (!$('.modal.show').length) {
                $('.modal-backdrop').remove();
                $('body').removeClass('modal-open').css('overflow', '');
            }
        });
    </script>
</body>
</html>