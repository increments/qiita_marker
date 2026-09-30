# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "qiita_marker/version"

Gem::Specification.new do |s|
  s.name = "qiita_marker"
  s.version = QiitaMarker::VERSION
  s.summary = "Qiita Marker is a Ruby library for Markdown processing, based on CommonMarker."
  s.description = "A Ruby library that is the core module of the Qiita-specified markdown processor."
  s.authors = ["Qiita Inc."]
  s.homepage = "https://github.com/increments/qiita_marker"
  s.license = "MIT"

  s.files         = ["LICENSE.txt", "README.md", "Rakefile", "qiita_marker.gemspec", "bin/qiita_marker"]
  s.files        += Dir.glob("lib/**/*.rb")
  s.files        += Dir.glob("ext/qiita_marker/*.*")
  s.extensions    = ["ext/qiita_marker/extconf.rb"]

  s.executables = ["qiita_marker"]
  s.require_paths = ["lib", "ext"]
  s.required_ruby_version = [">= 3.0", "< 4.0"]

  s.metadata["rubygems_mfa_required"] = "true"

  s.rdoc_options += ["-x", "ext/qiita_marker/cmark/.*"]
end
