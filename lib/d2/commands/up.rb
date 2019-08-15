# TODO: Test
require 'd2'

module D2
  module Commands
    class Up < D2::Command
      TaskFailed = Class.new(StandardError)

      def call(args, _name)
        # Gather all task constants
        all_tasks = tasks.flat_map do |task|
          D2::Tasks.tasks(task).map { |t| t.new }
        end

        # Short circuit if we're all good to go
        if all_tasks.all? { |t| t.met? }
          puts CLI::UI.fmt "{{v}} All dependencies are satisfied"
          return
        end

        all_tasks.each_with_index do |task, idx|
          if task.met?
            puts CLI::UI.fmt "{{v}} [#{idx + 1}/#{all_tasks.size}] #{task.title}"
            next
          end

          CLI::UI::Frame.open("[#{idx + 1}/#{all_tasks.size}] #{task.title}") do
            task.meet
            unless task.met?
              CLI::UI::Frame.divider('{{x}} Failure', color: :red)
              puts CLI::UI.fmt task.failed_message
              break false
            end
          end
        end
      end

      private

      def tasks
        return @tasks if @tasks

        definition = D2::Project.new.definition
        if definition && definition.key?('up')
          @tasks = definition['up']
        elsif definition
          logger.info "The definition file for this project has no up section"
          exit 1
        else
          logger.info "No {{info:d2.yml}} file found in the repository"
          exit 1
        end
      end

      def self.help
        <<~EOF
          Usage: {{command:#{D2::TOOL_NAME} up}}
        EOF
      end
    end
  end
end
