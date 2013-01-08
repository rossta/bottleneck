

desc "Demonstrate lack of ruby-trello thread safety"
task :ruby_trello_threads => :environment do
include Trello
include Trello::Authorization

Trello::Authorization.const_set :AuthPolicy, OAuthPolicy
OAuthPolicy.consumer_credential = OAuthCredential.new(ENV['TRELLO_USER_KEY'], ENV['TRELLO_USER_SECRET'])

threads = []
tokens = %w[
  687981780f4975f56ab7c544203993152123e4c07d627baeaef2a6cd785f8f46
  0d83d408eb26d1436434d4348a3871ed7b81efeaedc7fb730a94df8e27dba9fd
]

tokens.each_with_index do |token, i|
  threads << Thread.new(token) do |access_token|
    OAuthPolicy.token = OAuthCredential.new(access_token)
    member = Trello::Member.find('rossta')
    puts "Thread #{i + 1}: #{member.inspect}"
    puts "Thread #{i + 1}: #{member.boards.map(&:name).inspect}"
  end
end

threads.each { |thread| thread.join }
end
