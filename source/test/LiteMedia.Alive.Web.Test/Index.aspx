<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="LiteMedia.Alive.Web.Test.Index" %>
<!DOCTYPE html5>
<html>
    <head>
        <title>Alive custom performance counter</title>
        <style>
            div { display: block; }
            iframe { width: 100%; height: 500px; border: none; }
        </style>
    </head>
    <body>
        <form runat="server">
        <div>
            <h1>Press the button to increment the counter</h1>
            <asp:ScriptManager runat="server">
            </asp:ScriptManager>
            <asp:UpdatePanel runat="server">
                <ContentTemplate>
                    <asp:Button runat="server" Text="Press me" OnClick="IncreaseCounter" />
                </ContentTemplate>
            </asp:UpdatePanel>
            <iframe src="/Alive.axd/" />
        </div>
        </form>
    </body>
</html>
