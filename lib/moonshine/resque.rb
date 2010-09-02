module Moonshine
  module Resque

    def resque(options = {})
      # Moonshine currently has a bug with `gem 'foo', :version => :latest`
      package 'resque', :ensure => (options[:version] || :latest), :provider => :gem
      gem 'yajl-ruby', :ensure => :installed
    end

    def resque_web(options = {})
      %w(thin sinatra).each do |g|
        gem g, :ensure => :installed
      end
      
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

      file "#{configuration[:deploy_to]}/shared/resque_web/config.ru",
        :content => template(File.join(File.dirname(__FILE__), '..', '..', 'templates', 'config.ru.erb'), binding),
        :ensure => :file,
        :mode => '644',
        :owner => configuration[:user],
        :group => configuration[:group] || configuration[:user],
        :notify => service('apache2'),
        :alias => "resque_web_rack"

      file '/etc/apache2/sites-available/resque_web',
        :content => template(File.join(File.dirname(__FILE__), '..', '..', 'templates', 'resque_web.vhost.erb'), binding),
        :ensure => :file,
        :mode => '644',
        :notify => service('apache2'),
        :alias => "resque_web_vhost"

      a2ensite "resque_web", :require => file("resque_web_vhost")
    end

  end
end
