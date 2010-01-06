class BuildsController < ApplicationController

  protect_from_forgery :only => [:update, :destroy]   
  
  def index
    @builds = Build.paginate(:page => params[:page] || 1, :per_page => 10, :order => 'time DESC')
  end

  def feed
    @builds = Build.paginate(:page => 1, :per_page => 10, :order => 'time DESC')
    response.content_type = "application/rss+xml"
    render :action => "feed", :layout => false
  end

  def show
    if params[:id]
      @build = Build.find(params[:id])
    else
      redirect_to :action => 'index'
    end
  rescue Errno::ECONNREFUSED
    render :text => "Database: connection refused"
  end

  def create
    build = Build.json_create(JSON.parse(request.body.read))
    build.save!
    render :json => build
  rescue Errno::ECONNREFUSED
    render :text => "Database: connection refused"
  end

  def ping
    render :text => "Ok"
  end
end
