# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
admin_account = Account.find_or_create_by!(name: "Admin Account")

admin_role = Role.find_or_create_by!(name: "admin")

if (user = User.find_by(email: "admin@example.com")).nil?
  user = User.create!(
    email: "admin@example.com",
    password: "password123",
    password_confirmation: "password123",
    account: admin_account
  )
end

unless user.roles.include?(admin_role)
  user.roles << admin_role
end

puts "Seeded admin user: admin@example.com / password123"

# Create admin profile if not exists
Profile.find_or_create_by!(account: admin_account, user: user) do |p|
  p.first_name = "Admin"
  p.last_name = "User"
  p.bio = "System administrator"
end

# Example admin task
Task.find_or_create_by!(account: admin_account, user: user, title: "Welcome Task") do |t|
  t.description = "This is an example task created by seeds."
end
