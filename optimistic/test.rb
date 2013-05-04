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
    joe.save
    billy = User.find 2
    billy.name = "Billy"
    billy.save
  end
  
  def xtest_default_concurrency_access
    joe = User.find(1)
    bill = User.find(1)
    bill.name = "billy"
    bill.save
    assert_equal("billy", User.find(1).name)
    joe.name = "joe"
    joe.save
    assert_equal("joe", User.find(1).name)
  end

  def test_concurrency_optimistic_lock_fail_save
    joe = User.find(1)
    bill = User.find(1)
    bill.name = "billy"

    assert (bill.lock_version > 0)
    assert (joe.lock_version > 0)
    assert_equal joe.lock_version, bill.lock_version
    
    assert bill.save
    assert_equal "billy", User.find(1).name
    
    joe.name = "joe"
    assert_raise(ActiveRecord::StaleObjectError) {joe.save}
    assert_equal("billy", User.find(1).name)
  end

  def test_concurrency_optimistic_lock_ok_save
    joe = User.find(1)
    bill = User.find(1)
    joe.name = "joe"
    joe.save

    bill.name = "billy"
    assert_raise(ActiveRecord::StaleObjectError) {bill.save}
    begin
      bill.save
    rescue ActiveRecord::StaleObjectError
      bill.reload
      assert_equal("joe", bill.name)
    end
    assert_equal("joe", User.find(1).name)
  end
end
