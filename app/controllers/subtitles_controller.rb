class SubtitlesController < ApplicationController
  def index
    y params
    @subtitles = Video.find(params[:video_id]).subtitle
    respond_to do |format|
      format.html # index.html.slim
      format.xml  { render :xml => @subtitles }
      format.json { render :json => @subtitles }
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
    @subtitle = Subtitle.new do |s|
      s.video_id = params[:video_id]
      s.voice = params[:voice]
      s.start_time = params[:start_time]
      s.end_time = params[:end_time] == 'null' ? nil : params[:end_time]
      s.text = params[:text]
    end
    y @subtitle

    status = 200
    if @subtitle.save()
      data = {:type => 'create_subtitle', :value => @subtitle}
      Juggernaut.publish(@subtitle.video.uuid, data)
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
    @subtitle.start_time = params[:start_time]
    @subtitle.end_time = params[:end_time] == 'null' ? nil : params[:end_time]
    @subtitle.text = params[:text]

    status = 200
    if @subtitle.save()
      data = {:type => 'update_subtitle', :value => @subtitle}
      Juggernaut.publish(@subtitle.video.uuid, data)
    else
      status = 400
      data = {:type => 'update_subtitle', :value => Subtitle.find(params[:id])}
      Juggernaut.publish(@subtitle.video.uuid, data)
    end

    respond_to do |format|
      format.xml  { render :xml => @subtitle }
      format.json { render :json => @subtitle, :status => status }
    end
  end

  def destroy
    @subtitle = Subtitle.find(params[:id])
    if @subtitle.nil? == false
      Subtitle.destroy(params[:id])
      data = {:type => 'delete_subtitle', :value => params[:id]}
      Juggernaut.publish(@subtitle.video.uuid, data)
    end
    @response = [:destroy => 'destroy']
    respond_to do |format|
      format.xml  { render :xml => @response }
      format.json { render :json => @response }
    end
  end
end
