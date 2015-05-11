# config valid only for current version of Capistrano
lock '3.3.5'

# Load up the mBoy gem
Mboy.new() # Setting initial defaults.

set :application, '<%= projectNameString %>' # no spaces or special characters
set :project_name, '<%= projectName %>' # pretty name that can have spaces
set :repo_url, '<%= repoUrl %>' # the git repo url
set :current_dir, 'public_html' # almost always public_html

# Default value for :linked_files is []
<% if (linkedFiles) { %>set :linked_files, %w{<%= linkedFiles %>} # Note that this file must exist on the server already, Capistrano will not create it.<% } else { %>#set :linked_files, %w{} # Note that this file must exist on the server already, Capistrano will not create it.<% } %>

# Default value for linked_dirs is []
<% if (linkedDirs) { %>set :linked_dirs, %w{<%= linkedDirs %>}<% } else { %>#set :linked_dirs, %w{} # Note that Capistrano will create these directories if needed.<% } %>

namespace :deploy do
  STDOUT.sync

  desc 'Build'
  after :updated, :deploybuild do
    on roles(:web) do
      within release_path  do
        <% if (optionNpm) { %>invoke 'build:npm'<% } %>
        <% if (optionBower) { %>invoke 'build:bower'<% } %>
      end
    end
  end

  desc 'mBoy Deployment Initialized.'
  Mboy.deploy_starting_message

  desc 'Tag this release in git.'
  Mboy.tag_release

  desc 'mBoy Deployment Steps'
  Mboy.deploy_steps

  desc 'mBoy HipChat Notifications'
  Mboy.hipchat_notify

end

namespace :build do
  <% if (optionNpm) { %>
  desc 'Install/update node packages.'
  task :npm do
    on roles(:web) do
      within release_path do
        execute :npm, 'install --silent --no-spin' # install packages
      end
    end
  end

  desc 'Additional deploy steps for :build'
  before :npm, :deploy_step_beforenpm do
    on roles(:all) do
      print 'Updating node modules......'
    end
  end

  after :npm, :deploy_step_afternpm do
    on roles(:all) do
      puts '✔'.green
    end
  end
  <% } if (optionBower) { %>
  desc 'Install/update bower components.'
  task :bower do
    on roles(:web) do
      within release_path do
        execute :bower, 'install' # install components
      end
    end
  end

  before :bower, :deploy_step_beforebower do
    on roles(:all) do
      print 'Updating bower components......'
    end
  end

  after :bower, :deploy_step_afterbower do
    on roles(:all) do
      puts '✔'.green
    end
  end<% } %>

end
