module Dev
  module Utils
    module Formatter
      module ClassMethods
        def logger
          Dev::Utils::Formatter::SimpleFormatter
        end
      end

      def logger
        ClassMethods.logger
      end

      def self.included(base)
        base.extend(ClassMethods)
      end

      class SimpleFormatter
        def self.info(msg)
          return if ENV['ENVIRONMENT'] == 'test'
          puts CLI::UI.fmt(msg)
        end

        def self.with_frame(*kwargs)
          if ENV['ENVIRONMENT'] == 'test'
            yield
            return
          end

          CLI::UI::Frame.open(*kwargs) do
            yield
          end
        end
      end
    end
  end
end
