require "sqlite3"
require "./base"

module Showcase
  class Model::OnSqlite < Model::Base
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
  end
end
