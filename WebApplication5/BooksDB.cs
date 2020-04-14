using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Configuration;
using WebApplication5.Models;

namespace WebApplication5
{
    public class BooksDB
    {
        private string connectionString;
        public BooksDB()
        {
            connectionString = ConfigurationManager.ConnectionStrings["AB"].ConnectionString;
        }
        public BooksDB(string connectionString)
        {
            this.connectionString = connectionString;
        }
        public List<Book> GetBooks()
        {
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                SqlCommand cmd = new SqlCommand("ListOfBooks", con);
                cmd.CommandType = CommandType.StoredProcedure;

                List<Book> books = new List<Book>();

                try
                {
                    con.Open();
                    SqlDataReader reader = cmd.ExecuteReader();
                    while (reader.Read())
                    {
                        Book book = new Book((int)reader["BookID"], (string)reader["title"], (string)reader["authors"], (int)reader["QuantityPages"]);
                        books.Add(book);
                    }
                    reader.Close();

                    return books;
                }
                catch(SqlException)
                {
                    throw new ApplicationException("Ошибка данных");
                }
            }
        }
        public int InsertBook(Book book)
        {
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                SqlCommand cmd = new SqlCommand("InsertBook", con);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.Add(new SqlParameter("@Title", SqlDbType.NVarChar, 100));
                cmd.Parameters["@Title"].Value = book.Title;
                cmd.Parameters.Add(new SqlParameter("@Authors", SqlDbType.NVarChar, 100));
                cmd.Parameters["@Authors"].Value = book.Authors;
                cmd.Parameters.Add(new SqlParameter("@Quantity", SqlDbType.Int, 4));
                cmd.Parameters["@Quantity"].Value = book.QuantityPages;
                cmd.Parameters.Add(new SqlParameter("@BookId", SqlDbType.Int, 4) { Direction = ParameterDirection.Output });

                try
                {
                    con.Open();
                    cmd.ExecuteNonQuery();
                    return (int)cmd.Parameters["@BookId"].Value;
                }
                catch (SqlException)
                {
                    throw new ApplicationException("Ошибка данных");
                }
            }
        }
        public void DeleteBook(int BookId)
        {
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                SqlCommand cmd = new SqlCommand("DeleteBook", con);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.Add(new SqlParameter("@BookId", SqlDbType.Int, 4));
                cmd.Parameters["@BookId"].Value = BookId;

                try
                {
                    con.Open();
                    cmd.ExecuteNonQuery();
                }
                catch (SqlException)
                {
                    throw new ApplicationException("Ошибка данных");
                }
            }
        }
    }
}