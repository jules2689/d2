require 'd2'

module D2
  class Project
    def initialize(dir = Dir.pwd)
      @dir = dir
    end

    def definition
      @definition ||= begin
        require 'yaml'
        return YAML.load_file('d2.yml') if File.exist?('d2.yml')

        project_name = File.basename(@dir)
        yaml_file = File.join(D2::CONFIG_PATH, 'projects', "#{project_name}.yml")
        return {} unless File.exist?(yaml_file)

        YAML.load_file(yaml_file)
      end

    rescue Psych::SyntaxError, SyntaxError => e
      CLI::UI::Frame.open("SyntaxError in #{yaml_file}", color: :red) do
        puts CLI::UI.fmt "The yaml file at {{info::#{yaml_file}}} may be misformatted as we got a syntax error"
        puts e
      end
      return {}
    end
  end
end
