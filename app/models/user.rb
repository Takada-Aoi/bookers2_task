class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :books
  has_many :favorites,dependent: :destroy
  has_many :book_comments,dependent: :destroy

  attachment :profile_image, destroy: false

  validates :name, length: {maximum: 20, minimum: 2}, uniqueness: true
  validates :introduction, length: {maximum: 50}

  has_many :active_relationships,  class_name:  "Relationship",
                                   foreign_key: "followed_id",
                                   dependent:   :destroy
  has_many :passive_relationships, class_name:  "Relationship",
                                   foreign_key: "follower_id",
                                   dependent:   :destroy
  has_many :followed, through: :active_relationships,  source: :follower
  has_many :followers, through: :passive_relationships, source: :followed

 def followed_by?(user)
  passive_relationships.find_by(followed_id: user.id).present?
 end

 include JpPrefecture
 jp_prefecture :prefecture_code

 def prefecture_name
   JpPrefecture::Prefecture.find(code: prefecture_code).try(:name)
 end

 def prefecture_name=(prefecture_name)
   self.prefecture_code = JpPrefecture::Prefecture.find(name: prefecture_name).code
 end

end
