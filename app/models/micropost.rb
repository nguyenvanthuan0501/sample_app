class Micropost < ApplicationRecord
  belongs_to :user
  default_scope ->{order created_at: :desc}
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true, length:
    {maximum: Settings.user.micropost.max_length}
  validate :picture_size

  private
  def picture_size
    return if picture.size <= Settings.picture.size.megabytes

    errors.add :picture, I18n.t("static_pages.micropost.picture_size",
      max_size: Settings.picture.size)
  end
end
