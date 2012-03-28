ActiveRecord::Base.uncached do
  Subtitle.all.each do |st|
    st.subtitle_track = Video.find(st.video_id).subtitle_track_set.first.subtitle_track.first
    st.save()
  end
end
