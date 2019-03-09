require 'test_helper'

module Dev
  module Helpers
    module Git
      class LocalRepoTest < MiniTest::Test
        include CLI::Kit::Support::TestHelper
        include FakeConfig

        def setup
          super
          Dev::Config.set('src_path', 'default', '~/src')
          Dev::Config.set('git', 'default_provider', default_provider)
          Dev::Config.set('git', 'default_owner', default_owner)
        end

        def test_with_ssh_url
          local_repo = Dev::Helpers::Git::LocalRepo.new('git@github.com:jules2689/dev.git')
          assert_equal 'github.com', local_repo.provider
          assert_equal 'jules2689', local_repo.org_or_user
          assert_equal 'dev', local_repo.repo_name
          assert_equal 'git@github.com:jules2689/dev.git', local_repo.url(type: 'ssh')
          assert_equal 'https://github.com/jules2689/dev.git', local_repo.url(type: 'https')
          assert_equal File.expand_path("~/src/github.com/jules2689/dev"), local_repo.path_on_disk
        end

        def test_with_https_url
          local_repo = Dev::Helpers::Git::LocalRepo.new('https://github.com/jules2689/dev.git')
          assert_equal 'github.com', local_repo.provider
          assert_equal 'jules2689', local_repo.org_or_user
          assert_equal 'dev', local_repo.repo_name
          assert_equal 'git@github.com:jules2689/dev.git', local_repo.url(type: 'ssh')
          assert_equal 'https://github.com/jules2689/dev.git', local_repo.url(type: 'https')
          assert_equal File.expand_path("~/src/github.com/jules2689/dev"), local_repo.path_on_disk
        end

        def test_with_org_and_repo_fragment
          local_repo = Dev::Helpers::Git::LocalRepo.new('jules2689/dev')
          assert_equal default_provider, local_repo.provider
          assert_equal 'jules2689', local_repo.org_or_user
          assert_equal 'dev', local_repo.repo_name
          assert_equal "git@#{default_provider}:jules2689/dev.git", local_repo.url(type: 'ssh')
          assert_equal "https://#{default_provider}/jules2689/dev.git", local_repo.url(type: 'https')
          assert_equal File.expand_path("~/src/#{default_provider}/jules2689/dev"), local_repo.path_on_disk
        end

        def test_with_repo_fragment
          local_repo = Dev::Helpers::Git::LocalRepo.new('dev')
          assert_equal default_provider, local_repo.provider
          assert_equal default_owner, local_repo.org_or_user
          assert_equal 'dev', local_repo.repo_name
          assert_equal "git@#{default_provider}:#{default_owner}/dev.git", local_repo.url(type: 'ssh')
          assert_equal "https://#{default_provider}/#{default_owner}/dev.git", local_repo.url(type: 'https')
          assert_equal File.expand_path("~/src/#{default_provider}/#{default_owner}/dev"), local_repo.path_on_disk
        end

        def test_with_ssh_url_without_git_suffix
          local_repo = Dev::Helpers::Git::LocalRepo.new('git@github.com:jules2689/dev')
          assert_equal 'github.com', local_repo.provider
          assert_equal 'jules2689', local_repo.org_or_user
          assert_equal 'dev', local_repo.repo_name
          assert_equal 'git@github.com:jules2689/dev.git', local_repo.url(type: 'ssh')
          assert_equal 'https://github.com/jules2689/dev.git', local_repo.url(type: 'https')
          assert_equal File.expand_path('~/src/github.com/jules2689/dev'), local_repo.path_on_disk
        end

        def test_with_alternate_provider
          local_repo = Dev::Helpers::Git::LocalRepo.new('git@bitbucket.org:jules2689/dev')
          assert_equal 'bitbucket.org', local_repo.provider
          assert_equal 'jules2689', local_repo.org_or_user
          assert_equal 'dev', local_repo.repo_name
          assert_equal 'git@bitbucket.org:jules2689/dev.git', local_repo.url(type: 'ssh')
          assert_equal 'https://bitbucket.org/jules2689/dev.git', local_repo.url(type: 'https')
          assert_equal File.expand_path('~/src/bitbucket.org/jules2689/dev'), local_repo.path_on_disk
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
