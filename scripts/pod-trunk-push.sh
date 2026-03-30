#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

export COCOAPODS_XCODEBUILD_DESTINATION="${COCOAPODS_XCODEBUILD_DESTINATION:-generic/platform=iOS Simulator}"
export RUBYOPT="-r${ROOT}/scripts/cocoapods_destination_patch.rb ${RUBYOPT:-}"

cd "$ROOT"
pod trunk push "$@"
