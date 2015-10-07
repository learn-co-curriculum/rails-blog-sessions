class User < ActiveRecord::Base
  has_many :posts
  has_many :comments

  validates_uniqueness_of :name, :email
  validates_presence_of :name, :email

  has_secure_password
end
