# Copyright (c) 2021 Oracle and/or its affiliates.
# Updated 2023-05-17 by Brett Terpstra
# - Removes deprecated ::set-output

require 'json'
require 'shellwords'

file_name = 'licenses.json'
output = []

if ARGV.length > 0
  file_name = ARGV[0]
end

if ENV.include?('INPUT_LICENSES_FILE') && ENV['INPUT_LICENSES_FILE'].to_s.length > 0
  file_name = ENV['INPUT_LICENSES_FILE']
end

if !File.exist?(file_name)
  puts "ERROR - invalid (missing) file name given: #{file_name}"
  exit(1)
end

file_data = ''
open(file_name) do |f|
  file_data += f.read
end

if file_data.length <= 0
  puts "WARNING - no data read (0 byte JSON file)."
  output << "name=unapproved_licenses::false"
  exit(0)
end

json_data = JSON.parse(file_data)

unapproved_licenses = {}

json_data['files'].each do |f|
  if f['license_policy'].count <= 0
    f['licenses'].each do |l|
      if !unapproved_licenses.include?(l['key'])
        unapproved_licenses[l['key']] = []
      end
      
      if !unapproved_licenses[l['key']].include?(f['path'])
        unapproved_licenses[l['key']] << f['path']
      end
    end
  end
end

if unapproved_licenses.count > 0
  puts "ERROR - found some licenses that require further inspection:\n#{unapproved_licenses}"
  output << "name=unapproved_licenses::true"
else
  puts "All licenses found were approved for use."
  output << "name=unapproved_licenses::false"
end

`echo #{Shellwords.escape(output.join("\n"))} >> GITHUB_OUTPUT`
