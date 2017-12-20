#
# Cookbook Name:: chef_rails_sidekiq
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

app = AppHelpers.new node['app']

bundle_exec = <<~CMD.gsub(/\n|  +/, ' ')
  RAILS_ENV=#{app.env}
  PATH=/home/#{app.user}/.rbenv/bin:/home/#{app.user}/.rbenv/shims:$PATH
    bundle exec
CMD

systemd_unit "#{app.service(:sidekiq)}.service" do
  content <<~SERVICE
    [Unit]
    Description=Sidekiq for #{app.name} #{app.env}
    After=syslog.target network.target

    [Service]
    SyslogIdentifier=#{app.service(:sidekiq)}.service
    User=#{app.user}
    Group=#{app.group}
    UMask=0002
    WorkingDirectory=#{app.dir(:root)}
    Restart=on-failure

    ExecStart=/bin/bash -c '#{bundle_exec} sidekiq -e #{app.env}'
    ExecReload=/bin/bash -c '#{bundle_exec} sidekiqctl quiet $MAINPID'
    ExecStop=/bin/bash -c '#{bundle_exec} sidekiqctl stop $MAINPID'

    StandardOutput=journal
    StandardError=journal

    [Install]
    WantedBy=multi-user.target
  SERVICE

  triggers_reload true
  verify false
  action %i[create enable start]
end
