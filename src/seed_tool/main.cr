require "dotenv"
require "./cli"
require "./core"

module Showcase::SeedTool
  extend self

  alias TArgsForCore = NamedTuple(team_id: Int32, employees: Int32, mentors: Int32)

  def main(argv : Array(String)) : Int32
    args = CLI.parse_args(argv)
    puts "I: args=#{args}"

    Dotenv.load ".env", on_not_found: :ignore
    puts "I: SHOWCASE_DB_URI=#{ENV["SHOWCASE_DB_URI"]?.inspect}"

    Core.execute ENV["SHOWCASE_DB_URI"], **args_for_core(args)

    0
  rescue error
    STDERR.puts "UNHANDLED: #{error.inspect_with_backtrace}"

    2
  end

  private def args_for_core(args : TArgsTuple) : TArgsForCore
    args_for_core_h = args.to_h
    %i(env_path verbose).each { |key| args_for_core_h.delete key }

    TArgsForCore.from(args_for_core_h)
  end
end

exit Showcase::SeedTool.main ARGV
