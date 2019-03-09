# TODO: Test
#
module Dev
  module Helpers
    module Fzy
      PATH = File.join(Dev::ROOT, 'vendor', 'fzy', 'bin', 'fzy')
      private_constant :PATH

      # Fuzzy matches the output of a command against a query.
      # Returns n matches of output, defaulting to 1
      #
      # @param [String]  cmd Command to run
      # @param [String]  query Query to fuzzy match against
      # @param [Integer] num_matches number of matches to return (Default 1)
      # @return [Array] all possible matches
      #
      def self.fuzzy_match(cmd, query:, num_matches: 1)
        lines = num_matches > 3 ? num_matches : 3 # Min lines is 3 in fzy
        out, _ = CLI::Kit::System.capture2e("#{cmd} | #{PATH} --lines=#{lines} --show-matches=#{query}")
        out.lines.take(num_matches)
      end
    end
  end
end
