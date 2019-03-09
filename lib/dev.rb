require 'cli/ui'
require 'cli/kit'

CLI::UI::StdoutRouter.enable

module Dev
  extend CLI::Kit::Autocall

  # The name of the tool
  TOOL_NAME = 'dev'

  # The root directory of the tool
  ROOT      = File.expand_path('../..', __FILE__)

  # The file path where the log exists
  LOG_FILE  = '/tmp/dev.log'

  autoload(:EntryPoint, 'dev/entry_point')
  autoload(:Commands,   'dev/commands')

  autocall(:Config)  { CLI::Kit::Config.new(tool_name: TOOL_NAME) }

  autocall(:Executor) { CLI::Kit::Executor.new(log_file: LOG_FILE) }
  autocall(:Resolver) do
    CLI::Kit::Resolver.new(
      tool_name: TOOL_NAME,
      command_registry: Dev::Commands::Registry
    )
  end

  autocall(:ErrorHandler) do
    CLI::Kit::ErrorHandler.new(
      log_file: LOG_FILE,
      exception_reporter: nil
    )
  end

  class FileDescriptor
    # Path to the file descriptor. Set in Entrypoint
    # @private
    attr_accessor :path

    # Write out to the file descriptor to interact with the parent process (shell)
    #
    # @param [String] cmd to execute in the parent environment
    #
    def write(cmd)
      fd = IO.sysopen(@path, 'w')
      io = IO.new(fd)
      io.write("#{cmd}\n")
      io.close
    end
  end

  # The file descriptor object used to interact with the OS file descriptor 9
  # This is used by the Ruby process (child) to communicate with the parent process (shell).
  # On finalization of the shell function, the file descriptor is used to manipulate the
  # parent environment.
  # Use +Dev::FILE_DESCRIPTOR.write("cd blah")+ to add to the file descriptor for evaluation in the parent.
  FILE_DESCRIPTOR = FileDescriptor.new

  module Utils
    autoload :FirstRun,  'dev/utils/first_run'
    autoload :Formatter, 'dev/utils/formatter'
  end

  module Helpers
    autoload :Fzy,       'dev/helpers/fzy'
    autoload :Git,       'dev/helpers/git'
  end

  class Command < CLI::Kit::BaseCommand
    include Dev::Utils::Formatter
  end
end
