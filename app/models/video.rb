class Video < ActiveRecord::Base
  has_many :subtitle_track_set

  validates :url, :presence => true
  
  before_validation :generate_uuid

  def generate_uuid
    if not self.uuid
      self.uuid = UUIDTools::UUID.random_create.to_s
    end
  end
end
