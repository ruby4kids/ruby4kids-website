unless admin_user = User.find_by_username('admin')
  puts "Creating admin user"
  admin_user = User.new(
    username:              'admin',
    name:                  'Administrator',
    email:                 'admin@ruby4kids.com',
    password:              'secret',
    password_confirmation: 'secret',
    admin:                 true
  )
  admin_user.skip_confirmation!
  admin_user.save!
end
