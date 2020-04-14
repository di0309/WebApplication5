using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using WebApplication5.Models;

namespace WebApplication5
{
    public partial class Books : System.Web.UI.Page
    {
        BooksDB db = new BooksDB();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                GetData();
            }
        }
        public List<Book> GetData()
        {
            return db.GetBooks();
        }
    }
}