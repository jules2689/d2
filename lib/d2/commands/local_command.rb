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

        require 'tempfile'
        require 'fileutils'

        Tempfile.create("#{@name}", Dir.pwd) do |file|
          file.write(@params['run'])
          file.rewind
          FileUtils.chmod("+x", file.path)

          CLI::UI::Frame.open("Running #{@name} command") do
            CLI::Kit::System.system(file.path, *args) do |o, e|
              if o
                o.split("{{divider}}").each_with_index do |section, idx|
                  CLI::UI::Frame.divider(nil) unless idx == 0
                  logger.print CLI::UI.fmt section
                end
              end
              logger.print CLI::UI.fmt e if e
              logger.print CLI::UI::Color::RESET.code
            end
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
