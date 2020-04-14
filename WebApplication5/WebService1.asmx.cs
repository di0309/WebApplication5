using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using WebApplication5.Models;

namespace WebApplication5
{
    /// <summary>
    /// Сводное описание для WebService1
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]
    [System.Web.Script.Services.ScriptService]
    public class WebService1 : System.Web.Services.WebService
    {
        BooksDB db = new BooksDB();

        [WebMethod]
        public int Insert(string Title, string Authors, int QuantityPages)
        {
            return (int)db.InsertBook(new Book(Title, Authors, QuantityPages));
        }

        [WebMethod]
        public void Delete(int id)
        {
            db.DeleteBook(id);
        }
    }
}
