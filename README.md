# EncryptAttributes

EncryptAttributes encrypts Rails model's attributes before storing to DB.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'encrypt_attributes'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install encrypt_attributes

## Usage

Add a column to store encrypted attributes.
The name of the column has to begin with `encrypted_`

NOTE: It is recommended that the text type be used because the string stored in the database will be longer than the string before encryption.

example:

```ruby
class AddEncryptedEmailToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :encrypted_email, :text
  end
end
```

Then include `EncryptAttributes` in the model, and call `encrypted_attribute` with an attribute name and a secret key.
This secret key is used to encrypt or decrypt the attribute.

```ruby
class User < ApplicationRecord
  include EncryptAttributes

  encrypted_attribute :email, secret_key: ENV['ATTRIBUTES_SECRET_KEY']
end
```

Then you can call `User#email` or `User#email=`

```ruby
User.new(email: 'foo@example.com').email
# => "foo@example.com"

user = User.new
user.email = 'foo@example.com'
user.email
# => "foo@example.com"
```

When it's persisted, Database will only store encrypted values.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/encrypt_attributes.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

