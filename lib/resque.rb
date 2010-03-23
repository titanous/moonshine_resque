module Resque

  def resque(options = {})
    %w(resque redis redis-namespace yajl-ruby).each do |g|
      gem g, :ensure => :installed
    end
  end
  
  def resque_web(options = {} )
    %w(thin sinatra).each do |g|
      gem g, :ensure => :installed
    end
    
    file "#{configuration[:deploy_to]}/shared/resque_web", :ensure => :directory, :before => file("resque_web_rack")
    file "#{configuration[:deploy_to]}/shared/resque_web/public", :ensure => :directory, :before => file("resque_web_rack")
    file "#{configuration[:deploy_to]}/shared/resque_web/tmp", :ensure => :directory, :before => file("resque_web_rack")

    file "#{configuration[:deploy_to]}/shared/resque_web/config.ru",
      :content => template(File.join(File.dirname(__FILE__), '..', 'templates', 'config.ru.erb'), binding),
      :ensure => :file,
      :mode => '644',
      :notify => service('apache2'),
      :alias => "resque_web_rack"
    
    file '/etc/apache2/sites-available/resque_web',
      :content => template(File.join(File.dirname(__FILE__), '..', 'templates', 'resque_web.vhost.erb'), binding),
      :ensure => :file,
      :mode => '644',
      :notify => service('apache2'),
      :alias => "resque_web_vhost"
      
    a2ensite "resque_web", :require => file("resque_web_vhost")
  end
    
end
