Factory.define :user do |f|
  f.sequence(:username)   { |n| "#{Faker::Internet.user_name}_#{n}" }
  f.sequence(:email)      { |n| "#{Faker::Internet.user_name}_#{n}@#{Faker::Internet.domain_name}" }
  f.name                  { Faker::Name.name }
  f.password              'correctpassword'
  f.password_confirmation 'correctpassword'
end

Factory.define :unconfirmed_user, parent: :user do |f|
end

Factory.define :confirmed_user, parent: :user do |f|
  f.after_create do |o|
    o.confirm!
  end
end

Factory.define :admin_user, parent: :confirmed_user do |f|
  f.admin true
end

Factory.define :locked_user, parent: :confirmed_user do |f|
  f.after_create do |o|
    o.lock_access!
  end
end
