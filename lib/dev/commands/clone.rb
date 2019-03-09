require 'dev'

module Dev
  module Commands
    class Clone < Dev::Command
      def call(args, _name)
        git_repo = Dev::Helpers::Git::Url.new(args.shift)
        org_path = File.expand_path("~/src/#{git_repo.provider}/#{git_repo.org_or_user}/")
        repo_path = File.join(org_path, git_repo.repo_name)

        unless Dir.exist?(repo_path)
          require 'fileutils'
          FileUtils.mkdir_p(org_path)

          url = git_repo.url(type: 'ssh')
          puts "Cloning #{url}"
          system("git clone #{url} #{repo_path}")
        end

        Dev::FILE_DESCRIPTOR.write("cd #{repo_path}")
      end

      def self.help
        <<~EOF
          Clone a repository.
          Supports any git url, as well as fragments.

          E.g. The following would all clone https://#{Dev::Helpers::Git::Url::DEFAULT_PROVIDER}/#{Dev::Helpers::Git::Url::DEFAULT_ORG_OR_USER}/Repo.git
           {{info:git@#{Dev::Helpers::Git::Url::DEFAULT_PROVIDER}:#{Dev::Helpers::Git::Url::DEFAULT_ORG_OR_USER}/Repo.git
           https://#{Dev::Helpers::Git::Url::DEFAULT_PROVIDER}/#{Dev::Helpers::Git::Url::DEFAULT_ORG_OR_USER}/Repo.git
           #{Dev::Helpers::Git::Url::DEFAULT_ORG_OR_USER}/Repo
           Repo}}

          {{italic:Default Provider, when none specified, is #{Dev::Helpers::Git::Url::DEFAULT_PROVIDER}
          Default Repo Owner, when none specified, is #{Dev::Helpers::Git::Url::DEFAULT_ORG_OR_USER}}}

          Usage: {{command:#{Dev::TOOL_NAME} clone <repo>}}
        EOF
      end
    end
  end
end
