module Moonshine
  module Resque

    def resque(options = {})
      # Moonshine currently has a bug with `gem 'foo', :version => :latest`
      package 'resque', :ensure => (options[:version] || :latest), :provider => :gem
      gem 'yajl-ruby', :ensure => :installed
    end

    def resque_web_shared
      configure(:resque => {})
      gem 'sinatra', :ensure => :installed

      directories = [
        "#{configuration[:deploy_to]}/shared/resque_web",  
        "#{configuration[:deploy_to]}/shared/resque_web/public",
        "#{configuration[:deploy_to]}/shared/resque_web/tmp",
      ]

      directories.each do |dir|
        file dir,
        :ensure => :directory,
        :owner => configuration[:user],
        :group => configuration[:group] || configuration[:user],
        :mode => '775'
      end

    end

    def resque_web_apache(options = {})
      resque_web_shared

      gem 'thin', :ensure => :installed

      file "#{configuration[:deploy_to]}/shared/resque_web/config.ru",
        :content => template(File.join(File.dirname(__FILE__), '..', '..', 'templates', 'config.ru.erb'), binding),
        :ensure => :file,
        :mode => '644',
        :owner => configuration[:user],
        :group => configuration[:group] || configuration[:user],
        :notify => service('apache2'),
        :alias => "resque_web_rack"

      file '/etc/apache2/sites-available/resque_web',
        :content => template(File.join(File.dirname(__FILE__), '..', '..', 'templates', 'resque_web.apache_vhost.erb'), binding),
        :ensure => :file,
        :mode => '644',
        :notify => service('apache2'),
        :alias => "resque_web_vhost"

      a2ensite "resque_web", :require => file("resque_web_vhost")
    end

    def resque_web_nginx
      resque_web_shared

      file "#{configuration[:deploy_to]}/shared/resque_web/config.ru",
        :content => template(File.join(File.dirname(__FILE__), '..', '..', 'templates', 'config.ru.erb'), binding),
        :ensure => :file,
        :mode => '644',
        :owner => configuration[:user],
        :group => configuration[:group] || configuration[:user],
        :notify => exec('nginx_reload'),
        :alias => 'resque_web_rack'

      file '/opt/nginx/conf/vhosts/resque_web.conf',
        :content => template(File.join(File.dirname(__FILE__), '..', '..', 'templates', 'resque_web.nginx_vhost.erb'), binding),
        :ensure => :file,
        :mode => '644',
        :require => [file('passenger_nginx_vhost_directory')],
        :notify => exec('nginx_reload'),
        :alias => 'resque_web_vhost_conf'

      file "/opt/nginx/conf/vhosts/on/resque_web.conf",
        :ensure => "/opt/nginx/conf/vhosts/resque_web.conf",
        :require => [file('resque_web_vhost_conf'), file('passenger_nginx_vhost_directory'), file('passenger_nginx_vhost_on')],
        :notify => exec('nginx_reload'),
        :alias => 'resque_web_vhost'
    end

  end
end
