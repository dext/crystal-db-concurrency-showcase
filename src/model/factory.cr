require "db"
require "./on_postgres"
require "./on_mysql"
require "./on_sqlite"

module Showcase::Model
  def self.instance_for(db : ::DB::Database) : Base
    scheme = db.uri.scheme.not_nil! # ameba:disable Lint/NotNil

    case scheme
    when "postgres" then OnPostgres.new db
    when "mysql"    then OnMysql.new db
    when "sqlite3"  then OnSqlite.new db
    else
      raise "Unknown URI scheme: #{scheme}"
    end
  end
end
