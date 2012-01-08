class Video < ActiveRecord::Base
  has_many :time_point
  has_many :subtitle, :through => :time_point

  validates :url, :presence => true
end
