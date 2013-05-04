require 'user'


class AddLockVersion < ActiveRecord::Migration
  def self.up
    add_column :users, :lock_version, :int, :default => 0
  end
  def self.down
    remove_column :users, :lock_version
  end
end
