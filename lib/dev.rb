require 'cli/ui'
require 'cli/kit'

CLI::UI::StdoutRouter.enable

module Dev
  extend CLI::Kit::Autocall

  TOOL_NAME = 'dev'
  ROOT      = File.expand_path('../..', __FILE__)
  LOG_FILE  = '/tmp/dev.log'

  autoload(:EntryPoint, 'dev/entry_point')
  autoload(:Commands,   'dev/commands')

  autocall(:Config)  { CLI::Kit::Config.new(tool_name: TOOL_NAME) }
  autocall(:Command) { CLI::Kit::BaseCommand }

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
    attr_accessor :path

    def write(cmd)
      fd = IO.sysopen(@path, 'w')
      io = IO.new(fd)
      io.write("#{cmd}\n")
      io.close
    end
  end
  FILE_DESCRIPTOR = FileDescriptor.new

  module Helpers
    autoload :FirstRun, 'dev/helpers/first_run'
    autoload :Fzy,      'dev/helpers/fzy'
    autoload :Git,      'dev/helpers/git'
  end
end
