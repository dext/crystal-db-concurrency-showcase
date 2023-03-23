require "mysql"
require "./base"

module Showcase
  class Model::OnMysql < Model::Base
    def create_tables
      statement = <<-SQL
      CREATE TABLE IF NOT EXISTS employees (
        id INT PRIMARY KEY,
        team_id INT NOT NULL,
        name VARCHAR(20) NOT NULL
      );

      CREATE TABLE IF NOT EXISTS mentors (
        id INT PRIMARY KEY,
        team_id INT NOT NULL,
        employee_id INT NOT NULL,
        name VARCHAR(20) NOT NULL
      );
      SQL

      exec_multi statement
    end

    # Need these to be parameterized or this error pops up when limit reached:
    # "Can't create more than max_prepared_stmt_count statements"

    def create_employee(id : Int32?, team_id : Int32, name : String) : Nil
      statement = <<-SQL
        INSERT INTO employees (id, team_id, name)
        VALUES (?, ?, ?)
      SQL

      @db.exec statement, id, team_id, name
    end

    def create_mentor(id : Int32?, team_id : Int32, employee_id : Int32?, name : String) : Nil
      statement = <<-SQL
        INSERT INTO mentors (id, team_id, employee_id, name)
        VALUES (?, ?, ?, ?)
      SQL

      @db.exec statement, id, team_id, employee_id, name
    end
  end
end
