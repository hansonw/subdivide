# WEBM
#Video.seed do |v|
#  v.id  = 1
#  v.url = "//iterate.ca/video.webm"
#  v.uuid = UUIDTools::UUID.random_create.to_s
#end

Video.seed(
  {"created_at"=>"2012-01-07T22:34:09Z", "desc"=>"An introductory lecture from Stanford's AI online course.", "duration"=>434, "id"=>2, "thumbnail"=>"/assets/ml-thumbnail.png", "title"=>"What is Machine Learning?", "updated_at"=>"2012-03-28T04:28:46Z", "uploader"=>nil, "url"=>"//iterate.ca/video.webm", "uuid"=>"dfae471f-781b-4cfb-9829-bca4e1d1c118", "views"=>67, "yt_url"=>nil},
  {"created_at"=>"2012-03-28T00:14:50Z", "desc"=>"http://kylelandry.com\nhttp://facebook.com/kylelandrypiano\nhttp://twitter.com/kylelandrypiano\n\nThought this specific challenge was the best so I tried it out.  It was pretty difficult! Also, if anyone w", "duration"=>279, "id"=>16, "thumbnail"=>"http://i.ytimg.com/vi/6OVkiQ_3dmQ/0.jpg", "title"=>"improvisation no93 - The Inverted Keyboard", "updated_at"=>"2012-03-28T04:07:24Z", "uploader"=>"kylelandry", "url"=>nil, "uuid"=>"affe008b-c092-4931-9851-0647d34b34d3", "views"=>1, "yt_url"=>"6OVkiQ_3dmQ"},
  {"created_at"=>"2012-03-28T02:52:33Z", "desc"=>"This is a video of 10000 particles taking random walks in two dimensions. At each time step, every particle moves 1 unit in a random direction. The spreadsheet is from excelunusual.com.\n\nYou can see in", "duration"=>125, "id"=>18, "thumbnail"=>"http://i.ytimg.com/vi/NBdBFQbsfmc/0.jpg", "title"=>"Ten Thousand 2D Random Walks", "updated_at"=>"2012-03-28T04:10:11Z", "uploader"=>"daveagp", "url"=>nil, "uuid"=>"68d32e67-1dba-448b-8f07-ab095f91c29e", "views"=>2, "yt_url"=>"NBdBFQbsfmc"},
  {"created_at"=>"2012-03-28T02:52:48Z", "desc"=>"All rights owned by BBC.\n\nThis is the most essential part of the documentary, whether people see colors differently or not.", "duration"=>476, "id"=>19, "thumbnail"=>"http://i.ytimg.com/vi/4b71rT9fU-I/0.jpg", "title"=>"BBC Horizon: Do you see what I see? \"The Himba tribe\"", "updated_at"=>"2012-03-28T02:52:48Z", "uploader"=>"TheNeekerirotta", "url"=>nil, "uuid"=>"738a838f-9239-4917-8435-d9b98a2dbd38", "views"=>40, "yt_url"=>"4b71rT9fU-I"},
  {"created_at"=>"2012-03-28T02:53:07Z", "desc"=>"President Obama speaks to faculty, staff and students of Hankuk University in Seoul about global progress toward nuclear non-proliferation. March 26, 2012.", "duration"=>1778, "id"=>20, "thumbnail"=>"http://i.ytimg.com/vi/78JPYA7fqzQ/0.jpg", "title"=>"President Obama Speaks at Hankuk University", "updated_at"=>"2012-03-28T02:53:07Z", "uploader"=>"whitehouse", "url"=>nil, "uuid"=>"4f9f9349-aa09-499e-8568-4c63852a4f14", "views"=>50, "yt_url"=>"78JPYA7fqzQ"},
  {"created_at"=>"2012-03-28T02:55:03Z", "desc"=>"Highlights from the match between DRG and MKP from Day 3 of the Winter Arena Central stream.", "duration"=>783, "id"=>21, "thumbnail"=>"http://i.ytimg.com/vi/0k42BaHsrVE/0.jpg", "title"=>"Winter Arena Highlights - Day 3 - DRG vs MKP", "updated_at"=>"2012-03-28T02:55:03Z", "uploader"=>"MajorLeagueGaming", "url"=>nil, "uuid"=>"b99d0cdb-5463-423b-b752-016bbbf9b6ca", "views"=>45, "yt_url"=>"0k42BaHsrVE"},
  {"created_at"=>"2012-03-28T03:26:22Z", "desc"=>"These speed tests were filmed at actual web page rendering times. If you're interested in the technical details, read on!\r\n\r\nEquipment used: \r\n\r\n- Computer: MacBook Pro laptop with Windows installed\r\n-", "duration"=>130, "id"=>22, "thumbnail"=>"http://i.ytimg.com/vi/nCgQDjiotG0/0.jpg", "title"=>"Google Chrome Speed Tests", "updated_at"=>"2012-03-28T03:26:22Z", "uploader"=>"googlechrome", "url"=>nil, "uuid"=>"28ba7408-3755-4edc-8b33-08083517f559", "views"=>1, "yt_url"=>"nCgQDjiotG0"},
  {"created_at"=>"2012-01-07T22:34:09Z", "desc"=>"An introductory lecture from Stanford's AI online course.", "duration"=>434, "id"=>25, "thumbnail"=>"", "title"=>"What is Machine Learning?", "updated_at"=>"2012-03-28T04:28:46Z", "uploader"=>nil, "url"=>"//iterate.ca/video.webm", "uuid"=>"dfae471f-781b-4cfb-9829-bca4e1d1c118", "views"=>67, "yt_url"=>nil},
)

Video.all.each do |v|
  SubtitleTrackSet.seed do |sts|
    sts.id = 4*v.id
    sts.title = "English"
    sts.video_id = v.id
  end
  SubtitleTrackSet.seed do |sts|
    sts.id = (4*v.id)+1
    sts.title = "French"
    sts.video_id = v.id
  end
end

SubtitleTrackSet.all.each do |sts|
  (1..4).each do |track_no|
    SubtitleTrack.seed do |st|
      st.id = ((4*sts.id)+track_no)
      st.title = track_no.to_s
      st.subtitle_track_set_id = sts.id
    end
  end
end
