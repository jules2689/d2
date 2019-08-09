require 'd2'

module D2
  module Tasks
    REGISTRY = {}
    private_constant :REGISTRY

    def self.register(task, consts)
      consts.each do |const, path|
        autoload(const, path)
      end
      REGISTRY[task] = consts.keys
    end

    def self.tasks(task)
      REGISTRY[task].flat_map { |c| const_get(c) }
    end

    register 'homebrew', { InstallHomebrew: 'd2/tasks/install_homebrew', BundleHomebrew: 'd2/tasks/bundle_homebrew' }
  end
end
