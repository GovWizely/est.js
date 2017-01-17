# est.js

[![Build Status](https://travis-ci.org/GovWizely/est.js.svg?branch=gh-pages)](https://travis-ci.org/GovWizely/est.js)

## Dependencies

- Ruby 2.2 or up
- Bundler 1.12.5 or up
- Phantomjs 2.1.1 or up

## Setup

- Install [phantomjs](http://phantomjs.org)
  ```unix
  $ brew install phantomjs
  ```

  Verify that phantomjs is installed
  ```unix
  $ phantomjs -v
  #=> 2.1.1
  ```

- Install ruby
  See (http://rbenv.org) or (http://rvm.io)

- Install gems
  ```unix
  $ bundle install
  ```

- Start jekyll server
  ```
  $ bundle exec jekyll s
  ```

## Workflow

- Make changes to the spec
- Make changes to the .coffee
- View your changes by visiting the (http://localhost:4000/development.html) from your browser
- Build and run your tests until they all pass by running `rake`.

  This step will also generate a compressed `est.min.js` based on the .coffee

  ```unix
  $ bundle exec rake
  ```
- Verify the final build by visiting (http://localhost:4000/production.html) from your browser

