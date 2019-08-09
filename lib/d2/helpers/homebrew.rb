module D2
  module Helpers
    module Homebrew
      BREW_INSTALL_COMMAND = "/usr/bin/ruby -e \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)\""

      class << self
        def installed?
          CLI::Kit::System.capture2('which brew').last.success?
        end

        def install
          run(BREW_INSTALL_COMMAND)
        end

        def bundle
          run("brew bundle")
        end

        # TODO: Need to cache based on actually installed things?
        def bundle_check
          Utils::Cacheable.cached_by_file('homebrew/bundle', 'Brewfile') do
            CLI::Kit::System.capture2("brew bundle check").last.success?
          end
        end

        private

        def run(script)
          title = "Running {{command:#{script}}}"
          success = false

          CLI::UI::Spinner.spin(title) do |spinner|
            success = CLI::Kit::System.system(script).success?
            raise "#{script} failed" unless success
          end

          success
        end
      end
    end
  end
end
