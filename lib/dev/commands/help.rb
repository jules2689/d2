require 'dev'

module Dev
  module Commands
    class Help < Dev::Command
      def call(args, _name)
        logger.info "{{bold:Available commands}}"
        logger.info ""

        Dev::Commands::Registry.resolved_commands.each do |name, klass|
          next if name == 'help'
          logger.info "{{command:#{Dev::TOOL_NAME} #{name}}}"
          if help = klass.help
            logger.info help
          end
          logger.info ""
        end
      end
    end
  end
end
