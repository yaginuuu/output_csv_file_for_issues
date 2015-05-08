# coding: utf-8

require 'pp'
require 'octokit'
require 'pstore'
require 'yaml'
require 'csv'

if File.exists?("info.yml")
  CONFIG = YAML.load_file("info.yml")
else
  CONFIG = YAML.load_file("info_sample.yml")
end

USERNAME = CONFIG["username"]
PASSWORD = CONFIG["password"]
USER    = CONFIG["user"]
PROJECT = CONFIG["project"]

client = Octokit::Client.new(:login => USERNAME, :password => PASSWORD)

puts "Getting issues from Github..."
temp_issues = []
issues = []
page = 0
begin
  page = page + 1
  temp_issues = client.list_issues("#{USER}/#{PROJECT}", :state => "closed", :page => page)
  issues = issues + temp_issues;
end while not temp_issues.empty?

temp_issues = []
page = 0
begin
  page = page + 1
  temp_issues = client.list_issues("#{USER}/#{PROJECT}", :state => "open", :page => page)
  issues = issues + temp_issues;
end while not temp_issues.empty?

result = []
puts "Total #{issues.size} issues..."
issues.each do |issue|
  # puts "Processing issue #{issue['number']}..."

  result << issue["number"]
  result << issue["title"]
  begin
    result << issue["assignee"]["login"]
  rescue
    result << issue["user"]["login"]
  end
  result << "\n"
end

CSV.open("TOLK_issues.csv","a") do |csv|
    csv << result
end
