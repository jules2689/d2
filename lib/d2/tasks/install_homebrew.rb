module D2
  module Tasks
    class InstallHomebrew
      def title
        "Install Homebrew"
      end

      def failed_message
        "Homebrew failed to install"
      end

      def met?
        Helpers::Homebrew.installed?
      end

      def meet
        Helpers::Homebrew.install
      end
    end
  end
end
