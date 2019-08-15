require 'd2'

module D2
  class Registry < CLI::Kit::CommandRegistry
    def initialize
      super(default: 'help', contextual_resolver: nil)
    end

    def lookup_command(name)
      result = super(name)
      result = lookup_local_command(name) if result.first.nil?
      result
    end

    def local_commands
      @local_commands ||= D2::Project.new.definition['commands']
    end

    private

    def lookup_local_command(name)
      commands = local_commands
      return [nil, nil] unless commands.key?(name)
      [D2::Commands::LocalCommand.new(name, commands[name]), name]
    end
  end
end
