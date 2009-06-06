require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/builds/feed" do
  before(:each) do
    builds = []
    10.times do |n|
      builds << mock("build-#{n}", :name => "build-name-#{n}", :state => "success", :revision => 100 + n, :id => 200 + n)
    end
    assigns[:builds] = builds
    render 'builds/feed.builder'
  end
  
  it "should succeed" do
    response.should be_success
  end
  
  it "should create description" do
    response.should have_tag('description', 'Result: success')
  end

  it "should have rss structure" do
    response.should have_tag('rss') do
      with_tag('channel') do
        with_tag('title')
        with_tag('link', /\/builds\//)
        with_tag('description')
        with_tag('item')
        # ... and so on ...
      end
    end
  end
end