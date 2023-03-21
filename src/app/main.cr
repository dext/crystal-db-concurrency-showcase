require "dotenv"
require "./cli"
require "../model/base"
require "../model/factory"

module Showcase::App
  alias TChannel = Channel({Int32, Int32, Array(MemberRow)?, Time::Span})

  extend self

  def main(argv : Array(String)) : Int32
    args = CLI.parse_args(argv)
    puts "I: args=#{args}"

    Dotenv.load ".env", on_not_found: :ignore
    puts "I: SHOWCASE_DB_URI=#{ENV["SHOWCASE_DB_URI"]?.inspect}"

    execute ENV["SHOWCASE_DB_URI"], args[:count], args[:team_ids]
  rescue error
    STDERR.puts "E: UNHANDLED: #{error.inspect_with_backtrace}"

    2
  end

  private def execute(uri : String, count : Int32, team_ids : Array(Int32)) : Int32
    db = ::DB.open uri
    model = Showcase::Model.instance_for db
    channel = TChannel.new
    start_time = Time.monotonic

    spawn_requests channel, model, team_ids, count
    collect_responses channel, count

    0
  ensure
    db.close if db
    puts "I: Total time: #{(Time.monotonic - start_time).to_f.round(1)}s" if start_time
  end

  private def spawn_requests(channel : TChannel, model : Model::Base, team_ids : Array(Int32), count : Int32) : Nil
    spawn do
      puts "I: Spawning #{count} requests..."

      count.times do |idx|
        spawn do
          sleep rand(0.05..1.5)

          team_id = team_ids.sample
          team_members : Array(MemberRow)? = nil

          time_span = Time.measure do
            team_members = model.select_team_members team_id
          end

          channel.send({idx, team_id, team_members, time_span})
        end

        Fiber.yield
      end
    end
  end

  private def collect_responses(channel : TChannel, expected_count : Int32) : Nil
    received_count = 0

    loop do
      idx, team_id, team_members, time_span = channel.receive
      team_members = team_members || [] of MemberRow

      left_part = "Received #{received_count + 1} (idx=#{idx}) team_id=#{team_id}"

      if team_members[0][:id] == -1
        middle_part = "ERROR=#{team_members[0][:name]}"
      else
        middle_part = "size=#{team_members.size}"
      end

      STDOUT.puts "I: #{left_part} #{middle_part} time=#{time_span.to_f.round(2)}s"
      STDOUT.flush

      received_count += 1

      break if received_count == expected_count
    end
  end
end

exit Showcase::App.main ARGV
