require 'd2'

module D2
  module EntryPoint # @private
    # @private
    def self.call(args)
      # First argument is artificially changed to be the file descriptor in the shell function
      D2::FILE_DESCRIPTOR.path = args.shift

      D2::Utils::FirstRun.call
      cmd, command_name, args = D2::Resolver.call(args)
      D2::Executor.call(cmd, command_name, args)
    end
  end
end
