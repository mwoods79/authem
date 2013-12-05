require 'active_record'
require 'logger'

dbconfig = {
  :adapter => 'postgresql',
  :database => 'authem_test',
  :min_messages => 'warning'
}

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection(dbconfig.merge('database' => 'postgres', 'schema_search_path' => 'public'))
ActiveRecord::Base.connection.drop_database dbconfig[:database] rescue nil
ActiveRecord::Base.connection.create_database(dbconfig[:database])
ActiveRecord::Base.establish_connection(dbconfig)

class TestMigration < ActiveRecord::Migration
  def self.up
    create_table :sorcery_strategy_users, :force => true do |t|
      t.string :email, :string
      t.string :crypted_password
      t.string :salt
      t.string :reset_password_token
    end

    create_table :primary_strategy_users, :force => true do |t|
      t.string :email
      t.string :password_digest
      t.string :reset_password_token
    end

    create_table :authem_sessions, :force => true do |t|
      t.string  :token
      t.string  :revoked_at
      t.string  :authemable_type
      t.integer :authemable_id
      t.timestamps
    end
  end

  def self.down
    drop_table :sorcery_strategy_users
    drop_table :primary_strategy_users
    drop_table :authem_sessions
  end
end

RSpec.configure do |config|
  config.before(:suite) { TestMigration.up }
end

class SorceryStrategyUser < ActiveRecord::Base
  include Authem::SorceryUser
end

class PrimaryStrategyUser < ActiveRecord::Base
  include Authem::User
end
