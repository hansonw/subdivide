class SubtitleTrack < ActiveRecord::Base
  belongs_to :subtitle_track_set
  has_many :subtitle
end
