require 'test_helper'

module Dev
  module Helpers
    module Git
      class ExampleTest < MiniTest::Test
        include CLI::Kit::Support::TestHelper
        include FakeConfig

        def setup
          super
          Dev::Config.set('git', 'default_provider', default_provider)
          Dev::Config.set('git', 'default_owner', default_owner)
        end

        def test_with_ssh_url
          url = Dev::Helpers::Git::Url.new('git@github.com:jules2689/dev.git')
          assert_equal 'github.com', url.provider
          assert_equal 'jules2689', url.org_or_user
          assert_equal 'dev', url.repo_name
          assert_equal 'git@github.com:jules2689/dev.git', url.url(type: 'ssh')
          assert_equal 'https://github.com/jules2689/dev.git', url.url(type: 'https')
        end

        def test_with_https_url
          url = Dev::Helpers::Git::Url.new('https://github.com/jules2689/dev.git')
          assert_equal 'github.com', url.provider
          assert_equal 'jules2689', url.org_or_user
          assert_equal 'dev', url.repo_name
          assert_equal 'git@github.com:jules2689/dev.git', url.url(type: 'ssh')
          assert_equal 'https://github.com/jules2689/dev.git', url.url(type: 'https')
        end

        def test_with_org_and_repo_fragment
          url = Dev::Helpers::Git::Url.new('jules2689/dev')
          assert_equal default_provider, url.provider
          assert_equal 'jules2689', url.org_or_user
          assert_equal 'dev', url.repo_name
          assert_equal "git@#{default_provider}:jules2689/dev.git", url.url(type: 'ssh')
          assert_equal "https://#{default_provider}/jules2689/dev.git", url.url(type: 'https')
        end

        def test_with_repo_fragment
          url = Dev::Helpers::Git::Url.new('dev')
          assert_equal default_provider, url.provider
          assert_equal default_owner, url.org_or_user
          assert_equal 'dev', url.repo_name
          assert_equal "git@#{default_provider}:#{default_owner}/dev.git", url.url(type: 'ssh')
          assert_equal "https://#{default_provider}/#{default_owner}/dev.git", url.url(type: 'https')
        end

        def test_with_ssh_url_without_git_suffix
          url = Dev::Helpers::Git::Url.new('git@github.com:jules2689/dev')
          assert_equal 'github.com', url.provider
          assert_equal 'jules2689', url.org_or_user
          assert_equal 'dev', url.repo_name
          assert_equal 'git@github.com:jules2689/dev.git', url.url(type: 'ssh')
          assert_equal 'https://github.com/jules2689/dev.git', url.url(type: 'https')
        end

        def test_with_alternate_provider
          url = Dev::Helpers::Git::Url.new('git@bitbucket.org:jules2689/dev')
          assert_equal 'bitbucket.org', url.provider
          assert_equal 'jules2689', url.org_or_user
          assert_equal 'dev', url.repo_name
          assert_equal 'git@bitbucket.org:jules2689/dev.git', url.url(type: 'ssh')
          assert_equal 'https://bitbucket.org/jules2689/dev.git', url.url(type: 'https')
        end

        def default_provider
          'git-server.com'
        end

        def default_owner
          'a_user'
        end
      end
    end
  end
end
