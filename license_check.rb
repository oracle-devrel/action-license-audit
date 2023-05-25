# Copyright (c) 2021 Oracle and/or its affiliates.
# Updated 2023-05-17 by Brett Terpstra
# - Removes deprecated ::set-output

require 'json'
require 'shellwords'

file_name = 'licenses.json'
output = []

file_name = ARGV[0] unless ARGV.empty?

file_name = ENV['INPUT_LICENSES_FILE'] if ENV.include?('INPUT_LICENSES_FILE') && !ENV['INPUT_LICENSES_FILE'].empty?

unless File.exist?(file_name)
  puts "ERROR - invalid (missing) file name given: #{file_name}"
  exit(1)
end

file_data = IO.read(file_name)

if file_data.length <= 0
  puts 'WARNING - no data read (0 byte JSON file).'
  output << 'unapproved_licenses=false'
  Process.exit 0
end

json_data = JSON.parse(file_data)

unapproved_licenses = {}

json_data['files'].each do |f|
  next unless f['license_policy'].count.positive?

  next if f['license_policy']['label'] == 'Approved License'

  f['licenses'].each do |l|
    ok = %w[unknown-license-reference warranty-disclaimer]
    next if ok.include?(l['key'])

    unapproved_licenses[l['key']] = [] unless unapproved_licenses.include?(l['key'])

    unapproved_licenses[l['key']] << f['path'] unless unapproved_licenses[l['key']].include?(f['path'])
  end
end

if unapproved_licenses.count.positive?
  puts "ERROR - found some licenses that require further inspection:\n#{unapproved_licenses}"
  output << 'unapproved_licenses=true'
else
  puts 'All licenses found were approved for use.'
  output << 'unapproved_licenses=false'
end

`echo #{Shellwords.escape(output.join("\n"))} >> "$GITHUB_OUTPUT"`
