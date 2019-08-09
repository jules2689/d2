require 'd2'

module D2
  module Commands
    Registry = D2::Registry.new

    def self.register(const, cmd, path)
      autoload(const, path)
      Registry.add(->() { const_get(const) }, cmd)
    end

    autoload "LocalCommand", "d2/commands/local_command"

    register :Cd,      'cd',      'd2/commands/cd'
    register :Clone,   'clone',   'd2/commands/clone'
    register :Config,  'config',  'd2/commands/config'
    register :Help,    'help',    'd2/commands/help'
    register :Open,    'open',    'd2/commands/open'
    register :Up,      'up',      'd2/commands/up'
  end
end
