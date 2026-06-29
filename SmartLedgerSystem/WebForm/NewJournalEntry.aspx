<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="NewJournalEntry.aspx.cs" Inherits="SmartLedgerSystem.WebForm.NewJournalEntry" ValidateRequest="false" %>
<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head runat="server">
    <title>إضافة/تعديل قيد | Smart Ledger</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.rtl.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
    <style>
        :root { --primary-dark: #1e293b; --accent-blue: #3b82f6; --bg-light: #f1f5f9; --card-radius: 12px; }
        body { background-color: var(--bg-light); font-family: 'Segoe UI', Tahoma, sans-serif; }
        .main-header { background: linear-gradient(135deg, var(--primary-dark) 0%, #0f172a 100%); padding: 0.8rem 2rem; border-bottom: 3px solid var(--accent-blue); }
        .company-name { color: #ffffff; font-weight: 700; font-size: 1.2rem; display: flex; align-items: center; }
        .company-logo-icon { background: var(--accent-blue); width: 32px; height: 32px; border-radius: 8px; display: flex; align-items: center; justify-content: center; margin-left: 10px; }
        .card { border: none; border-radius: var(--card-radius); box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); margin-bottom: 1.5rem; }
        .card-header-custom { background: #fff; border-bottom: 1px solid #edf2f7; padding: 1rem 1.5rem; border-radius: var(--card-radius) var(--card-radius) 0 0; }
        .table-input { border: 1px solid transparent; background: transparent; text-align: center; width: 100%; padding: 8px; transition: 0.3s; border-radius: 4px; }
        .table-input:focus { border-color: var(--accent-blue); background: #fff; outline: none; box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1); }
        .balance-summary { background: #fff; border-radius: var(--card-radius); padding: 20px; border: 1px solid #e2e8f0; }
        .balanced { color: #10b981 !important; }
        .unbalanced { color: #ef4444 !important; }
        th { font-weight: 600; color: #64748b; text-transform: uppercase; font-size: 0.85rem; }
        .select2-container--default .select2-selection--single { border: 1px solid #dee2e6; height: 38px; border-radius: 6px; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <header class="main-header shadow-sm">
            <div class="container-fluid d-flex justify-content-between align-items-center">
                <div class="company-name">
                    <div class="company-logo-icon"><i class="fas fa-building text-white"></i></div>
                    <asp:Label ID="lblCompanyName" runat="server" Text="Smart Ledger"></asp:Label>
                </div>
                <div><a href="JournalEntries.aspx" class="btn btn-outline-light btn-sm rounded-pill px-3">إلغاء والعودة</a></div>
            </div>
        </header>

        <div class="container py-4">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div><h3 class="fw-bold text-dark mb-0"><%= Request.QueryString["id"] != null ? "تعديل قيد رقم " + Request.QueryString["id"] : "إنشاء قيد جديد" %></h3></div>
                <asp:Button ID="btnSave" runat="server" Text="حفظ القيد المحاسبي" CssClass="btn btn-primary px-5 shadow-sm rounded-3" OnClick="btnSave_Click" OnClientClick="return validateBalance();" />
            </div>

            <div class="card">
                <div class="card-body p-4">
                    <div class="row g-3">
                        <div class="col-md-2">
                            <label class="form-label fw-semibold">نوع القيد</label>
                            <asp:DropDownList ID="ddlEntryType" runat="server" CssClass="form-select"></asp:DropDownList>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label fw-semibold">التاريخ</label>
                            <asp:TextBox ID="txtDate" runat="server" TextMode="Date" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="col-md-5">
                            <label class="form-label fw-semibold">البيان (الوصف العام)</label>
                            <asp:TextBox ID="txtDescription" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-semibold">المرجع / رقم السند</label>
                            <asp:TextBox ID="txtRef" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                    </div>
                </div>
            </div>

            <div class="card">
                <div class="card-header-custom d-flex justify-content-between align-items-center">
                    <span class="fw-bold"><i class="fas fa-list ms-2 text-primary"></i>تفاصيل القيد</span>
                </div>
                <div class="table-responsive">
                    <table class="table mb-0" id="linesTable">
                        <thead class="bg-light">
                            <tr class="text-center">
                                <th style="width: 20%">الحساب المحاسبي</th>
                                <th style="width: 15%">مركز التكلفة</th>
                                <th style="width: 10%">مدين</th>
                                <th style="width: 10%">دائن</th>
                                <th style="width: 20%">وصف السطر</th>
                                <th style="width: 20%">رقم الصك/المرجع</th>
                                <th style="width: 5%"></th>
                            </tr>
                        </thead>
                        <tbody id="tbodyLines"></tbody>
                    </table>
                </div>
                <div class="p-3 bg-light-subtle border-top text-center">
                    <button type="button" class="btn btn-outline-secondary btn-sm px-4 rounded-pill" onclick="addRow()">
                        <i class="fas fa-plus ms-1"></i> إضافة سطر جديد
                    </button>
                </div>
            </div>

            <div class="row justify-content-end mb-5">
                <div class="col-md-4">
                    <div class="balance-summary shadow-sm">
                        <div class="d-flex justify-content-between mb-2"><span>إجمالي المدين:</span><span id="sumDebit" class="fw-bold">0.00</span></div>
                        <div class="d-flex justify-content-between mb-2"><span>إجمالي الدائن:</span><span id="sumCredit" class="fw-bold">0.00</span></div>
                        <hr />
                        <div class="d-flex justify-content-between align-items-center"><span class="fw-bold">الفرق:</span><span id="sumBalance" class="fs-5 fw-bold unbalanced">0.00</span></div>
                    </div>
                </div>
            </div>
        </div>

        <asp:HiddenField ID="hfAccountsOptions" runat="server" />
        <asp:HiddenField ID="hfCostCentersOptions" runat="server" />
        <asp:HiddenField ID="hfLinesData" runat="server" ClientIDMode="Static" />
    </form>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>

    <script>
        function addRow() {
            let accOptions = $('#hfAccountsOptions').val();
            let ccOptions = $('#hfCostCentersOptions').val();
            
            let row = `<tr class="align-middle">
                <td><select class="form-select acc-select select2-acc">${accOptions}</select></td>
                <td><select class="form-select cc-select select2-cc">${ccOptions}</select></td>
                <td><input type="number" step="0.01" class="table-input debit fw-bold text-primary" value="0.00" oninput="calc()"></td>
                <td><input type="number" step="0.01" class="table-input credit fw-bold text-danger" value="0.00" oninput="calc()"></td>
                <td><input type="text" class="table-input line-desc text-start" placeholder="وصف السطر..."></td>
                <td><input type="text" class="table-input bank-ref text-start" placeholder="رقم الصك..."></td>
                <td class="text-center"><button type="button" class="btn btn-link text-danger p-0" onclick="removeRow(this)"><i class="fas fa-minus-circle fa-lg"></i></button></td>
            </tr>`;

            $('#tbodyLines').append(row);
            $('.select2-acc:last, .select2-cc:last').select2({ dir: "rtl", width: '100%' });
            
            $('.table-input:last').on('input', prepareData);
            $('.acc-select:last, .cc-select:last').on('change', prepareData);
        }

        function removeRow(btn) { 
            if ($('#tbodyLines tr').length > 1) { 
                $(btn).closest('tr').remove(); 
                calc(); 
            } 
        }

        function calc() {
            let totalD = 0, totalC = 0;
            $('.debit').each(function () { totalD += parseFloat($(this).val()) || 0; });
            $('.credit').each(function () { totalC += parseFloat($(this).val()) || 0; });
            $('#sumDebit').text(totalD.toFixed(2));
            $('#sumCredit').text(totalC.toFixed(2));
            let diff = Math.abs(totalD - totalC);
            $('#sumBalance').text(diff.toFixed(2)).removeClass('balanced unbalanced').addClass(diff < 0.01 && totalD > 0 ? 'balanced' : 'unbalanced');
            prepareData();
        }

        function prepareData() {
            let data = [];
            $('#tbodyLines tr').each(function (index) {
                data.push({
                    accId: $(this).find('.acc-select').val(),
                    ccId: $(this).find('.cc-select').val(),
                    d: $(this).find('.debit').val(),
                    c: $(this).find('.credit').val(),
                    lineDesc: $(this).find('.line-desc').val(),
                    bankRef: $(this).find('.bank-ref').val(), // جلب حقل المصرف
                    idx: index 
                });
            });
            $('#hfLinesData').val(JSON.stringify(data));
        }

        function validateBalance() {
            calc();
            let d = parseFloat($('#sumDebit').text());
            let c = parseFloat($('#sumCredit').text());
            if (Math.abs(d - c) > 0.01 || d === 0) { alert("القيد غير متوازن أو فارغ!"); return false; }
            return true;
        }

        $(document).ready(function () {
            $('#<%= ddlEntryType.ClientID %>').select2({ dir: "rtl", width: '100%' });
            let existingData = $('#hfLinesData').val();
            if (existingData && existingData !== "[]") {
                JSON.parse(existingData).forEach(item => {
                    addRow();
                    let last = $('#tbodyLines tr:last');
                    last.find('.acc-select').val(item.accId).trigger('change');
                    last.find('.cc-select').val(item.ccId).trigger('change');
                    last.find('.debit').val(item.d);
                    last.find('.credit').val(item.c);
                    last.find('.line-desc').val(item.lineDesc);
                    last.find('.bank-ref').val(item.bankRef); // تعبئة حقل المصرف عند التعديل
                });
                calc();
            } else { addRow(); addRow(); }
        });
    </script>
</body>
</html>