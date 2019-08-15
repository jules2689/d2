# frozen_string_literal: true

require 'digest'

module D2
  module Utils
    module Cacheable
      FILE_CACHE_KEY = -> (file) do
        -> { Digest::SHA2.hexdigest(File.read(file)) }
      end
      FOLDER_CACHE_KEY = -> (folder) do
        -> { CLI::Kit::System.capture2("ls #{folder} | shasum | awk '{ print $1 }'").first }
      end

      class << self
        def cache_by(section, params)
          cache_procs = params.map do |param, value|
            case param
            when :file
              FILE_CACHE_KEY.call(value)
            when :folder
              FOLDER_CACHE_KEY.call(value)
            else
              raise ArgumentError, "#{value} is not a valid cache_by argument"
            end
          end

          cached(section, cache_procs) do
            yield
          end
        end

        def cached_by_file(section, file)
          cached(section, FILE_CACHE_KEY.call(file)) do
            yield
          end
        end

        def cached_by_folder_contents(section, folder)
          cached(section, FOLDER_CACHE_KEY.call(folder)) do
            yield
          end
        end

        def cached(section, cache_key_procs)
          run_yield = lambda do |cache_key_file|
            ret = yield
            if ret
              new_cache_key = cache_key_procs.map(&:call).join
              File.write(cache_key_file, new_cache_key)
            end
            ret
          end

          require 'digest'
          cache_key_file = D2::DATA_DIR.file(File.join('cache', section, Digest::SHA2.hexdigest(Dir.pwd)))

          # Cache key doesnt exist
          return run_yield.call(cache_key_file) unless File.exist?(cache_key_file)

          # Cache key exists and matches
          existing_cache_key = File.read(cache_key_file)
          new_cache_key = cache_key_procs.map(&:call).join

          return true if existing_cache_key == new_cache_key

          # Cache key exist but doesnt match
          run_yield.call(cache_key_file)
        end
      end
    end
  end
end
