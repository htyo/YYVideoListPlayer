require 'fourflusher'

module Fourflusher
  class SimControl
    unless method_defined?(:_codex_orig_destination)
      alias_method :_codex_orig_destination, :destination

      def destination(filter, os = :ios, minimum_version = '1.0')
        dest = ENV['COCOAPODS_XCODEBUILD_DESTINATION']
        return ['-destination', dest] if dest && !dest.empty?
        _codex_orig_destination(filter, os, minimum_version)
      end
    end
  end
end
