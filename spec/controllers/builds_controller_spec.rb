require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BuildsController do

  def mock_build(stubs={})
    @mock_build ||= mock_model(Build, stubs)
  end

  describe "should index" do
    before(:each) do
      Build.stub!(:paginate).and_return(@mock_builds = [mock_build])
    end

    it "successfully and assign builds" do
      get :index
      response.should be_success
      assigns(:builds).should == @mock_builds
    end
  end

  describe "should show" do
    it "GET build" do
      Build.should_receive(:find).with("35340").and_return(mock_build)
      get :show, :id => "35340"
      response.should be_success
      assigns[:build].should equal(mock_build)
    end

    it "GET build without id" do
      get :show
      response.should redirect_to(:action => :index)
    end
  end

  describe "should create" do
    before(:each) do
      @build_json = '{"log":null,"created_at":"1999/06/19 23:00:00 +0000","revision":61999,"state":"success","updated_at":"1999/06/19 23:00:00 +0000","cpu":"i686","time":"1999/06/19 23:00:00 +0000","name":"foo","os":"Darwin 9.7.0","ruby_class":"Build"}'
      @mock_build = mock_build(:to_json => @build_json, :save! => true)
      JSON.stub!(:parse)
      Build.stub!(:json_create).and_return(@mock_build)
    end

    it "POST create" do
      put :create, :post => { :body => nil }
      response.should be_success
      response.headers[content_type_header].should match(/^application\/json/)
      response.body.should == @build_json
    end
  end
  
  describe "should ping" do
    it "successfully and respond Ok" do
      post :ping
      response.should be_success
      response.should have_text("Ok")
    end
  end

  describe "feed action" do
    before(:each) do
      builds = []
      10.times do
        builds << mock_build
      end
      Build.should_receive(:paginate).with(1,10,an_instance_of(Hash)).and_return(builds)
    end

    it "create response with proper content type" do
      get :feed
      response.should be_success
      response.headers[content_type_header].should_not be_nil
      response.headers[content_type_header].should match(/application\/rss\+xml/)
      assigns[:builds].should_not be_nil
    end
  end

  describe "handles CouchDB connection refused exception" do
    before(:each) do
      JSON.stub!(:parse)
      Build.stub!(:find).and_raise(Errno::ECONNREFUSED)
      Build.stub!(:json_create).and_raise(Errno::ECONNREFUSED)
    end

    it "succeeds and renders an error message on show" do
      get :show, :id => "35340"
      response.should be_success
      response.should have_text("Database: connection refused")
    end

    it "succeeds and renders an error message on create" do
      put :create, :post => { :body => nil }
      response.should be_success
      response.should have_text("Database: connection refused")
    end
  end
end
