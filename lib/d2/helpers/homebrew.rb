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

        def bundle_check
          Utils::Cacheable.cached_by_folder_contents('homebrew/bundle_folder', "/usr/local/Cellar") do
            Utils::Cacheable.cached_by_file('homebrew/bundle_brewfile', 'Brewfile') do
              CLI::Kit::System.capture2("brew bundle check").last.success?
            end
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
