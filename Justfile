# <https://just.systems>

default:
  @just --list

list:
  @just --list

install-toolchain:
    curl -O --output-dir /tmp https://download.swift.org/swift-5.8-release/xcode/swift-5.8-RELEASE/swift-5.8-RELEASE-osx.pkg
    sudo installer -pkg /tmp/swift-5.8-RELEASE-osx.pkg -target /

fuzz-build:
    xcrun --toolchain swift swift build --configuration debug  -Xswiftc -sanitize=fuzzer,address -Xswiftc -parse-as-library

fuzz-one: fuzz-build
    caffeinate -dis .build/debug/ExampleFuzzer -rss_limit_mb=4096 Corpus/New Corpus/Existing
    open ~/Library/Logs/DiagnosticReports

fuzz: fuzz-build
    caffeinate -dis .build/debug/ExampleFuzzer -fork=16 -rss_limit_mb=4096 Corpus/New Corpus/Existing
    open ~/Library/Logs/DiagnosticReports
