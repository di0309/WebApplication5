using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApplication5.Models
{
    public class Author
    {
        public int Id { get; private set; }
        public string Name { get; private set; }

        public Author(int Id, string Name)
        {
            this.Id = Id;
            this.Name = Name;
        }
    }
}