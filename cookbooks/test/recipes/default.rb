#
# Cookbook Name:: test
# Recipe:: default
#
# Copyright 2016, Bipin Bachhao
#
# All rights reserved - Do Not Redistribute
#
package "git"

log "Well, that was too easy"

group 'bipin_group' do
  gid '5000'
  non_unique true
  action :create
end

user 'bipin' do
  uid '5000'
  gid '5000'
  home '/home/bipin'
  shell '/bin/bash'
  action :create
end
