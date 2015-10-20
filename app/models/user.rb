# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class User < ActiveRecord::Base
  attr_accessible :email, :name, :password, :password_confirmation, :following_email
  has_secure_password
  has_many :microposts, dependent: :destroy

  has_many :replies, foreign_key: 'in_reply_to',
                     class_name: 'Micropost'

  has_many :relationships, foreign_key: 'follower_id',
                           dependent: :destroy
  has_many :followed_users, through: :relationships,
                            source: :followed
  has_many :reverse_relationships, foreign_key: 'followed_id',
                                   class_name: 'Relationship',
                                   dependent: :destroy
  has_many :followers, through: :reverse_relationships,
                       source: :follower

  before_save { |user| user.email = email.downcase }
  before_save :create_remember_token



  validates :name, presence: true,
                    length: { maximum: 20 },
                    uniqueness: { case_sensitive: false }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6 }
  validates :password_confirmation, presence: true
  after_validation { self.errors.messages.delete(:password_digest) }

  def feed
    Micropost.from_users_followed_by_including_replies(self)
    # Micropost.including_replies
  end

  def following?(other_user)
    relationships.find_by_followed_id(other_user.id)
  end

  def follow!(other_user)
    relationships.create!(followed_id: other_user.id)
  end

  def unfollow!(other_user)
    relationships.find_by_followed_id(other_user.id).destroy
  end

  private

  def create_remember_token
    self.remember_token = SecureRandom.urlsafe_base64
  end

  def self.shorthand_to_name(sh)
   # name.gsub(/\s*/,"")
   sh.gsub(/_/," ")
  end

  def self.find_by_shorthand(shorthand_name)
    all = where(name: User.shorthand_to_name(shorthand_name))
    if all.empty?
       return nil
    end
    all.first
  end
end
