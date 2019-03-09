require 'dev'

module Dev
  module Commands
    Registry = CLI::Kit::CommandRegistry.new(
      default: 'help',
      contextual_resolver: nil
    )

    def self.register(const, cmd, path)
      autoload(const, path)
      Registry.add(->() { const_get(const) }, cmd)
    end

    register :Cd,      'cd',      'dev/commands/cd'
    register :Clone,   'clone',   'dev/commands/clone'
    register :Config,  'config',  'dev/commands/config'
    register :Help,    'help',    'dev/commands/help'
  end
end
