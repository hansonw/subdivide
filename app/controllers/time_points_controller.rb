class TimePointsController < ApplicationController
  def index
    @timepoints = TimePoint.all
    respond_to do |format|
      format.html # index.html.slim
      format.xml  { render :xml => @timepoints }
      format.json { render :json => @timepoints }
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
    @response = []
    respond_to do |format|
      format.xml  { render :xml => @response }
      format.json { render :json => @response }
    end
  end

  def show
    @response = []
    respond_to do |format|
      format.html # show.html.slim
      format.xml  { render :xml => @response }
      format.json { render :json => @response }
    end
  end

  def update
    @response = []
    respond_to do |format|
      format.xml  { render :xml => @response }
      format.json { render :json => @response }
    end
  end

  def destroy
    @response = []
    respond_to do |format|
      format.xml  { render :xml => @response }
      format.json { render :json => @response }
    end
  end
end
