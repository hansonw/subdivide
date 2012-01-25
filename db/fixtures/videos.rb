# English
Video.seed do |v|
  v.id  = 2
  v.url = "//iterate.ca/video.webm"
  v.uuid = UUIDTools::UUID.random_create.to_s
end

# French
Video.seed do |v|
  v.id  = 3
  v.url = "//iterate.ca/video.webm"
  v.uuid = UUIDTools::UUID.random_create.to_s
end

# MP4
Video.seed do |v|
  v.id  = 4
  v.url = "//iterate.ca/video.mp4"
  v.uuid = UUIDTools::UUID.random_create.to_s
end

