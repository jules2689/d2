module Dev
  module Helpers
    module Git
      autoload :Url, 'dev/helpers/git/url'

      # Returns a hash representation of the current git config
      #
      # @return [Hash] hash representing the git config
      def self.config
        config, _ = CLI::Kit::System.capture2e('git config --list')
        ini = CLI::Kit::Ini.new
        ini.instance_variable_set(:@config, config.lines) # TODO: Add support
        ini.parse
      end
    end
  end
end
