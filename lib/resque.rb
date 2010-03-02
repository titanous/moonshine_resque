module Resque

  def redis(options = {})
    package 'redis-server', :ensure => 'absent'
    gem 'redis'
    # gem 'resque' # needed for the rake test in the install step

    exec 'install redis',
      :cwd => '/tmp',
      :command => [
        'git clone git://github.com/defunkt/resque.git',
        'cd /tmp/resque',
        'rake redis:install dtach:install',
      ].join(' && '),
      :creates => '/usr/bin/redis-server'

    file '/etc/redis.conf',
      :content => template(File.join(File.dirname(__FILE__), '..', 'templates', 'redis.conf.erb'), binding),
      :ensure => :file,
      :mode => '644',
      :require => exec('install redis'),
      :notify => service('redis-server')

    service 'redis-server',
      :provider => :base,
      :start => '/usr/bin/redis-server /etc/redis.conf',
      :pattern => 'redis-server',
      :ensure => :running,
      :enable => true,
      :require => file('/etc/redis.conf')
  end

  def resque_web(options = {} )
    %w(json thin sinatra).each do |g|
      gem g, :ensure => :installed
    end
    
    file "#{configuration[:deploy_to]}/shared/resque_web", :ensure => :directory, :before => file("resque_web_rack")
    file "#{configuration[:deploy_to]}/shared/resque_web/public", :ensure => :directory, :before => file("resque_web_rack")
    file "#{configuration[:deploy_to]}/shared/resque_web/tmp", :ensure => :directory, :before => file("resque_web_rack")

    file "#{configuration[:deploy_to]}/shared/resque_web/config.ru",
      :content => template(File.join(File.dirname(__FILE__), '..', 'templates', 'config.ru.erb'), binding),
      :ensure => :file,
      :mode => '644',
      :require => exec('install redis'),
      :notify => service('apache2'),
      :alias => "resque_web_rack"
    
    
    file '/etc/apache2/sites-available/resque_web',
      :content => template(File.join(File.dirname(__FILE__), '..', 'templates', 'resque_web.vhost.erb'), binding),
      :ensure => :file,
      :mode => '644',
      :require => exec('install redis'),
      :notify => service('apache2'),
      :alias => "resque_web_vhost"
      
    a2ensite "resque_web", :require => file("resque_web_vhost")
  end
  
  def resque(options = {})
    gem "resque", :ensure => :installed
  end
  
end
