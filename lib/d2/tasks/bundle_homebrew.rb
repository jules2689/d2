module D2
  module Tasks
    class BundleHomebrew
      def title
        "Homebrew bundle"
      end

      def failed_message
        "Homebrew failed to complete a {{command:brew bundle install}}"
      end

      def met?
        Helpers::Homebrew.bundle_check
      end

      def meet
        Helpers::Homebrew.bundle
      end
    end
  end
end
