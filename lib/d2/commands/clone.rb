require 'd2'

module D2
  module Commands
    class Clone < D2::Command
      def call(args, _name)
        git_repo = D2::Helpers::Git::LocalRepo.new(args.shift)

        unless Dir.exist?(git_repo.path_on_disk)
          require 'fileutils'
          FileUtils.mkdir_p(File.dirname(git_repo.path_on_disk))

          url = git_repo.url(type: 'ssh')
          logger.info "Cloning #{url}"
          CLI::Kit::System.system("git clone #{url} #{git_repo.path_on_disk}")
        end

        D2::FILE_DESCRIPTOR.write("cd #{git_repo.path_on_disk}")
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

          {{italic:Default Provider, when none specified, is #{ D2::Config.get('git', 'default_provider')}
          Default Repo Owner, when none specified, is #{ D2::Config.get('git', 'default_owner')}}}

          Usage: {{command:#{D2::TOOL_NAME} clone <repo>}}
        EOF
      end
    end
  end
end
