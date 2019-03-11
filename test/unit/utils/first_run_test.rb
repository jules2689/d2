require 'test_helper'

module D2
  module Utils
    class FirstRunTest < MiniTest::Test
      include CLI::Kit::Support::TestHelper
      include FakeConfig

      def test_first_run_without_default_provider
        CLI::UI.expects(:ask).with(
          'What is the most common git provider you use?',
          options: %w(github.com gitlab.com bitbucket.org other)
        ).returns('github.com')
        D2::Config.set('git', 'default_owner', 'default_owner')
        D2::Config.set('src_path', 'default', '~/src')
        D2::Utils::FirstRun.call
        assert_equal 'github.com', D2::Config.get('git', 'default_provider')
      end

      def test_first_run_without_other_default_provider
        CLI::UI.expects(:ask).with(
          'What is the most common git provider you use?',
          options: %w(github.com gitlab.com bitbucket.org other)
        ).returns('other')
        CLI::UI.expects(:ask).with(
          'Please enter the most common git provider you use? (format as domain.com)'
        ).returns('mydomain.com')
        D2::Config.set('git', 'default_owner', 'default_owner')
        D2::Config.set('src_path', 'default', '~/src')
        D2::Utils::FirstRun.call
        assert_equal 'mydomain.com', D2::Config.get('git', 'default_provider')
      end

      def test_first_run_without_default_owner
        CLI::UI.expects(:ask)
          .with('From which organization or user do you clone repos the most?')
          .returns('owner')
        D2::Config.set('git', 'default_provider', 'default_provider')
        D2::Config.set('src_path', 'default', '~/src')
        D2::Utils::FirstRun.call
        assert_equal 'owner', D2::Config.get('git', 'default_owner')
      end

      def test_first_run_without_any_git_config
        CLI::UI.expects(:ask).with(
          'What is the most common git provider you use?',
          options: %w(github.com gitlab.com bitbucket.org other)
        ).returns('github.com')

        CLI::UI.expects(:ask)
          .with('From which organization or user do you clone repos the most?')
          .returns('owner')

        D2::Config.set('src_path', 'default', '~/src')

        D2::Utils::FirstRun.call

        assert_equal 'github.com', D2::Config.get('git', 'default_provider')
        assert_equal 'owner', D2::Config.get('git', 'default_owner')
      end

      def test_first_run_without_src_path
        dir = Dir.mktmpdir
        D2::Config.set('git', 'default_provider', 'default_provider')
        D2::Config.set('git', 'default_owner', 'default_owner')

        CLI::UI.expects(:ask)
          .with(
            'Where do you want your code to clone to? (Must be a directory)',
            is_file: true,
            default: '~/src'
          ).returns(dir)

        D2::Utils::FirstRun.call
      ensure
        FileUtils.rm_rf(dir)
      end

      def test_first_run_with_all_options
        D2::Config.set('git', 'default_provider', 'default_provider')
        D2::Config.set('git', 'default_owner', 'default_owner')
        D2::Config.set('src_path', 'default', '~/src')
        D2::Utils::FirstRun.call
      end
    end
  end
end
