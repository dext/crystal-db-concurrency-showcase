require "option_parser"

module Showcase::SeedTool
  alias TArgsHash = Hash(Symbol, Int32)
  alias TArgsTuple = NamedTuple(employees: Int32, mentors: Int32, team_id: Int32)

  module CLI
    DEFAULT_ARGS = {
      employees: 33000,
      mentors:   22000,
      team_id:   1,
    }

    extend self

    def parse_args(argv : Array(String)) : TArgsTuple
      args_hash = DEFAULT_ARGS.to_h
      the_parser = create_parser(DEFAULT_ARGS, args_hash)
      the_parser.parse argv

      TArgsTuple.from args_hash
    end

    private def create_parser(default_args : TArgsTuple, args_hash : TArgsHash) : OptionParser
      base_name = File.basename(PROGRAM_NAME)

      OptionParser.new do |parser|
        parser.banner = <<-USAGE_SECTION
      #{PROGRAM_NAME}
        Create (a presumably large amount of) employees and mentors for a given team_id.

      USAGE:
        #{base_name} -h
        #{base_name} [-e EMPLOYEES] [-m MENTORS] [-t TEAM_ID]

      USAGE_SECTION

        parser.on "-h", "--help", "Show this screen" do
          puts parser

          exit 0
        end

        parser.on(
          "-e EMPLOYEES",
          "--employees EMPLOYEES",
          "The number of employees to create (default: #{default_args[:employees]})",
        ) do |employees|
          args_hash[:employees] = employees.to_i32
        end

        parser.on(
          "-m MENTORS",
          "--mentors MENTORS",
          "The number of mentors to create (default: #{default_args[:mentors]})",
        ) do |mentors|
          args_hash[:mentors] = mentors.to_i32
        end

        parser.on(
          "-t TEAM_ID",
          "--team-id TEAM_ID",
          "The team-id to relate created records to (default: #{default_args[:team_id]})",
        ) do |team_id|
          args_hash[:team_id] = team_id.to_i32
        end

        parser.invalid_option do |option_flag|
          puts "Oops - invalid option: #{option_flag} (try -h)."

          exit 1
        end
      end
    end
  end
end
