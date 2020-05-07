set :stage, :staging
server '10.100.97.55', port: '18022', user: 'hxt', roles: %w{app web db}
#server 'fa-test.huaxing.com', port: '18022', user: 'hxt', roles: %w{app web db}

set :branch, ask('Enter the branch name', `git rev-parse --abbrev-ref HEAD`.chomp, echo: true)
set :deploy_to, "/data/www/magazine"
set :rvm_ruby_version, '2.7.0'

set :rails_env, 'staging'
set :shared_path, "#{fetch(:deploy_to)}/shared"
