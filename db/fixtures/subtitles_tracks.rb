Subtitle.all.each do |st|
  st.subtitle_track_id = Video.find(st.video_id).subtitle_track_set.first.subtitle_track.first.id
  st.save()
end
