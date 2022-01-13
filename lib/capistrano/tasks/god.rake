namespace :god do
  def god_is_running
    !capture("#{god_command} status >/dev/null 2>/dev/null || echo 'not running'").start_with?('not running')
  end

  def god_command
    "cd #{current_path}; bundle exec god"
  end

  # desc "Stop god"
  # task :terminate_if_running do
  #   if god_is_running
  #     run "#{god_command} terminate"
  #   end
  # end

  desc 'start god'
  task :start do
    on roles(:app) do
      within "#{current_path}" do
        with rails_env: "#{fetch(:stage)}" do
          if god_is_running
            run "#{god_command} terminate"
          end
        end
      end
    end
  end

  # desc "Start god"
  # task :start do
  #   # config_file = "#{current_path}/config/resque.god"
  #   config_file = "#{current_path}/config/god/simple_rake.god"
  #   environment = { :RAILS_ENV => rails_env, :RAILS_ROOT => current_path }
  #   run "#{god_command} -c #{config_file}", :env => environment
  # end

  desc 'start god'
  task :start do
    on roles(:app) do
      within "#{current_path}" do
        with rails_env: "#{fetch(:stage)}" do
          # execute :rake, args[:param]
          config_file = "#{current_path}/config/god/simple_rake.god"
          environment = {:RAILS_ENV => rails_env, :RAILS_ROOT => current_path}
          run "#{god_command} -c #{config_file}", :env => environment
        end
      end
    end
  end

  desc 'run some rake task'
  task :say_hello_world do
    on roles(:app) do
      within "#{current_path}" do
        with rails_env: "#{fetch(:stage)}" do
          config_file = "#{current_path}/config/god/simple_rake.god"
          puts "#{current_path}"
          puts "#{current_path}/config/god/simple_rake.god"
          puts "#{config_file}"
          puts "hello world!"
          environment = {:RAILS_ENV => fetch(:rails_env), :RAILS_ROOT => current_path}
          puts environment
          puts "#{god_command} -c #{config_file}"
          run "#{god_command} -c #{config_file}", :env => environment
        end
      end
    end
  end

end
