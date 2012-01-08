class VideosController < ApplicationController
  def index
    @videos = Video.all
    respond_to do |format|
      format.html # index.html.slim
      format.xml  { render :xml => @videos }
      format.json { render :json => @videos }
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
    @video = Video.new do |v|
      v.url = params[:url]
    end
    @video.save()
    respond_to do |format|
      format.xml  { render :xml => @video }
      format.json { render :json => @video }
    end
  end

  def show
    @video = Video.find(params[:id])
    respond_to do |format|
      format.html # show.html.slim
      format.xml  { render :xml => @video }
      format.json { render :json => @video }
    end
  end

  def update
    @video = Video.find(params[:id])
    @video.url = params[:url]
    @video.save()
    respond_to do |format|
      format.xml  { render :xml => @video }
      format.json { render :json => @video }
    end
  end

  def destroy
    Video.destroy(params[:id])
    @response = [:destroy => 'destroy']
    respond_to do |format|
      format.xml  { render :xml => @response }
      format.json { render :json => @response }
    end
  end
end
