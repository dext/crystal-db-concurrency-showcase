require "../model/factory"

module Showcase
  module SeedTool::Core
    CLEAR_TO_EOL = "\033[K"

    extend self

    def execute(uri : String, *, team_id : Int32, employees : Int32, mentors : Int32) : Nil
      db = ::DB.open uri

      model = Model.instance_for db
      model.create_tables

      if employees + mentors > 0
        puts "I: Creating #{employees} employees and #{mentors} mentors..."

        create_records(model, team_id, employees, mentors)
      end

      puts "Done."
    ensure
      db.close if db
    end

    private def create_records(model : Model::Base, team_id : Int32, employees : Int32, mentors : Int32) : Nil
      total_count = employees + mentors

      start_id = model.max_id("employees") + 1
      employees.times do |idx|
        id = start_id + idx
        model.create_employee id, team_id, "Employee ##{id}"

        current = idx
        if current % 77 == 0
          percent = (current * 100.0 / total_count).round(0).to_i32

          print "\rCreated #{current} of #{total_count} (#{percent}%)#{CLEAR_TO_EOL}"
        end
      end

      start_id = model.max_id("mentors") + 1
      mentors.times do |idx|
        id = start_id + idx
        model.create_mentor id, team_id, id, "Mentor ##{id}"

        current = idx + employees
        if current % 77 == 0
          percent = (current * 100.0 / total_count).round(0).to_i32

          print "\rCreated #{current} of #{total_count} (#{percent}%)#{CLEAR_TO_EOL}"
        end
      end

      print "\rCreated #{total_count} of #{total_count} (100%)#{CLEAR_TO_EOL}\n"
    end
  end
end
