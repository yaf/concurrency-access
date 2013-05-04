require 'test/unit'
require 'user'

class ConccurentAccesTest < Test::Unit::TestCase
  def setup
    ActiveRecord::Base.establish_connection(:adapter => 'mysql', :database => 'test', :user => 'root', :password => 'm3rl1p', :socket => '/var/run/mysql/mysql.sock')
    ActiveRecord::Base.logger = Logger.new(File.open('test_db.log', 'a'))
  end

  def teardown
    joe = User.find 1
    joe.name = "Joe"
    joe.visit = 0
    joe.save
    billy = User.find 2
    billy.name = "Billy"
    billy.visit = 0
    billy.save
  end

  def test_reading
    joe = User.find(1)
    assert_equal "Joe", joe.name
    assert_equal 0, joe.visit
  end
  def test_concurrent_access_withoutlock
    joe = User.find(1)
    billy = User.find(1)
    joe.visit += 1
    billy.visit += 1
    joe.save
    billy.save
    assert_equal 2, User.find(1).visit
  end
  def test_concurrent_access
    joe = User.find(1, :lock => true)
    billy = User.find(1, :lock => true)
    joe.visit += 1
    billy.visit += 1
    joe.save
    billy.save
    assert_equal 2, User.find(1).visit
  end
end
