require 'd2'

module D2
  module Commands
    class LocalCommand < D2::Command
      def initialize(name, params)
        @name = name
        @params = params
      end

      def call(args, _name)
        env = ENV.dup
        env['LOCAL_COMMAND_ARGS'] = args.join(' ') if args

        CLI::Kit::System.system(@params['run'], env: env) do |o, e|
          puts CLI::UI.fmt o if o
          puts CLI::UI.fmt e if e
          puts CLI::UI::Color::RESET.code
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
