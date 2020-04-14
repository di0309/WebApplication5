<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Books.aspx.cs" Inherits="WebApplication5.Books" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>Книги</title>
    <style type="text/css">
        table {width: 100%; border-collapse: separate; border-spacing: 4px;}
        table thead tr {color: #ffffff; font-weight: bold;}
        table thead tr td {border-radius: 4px 4px 0 0; background: #2e82c3;}
        table tbody tr td {border: 1px solid #2e82c3; border-radius: 4px; background: #cbdfef;}
        table tbody tr td:hover {background: #a2c3dd; transition-duration: 0.2s;}
        .add{
            width:100%;
            height:100%;
        }
    </style>
    <script type="text/javascript">
        window.onload = function () {
            let delButtons = document.getElementsByClassName('delButton');
            let heads = document.getElementsByTagName('th');
            let addTitle = document.getElementById('addTitle');
            let addAuthors = document.getElementById('addAuthors');
            let addQuantity = document.getElementById('addQuantity');
            let add = document.getElementById('add');
            let inputs = [addTitle,addAuthors,addQuantity];
            
            for (let i = 0; i < delButtons.length; i++) {
                delButtons[i].addEventListener('click', deleteBook, false);
            }
            for (let i = 0; i < inputs.length; i++) {
                inputs[i].addEventListener('input', availabilityAdd, false);
            }
            for (let i = 0; i < heads.length - 1; i++) {
                heads[i].addEventListener('click', sortTable.bind(this, heads[i].cellIndex), false);
            }

            add.addEventListener('click', insertBook, false);
        }
        function insertBook() {
            let title = document.getElementById('addTitle').value;
            let author = document.getElementById('addAuthors').value;
            let quantity = document.getElementById('addQuantity').value;
            WebApplication5.WebService1.Insert(checkString(title), checkString(author), quantity, onInsertComplete, onError);
        }

        function deleteBook() {
            WebApplication5.WebService1.Delete(this.id, onDelComplete(this), onError);
        }

        function sortColumn() {

        }

        function availabilityAdd() {
            let add = document.getElementById('add');
            let addTitle = document.getElementById('addTitle');
            let addAuthors = document.getElementById('addAuthors');

            if (addTitle.value.length >= 1 && addAuthors.value.length >= 1) {
                add.disabled = false;
            }
            else
                add.disabled = true;
        }
        function onInsertComplete(result) {
            if (result) {
                addRow(result, document.getElementById('addTitle').value, document.getElementById('addAuthors').value, document.getElementById('addQuantity').value);
                document.getElementById(result).addEventListener('click', deleteBook, false);
                resetInputs();
            }
        }

        var onDelComplete = function (btn) {
            return function () {
                btn.parentElement.parentElement.remove();
            }

        }

        function onError(error) {
            alert('ERROR:' + error._message);
        }

        function addRow(id, title, author, quantity) {
            let table = document.getElementById('tbl');
            let row = document.createElement("TR");
            table.rows[table.rows.length - 2].parentElement.insertBefore(row, table.rows[table.rows.length - 1]);

            let td1 = document.createElement("TD");
            let td2 = document.createElement("TD");
            let td3 = document.createElement("TD");
            let td4 = document.createElement("TD");

            row.appendChild(td1);
            row.appendChild(td2);
            row.appendChild(td3);
            row.appendChild(td4);
            
            td1.innerHTML = title;
            td2.innerHTML = author;
            td3.innerHTML = quantity;
            td4.innerHTML = '<input type="button" id=' + id + ' class="delButton" value="Удалить">';
        }
        function resetInputs() {
            document.getElementById('addTitle').value = '';
            document.getElementById('addAuthors').value = '';
            document.getElementById('addQuantity').value = 1;
        }
        function sortTable(n) {
            var table, rows, switching, i, x, y, shouldSwitch, dir, switchcount = 0;
            table = document.getElementById("tbl");
            switching = true;
            dir = "asc";

            while (switching) {
                switching = false;
                rows = table.rows;
                for (i = 1; i < (rows.length - 2) ; i++) {
                    shouldSwitch = false;
                    x = rows[i].getElementsByTagName("TD")[n];
                    y = rows[i + 1].getElementsByTagName("TD")[n];
                    if (isFinite(x.innerHTML)) {
                        if (dir == "asc") {
                            if (x.innerHTML.toLowerCase() > y.innerHTML.toLowerCase()) {
                                shouldSwitch = true;
                                break;
                            }
                        } else if (dir == "desc") {
                            if (x.innerHTML.toLowerCase() < y.innerHTML.toLowerCase()) {
                                shouldSwitch = true;
                                break;
                            }
                        }
                    }
                    else {
                        if (dir == "asc") {
                            if (x.innerHTML > y.innerHTML) {
                                shouldSwitch = true;
                                break;
                            }
                        } else if (dir == "desc") {
                            if (x.innerHTML < y.innerHTML) {
                                shouldSwitch = true;
                                break;
                            }
                        }
                    }
                }
                if (shouldSwitch) {
                    rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
                    switching = true;
                    switchcount++;
                } else {
                    if (switchcount == 0 && dir == "asc") {
                        dir = "desc";
                        switching = true;
                    }
                }
            }
        }
        function checkString(str) {
            return str.replace(/[<>]/g, '');
        }
        function filter(phrase) {
            var words = phrase.value.toLowerCase().split(" ");
            var table = document.getElementById('tbl');
            var ele;
            for (var r = 1; r < table.rows.length; r++) {
                ele = table.rows[r].innerHTML.replace(/<[^>]+>/g, "");
                var displayStyle = 'none';
                for (var i = 0; i < words.length; i++) {
                    if (ele.toLowerCase().indexOf(words[i]) >= 0)
                        displayStyle = '';
                    else {
                        displayStyle = 'none';
                        break;
                    }
                }
                table.rows[r].style.display = displayStyle;
            }
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <asp:ScriptManager runat="server">
            <Services>
                <asp:ServiceReference Path="~/WebService1.asmx" />
            </Services>
        </asp:ScriptManager>
        <b>Фильтрация</b>
        <input name="filt" onkeyup="filter(this)" style="width:350px;" type="text" /><br /><br />
        <asp:Repeater ID="BookList" ItemType="WebApplication5.Models.Book" SelectMethod="GetData" runat="server">
            <HeaderTemplate>
                <table id="tbl">
                    <tr>
                        <th>Название</th>
                        <th>Авторство</th>
                        <th>Страниц</th>
                        <th>Удалить</th>
                    </tr>
            </HeaderTemplate>
            <ItemTemplate>
                <tr>
                    <td><%#: Item.Title %></td>
                    <td><%#: Item.Authors %></td>
                    <td><%#: Item.QuantityPages %></td>
                    <td><input type="button" id="<%#: Item.Id %>" class="delButton" value="Удалить"></td>
                </tr>
            </ItemTemplate>
            <FooterTemplate>
                <tr>
                    <td><input type="text" id="addTitle" name="title" placeholder="Название книги" class="add" /></td>
                    <td><input type="text" id="addAuthors" name="authors" placeholder="Если авторов несколько, то писать через запятую" class="add" /></td>
                    <td><input type="number" id="addQuantity" name="quantity" min="1" max="5000" value="1" class="add" /></td>
                    <td><input type="button" id="add" value="Добавить" disabled="disabled" /></td>
                </tr>
                </table>
            </FooterTemplate>
        </asp:Repeater>
    </div>
    </form>
</body>
</html>
