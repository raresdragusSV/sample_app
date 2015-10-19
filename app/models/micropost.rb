class Micropost < ActiveRecord::Base

  attr_accessible :content, :to
  belongs_to :user
  belongs_to :to, class_name: "User"

  DIRECT_MESSAGE_REGEX = /^d\s[a-zA-Z](\w*[a-z0-9])*\s/i

  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }

  default_scope order: 'microposts.created_at DESC'
  before_save :extract_in_reply_to


  scope :from_users_followed_by_including_replies, lambda { |user| followed_by_including_replies(user) }

  def self.from_users_followed_by(user)
    followed_user_ids = "SELECT followed_id FROM relationships
                         WHERE follower_id = :user_id"
    where("user_id IN (#{followed_user_ids}) OR user_id = :user_id", user_id: user.id)
  end

  def self.followed_by_including_replies(user)
    followed_ids = "SELECT followed_id FROM relationships
                     WHERE follower_id = :user_id"
    where("user_id IN (#{followed_ids}) OR user_id = :user_id OR in_reply_to = :user_id",
          { :user_id => user })
  end

  def extract_in_reply_to

    if match = (/\A@([^\s]*)/).match(content)
      user = User.find_by_shorthand(match[1])
      self.to=user if user
    end
  end

  def direct_message_format?
    self.content.clone.match(DIRECT_MESSAGE_REGEX) && message_recipient
  end

  def to_direct_message_hash
    body = self.content.clone
    body.slice!(DIRECT_MESSAGE_REGEX)

    { content: body, sender_id: self.user_id,
      recipient_id: message_recipient.id }
  end

  private

  def extract_username_from_direct_message
      username = self.content.clone.match( DIRECT_MESSAGE_REGEX )[0].strip
      username.slice!('d ')
      username
    end

    def message_recipient
      @recipient ||= User.find_by_name(extract_username_from_direct_message)
    end
end
