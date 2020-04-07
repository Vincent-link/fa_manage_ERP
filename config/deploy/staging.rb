set :stage, :staging
server 'fa-test.huaxing.com', user: 'deploy', roles: %w{app web db}

set :branch, ask('Enter the branch name', `git rev-parse --abbrev-ref HEAD`.chomp, echo: true)
set :deploy_to, "/data/www/quiver#{fetch(:test_env_no)}"
set :rvm_ruby_version, '2.7.0'

set :rails_env, 'staging'
set :shared_path, "#{fetch(:deploy_to)}/shared"
set :rvm_type, :system