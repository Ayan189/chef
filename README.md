# Docker Monitoring Setup using Chef

This project automates the setup of Docker containers for an NGINX-HAProxy service and Prometheus monitoring using Chef. The configuration spins up two Docker containers, one for the NGINX-HAProxy service and another for Prometheus, with Node Exporter pre-installed in the NGINX-HAProxy container for system metrics monitoring.

## Prerequisites

- **ChefDK** installed on your machine.
- **Docker** installed on the target node.
- Access to a Docker registry where the `a4ayan/nginx-haproxy` image is hosted.

## Steps to Reproduce

### 1. Generate the Chef Cookbook

Run the following command to generate a new Chef cookbook:

```bash
chef generate cookbook  docker-monitoring
```
### 2. Add Docker Dependency
Add the Docker cookbook dependency to your metadata.rb file:

```ruby
depends 'docker', '~> 8.0'
```
### 3. Configure Chef Solo
Create the following files:

solo.rb:

```ruby
file_cache_path "/Users/mohammadayan/chef/cache"
cookbook_path "/Users/mohammadayan/chef"
```
web.json:
```json
{
    "run_list": [ "recipe[docker-monitoring]" ]
}
```
Create a cache directory at /Users/mohammadayan/chef.

### 4. Install Dependencies
Run the following commands to install dependencies:

```bash
berks install
berks vendor /Users/mohammadayan/chef
```
### 5. Update Recipe
Edit the recipes/default.rb file in the docker-monitoring cookbook:

```ruby
#
# Cookbook:: docker-monitoring
# Recipe:: default
#
# Copyright:: 2024, The Authors, All Rights Reserved.

package 'docker' do
    action :install
end

service 'docker' do
    action [ :enable, :start ]
end

# Create Docker network
docker_network 'private-net' do
    action :create
end

# Pull and run NGINX-HAProxy container
docker_image 'a4ayan/nginx-haproxy' do
    tag 'latest'
    action :pull
end

docker_container 'nginx_haproxy' do
    image 'a4ayan/nginx-haproxy'
    tag 'latest'
    network_mode 'private-net'
    port ['80:80', '9100:9100']
    action :run
end

# Pull and run Prometheus container
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
```

### 6. Run the Chef Solo Command
Execute the following command to test your setup:

``` bash
chef-solo -c docker-monitoring/solo.rb -j docker-monitoring/web.json
```
### Step 7: Access the Services
NGINX-HAProxy: Access the service at http://localhost:80
Prometheus: Access the Prometheus dashboard at http://localhost:9090


Summary
This cookbook sets up a Docker network, pulls necessary Docker images, and runs two containers:

NGINX-HAProxy: Serves as the web proxy with Node Exporter for metrics.
Prometheus: Monitors the metrics exported by the NGINX-HAProxy container.
Prometheus is configured to scrape metrics from the NGINX-HAProxy container on the Docker network private-net.
