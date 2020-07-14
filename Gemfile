source 'https://gems.ruby-china.com'

git_source(:github) {|repo| "https://github.com/#{repo}.git"}

ruby '2.7.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.3', '>= 6.0.3.1'

# Use Puma as the app server
gem 'puma', '~> 4.1'

# Use Redis adapter to run Action Cable in production
gem 'redis-rails'

gem 'pg'

# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

gem 'acts_as_paranoid'
gem 'paper_trail'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'

# sso
gem 'sso_client', :git => "git@10.101.7.1:imt/sso_client.git"

# role
gem 'cancancan'

# zombie
gem 'zombie_service', :git => "git@10.101.7.1:imt/zombie_service.git", tag: '1.3.2'
gem 'zombie', :git => "git@10.101.7.1:imt/zombie_client.git", tag: '1.3.2'

gem "config"
gem "whenever"

gem 'will_paginate'

# gems below is optional, uncomment is you need
# kafka
# gem 'ruby-kafka', '~> 0.7.8'
# gem 'racecar', :git => "git@10.101.7.1:imt/racecar.git"

# es
gem 'searchkick'

# oss
gem 'aws-sdk', '~> 3'

gem 'acts-as-taggable-on', '~> 6.0'

# excel
gem 'spreadsheet'
# gem 'axlsx'
# gem 'zip-zip'
# gem 'axlsx_styler'

# grape
gem 'grape'
gem 'grape-swagger'
gem 'grape-entity'
gem 'grape-swagger-entity'
gem 'grape-cancan'
gem 'grape_logging'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  gem 'capistrano'
  gem 'capistrano-rails'
  gem 'capistrano-bundler'
  gem 'capistrano-rvm'
  gem 'capistrano-passenger'

  gem 'ed25519', '>= 1.2', '< 2.0'
  gem 'bcrypt_pbkdf', '>= 1.0', '< 2.0'
end

group :test do
  gem 'minitest-hooks'
  gem 'minitest-rails'
end

gem 'pry'
gem 'acts-as-taggable-on', '~> 6.0'

gem 'pdf_watermark'
gem 'hexapdf', git: 'https://github.com/shibocuhk/hexapdf'
