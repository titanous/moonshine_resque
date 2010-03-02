class MoonshineResqueGodGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.directory File.join("config", "god")
      m.template "resque.god", "config/god/resque.god"
    
      intro = <<-INTRO


- To monitor Resque with God, install moonshine_god.

  script/plugin install git://github.com/railsmachine/moonshine_god.git


INTRO
      
      puts intro
    end
  end
end
