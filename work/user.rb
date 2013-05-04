require 'rubygems'
require 'active_support'
require 'active_record'

class User < ActiveRecord::Base
end

#ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => 'db_test.sqlite3'
ActiveRecord::Base.establish_connection :adapter => 'mysql', :database => 'test', :user => 'root', :password => 'm3rl1p'
