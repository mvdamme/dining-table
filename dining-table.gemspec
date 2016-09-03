# Generated by juwelier
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Juwelier::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: dining-table 0.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "dining-table"
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Micha\u{eb}l Van Damme"]
  s.date = "2016-09-03"
  s.description = "Easily output tabular data, be it in HTML, CSV or XLSX. Create clean table classes instead of messing with views to create nice tables."
  s.email = "michael.vandamme@vub.ac.be"
  s.extra_rdoc_files = [
    "LICENSE",
    "README.md"
  ]
  s.files = [
    ".travis.yml",
    "CHANGELOG.md",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE",
    "README.md",
    "Rakefile",
    "VERSION",
    "dining-table.gemspec",
    "lib/dining-table.rb",
    "lib/dining-table/columns/actions_column.rb",
    "lib/dining-table/columns/column.rb",
    "lib/dining-table/config.rb",
    "lib/dining-table/presenters/csv_presenter.rb",
    "lib/dining-table/presenters/excel_presenter.rb",
    "lib/dining-table/presenters/html_presenter.rb",
    "lib/dining-table/presenters/presenter.rb",
    "lib/dining-table/presenters/spreadsheet_presenter.rb",
    "lib/dining-table/table.rb",
    "spec/collection.rb",
    "spec/csv_table_spec.rb",
    "spec/date_column.rb",
    "spec/html_table_spec.rb",
    "spec/spec_helper.rb",
    "spec/tables/car_table.rb",
    "spec/tables/car_table_with_actions.rb",
    "spec/tables/car_table_with_footer.rb",
    "spec/tables/car_table_with_header.rb",
    "spec/tables/car_table_with_options.rb"
  ]
  s.homepage = "http://github.com/mvdamme/dining-table"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.8"
  s.summary = "Create tables easily. Supports html, csv and xlsx."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, ["~> 1.0"])
      s.add_development_dependency(%q<juwelier>, ["~> 2.1.0"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.0"])
      s.add_dependency(%q<juwelier>, ["~> 2.1.0"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.0"])
    s.add_dependency(%q<juwelier>, ["~> 2.1.0"])
  end
end

