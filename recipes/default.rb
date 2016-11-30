#
# Cookbook Name:: blackmirror
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

apt_package 'xserver-xorg-legacy'
apt_package 'xorg'
apt_package 'dbus-x11'
apt_package 'plymouth'
apt_package 'udisks2'
apt_package 'consolekit'

include_recipe 'kodi'
include_recipe 'couchpotato'
include_recipe 'sickrage'

user 'kodi' do
	home '/opt/kodi'
	system true
	shell '/bin/false'
end

group 'kodi' do
  members 'kodi'
end

directory '/opt/kodi' do
	owner 'kodi'
	group 'kodi'
	mode '0755'
end

template '/var/lib/polkit-1/localauthority/50-local.d/50-kodi.pkla' do
	source 'kodi-policykit.erb'
	owner 'root'
	group 'root'
	mode '0644'
end

%w{cdrom audio video plugdev users dialout dip input netdev}.each do |g|
  group g do
    action :modify
    members 'kodi'
    append true
  end
end

template '/etc/systemd/system/kodi.service' do
  source 'kodi-systemd.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

template '/etc/X11/Xwrapper.config' do
	source 'xwrapper.erb'
	owner 'root'
	group 'root'
	mode '0644'
end

service 'kodi' do
  action [ :enable, :start ]
end

directory '/storage/' do
	owner 'kodi'
	group 'kodi'
	mode '0777'
end

include_recipe 'samba::server'

%w{torrents torrents/downloads torrents/incomplete torrents/torrents tvshows movies music}.each do |dir|
	directory "/storage/#{dir}" do
		owner 'kodi'
		group 'kodi'
		mode '0777'
		recursive true
	end
end

include_recipe 'transmission'
