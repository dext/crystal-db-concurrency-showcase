require "option_parser"

module Showcase::App
  alias TArgsTuple = NamedTuple(team_ids: Array(Int32), count: Int32)
  alias TArgsHash = Hash(Symbol, Int32 | Array(Int32))

  module CLI
    DEFAULT_ARGS = {
      team_ids: [1, 2, 3],
      count:    50,
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
        Reproduces a use case of sending a batch of concurrent queries to a database.
        Before running, make sure you have a `.env` file pointing to a seeded database;
        see README.md.

      USAGE:
        #{base_name} -h
        #{base_name} [-t TEAM_IDS] [-c COUNT]

      USAGE_SECTION

        parser.on "-h", "--help", "Show this screen" do
          puts parser

          exit 0
        end

        parser.on(
          "-t TEAM_IDS",
          "--team-ids TEAM_IDS",
          "A comma-separated list of team_ids to make requests with\n(default: #{default_args[:team_ids].join(',')})",
        ) do |team_ids|
          args_hash[:team_ids] = team_ids.split(',').map(&.strip).map(&.to_i32)
        end

        parser.on(
          "-c COUNT",
          "--count COUNT",
          "The number of concurrent queries to initiate (default: #{default_args[:count]})\n",
        ) do |count|
          args_hash[:count] = count.to_i32
        end

        parser.invalid_option do |option_flag|
          puts "Oops - invalid option: #{option_flag} (try -h)."

          exit 1
        end
      end
    end
  end
end
