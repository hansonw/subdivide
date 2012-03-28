class SubtitlesController < ApplicationController
  def time_to_str(time)
    ms = time - time.to_i
    s = time.to_i % 60
    m = time.to_i / 60 % 60
    h = time.to_i / 60 / 60
    return sprintf("%d:%02d:%02d.%03d", h, m, s, ms*1000)
  end
  def index
    @video = Video.find(params[:video_id])
    #@subtitles = @video.subtitle
    @subtitles = Subtitle.all.find_all{|st| (st.subtitle_track.get_video_id() == params[:video_id].to_i)}
    respond_to do |format|
      format.html # index.html.slim
      format.xml  { render :xml => @subtitles }
      format.json { render :json => @subtitles }
      format.sub do
        data = ''
        @subtitles.sort_by{|s| s.start_time}.each do |s|
          data += time_to_str(s.start_time)
          data += "," + time_to_str(s.end_time)
          data += "\n"
          data += s.text + "\n"
        end
        send_data data,
                  :filename => @video.title.gsub(/[^a-zA-Z0-9]/, '') + '.sub',
                  :type => 'text/plain'
      end
    end
  end

  def new
    respond_to do |format|
      format.html # new.html.slim
    end
  end

  def edit
    respond_to do |format|
      format.html # edit.html.slim
    end
  end

  def create
    @video = Video.find(params[:video_id])
    @subtitle = Subtitle.new do |s|
      s.video_id = params[:video_id]
      s.voice = params[:voice]
      s.start_time = params[:start_time]
      s.end_time = params[:end_time] == 'null' ? nil : params[:end_time]
      s.text = params[:text]
      s.subtitle_track = @video.subtitle_track_set.first.subtitle_track.first
    end

    status = 200
    if @subtitle.save()
      data = {:type => 'create_subtitle', :value => @subtitle}
      Juggernaut.publish(@video.uuid, data)
    else
      status = 400
    end

    respond_to do |format|
      format.xml  { render :xml => @subtitle }
      format.json { render :json => @subtitle, :status => status }
    end
  end

  def show
    @subtitle = Subtitle.find(params[:id])
    respond_to do |format|
      format.html # show.html.slim
      format.xml  { render :xml => @subtitle }
      format.json { render :json => @subtitle }
    end
  end

  def update
    @subtitle = Subtitle.find(params[:id])
    @video = Video.find(@subtitle.subtitle_track.get_video_id())
    @subtitle.start_time = params[:start_time]
    @subtitle.end_time = params[:end_time] == 'null' ? nil : params[:end_time]
    @subtitle.text = params[:text]

    status = 200
    if @subtitle.save()
      data = {:type => 'update_subtitle', :value => @subtitle}
      Juggernaut.publish(@video.uuid, data)
    else
      status = 400
      data = {:type => 'update_subtitle', :value => Subtitle.find(params[:id])}
      Juggernaut.publish(@video.uuid, data)
    end

    respond_to do |format|
      format.xml  { render :xml => @subtitle }
      format.json { render :json => @subtitle, :status => status }
    end
  end

  def destroy
    @subtitle = Subtitle.find(params[:id])
    @video = Video.find(@subtitle.subtitle_track.get_video_id())
    if @subtitle.nil? == false
      Subtitle.destroy(params[:id])
      data = {:type => 'delete_subtitle', :value => params[:id]}
      Juggernaut.publish(@video.uuid, data)
    end
    @response = [:destroy => 'destroy']
    respond_to do |format|
      format.xml  { render :xml => @response }
      format.json { render :json => @response }
    end
  end
end
