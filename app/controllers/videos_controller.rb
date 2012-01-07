class VideosController < ApplicationController
  def index
    @videos = Video.all
    respond_to do |format|
      format.html # index.html.slim
      format.xml  { render :xml => @videos }
      format.json { render :json => @videos }
    end
  end
# index
# new
# create
# show
# edit
# update
# destroy
end
