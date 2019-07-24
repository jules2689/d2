require 'uri'

module D2
  module Helpers
    module Git
      class LocalRepo
        TYPES = {
          ssh: 'ssh',
          https: 'https',
          org_repo: 'org_repo',
          repo: 'repo',
          undetermined: 'undetermined'
        }
        private_constant :TYPES
        UndeterminedError = Class.new(StandardError)

        def self.current_branch
          CLI::Kit::System.capture3("git branch | grep \\* | cut -d ' ' -f2")&.first&.chomp
        end

        def self.origin
          CLI::Kit::System.capture3("git config --local remote.origin.url")&.first&.chomp
        end

        def initialize(fragment: LocalRepo.origin)
          @fragment = fragment.gsub(/\.git$/, '').chomp
        end

        # The provider for the url, aka the git server
        # This will usually be one of: github.com, bitbucket.org, or gitlab.com
        # Defaults to the default provider set in the config in the case none is specified
        #
        # @return [String] the provider (host) for the repo
        #
        def provider
          case fragement_type
          when TYPES[:ssh], TYPES[:https]
            parsed_uri.host
          when TYPES[:org_repo], TYPES[:repo]
            D2::Config.get('git', 'default_provider')
          when TYPES[:undetermined]
            raise UndeterminedError
          end
        end

        # The organization or user that owns the repo
        # Defaults to DEFAULT_ORG_OR_USER in the case none is specified
        #
        # @return [String] the organization or user
        #
        def org_or_user
          split_path = path.split('/', 2)
          case split_path.size
          when 1
            D2::Config.get('git', 'default_owner')
          when 2
            split_path.first
          end
        end

        # The repository name
        #
        # @return [String] the repo name
        #
        def repo_name
          path.split('/', 2).last
        end

        # Provides a full git URL in SSH or HTTPS format
        #
        # @param [String] type (ssh or https) The type of the url required
        # @return [String] url representing the repo in the requested format
        # @raise [ArgumentError] when type is not supported
        #
        def url(type:, with_dot_git: true)
          url = case type
          when 'ssh'
            "git@#{provider}:#{org_or_user}/#{repo_name}"
          when 'https'
            "https://#{provider}/#{org_or_user}/#{repo_name}"
          else
            raise ArgumentError, "#{type} is not a supported type"
          end
          url = url + ".git" if with_dot_git
          url
        end

        def path_on_disk
          File.expand_path(
            File.join(
              D2::Config.get('src_path', 'default'),
              provider,
              org_or_user,
              repo_name
            )
          )
        end

        private

        def path
          @path = case fragement_type
          when TYPES[:ssh], TYPES[:https]
            parsed_uri.path.gsub(/^\//, '')
          when TYPES[:org_repo], TYPES[:repo]
            @fragment
          when TYPES[:undetermined]
            raise UndeterminedError
          end
        end

        def parsed_uri
          @parsed_uri ||= case fragement_type
          when TYPES[:ssh]
            # Convert from git@Provider.com:OrgOrUser/Repo.git
            # to https url https://Provider.com/OrgOrUser/Repo.git
            url = @fragment.gsub(/git@/, 'https://').gsub(/(\.\w+):(\w+)/, '\1/\2')
            URI.parse(url)
          when TYPES[:https]
            URI.parse(@fragment)
          else
            nil
          end
        end

        def fragement_type
          @fragement_type ||= begin
            case @fragment
            when /^git@.*/
              TYPES[:ssh]
            when /https:/
              TYPES[:https]
            when /\w+\/\w+/
              TYPES[:org_repo]
            when /\w+/
              TYPES[:repo]
            else
              TYPES[:undetermined]
            end
          end
        end
      end
    end
  end
end
