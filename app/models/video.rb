class Video < ActiveRecord::Base
  has_many :time_point
  has_many :subtitle, :through => :time_point

  validates :url, :presence => true
  
  before_validation :generate_uuid

  def generate_uuid
    if not self.uuid
      self.uuid = UUIDTools::UUID.random_create.to_s
    end
  end
end
