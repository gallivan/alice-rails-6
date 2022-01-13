namespace :custom do
  desc 'run some rake task'
  task :say_hello_world do
    on roles(:app) do
      within "#{current_path}" do
        with rails_env: "#{fetch(:stage)}" do
          # execute :rake, "db:create"
          puts "hello world!"
        end
      end
    end
  end

  desc 'run some rake task with one param'
    task :say_hello_name, :param do |t, args|
      on roles(:app) do
        within "#{current_path}" do
          with rails_env: "#{fetch(:stage)}" do
            # execute :rake, args[:param]
            puts args[:param]
          end
        end
      end
    end

end

namespace :deploy do
  # ....
  # @example
  #   bundle exec cap uat deploy:invoke task=users:update_defaults
  #
  desc 'Invoke rake task on the server'
  task :invoke do
    fail 'no task provided' unless ENV['task']

    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, ENV['task']
        end
      end
    end
  end

end