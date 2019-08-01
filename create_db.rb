require "sqlite3"

# Open a database
db = SQLite3::Database.new "data.db"

db.execute <<-SQL
  create table accounts (
    name text NOT NULL UNIQUE
  );
SQL

db.execute <<-SQL
  create table money (
    name text NOT NULL,
    value int
  );
SQL

db.execute <<-SQL
  create table children (
    name text NOT NULL,
    value int
  );
SQL

db.execute <<-SQL
  create table jail (
    name text NOT NULL,
    value int
  );
SQL