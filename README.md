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
* Ruby 2.2.2
* PostgreSQL
* MongoDB
* Redis

## Installation instructions for development:

### (Preferred) Option 1: Local Setup

See details [here](https://github.com/UM-USElab/gradecraft-development/wiki/Installation-Notes).

### Option 2: Vagrant
**Note that this solution is no longer maintained**

1. Install Vagrant (https://www.vagrantup.com/)
2. Clone repository
3. `vagrant up`
4. `vagrant ssh`
5. `cd /vagrant`
6. `foreman start`
7. Browse to [http://localhost:5000/](http://localhost:5000/)

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
