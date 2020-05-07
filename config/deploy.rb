# config valid for current version and patch releases of Capistrano
lock "~> 3.12.1"

set :application, "magazine"
set :repo_url, "git@10.101.7.1:imt/magazine.git"

set :use_sudo, true
set :linked_files, %w{config/database.yml config/master.key config/schedule.rb config/honeybadger.yml} << "config/settings/#{fetch(:stage)}.yml"
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'public', 'tmp/cache', 'tmp/pids')
set :whenever_identifier, -> {"#{fetch(:application)}_#{fetch(:stage)}#{fetch(:test_env_no)}"}

## sidekiq
set :sidekiq_config, -> {"#{current_path}/config/sidekiq.yml"}
set :passenger_restart_with_touch, true

set :format_options, command_output: true, log_file: 'log/capistrano.log', color: :auto, truncate: :auto

