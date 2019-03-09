module Dev
  module Helpers
    module FirstRun
      class << self
        # Runs or No-Ops on a series of first-run checks
        # This makes sure that the system is configured as expected
        #
        def call
          git_run
          src_path
        end

        private

        def git_run
          git_section = Dev::Config.get_section('git')
          return if git_section['default_provider'] && git_section['default_owner']

          CLI::UI::Frame.open('Git Integration', timing: false) do
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

        def src_path
          return if Dev::Config.get('src_path', 'default')

          CLI::UI::Frame.open('Code Source Path', timing: false) do
            puts CLI::UI.fmt "Code will be cloned to the source path you specify here."
            puts CLI::UI.fmt "Inside the folder, code will obey a simple heuristic:"
            puts CLI::UI.fmt "  {{info:path/to/src_path}}/{{info:provider}}/{{info:owner}}/{{info:repo_name}}"
            puts CLI::UI.fmt "For example, https://github.com/user/repo would clone to:"
            puts CLI::UI.fmt "  {{info:path/to/src_path}}/{{info:github.com}}/{{info:user}}/{{info:repo}}"
            puts CLI::UI.fmt ""

            src_path = nil
            while src_path.nil? || !File.directory?(File.expand_path(src_path))
              src_path = CLI::UI.ask('Where do you want your code to clone to? (Must be a directory)', is_file: true, default: '~/src')
            end

            require 'fileutils'
            FileUtils.mkdir_p(File.expand_path(src_path))

            Dev::Config.set('src_path', 'default', src_path)
          end
        end
      end
    end
  end
end
