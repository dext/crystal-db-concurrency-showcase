require "spec"
require "dotenv"
require "../src/model/*"

module Showcase
  DOTENV_PATH = ".env.test"

  Dotenv.load DOTENV_PATH, on_not_found = :fail
  puts "Using dotenv in '#{DOTENV_PATH}'"
  puts "SHOWCASE_DB_URI='#{ENV["SHOWCASE_DB_URI"]}'"

  describe Model do
    db = ::DB.open ENV["SHOWCASE_DB_URI"]
    model = Model.instance_for db

    before_all do
      model.drop_tables
      model.create_tables
    end

    after_all do
      model.drop_tables
    end

    it "creates records and counts team members" do
      model.in_rolled_back_transaction do
        model.create_employee 1, 1, "Doe Junior"
        model.create_mentor 1, 1, 1, "Doe Senior"

        model.rows_count("employees", 1).should eq 1
        model.rows_count("mentors", 1).should eq 1
      end
    end

    it "returns the current max id of a given table" do
      model.in_rolled_back_transaction do
        model.max_id("employees").should eq 0

        model.create_employee 2, 1, "Doe First"
        model.create_employee 3, 1, "Doe Second"

        model.max_id("employees").should eq 3
      end
    end
  ensure
    db.close if db
  end

  abstract class Model::Base
    def drop_tables(on_non_existent = :ignore) : Nil
      statement = <<-SQL
        DROP TABLE IF EXISTS mentors;
        DROP TABLE IF EXISTS employees;
        SQL

      exec_multi statement
    end

    def in_rolled_back_transaction(&)
      @db.exec "BEGIN"

      yield
    ensure
      @db.exec "ROLLBACK"
    end
  end
end
