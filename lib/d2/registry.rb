require 'd2'

module D2
  class Registry < CLI::Kit::CommandRegistry
    def initialize
      super(default: 'help', contextual_resolver: nil)
    end

    def lookup_command(name)
      result = super(name)
      result = lookup_local_command(name) if result.first.nil?
      result
    end

    def local_commands
      require 'yaml'
      project_name = File.basename(Dir.pwd)
      yaml_file = File.join(D2::CONFIG_PATH, 'commands', "#{project_name}.yml")
      return {} unless File.exist?(yaml_file)
      YAML.load_file(yaml_file)
    rescue Psych::SyntaxError, SyntaxError => e
      CLI::UI::Frame.open("SyntaxError in #{yaml_file}", color: :red) do
        puts CLI::UI.fmt "The yaml file at {{info::#{yaml_file}}} may be misformatted as we got a syntax error"
        puts e
      end
      return {}
    end

    private

    def lookup_local_command(name)
      commands = local_commands
      return [nil, nil] unless commands.key?(name)
      [D2::Commands::LocalCommand.new(name, commands[name]), name]
    end
  end
end
