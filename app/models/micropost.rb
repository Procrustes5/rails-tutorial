# == Schema Information
#
# Table name: microposts
#
#  id         :bigint           not null, primary key
#  content    :text             not null
#  user_id    :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  picture    :string
#
class Micropost < ApplicationRecord
  belongs_to :user
  default_scope -> { order(created_at: :desc) }
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validate  :check_picture_size

  private

  def check_picture_size
    return unless picture.size > 5.megabytes

    errors.add(:picture, 'should be less than 5MB')
  end
end
