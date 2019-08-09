require 'd2'

module D2
  module Commands
    class Help < D2::Command
      def call(args, _name)
        CLI::UI::Frame.open("Available Commands", timing: false) do
          local_commands = D2::Commands::Registry.local_commands

          unless local_commands.empty?
            logger.info "{{bold:Local Commands for this project}}"
            local_commands.each do |name, params|
              logger.info "{{command:#{D2::TOOL_NAME} #{name}}}"
              cmd = D2::Commands::LocalCommand.new(name, local_commands[name])
              cmd.help
              logger.info ""
            end
            CLI::UI::Frame.divider(nil)
          end

          logger.info "{{bold:Global Commands}}"

          commands = D2::Commands::Registry.resolved_commands
          if filter = args.shift
            commands = commands.select { |k, _| k == filter }
          end

          commands.each do |name, klass|
            next if name == 'help'
            logger.info "{{command:#{D2::TOOL_NAME} #{name}}}"
            if help = klass.help
              logger.info help
            end
            logger.info ""
          end
        end
      end
    end
  end
end
