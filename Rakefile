require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'

db_config = YAML.load ERB.new(File.read("database.yml")).result
ActiveRecord::Base.establish_connection db_config["development"]
