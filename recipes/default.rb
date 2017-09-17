#
# Cookbook Name:: chef_rails_sidekiq
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

app = AppHelpers.new node['app']

template "/etc/init.d/#{app.service :sidekiq}" do
  source 'init_sidekiq.erb'

  variables(
    app_name: app.name,
    app_user: app.user,
    app_env: app.env,
    app_root: app.dir(:root),
    app_shared: app.dir(:shared)
  )

  mode '0755'
end

if File.exists? app.dir(:root)
  service(app.service(:sidekiq)) { action :enable }
end
