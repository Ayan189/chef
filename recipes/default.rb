#
# Cookbook:: docker-monitoring
# Recipe:: default
#
# Copyright:: 2024, The Authors, All Rights Reserved.


package 'docker' do
    action :install
  end
  
  service 'default' do
    action [ :enable, :start ]
  end
  
# Create Docker network
docker_network 'private-net' do
    action :create
  end
  


  docker_image 'a4ayan/nginx-haproxy' do
    tag '2'
    action :pull
  end
  
  docker_container 'nginx_haproxy' do
    image 'a4ayan/nginx-haproxy'
    tag 'latest'
    network_mode 'private-net'
    port '80:80'
    port '9100:9100'
    action :run
  end
  
  docker_image 'prom/prometheus' do
    tag 'latest'
    action :pull
  end
  
  docker_container 'prometheus' do
    image 'prom/prometheus'
    tag 'latest'
    port '9090:9090'
    network_mode 'private-net'
    volumes [ '/Users/mohammadayan/chef/docker-monitoring/prometheus-config/prometheus.yml:/etc/prometheus/prometheus.yml' ]
    action :run
  end
