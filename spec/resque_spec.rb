require File.join(File.dirname(__FILE__), 'spec_helper.rb')

class ResqueManifest < Moonshine::Manifest::Rails
end

describe "A manifest with the Resque plugin" do

  before do
    @manifest = ResqueManifest.new
  end

  it "should be executable" do
    @manifest.should be_executable
  end

  describe "using the `resque` recipe" do
    before do
      @manifest.resque
    end

    it "should install the resque and yajl-ruby packages" do
      @manifest.packages.keys.should include('resque')
      @manifest.packages.keys.should include('yajl-ruby')
    end

    it "should install specified resque gem version or default to latest" do
      @manifest.packages['resque'].ensure.should == :latest
      @manifest.resque(:version => '1.6.1')
      @manifest.packages['resque'].ensure.should == '1.6.1'
    end
  end

  describe "resque_web" do
    before do
      @manifest.configure({
        :deploy_to => '/srv/app',
        :domain => 'example.com',
        :passenger => {:rack_env => 'testing'},
        :user => 'rails'
      })
      @manifest.configure({:resque => {:web => {:username => "test",:password => "test"}}})
      @manifest.resque_web
    end
    
    it "should install the resque web config.ru" do
      @manifest.files['/srv/app/shared/resque_web/config.ru'].should_not be(nil)
    end
    
    it "should install the resque web apache vhost" do
      @manifest.files['/etc/apache2/sites-available/resque_web'].should_not be(nil)
    end
    
    it "should ensure that thin and sinatra are installed" do
      @manifest.packages.keys.should include('thin')
      @manifest.packages.keys.should include('sinatra')
    end
  end
end
