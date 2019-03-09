require 'uri'

module Dev
  module Helpers
    module Git
      class Url
        TYPES = {
          ssh: 'ssh',
          https: 'https',
          org_repo: 'org_repo',
          repo: 'repo',
          undetermined: 'undetermined'
        }
        private_constant :TYPES
        UndeterminedError = Class.new(StandardError)

        def initialize(fragment)
          @fragment = fragment.gsub(/\.git$/, '')
        end

        # The provider for the url, aka the git server
        # This will usually be one of: github.com, bitbucket.org, or gitlab.com
        # Defaults to the default provider set in the config in the case none is specified
        #
        # == Returns
        # @return String the provider (host) for the repo
        #
        def provider
          case fragement_type
          when TYPES[:ssh], TYPES[:https]
            parsed_uri.host
          when TYPES[:org_repo], TYPES[:repo]
            Dev::Config.get('git', 'default_provider')
          when TYPES[:undetermined]
            raise UndeterminedError
          end
        end

        # The organization or user that owns the repo
        # Defaults to DEFAULT_ORG_OR_USER in the case none is specified
        #
        # == Returns
        # @return String the organization or user
        #
        def org_or_user
          split_path = path.split('/', 2)
          case split_path.size
          when 1
            Dev::Config.get('git', 'default_owner')
          when 2
            split_path.first
          end
        end

        # The repository name
        #
        # == Returns
        # @return String the repo name
        #
        def repo_name
          path.split('/', 2).last
        end

        # Provides a full git URL in SSH or HTTPS format
        #
        # == Params
        # @param type [ssh, https] The type of the url required
        #
        # == Returns
        # @return String url representing the repo in the requested format
        #
        # == Raises
        # @raise ArgumentError when type is not supported
        #
        def url(type:)
          case type
          when 'ssh'
            "git@#{provider}:#{org_or_user}/#{repo_name}.git"
          when 'https'
            "https://#{provider}/#{org_or_user}/#{repo_name}.git"
          else
            raise ArgumentError, "#{type} is not a supported type"
          end
        end

        def inspect
          [
            "Class: #{self}",
            "fragment [#{@fragment}]",
            "provider [#{provider}]",
            "path [#{path}]",
            "org_or_user [#{org_or_user}]",
            "repo_name [#{repo_name}]",
            "ssh [#{url(type: 'ssh')}]",
            "https [#{url(type: 'https')}]",
          ].join(" || ")
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
