require 'resque/tasks'

# Fix for environment loading issue
# https://github.com/defunkt/resque/pull/354
# Also: before fork setup:
# http://stackoverflow.com/questions/7807733/resque-worker-failing-with-postgresql-server/7846127#7846127
task "resque:setup" => :environment do
  Resque.before_fork = Proc.new { ActiveRecord::Base.establish_connection }
end
