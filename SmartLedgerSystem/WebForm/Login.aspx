<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="SmartLedgerSystem.WebForm.Login" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>تسجيل الدخول | منظومة  المحاسب الذكي </title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet" />
    <style>
        :root {
            --primary-color: #2563eb;
            --secondary-color: #1e40af;
            --bg-gradient: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);
        }

        body {
            font-family: 'Segoe UI', Tahoma, sans-serif;
            background: var(--bg-gradient);
            margin: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            direction: rtl;
        }

        .login-container {
            background: white;
            width: 400px;
            padding: 40px;
            border-radius: 16px;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.05);
            border: 1px solid #e2e8f0;
        }

        .brand-logo {
            font-size: 2rem;
            color: var(--primary-color);
            font-weight: bold;
            margin-bottom: 10px;
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 10px;
        }

        .brand-logo i { font-size: 1.5rem; }

        h2 {
            color: #1e293b;
            font-size: 1.25rem;
            margin-bottom: 30px;
            font-weight: 500;
        }

        .input-group {
            margin-bottom: 20px;
            position: relative;
            text-align: right;
        }

        .input-group label {
            display: block;
            margin-bottom: 8px;
            color: #64748b;
            font-size: 0.9rem;
        }

        .input-group i {
            position: absolute;
            right: 12px;
            top: 38px;
            color: #94a3b8;
        }

        .form-control {
            width: 100%;
            padding: 12px 40px 12px 12px;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            font-size: 1rem;
            transition: all 0.3s ease;
            box-sizing: border-box;
        }

        .form-control:focus {
            outline: none;
            border-color: var(--primary-color);
            box-shadow: 0 0 0 4px rgba(37, 99, 235, 0.1);
        }

        .btn-login {
            width: 100%;
            padding: 12px;
            background: var(--primary-color);
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: background 0.3s ease;
            margin-top: 10px;
        }

        .btn-login:hover {
            background: var(--secondary-color);
        }

        .footer-text {
            margin-top: 25px;
            font-size: 0.85rem;
            color: #94a3b8;
        }

        .error-label {
            display: block;
            background: #fef2f2;
            color: #dc2626;
            padding: 10px;
            border-radius: 6px;
            margin-bottom: 20px;
            font-size: 0.85rem;
            border: 1px solid #fee2e2;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="login-container">
            <div class="brand-logo">
                <i class="fas fa-calculator"></i> Smart Ledger
            </div>
            <h2>سجل دخولك لإدارة حساباتك</h2>

            <asp:Panel ID="pnlError" runat="server" Visible="false">
                <asp:Label ID="lblError" runat="server" CssClass="error-label"></asp:Label>
            </asp:Panel>

            <div class="input-group">
                <label>البريد الإلكتروني</label>
                <i class="fas fa-envelope"></i>
                <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" placeholder="admin@company.com"></asp:TextBox>
            </div>

            <div class="input-group">
                <label>كلمة المرور</label>
                <i class="fas fa-lock"></i>
                <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password" placeholder="••••••••"></asp:TextBox>
            </div>

            <asp:Button ID="btnLogin" runat="server" Text="دخول إلى المنظومة" CssClass="btn-login" OnClick="btnLogin_Click" />

            <div class="footer-text">
                &copy; 2026 جميع الحقوق محفوظة - نظام الحسابات الذكي
            </div>
        </div>
    </form>
</body>
</html>