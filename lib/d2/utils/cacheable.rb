# frozen_string_literal: true

require 'digest'

module D2
  module Utils
    module Cacheable
      def self.cached_by_file(section, file)
        cached(section, -> { Digest::SHA2.hexdigest(File.read(file)) }) do
          yield
        end
      end

      def self.cached_by_folder_contents(section, folder)
        cached(section, -> { CLI::Kit::System.capture2("ls #{folder} | shasum | awk '{ print $1 }'").first }) do
          yield
        end
      end

      def self.cached(section, cache_key_proc)
        run_yield = lambda do |cache_key_file|
          ret = yield
          if ret
            new_cache_key = cache_key_proc.call
            File.write(cache_key_file, new_cache_key)
          end
          ret
        end

        cache_key_file = D2::DATA_DIR.file(File.join('cache', section, Digest::SHA2.hexdigest(Dir.pwd)))

        require 'digest'
        cache_key_file = D2::DATA_DIR.file(File.join('cache', section, Digest::SHA2.hexdigest(Dir.pwd)))

        # Cache key doesnt exist
        return run_yield.call(cache_key_file) unless File.exist?(cache_key_file)

        # Cache key exists and matches
        existing_cache_key = File.read(cache_key_file)
        new_cache_key = cache_key_proc.call
        return true if existing_cache_key == new_cache_key

        # Cache key exist but doesnt match
        run_yield.call(cache_key_file, file)
      end
    end
  end
end
