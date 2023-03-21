require "db"
require "./on_sqlite"
require "./on_postgres"

module Showcase::Model
  def self.instance_for(db : ::DB::Database) : Base
    scheme = db.uri.scheme.not_nil! # ameba:disable Lint/NotNil

    case scheme
    when "postgres" then OnPostgres.new db
    when "sqlite3"  then OnSqlite.new db
    else
      raise "Unknown URI scheme: #{scheme}"
    end
  end
end
