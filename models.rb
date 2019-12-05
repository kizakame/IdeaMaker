require 'bundler/setup'
Bundler.require

if development?
ActiveRecord::Base.establish_connection("sqlite3:db/development.db")
end

class User < ActiveRecord::Base
  has_secure_password
  validates :mail,
    presence: true,
    format: { with:/.+@.+/}
  validates :password,
    length: { in: 5..10}
    has_many :tasks
    has_many :active_relationships,class_name: "Relationship",foreign_key: "follower_id", dependent: :destroy #active_relationshipsでフォロー
    has_many :passive_relationships,class_name: "Ralationship", foreign_key: "following"
    has_many :following, through: :active_relationships, source: :following
    has_many :followers, through: :passive_relationships, source: :follower


     # ユーザーをフォローする
  def follow(other_user)
    active_relationships.create(following_id: other_user.id)
  end

  # ユーザーをアンフォローする
  def unfollow(other_user)
    active_relationships.find_by(following_id: other_user.id).destroy
  end

  # 現在のユーザーがフォローしてたらtrueを返す
  def following?(other_user)
    following.include?(other_user)
  end
end

class Task < ActiveRecord::Base
  validates :title,
    presence: true
  validates :question,
    presence: true
  belongs_to :user
  has_many :comments
end

class Comment < ActiveRecord::Base
  belongs_to :task
end

class Relationship < ActiveRecord::Base
  belongs_to :follower, class_name: "User"
  belongs_to :following, class_name: "User"
end
