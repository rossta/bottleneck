require 'resque/tasks'

# Fix for environment loading issue
# https://github.com/defunkt/resque/pull/354
task "resque:setup" => :environment
