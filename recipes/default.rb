#
# Cookbook Name:: virtualbox
# Recipe:: default
#
# Copyright 2013, kangaechu.com
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

%w{gcc make kernel-devel}.each do |package_name|
  package package_name do
    action :install
  end
end

# get latest Virtualbox Guest Additions version
versionServer = `curl http://download.virtualbox.org/virtualbox/LATEST.TXT`.strip
filename = "VBoxGuestAdditions_#{versionServer}"

remote_file "#{Chef::Config[:file_cache_path]}/#{filename}.iso" do
  source "http://download.virtualbox.org/virtualbox/#{versionServer}/#{filename}.iso"
  not_if do
    ::File.exists?("#{Chef::Config[:file_cache_path]}/#{filename}.iso") or
    ::File.exists?("/opt/VBoxGuestAdditions-" + versionServer + "/bin")
  end
end

bash "install Virtualbox Guest Additions" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  mkdir -p /mnt/#{filename}
  mount #{Chef::Config[:file_cache_path]}/#{filename}.iso -o loop /mnt/#{filename}
  sh /mnt/#{filename}/VBoxLinuxAdditions.run --nox11
  umount /mnt/#{filename}
  rmdir /mnt/#{filename}
  EOH
  not_if do
    ! ::File.exists?("#{Chef::Config[:file_cache_path]}/#{filename}.iso") or
    ::File.exists?("/opt/VBoxGuestAdditions-" + versionServer + "/bin")
  end
end
