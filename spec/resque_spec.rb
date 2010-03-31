require File.join(File.dirname(__FILE__), 'spec_helper.rb')

class ResqueManifest < Moonshine::Manifest::Rails
  plugin :resque
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

end
