require 'fourflusher'
require 'cocoapods'

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

class Pod::Validator
  unless method_defined?(:_codex_orig_download_pod)
    alias_method :_codex_orig_download_pod, :download_pod

    def download_pod
      _codex_orig_download_pod
      yy_fix_zfplayer_private_header!
    end

    private

    def yy_fix_zfplayer_private_header!
      file = validation_dir + 'Pods/ZFPlayer/ZFPlayer/Classes/Core/ZFReachabilityManager.m'
      return unless file.exist?

      content = file.read
      fixed = content.gsub('<netinet6/in6.h>', '<netinet/in.h>')
      file.open('w') { |f| f.write(fixed) } if fixed != content
    end
  end
end
