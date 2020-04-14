USE [AB]
GO
/****** Object:  UserDefinedFunction [dbo].[iter_charlist_to_table]    Script Date: 14.04.2020 16:21:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[iter_charlist_to_table]
                    (@list      ntext,
                     @delimiter nchar(1) = N',')
         RETURNS @tbl TABLE (listpos int IDENTITY(1, 1) NOT NULL,
                             str     varchar(100)) AS

   BEGIN
      DECLARE @pos      int,
              @textpos  int,
              @chunklen smallint,
              @tmpstr   nvarchar(4000),
              @leftover nvarchar(4000),
              @tmpval   nvarchar(4000)

      SET @textpos = 1
      SET @leftover = ''
      WHILE @textpos <= datalength(@list) / 2
      BEGIN
         SET @chunklen = 4000 - datalength(@leftover) / 2
         SET @tmpstr = @leftover + substring(@list, @textpos, @chunklen)
         SET @textpos = @textpos + @chunklen

         SET @pos = charindex(@delimiter, @tmpstr)

         WHILE @pos > 0
         BEGIN
            SET @tmpval = ltrim(rtrim(left(@tmpstr, charindex(@delimiter, @tmpstr) - 1)))
            INSERT @tbl (str) VALUES(@tmpval)
            SET @tmpstr = substring(@tmpstr, @pos + 1, len(@tmpstr))
            SET @pos = charindex(@delimiter, @tmpstr)
         END

         SET @leftover = @tmpstr
      END

      INSERT @tbl(str) VALUES (ltrim(rtrim(@leftover)))
   RETURN
   END
GO
/****** Object:  Table [dbo].[Author]    Script Date: 14.04.2020 16:21:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Author](
	[AuthorID] [int] IDENTITY(1,1) NOT NULL,
	[AuthorName] [nvarchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[AuthorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AuthorsBooks]    Script Date: 14.04.2020 16:21:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AuthorsBooks](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[AuthorID] [int] NOT NULL,
	[BookID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Book]    Script Date: 14.04.2020 16:21:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Book](
	[BookID] [int] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](100) NOT NULL,
	[QuantityPages] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[BookID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[AuthorsBooks]  WITH CHECK ADD FOREIGN KEY([AuthorID])
REFERENCES [dbo].[Author] ([AuthorID])
GO
ALTER TABLE [dbo].[AuthorsBooks]  WITH CHECK ADD FOREIGN KEY([BookID])
REFERENCES [dbo].[Book] ([BookID])
GO
/****** Object:  StoredProcedure [dbo].[DeleteBook]    Script Date: 14.04.2020 16:21:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DeleteBook]
	@BookId int
AS
SET XACT_ABORT, NOCOUNT ON
BEGIN TRY
BEGIN TRANSACTION 
   DECLARE @DelAuthors table (AuthorID INT not null)
   DECLARE @AuthorID int

   INSERT INTO @DelAuthors
   SELECT b.[AuthorID]
	FROM [dbo].[AuthorsBooks] AS ab
	RIGHT JOIN 
	(SELECT [Id], [AuthorID],[BookID]
	FROM [dbo].[AuthorsBooks]
	WHERE BookID = @BookId) AS b
	ON ab.AuthorID = b.AuthorID and ab.Id <> b.Id
	WHERE ab.AuthorID IS NULL

   DELETE FROM [dbo].[AuthorsBooks]
   WHERE [BookID] = @BookId
   	
   DELETE FROM [dbo].[Book]
   WHERE [BookID] = @BookId

   DELETE FROM [dbo].[Author]
   WHERE [AuthorID] IN(
   SELECT [AuthorID] FROM @DelAuthors
   )
COMMIT
END TRY
BEGIN CATCH
      IF @@trancount > 0 ROLLBACK TRANSACTION
      DECLARE @msg nvarchar(2048) = error_message()  
      RAISERROR (@msg, 16, 1)
      RETURN 888
END CATCH

GO
/****** Object:  StoredProcedure [dbo].[InsertBook]    Script Date: 14.04.2020 16:21:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[InsertBook]
	@Title nvarchar(100),
	@Authors nvarchar(100),
	@Quantity int,
	@BookId int OUTPUT

AS
SET XACT_ABORT, NOCOUNT ON
BEGIN TRY
BEGIN TRANSACTION 
   DECLARE @AllAuthors table (AuthorName nvarchar(100) not null)
   DECLARE @NewAuthors table (AuthorName nvarchar(100) not null)
   
   INSERT INTO [dbo].[Book]
   VALUES(@Title, @Quantity)

   SET @BookID = @@IDENTITY
   
   INSERT INTO @AllAuthors
   SELECT [str]
   FROM dbo.iter_charlist_to_table(@Authors, DEFAULT)

   INSERT INTO @NewAuthors
   SELECT a1.AuthorName
   FROM @AllAuthors as a1
   LEFT JOIN [dbo].[Author] as a2
   ON a1.AuthorName = a2.AuthorName
   WHERE a2.[AuthorName] IS NULL

   INSERT INTO [dbo].[Author]
   SELECT AuthorName
   FROM @NewAuthors

   INSERT INTO [dbo].[AuthorsBooks]
   SELECT [AuthorID], @BookID
   FROM (
	select [AuthorID] from [dbo].[Author] as a
	inner join @AllAuthors as b
	on a.AuthorName = b.AuthorName
	) as t
COMMIT
END TRY
BEGIN CATCH
      IF @@trancount > 0 ROLLBACK TRANSACTION
      DECLARE @msg nvarchar(2048) = error_message()  
      RAISERROR (@msg, 16, 1)
      RETURN 888
END CATCH
GO
/****** Object:  StoredProcedure [dbo].[ListOfBooks]    Script Date: 14.04.2020 16:21:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ListOfBooks]
   AS
  
BEGIN
   DECLARE @temp table (BookID int not null
					   ,title nvarchar(100) not null
					   ,AuthorID int not null
					   ,AuthorName nvarchar(100) not null
					   ,QuantityPages int)

    INSERT INTO @temp
    SELECT b.BookID, [Title], a.[AuthorID], [AuthorName], [QuantityPages]
	FROM [dbo].[AuthorsBooks] as ab
	JOIN [dbo].[Book] as b
	ON ab.[BookID] = b.[BookID]
	JOIN [dbo].[Author] as a
	ON ab.[AuthorID] = a.[AuthorID]
   
    SELECT distinct t1.BookID, t2.title, t1.authors, t2.QuantityPages
	FROM (
	SELECT BookID,
	STUFF((SELECT ', ' + AuthorName as 'data()' FROM @temp as t2 WHERE t1.BookID=t2.BookID FOR XML PATH('')),1, 1, '') as authors
	FROM @temp as t1
	GROUP BY BookID) as t1
	JOIN @temp as t2
	ON t1.BookID=t2.BookID
END
GO
