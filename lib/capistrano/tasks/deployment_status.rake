require 'erb'

set :deploy_status_template, "public/deployment_status.html"
# load File.expand_path("../set_rails_env.rake", __FILE__)

# module Capistrano
#   class FileNotFound < StandardError
#   end
# end

namespace :deploy do
  desc 'Create deployment status page'
  task :status_page do
    unless release_path
      warn("This task is meant to be run with a full deployment")
    end

    application = fetch(:application, 'unknown')
    branch = fetch(:branch, 'unknown')
    real_revision = fetch(:current_revision, 'unknown')
    release_timestamp = fetch(:release_timestamp, 'unknown')
    deployed_by = fetch(:deployed_by, ENV['USER'])

    result = StringIO.new(ERB.new(template).result(binding))
    output_path = "#{release_path}/#{fetch(:deploy_status_template)}"
    on roles(:app) do
      upload! result, output_path
      execute :chmod, '644', output_path
    end
  end
end
after "deploy:published", "deploy:status_page"

def template
  input_path = File.join(File.dirname(__FILE__), "../deployment_status/view.html.erb")
  File.read(input_path)
end
