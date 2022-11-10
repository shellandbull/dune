require_relative "lib/dune/version"

Gem::Specification.new do |spec|
  spec.name    = "dune"
  spec.version = Dune::VERSION
  spec.authors = ["shellandbull"]
  spec.email   = ["sudo@morph.tech"]

  spec.summary  = "A Ruby API client for the Dune Analytics API"
  spec.homepage = "https://github.com/shellandbull/dune"
  spec.license  = "MIT"
  spec.required_ruby_version = ">= 2.6"

  spec.metadata = {
    "bug_tracker_uri"       => "https://github.com/shellandbull/dune/issues",
    "changelog_uri"         => "https://github.com/shellandbull/dune/releases",
    "source_code_uri"       => "https://github.com/shellandbull/dune",
    "homepage_uri"          => spec.homepage,
    "rubygems_mfa_required" => "true"
  }

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.glob(%w[LICENSE.txt README.md {lib}/**/*]).reject { |f| File.directory?(f) }
  spec
end
