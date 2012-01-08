Video.seed do |v|
  v.id  = 2
  v.url = "//iterate.ca/video.webm"
  v.uuid = UUIDTools::UUID.random_create.to_s
end
