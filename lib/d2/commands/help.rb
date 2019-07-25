require 'd2'

module D2
  module Commands
    class Help < D2::Command
      def call(args, _name)
        logger.info "{{bold:Available commands}}"
        logger.info ""

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
