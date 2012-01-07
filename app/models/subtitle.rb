class Subtitle < ActiveRecord::Base
  belongs_to :video
  has_many :time_points
end
