# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

%w(admin user VIP).each do |role_name|
  Role.find_or_create_by_name(role_name)
end

admins = %w(admin rossta)
users = %w(bob jane)
(admins + users).each do |user_name|
  user = User.find_or_create_by_name(user_name)
  user.update_attributes(:email => "#{user_name}@example.com", :password => 'password', :password_confirmation => 'password')
  if admins.include?(user_name)
    user.add_role :admin
  else
    user.add_role :user
  end
end
