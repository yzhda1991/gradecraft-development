# Gradecraft is a gamified learning management system.

[ ![Codeship Status for UM-USElab/gradecraft-development](https://codeship.com/projects/a7421010-4e8b-0133-aacd-4e8e1c03c7f2/status?branch=master)](https://codeship.com/projects/106957)

## Current features:
* Badges
* Teams (course-long memberships)
* Groups (single-assignment memberships)
* Assignments
* Assignment Submissions
* Student Dashboard
* Interactive Grade Predictor
* Interactive Course Timeline
* Grading Rubrics
* Export students and final grades
* User analytics
* Team analytics
* Learning analytics suite
* Custom leveling system
* Assignment stats
* Student-logged assignment scoring
* Multipliers (students decide assignment weight)

## Coming soon:
* Assignment Unlocks
* Multi-factor leveling system

## Pre-reqs:
* Ruby 2.2
* PostgreSQL
* MongoDB
* Redis

## Installation instructions for development:
1. Clone repository
1. Run `cp config/database.yml.sample config/database.yml` (within the file, replace ```username``` with your current username
1. Run `cp config/mongoid.yml.sample config/mongoid.yml`
1. Run `cp .env.sample .env`
1. Run `bundle install`
1. Run `bundle exec rake db:create`
1. Optional: run `bundle exec rake db:sample`
1. Run `foreman start`

## Running specs

To run all of the spec examples, you can run the following (this is also the default rake task):

```
bundle exec rake spec
```

To run all of the spec examples with code coverage, you can run the following:

```
bundle exec rake spec:coverage
```

## Contributing

1. Clone the repository `git clone https://github.com/UM-USElab/gradecraft-development`
1. Create a feature branch `git checkout -b my-awesome-feature`
1. Code!
1. Commit your changes (small commits please)
1. Push your new branch `git push origin my-awesome-feature`
1. Create a pull request `hub pull-request -b um-uselab:master -h um-uselab:my-awesome-feature`
