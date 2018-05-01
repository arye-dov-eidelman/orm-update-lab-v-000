require_relative "../config/environment.rb"
require 'pry'

# Remember, you can access your database connection anywhere in this class
#  with DB[:conn]

class Student
  attr_accessor :name, :grade
  attr_reader :id, :saved

  def initialize(id = nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  def already_saved
    @id
  end

  def update
    sql = <<-SQL
      UPDATE students
      SET name = ?, grade = ?
      WHERE id = ?;
    SQL
    DB[:conn].execute(sql, name, grade, id)
  end

  def save
    if self.already_saved
      self.update
    else
      sql = <<-SQL
      INSERT INTO students(name, grade) VALUES (?, ?);
      SQL
      DB[:conn].execute(sql, name, grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid()")[0][0]
    end
    self
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE students(
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS students")
  end

  def self.create(id = nil, name, grade)
    self.new(id, name, grade).save
  end

  def self.new_from_db(row)
    self.new(row[0], row[1], row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM students
    WHERE name = ?
    LIMIT 1;
    SQL
    row = DB[:conn].execute(sql, name)[0]
    self.new_from_db(row)
  end
end
