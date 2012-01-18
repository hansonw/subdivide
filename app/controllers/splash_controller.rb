class SplashController < ApplicationController
  layout 'splash'
  def index
    render :template => "splash/index"
  end
end
