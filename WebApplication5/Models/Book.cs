using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApplication5.Models
{
    public class Book
    {
        public int Id { get; private set; }
        public string Title { get; private set; }
        public string Authors { get; private set; }
        public int QuantityPages { get; private set; }
        public Book(string Title, string Authors, int QuantityPages)
        {
            this.Title = Title;
            this.Authors = Authors;
            this.QuantityPages = QuantityPages;
        }
        public Book(int Id, string Title, string Authors, int QuantityPages)
        {
            this.Id = Id;
            this.Title = Title;
            this.Authors = Authors;
            this.QuantityPages = QuantityPages;
        }
    }
}