require 'dev'

module Dev
  module Commands
    class Clone < Dev::Command
      def call(args, _name)
        git_repo = Dev::Helpers::Git::LocalRepo.new(args.shift)

        unless Dir.exist?(git_repo.path_on_disk)
          require 'fileutils'
          FileUtils.mkdir_p(File.dirname(git_repo.path_on_disk))

          url = git_repo.url(type: 'ssh')
          puts "Cloning #{url}"
          system("git clone #{url} #{git_repo.path_on_disk}")
        end

        Dev::FILE_DESCRIPTOR.write("cd #{git_repo.path_on_disk}")
      end

      def self.help
        <<~EOF
          Clone a repository.
          Supports any git url, as well as fragments.

          E.g. The following would all clone https://github.com/owner/Repo.git
           {{info:git@github.com:owner/Repo.git
           https://github.com/owner/Repo.git
           owner/Repo
           Repo}}

          {{italic:Default Provider, when none specified, is #{ Dev::Config.get('git', 'default_provider')}
          Default Repo Owner, when none specified, is #{ Dev::Config.get('git', 'default_owner')}}}

          Usage: {{command:#{Dev::TOOL_NAME} clone <repo>}}
        EOF
      end
    end
  end
end
