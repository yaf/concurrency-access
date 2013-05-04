require 'rubygems'
require 'active_record'
require 'yaml'

task :default => :migration

desc "Migrate the database through scripts in migrate directory. Target specific version with VERSION=X"
task :migration => :environnement do
  ActiveRecord::Migrator.migrate('migrate', ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
end

task :environnement do
  ActiveRecord::Base.establish_connection(:adapter => 'mysql', :database => 'test', :user => 'root', :password => 'm3rl1p', :socket => '/var/run/mysql/mysql.sock')
  ActiveRecord::Base.logger = Logger.new(File.open('database.log', 'a'))
end
