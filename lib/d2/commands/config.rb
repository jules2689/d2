# TODO: Test
require 'd2'

module D2
  module Commands
    class Config < D2::Command
      def call(args, _name)
        case args.shift
        when 'set'
          set(args)
        when 'unset'
          unset(args)
        when 'get'
          get(args)
        when 'list', nil
          logger.info D2::Config.to_s
        else
          logger.info "Unrecognized command. Please see usage\n#{self.class.help}"
        end
      end

      private

      def set(args)
        section = args.shift
        key = nil
        val = nil

        # Set requires a key and a value, so first try to see if section
        # has the key embedded inside
        if section.include?('.')
          section, key = section.split('.', 2)
          val = args.shift
        else
          key = args.shift
          val = args.shift
        end

        if key.nil?
          logger.info "Missing key. Please see usage\n#{self.class.help}"
          return
        end

        if val.nil?
          logger.info "Missing value. Please see usage\n#{self.class.help}"
          return
        end

        logger.info "Setting #{section}.#{key} to #{val}"
        D2::Config.set(section, key, val)
      end

      def unset(args)
        section = args.shift
        key = args.shift

        # If the key is nil and the section has a .
        # then the key is embedded in the section
        if key.nil? && section.include?('.')
          section, key = section.split('.', 2)
        end

        # If the key is still nil, then we need to fail
        if key.nil?
          logger.info "Missing key. Please see usage\n#{self.class.help}"
          return
        end

        if D2::Config.get(section, key)
          logger.info "Unsetting #{section}.#{key}"
          D2::Config.unset(section, key)
        else
          logger.info "No value found for #{section}.#{key} to unset"
        end
      end

      def get(args)
        section = args.shift
        key = args.shift

        # If the key is nil and the section has a .
        # then the key is embedded in the section
        if key.nil? && section.include?('.')
          section, key = section.split('.', 2)
        end

        # If the key is still nil, then we are getting a section
        if key.nil?
          if val = D2::Config.get_section(section)
            logger.info "{{underline:#{section}}}"
            val.each do |k, v|
              logger.info "Value for #{section}.#{k} is #{v}"
            end
          else
            logger.info "No value found for section #{section}"
          end
          return
        end

        # If we make it this far, we have a section and key
        if val = D2::Config.get(section, key)
          logger.info "Value for #{section}.#{key} is #{val}"
        else
          logger.info "No value found for #{section}.#{key}"
        end
      end

      def self.help
        <<~EOF
          D2's Config Manipulation.
          Config is located at #{D2::Config.file}

          Usage:

          List full config
          ===
          {{command:#{D2::TOOL_NAME} config}}

          Get a value
          ===
          {{command:#{D2::TOOL_NAME} config get <section> <key>}}
          {{command:#{D2::TOOL_NAME} config get <section>.<key>}}

          Get a section
          ===
          {{command:#{D2::TOOL_NAME} config get <section>}}

          Set a value
          ===
          {{command:#{D2::TOOL_NAME} config set <section> <key> <val>}}
          {{command:#{D2::TOOL_NAME} config set <section>.<key> <val>}}

          Unset a value
          ===
          {{command:#{D2::TOOL_NAME} config unset <section> <key>}}
          {{command:#{D2::TOOL_NAME} config unset <section>.<key>}}
        EOF
      end
    end
  end
end
