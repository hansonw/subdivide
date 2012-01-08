class SubtitlesController < ApplicationController
  def index
    @subtitles = TimePoint.find(params[:time_point_id]).subtitle
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
      s.time_point_id = params[:time_point_id]
      s.text = params[:text]
    end
    @subtitle.save()
    data = {:type => 'create_subtitle', :value => @subtitle}
    Juggernaut.publish(@subtitle.time_point.video.uuid, data)
    respond_to do |format|
      format.xml  { render :xml => @subtitle }
      format.json { render :json => @subtitle }
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
    @subtitle.text = params[:text]
    @subtitle.save()
    data = {:type => 'update_subtitle', :value => @subtitle}
    Juggernaut.publish(@subtitle.time_point.video.uuid, data)
    respond_to do |format|
      format.xml  { render :xml => @subtitle }
      format.json { render :json => @subtitle }
    end
  end

  def destroy
    Subtitle.destroy(params[:id])
    @response = [:destroy => 'destroy']
    respond_to do |format|
      format.xml  { render :xml => @response }
      format.json { render :json => @response }
    end
  end
end
