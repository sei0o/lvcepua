require 'bcrypt'

class User < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  validates :twitter_uid, uniqueness: true
end
