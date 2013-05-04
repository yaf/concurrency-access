require 'test/unit'
require 'user'

class ConcurrencyAccess < Test::Unit::TestCase
  def test_user_is_user
    user = User.new
    assert_kind_of User, user
  end
  
  def test_user_respond_to_save
    user = User.new
    assert user.respond_to?("save")
  end
  
  def test_get_all_user
    list_user = User.find(:all)
    assert_equal 2, list_user.size
  end

  def test_get_all_user
    user_1 = User.find(1)
    #assert_equal 0, user_1.lock_version
    assert_equal "testeur A", user_1.name
    user_2 = User.find(2)
    assert_equal "testeur B", user_2.name
  end

  def test_concurrency
    joe = User.find(1)
    bill = User.find(1)
    bill.name = "bill"
    #assert_raise(ActiveRecord::StaleObjectError) {bill.save}
    bill.save
    joe.name = "joe"
    #assert_raise(ActiveRecord::StaleObjectError) {joe.save}
    joe.save
    assert_equal "joe", User.find(1).name
    usr = User.find(1)
    usr.name = "testeur A"
    usr.save
  end

  def test_lock
    assert_nothing_raised do
      User.transaction do
        user = User.find 1
        old, user.name = user.name, 'fooman'
        user.lock!
        assert_equal old, user.name
        assert_equal 'testeur A', user.name
        user.save
        assert_equal 'testeur A', user.name
      end
    end
  end

  def test_thread_lock
    t = Thread.new do
      joe = User.find 1
      assert_equal "testeur A", joe.name
      joe.name = "joe"
      sleep 5
      joe.save
    end
    
    t2 = Thread.new do
      billy = User.find 1
      assert_equal "testeur A", billy.name
      sleep 0.1
      billy.name = "billy"
      billy.save
    end
    t.join
    t2.join

    usr = User.find 1
    assert_equal "joe", usr.name
    usr.name = "testeur A"
    usr.save
  end

  def test_thread_lock_pessimistic
    t = Thread.new do
      joe = User.find 1
      assert_equal "testeur A", joe.name
      joe.name = "joe"
      sleep 3
      joe.save
    end
    
    t2 = Thread.new do
      billy = User.find 1
      assert_equal "testeur A", billy.name
      sleep 0.1
      billy.name = "billy"
      billy.save
    end
    t.join
    t2.join

    usr = User.find 1
    assert_equal "joe", usr.name
    usr.name = "testeur A"
    usr.save
  end

  def test_thread_lock_pessimistic_lock
      bill = User.find 1

      joe = User.find 1, :lock => true
      joe.name = "joe"

      assert_equal "testeur A", bill.name

      bill.name = "bill"
      assert ! bill.save
      usr = User.find 1

      joe.save

      usr = User.find 1
      assert_equal "joe", usr.name

      usr.name = "testeur A"
      usr.save!
  
  end

end
