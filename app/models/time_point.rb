class TimePoint < ActiveRecord::Base
  belongs_to :video
  has_many :subtitle
end
