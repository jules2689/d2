# TODO: Test
require 'd2'

module D2
  module Commands
    class Open < D2::Command
      def call(args, _name)
        git_dir = File.join(Dir.pwd, '.git')
        if !File.exist?(git_dir)
          logger.info "No git repo found in current path (#{git_dir})"
          return
        end

        return if base_url.nil?

        case args.shift
        when 'i', 'issues', 'issue'
          open_url(path: 'issues')
        when 'prs', 'pulls', 'pull_requests'
          open_url(path: 'pulls')
        when 'pr', 'pull_request'
          pr = args.shift || D2::Helpers::Git::LocalRepo.current_branch
          open_url(path: ['pull', pr])
        else
          open_url
        end
      end

      private

      def base_url
        repo = D2::Helpers::Git::LocalRepo.new
        repo.url(type: 'https', with_dot_git: false)
      end

      def open_url(url: base_url, path: nil)
        url = path ? File.join(url, *[path].flatten) : url
        logger.info "Opening #{url}"
        sleep 0.5
        CLI::Kit::System.system("open #{url}")
      end

      def self.help
        <<~EOF
          Open the repo, issues, or PR.
          Usage:

          {{bold:Open a Repo}}
          {{command:#{D2::TOOL_NAME} open}}

          {{bold:Open a Repo's Issues}}
          {{command:#{D2::TOOL_NAME} open issues}}
          {{command:#{D2::TOOL_NAME} open i}}

          {{bold:Open a Repo's Pull Requests}}
          {{command:#{D2::TOOL_NAME} open prs}}
          {{command:#{D2::TOOL_NAME} open pull_request}}

          {{bold:Open a PR}}
          {{command:#{D2::TOOL_NAME} open pr <NUMBER>}}

          {{bold:Open a PR for the current branch}}
          {{command:#{D2::TOOL_NAME} open pr}}
        EOF
      end
    end
  end
end
