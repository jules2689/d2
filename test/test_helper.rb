require_relative '../exe/load_dev'
require 'cli/kit'

require 'fileutils'
require 'tmpdir'
require 'tempfile'

require 'rubygems'
require 'bundler/setup'

CLI::UI::StdoutRouter.enable

require 'minitest/autorun'
require "minitest/unit"
require 'mocha/minitest'

ENV['ENVIRONMENT'] = 'test'

module FakeConfig
  def setup
    super
    Dev::Config.instance_variable_set(:@ini, nil)
    @original_config_home = ENV['XDG_CONFIG_HOME']
    ENV['XDG_CONFIG_HOME'] = Dir.mktmpdir
  end

  def teardown
    FileUtils.rm_rf(ENV['XDG_CONFIG_HOME'])
    ENV['XDG_CONFIG_HOME'] = @original_config_home
    super
  end
end
