require "pg"
require "./base"

module Showcase
  class Model::OnPostgres < Model::Base
    def create_tables
      statement = <<-SQL
      CREATE TABLE IF NOT EXISTS employees (
        id SERIAL PRIMARY KEY,
        team_id INT NULL,
        name VARCHAR(20) NOT NULL
      );

      CREATE TABLE IF NOT EXISTS mentors (
        id SERIAL PRIMARY KEY,
        team_id INT NULL,
        employee_id INT NOT NULL,
        name VARCHAR(20) NOT NULL
      );
      SQL

      exec_multi statement
    end
  end
end
