class Video < ActiveRecord::Base
  has_many :subtitle

  validate :has_url
  before_validation :generate_uuid

  def has_url
    if url.nil? && yt_url.nil?
      errors.add(:url, "must specify url or YouTube url")
    end
  end

  def generate_uuid
    if not self.uuid
      self.uuid = UUIDTools::UUID.random_create.to_s
    end
  end
end
