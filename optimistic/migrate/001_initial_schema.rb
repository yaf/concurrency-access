require 'user'


class InitialSchema < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.column :name, :string, :null => false
    end

    User.create :name => "Joe"
    User.create :name => "Billy"
  end
  def self.down
    drop_table :users
  end
end
