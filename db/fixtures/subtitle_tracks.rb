(1..4).each do |track_set_no|
  (1..4).each do |track_no|
    SubtitleTrack.seed do |st|
      st.id = ((track_set_no-1)*4)+track_no
      st.title = track_no.to_s
      st.subtitle_track_set_id = track_set_no
    end
  end
end
