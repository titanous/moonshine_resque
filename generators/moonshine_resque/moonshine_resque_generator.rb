class MoonshineResqueGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.directory "config"
      m.template "resque.yml", "config/resque.yml"
      m.template "load_resque.rb", "config/initializers/load_resque.rb"
    
      intro = <<-INTRO


- Be sure to install moonshine_redis to use moonshine_resque.

  script/plugin install git://github.com/railsmachine/moonshine_redis.git

- To monitor Resque with God, generate the configuration file 
  and install moonshine_god.

  script/generate moonshine_resque_god
  script/plugin install git://github.com/railsmachine/moonshine_god.git


INTRO
      
      puts intro
    end
  end
end