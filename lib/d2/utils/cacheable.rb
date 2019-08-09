module D2
	module Utils
		module Cacheable
			def self.cached_by_file(section, file)
				run_yield = ->(cache_key_file, file) do
					ret = yield
					if ret
						new_cache_key = Digest::SHA2.hexdigest(File.read(file))
						File.write(cache_key_file, new_cache_key)
					end
					ret
				end

				require 'digest'
				cache_key_file = D2::DATA_DIR.file(File.join(section, Digest::SHA2.hexdigest(Dir.pwd)))

				# Cache key doesnt exist
				return run_yield.call(cache_key_file, file) unless File.exist?(cache_key_file)

				# Cache key exists and matches
				existing_cache_key = File.read(cache_key_file)
				new_cache_key = Digest::SHA2.hexdigest(File.read(file))
				return true if existing_cache_key == new_cache_key

				# Cache key exist but doesnt match
				run_yield.call(cache_key_file, file)
			end
		end
	end
end