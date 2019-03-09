module Dev
  module Helpers
    module FirstRun
      class << self
        # Runs or No-Ops on a series of first-run checks
        # This makes sure that the system is configured as expected
        #
        def call
          git_run
        end

        private

        def git_run
          git_section = Dev::Config.get_section('git')
          return if git_section['default_provider'] && git_section['default_owner']

          if git_section['default_provider'].nil?
            default_provider = CLI::UI.ask(
              'What is the most common git provider you use?',
              options: %w(github.com gitlab.com bitbucket.org other)
            )

            while default_provider !~ /\w+\.com/
              default_provider = CLI::UI.ask(
                'Please enter the most common git provider you use? (format as domain.com)'
              )
            end

            Dev::Config.set('git', 'default_provider', default_provider)
          end

          if git_section['default_owner'].nil?
            owner = CLI::UI.ask(
              'From which organization or user do you clone repos the most?'
            )
            Dev::Config.set('git', 'default_owner', owner)
          end
        end
      end
    end
  end
end
