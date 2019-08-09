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

    private

    def lookup_local_command(name)
      project_name = File.basename(Dir.pwd)
      yaml_file = File.join(D2::CONFIG_PATH, 'commands', "#{project_name}.yml")
      return [nil, nil] unless File.exist?(yaml_file)

      require 'yaml'
      begin
        yaml = YAML.load_file(yaml_file)
        return [nil, nil] unless yaml.key?(name)

        [D2::Commands::LocalCommand.new(name, yaml[name]), name]
      rescue Psych::SyntaxError, SyntaxError => e
        CLI::UI::Frame.open("SyntaxError in #{yaml_file}", color: :red) do
          puts CLI::UI.fmt "The yaml file at {{info::#{yaml_file}}} may be misformatted as we got a syntax error"
          puts e
        end
        [nil, nil]
      end
    end
  end
end
