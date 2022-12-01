# Trixie

Trixie let you load 1password secrets as ENVs for your development environment

## Usage

Initialize a `.trixie.yml` config file with:

```sh
trixie init
```

Then update it with a URI for you secret as `op://<vault>/<item>[/<section>]/<field>`, and the ENV your want, eg:

```yaml
secrets:
  -  env: 'NPM_TOKEN'
     value: "{{ op://Developers/NPM_TOKEN/SETUP_SECRET/value }}"
```

Then you can run `trixie load > .env.secrets` to update your env file with the `NPM_TOKEN`.

Alternatively, you can also leverage the following environment variables:
- TRIXIE_OP_ADDRESS - sets the authentication address for 1Password
- TRIXIE_OP_EMAIL - sets the user email address for 1Password

Example:
```ssh
  TRIXIE_OP_ADDRESS=https://{account}.1password.com \
  TRIXIE_OP_EMAIL=john.doe@email.com \
  trixie load > .env.secrets
```
this will populate your env file with:
`export NPM_TOKEN={toptals-read-only-npm-token}`

### Groups

If you have multiple secrets you can declare groups, eg:

```yaml
secrets:
  -  env: 'NPM_TOKEN'
     value: "{{ op://Developers/NPM_TOKEN/SETUP_SECRET/value }}"
     groups: [ dev ]
  -  env: 'MY_API_TOKEN'
     value: "{{ op://Developers/MY_API_TOKEN/SETUP_SECRET/password }}"
     groups: [ api ]
  -  env: 'MY_TEST_API_TOKEN'
     value: "{{ op://Developers/MY_TEST_API_TOKEN/SETUP_SECRET/password }}"
     groups: [ test ]
```

Then you could run `trixie load --groups GROUP_NAME` to select which group you want to fetch, eg: `trixie load --groups api,test`

### Formats

Trixie also supports other formats as the output as json, pretty_json and sh (ENVs with export), eg:

```sh
# Load envs in the current shell session
eval $(trixie load --format sh)

# Handle your ENVs in JSON format
trixie load --format json | jq '.[0].value'
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'trixie'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install trixie

## TODO IDEAS

1. Support Multiple Backends/Password Managers, Trixie::Loader can be refactored to be an adapter for the op CLI
2. Add a load --cache option, so fetched secrets could be retained for a while without using the Password Manager Backend

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/toptal/trixie.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
