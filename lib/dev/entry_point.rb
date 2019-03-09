require 'dev'

module Dev
  module EntryPoint
    def self.call(args)
      # First argument is artificially changed to be the file descriptor in the shell function
      Dev::FILE_DESCRIPTOR.path = args.shift

      Dev::Helpers::FirstRun.call
      cmd, command_name, args = Dev::Resolver.call(args)
      Dev::Executor.call(cmd, command_name, args)
    end
  end
end
