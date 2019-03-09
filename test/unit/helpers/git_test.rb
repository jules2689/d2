require 'test_helper'

module Dev
  module Helpers
    class GitTest < MiniTest::Test
      include CLI::Kit::Support::TestHelper

      def test_config
        CLI::Kit::System.fake('git config --list', success: true, stdout: <<~EOF)
        credential.helper=osxkeychain
        commit.gpgsign=true
        user.name=Julian Nadeau
        user.email=email@email.com
        gpg.program=gpg
        EOF

        assert_equal({
          'credential.helper' => 'osxkeychain',
          'commit.gpgsign' => 'true',
          'user.name' => 'Julian Nadeau',
          'user.email' => 'email@email.com',
          'gpg.program' => 'gpg',
        }, Dev::Helpers::Git.config)
      end
    end
  end
end
