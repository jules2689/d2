require 'cli/ui'
require 'cli/kit'

CLI::UI::StdoutRouter.enable

module D2
  extend CLI::Kit::Autocall

  # The name of the tool
  TOOL_NAME = 'd2'

  # The root directory of the tool
  ROOT = File.expand_path('../..', __FILE__)

  # The file path where the log exists
  LOG_FILE  = '/tmp/d2.log'
  CONFIG_PATH = File.expand_path(File.join(ENV.fetch('XDG_CONFIG_HOME', '~/.config'), TOOL_NAME))

  autoload(:EntryPoint, 'd2/entry_point')
  autoload(:Commands,   'd2/commands')
  autoload(:Tasks,      'd2/tasks')
  autoload(:Registry,   'd2/registry')
  autoload(:Project,    'd2/project')

  autocall(:Config)  { CLI::Kit::Config.new(tool_name: TOOL_NAME) }

  autocall(:Executor) { CLI::Kit::Executor.new(log_file: LOG_FILE) }
  autocall(:Resolver) do
    CLI::Kit::Resolver.new(
      tool_name: TOOL_NAME,
      command_registry: D2::Commands::Registry
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
  # Use +D2::FILE_DESCRIPTOR.write("cd blah")+ to add to the file descriptor for evaluation in the parent.
  FILE_DESCRIPTOR = FileDescriptor.new


  class DataDir
    attr_accessor :path

    def file(file)
      require 'fileutils'
      path = File.join(@path, file)
      FileUtils.mkpath(File.dirname(path)) unless File.exist?(path)
      path
    end
  end
  DATA_DIR = DataDir.new

  module Utils
    autoload :Cacheable, 'd2/utils/cacheable'
    autoload :FirstRun,  'd2/utils/first_run'
    autoload :Formatter, 'd2/utils/formatter'
  end

  module Helpers
    autoload :Fzy,       'd2/helpers/fzy'
    autoload :Git,       'd2/helpers/git'
    autoload :Homebrew,  'd2/helpers/homebrew'
  end

  class Command < CLI::Kit::BaseCommand
    include D2::Utils::Formatter
  end
end
