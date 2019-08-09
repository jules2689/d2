require 'd2'

module D2
  module Commands
    class LocalCommand < D2::Command
      def initialize(name, params)
        @name = name
        @params = params
      end

      def call(args, _name)
        require 'tempfile'
        require 'fileutils'

        Tempfile.create("#{@name}", Dir.pwd) do |file|
          file.write(@params['run'])
          file.rewind
          FileUtils.chmod("+x", file.path)

          CLI::Kit::System.system(file.path, *args) do |o, e|
            puts CLI::UI.fmt o if o
            puts CLI::UI.fmt e if e
            puts CLI::UI::Color::RESET.code
          end
        end
      end

      def self.help
        <<~EOF
          Runs a local command defined in #{D2::CONFIG_PATH}/<project>.yml
        EOF
      end
    end
  end
end
