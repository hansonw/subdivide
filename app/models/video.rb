class Video < ActiveRecord::Base
  has_many :subtitles
end