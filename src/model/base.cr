require "db"
require "uri"

module Showcase
  alias MemberRow = {id: Int32, name: String}

  abstract class Model::Base
    def initialize(@db : ::DB::Database)
    end

    abstract def create_tables

    def create_employee(id : Int32?, team_id : Int32, name : String) : Nil
      statement = <<-SQL
        INSERT INTO employees (id, team_id, name)
        VALUES (#{id}, #{team_id}, '#{name}')
      SQL

      @db.exec statement
    end

    def create_mentor(id : Int32?, team_id : Int32, employee_id : Int32?, name : String) : Nil
      statement = <<-SQL
        INSERT INTO mentors (id, team_id, employee_id, name)
        VALUES (#{id}, #{team_id}, #{employee_id}, '#{name}')
      SQL

      @db.exec statement
    end

    def select_team_members(team_id : Int32) : Array(MemberRow)
      statement = <<-SQL
        SELECT id, name FROM employees WHERE team_id = #{team_id}
        UNION
        SELECT id, name FROM mentors WHERE team_id = #{team_id}
        ORDER BY name ASC
        LIMIT 50000
      SQL

      @db.query_all statement, as: {id: Int32, name: String}
    rescue error
      [{id: -1, name: "#{error.inspect}"}]
    end

    def rows_count(table_name : String, team_id : Int32) : Int32
      statement = "SELECT count(*) from #{table_name} WHERE team_id=#{team_id}"

      @db.scalar(statement).as(Int32 | Int64).to_i32
    end

    def max_id(table_name : String) : Int32
      result = @db.scalar("SELECT max(id) FROM #{table_name}").as(Int32 | Int64 | Nil)

      return result.to_i32 if result

      0
    end

    protected def exec_multi(statements : String) : Nil
      statements.strip.split(';').reject(&.blank?).map(&.strip).each do |single_statement|
        @db.exec single_statement
      end
    end
  end
end
