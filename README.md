# Gradecraft is a gameful learning management system.

[ ![Codeship Status for UM-USElab/gradecraft-development](https://codeship.com/projects/a7421010-4e8b-0133-aacd-4e8e1c03c7f2/status?branch=master)](https://codeship.com/projects/106957)

[![Test Coverage](https://codeclimate.com/github/UM-USElab/gradecraft-development/badges/coverage.svg)](https://codeclimate.com/github/UM-USElab/gradecraft-development/coverage)

[![Code Climate](https://codeclimate.com/github/UM-USElab/gradecraft-development/badges/gpa.svg)](https://codeclimate.com/github/UM-USElab/gradecraft-development)

## Current features:
* Badges
* Teams (course-long memberships)
* Groups (single-assignment memberships)
* Assignments
* Assignment Submissions
* Assignment Unlocks
* Student Dashboard
* Interactive Grade Predictor
* Interactive Course Timeline
* Grading Rubrics
* Export students and final grades
* User analytics
* Team analytics
* Learning analytics suite
* Custom, multi-component leveling system
* Assignment stats
* Student-logged assignment scoring
* Multipliers (students decide assignment weight)

## Pre-reqs:
* Ruby 2.5.1
* PostgreSQL
* MongoDB
* Redis

## Installation Notes for running locally

1. Install Homebrew (Optional: `brew update`)

2. Install a Ruby version manager of your choice and set current version to project version (Steps below pertain to [rbenv](https://github.com/rbenv/rbenv))

```
brew install rbenv

# run command and follow instructions, will likely be the next step where you edit ~/.bash_profile
rbenv init

# make rbenv start up with terminal
edit ~/.bash_profile and add eval "$(rbenv init -)"

# optional (rbenv doctor script to check installation)
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-doctor | bash

# install and set the current version
rbenv install 2.5.1 (or whatever version Gradecraft is on)
rbenv local 2.5.1 (or rbenv global 2.5.1 if preferred)

# Restart terminal for changes to fully take into effect and ensure that the command rbenv works
```

3. Install databases

```
brew install mongodb
brew install redis
brew install postgresql
```

4. Ensure access to `/data/db` write directory for MongodDB
```
# create the directory, if it does not exist
mkdir -p /data/db
sudo chown -R {user}:{group} /data/db (replace user, group; can ls -l to determine values)

# (optional) mongod command should bring up mongodb; close with ctrl+c before proceeding to step 5
```

5. Clone the repository

```
# clone to current directory; change if desired
git clone https://github.com/UM-USElab/gradecraft-development.git
```

6. Copy configuration files
```
# Note: ensure that you are in the newly cloned /gradecraft-development dir
cp config/database.yml.sample config/database.yml
cp config/mongoid.yml.sample config/mongoid.yml
cp .env.sample .env

# obtain and replace required credentials for .env (AWS, etc.)

# comment out ALL SAML and IDP-related lines
```

7. Install Bundler
```
# install Bundler version specified in Gemfile.lock to avoid conflicts
gem install bundler -v 1.16.2
```

8. Install project dependencies
```
bundle (or bundle install)
```

9. Start Postgres database and ensure it is running on port `5432` (Optional: Download and run with [Postgres.app](https://postgresapp.com/) for Mac OS)

10. Create and populate databases with sample data

```
bundle exec rails db:create

# optional
bundle exec rails db:sample
```

11. Done! Run `foreman start` to begin

### Installation Notes

* Don't `sudo gem install`, as it will install gems in a way that does not work properly with `rbenv`. If using `rbenv` as the version manager, you may need to ensure that proper read/write permissions are granted for `/Users/{user}/.rbenv`

See db/samples.rb for dev usernames and passwords

## Testing Emails Locally

1. `gem install mailcatcher`
2. Run `mailcatcher` in terminal
3. Visit `http://127.0.0.1:1080`. Emails are routed through to the web interface.

Modify action_mailer config settings in development.rb if needed

## Linting code

Note: Both rubocop and coffeelint are installed directly on your machine, as they are
not required for development, and thus are not specified within the gemfile or node package.

### To lint ruby:

Install rubocop:

`gem install rubocop`

then

`$ rubocop [path/to/file.rb]`

### To lint coffeescript:

Install coffeelint:

`npm install -g coffeelint`

to lint all files in `javascripts/`

`rake lint:js`

to lint a directory:

`coffeelint -f coffeelint.json path/to/directory`

to lint a single file:

`coffeelint -f coffeelint.json path/to/file.coffee`

### To lint javascript:

Install jslint:

`npm install -g eslint`

to lint the javacripts directory:

`eslint ./app/assets/javascripts --ext .js`

## Running specs

To run all of the spec examples, you can run the following (this is also the default rake task):

```
bundle exec rails spec
```

To run all of the spec examples with code coverage, you can run the following:

```
bundle exec rails spec:coverage
```

## Contributing

1. Clone the repository `git clone https://github.com/UM-USElab/gradecraft-development`
1. Create a feature branch `git checkout -b my-awesome-feature`
1. Code!
1. Commit your changes (small commits please)
1. Push your new branch `git push origin my-awesome-feature`
1. Create a pull request `hub pull-request -b um-uselab:master -h um-uselab:my-awesome-feature`
