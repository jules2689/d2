require 'd2'

module D2
  module Commands
    class LocalCommand < D2::Command
      def initialize(name, params)
        @name = name
        @params = params
      end

      def call(args, _name)
        help and return true if args.include?("--help")

        # If the run command is one line, it may be a file to run
        # Check if it is, if it is, run it.
        command = nil
        if @params['run'].lines.size == 1
          path = @params['run'].gsub(/{{config}}/, D2::CONFIG_PATH)
          if File.exist?(path)
            command = path
          end
        end
        command = @params['run'] if command.nil?

        CLI::UI::Frame.open("Running #{@name} command") do
          CLI::Kit::System.system(command, *args) do |o, e|
            if o
              o.split("{{divider}}").each_with_index do |section, idx|
                CLI::UI::Frame.divider(nil) unless idx == 0
                print CLI::UI.fmt section
              end
            end
            print CLI::UI.fmt e if e
            print CLI::UI::Color::RESET.code
          end
        end
      end

      def help
        msg = @params['help'] ? @params['help'] : "No help listed for #{@name}"
        logger.info(msg)
        true
      end

      def self.help
        <<~EOF
          Runs a local command defined in #{D2::CONFIG_PATH}/<project>.yml
        EOF
      end
    end
  end
end
