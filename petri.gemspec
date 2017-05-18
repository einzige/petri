# -*- encoding: utf-8 -*-
require File.expand_path('../lib/version', __FILE__)

Gem::Specification.new do |s|
  s.name = %q{petri}
  s.version = Petri::VERSION

  s.date = %q{2016-03-01}
  s.authors = ["Sergei Zinin (einzige)"]
  s.email = %q{szinin@gmail.com}
  s.homepage = %q{http://github.com/einzige/petri}

  s.licenses = ["MIT"]

  s.files = `git ls-files`.split("\n")
  s.require_paths = ["lib"]
  s.extra_rdoc_files = ["README.md"]

  s.description = %q{A petri nets framework}
  s.summary = %q{Moves tokens around}

  s.add_dependency 'activesupport', '>= 4.2.0'
end

