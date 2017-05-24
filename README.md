# PagerDuty

[![Build Status](https://travis-ci.org/veverkap/pager_duty.svg?branch=master)](https://travis-ci.org/veverkap/pager_duty) [![codebeat badge](https://codebeat.co/badges/da87a6f5-34c2-445f-8cc6-62343c5e6acc)](https://codebeat.co/projects/github-com-veverkap-pager_duty-master) [![Gem Version](https://badge.fury.io/rb/pager_duty.svg)](https://badge.fury.io/rb/pager_duty)

Ruby client for v2 of the [PagerDuty API](https://v2.developer.pagerduty.com/v2/page/api-reference)

## Table of Contents

1. [Philosophy](#philosophy)
2. [Quick start](#quick-start)
3. [Making requests](#making-requests)
4. [Consuming resources](#consuming-resources)
6. [Authentication](#authentication)
   1. [API tokens](#api-tokens)
7. [Configuration and defaults](#configuration-and-defaults)
    1. [Configuring module defaults](#configuring-module-defaults)
    2. [Using ENV variables](#using-env-variables)
8. [Advanced usage](#advanced-usage)
    1. [Debugging](#debugging)
    2. [Caching](#caching)
9. [Hacking on PagerDuty](#hacking-on-pagerduty)
    1. [Running and writing new tests](#running-and-writing-new-tests)
10. [Supported Ruby Versions](#supported-ruby-versions)
11. [Versioning](#versioning)
12. [License](#license)

## Philosophy

This gem borrows liberally from the design philosophy of the 
wonderful [octokit](https://github.com/octokit/octokit.rb) library.
Most methods have positional arguments for required input and an options hash
for optional parameters, headers, or other options:

## Quick start

Install via Rubygems

    gem install pager_duty

... or add to your Gemfile

    gem "pager_duty", "~> 0.1"

### Making requests

[API methods][] are available as module methods (consuming module-level
configuration) or as client instance methods.

```ruby
# Provide authentication credentials
PagerDuty.configure do |c|
  c.api_token = "XXXXXXXX"
end

# Fetch the current user
PagerDuty.abilities
```
or

```ruby
# Provide authentication credentials
client = PagerDuty::Client.new(api_token: "XXXXXXXX")
# Fetch the current user
client.abilities
```

[API methods]: http://veverkap.github.io/pager_duty/method_list.html

### Consuming resources

Most methods return a `Resource` object which provides dot notation and `[]`
access for fields returned in the API response.

```ruby
# Fetch a user
addon = PagerDuty.addon("P5R5GQ4")
puts addon.name
# => "Great Addon"
puts addon.fields
# => <Set: {:id, :type, :summary, :self, :html_url, :name, :src, :services}>
puts addon[:type]
# => "full_page_addon"
```

## Authentication

PagerDuty supports the API token method for authentication:

### API Tokens

API tokens can be revoked, removing access for only that token without having to change your password everywhere.

To use an access token with the PagerDuty client, pass your token in the `:access_token` options parameter:

```ruby
client = PagerDuty::Client.new(:access_token => "<your token>")
```

You can create access tokens through your Account Settings which are typically at https://YOURSUBDOMAIN.pagerduty.com/api_keys

### Using ENV variables

Default configuration values are specified in {PagerDuty::Default}. Many
attributes will look for a default value from the ENV before returning
PagerDuty's default.

```ruby
# Given $PAGERDUTY_API_ENDPOINT is "http://api.pagerduty.dev"
PagerDuty.api_endpoint

# => "http://api.pagerduty.dev"
```

## Advanced usage

Since PagerDuty employs [Faraday][faraday] under the hood, some behavior can be
extended via middleware.

### Debugging

Often, it helps to know what PagerDuty is doing under the hood. You can add a
logger to the middleware that enables you to peek into the underlying HTTP
traffic:

```ruby
stack = Faraday::RackBuilder.new do |builder|
  builder.response :logger
  builder.use PagerDuty::Response::RaiseError
  builder.adapter Faraday.default_adapter
end
PagerDuty.middleware = stack
PagerDuty.abilities
```
```
I, [2017-05-22T12:47:16.335959 #79147]  INFO -- : GET https://api.pagerduty.com/abilities
D, [2017-05-22T12:47:16.336026 #79147] DEBUG -- : "Accept: application/vnd.pagerduty+json;version=2
User-Agent: PagerDuty Ruby Gem 0.1.0
Content-Type: application/json
Authorization: Token token=\"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\""
I, [2017-05-22T12:47:16.350493 #79147]  INFO -- : HTTP 200
D, [2017-05-22T12:47:16.350568 #79147] DEBUG -- : "server: nginx
date: Fri, 19 May 2017 14:02:40 GMT
content-type: application/json; charset=utf-8
transfer-encoding: chunked
connection: keep-alive
status: 200 OK
access-control-allow-methods: GET, POST, PUT, DELETE, OPTIONS
access-control-max-age: 1728000
access-control-allow-origin: *
access-control-allow-headers: Authorization, Content-Type
x-ua-compatible: IE=Edge,chrome=1
etag: W/\"0da61ef0d8a5571c22d819a5ed89665e\"
cache-control: max-age=0, private, must-revalidate
x-request-id: 5f125e02489796ac002cf0f7a321fe88

{\"abilities\":[\"sso\",\"advanced_reports\",\"teams\",\"read_only_users\",\"team_responders\",\"service_support_hours\",\"urgencies\",\"manage_schedules\",\"manage_api_keys\",\"coordinated_responding\",\"event_rules\",\"beta_custom_actions\",\"coordinated_responding_preview\",\"preview_incident_alert_split\",\"permissions_service\",\"on_call_selfie\",\"features_in_use_preventing_downgrade_to\",\"feature_to_plan_map\"]}"
...
```

See the [Faraday README][faraday] for more middleware magic.

### Caching

If you want to boost performance, stretch your API rate limit, or avoid paying
the hypermedia tax, you can use [Faraday Http Cache][cache].

Add the gem to your Gemfile

    gem 'faraday-http-cache'

Next, construct your own Faraday middleware:

```ruby
stack = Faraday::RackBuilder.new do |builder|
  builder.use Faraday::HttpCache, serializer: Marshal, shared_cache: false
  builder.use PagerDuty::Response::RaiseError
  builder.adapter Faraday.default_adapter
end
PagerDuty.middleware = stack
```

Once configured, the middleware will store responses in cache based on ETag
fingerprint and serve those back up for future `304` responses for the same
resource. See the [project README][cache] for advanced usage.


[cache]: https://github.com/plataformatec/faraday-http-cache
[faraday]: https://github.com/lostisland/faraday

## Hacking on PagerDuty

If you want to hack on PagerDuty locally, we try to make [bootstrapping the
project][bootstrapping] as painless as possible. To start hacking, clone and run:

    script/bootstrap

This will install project dependencies and get you up and running. If you want
to run a Ruby console to poke on PagerDuty, you can crank one up with:

    script/console

Using the scripts in `./scripts` instead of `bundle exec rspec`, `bundle
console`, etc.  ensures your dependencies are up-to-date.

### Running and writing new tests

PagerDuty uses [VCR][] for recording and playing back API fixtures during test
runs. These cassettes (fixtures) are part of the Git project in the `spec/cassettes`
folder. If you're not recording new cassettes you can run the specs with existing
cassettes with:

    script/test

[bootstrapping]: http://wynnnetherland.com/linked/2013012801/bootstrapping-consistency
[VCR]: https://github.com/vcr/vcr

## Supported Ruby Versions

This library aims to support and is [tested against][travis] the following Ruby
implementations:

* Ruby 2.3
* Ruby 2.4

If something doesn't work on one of these Ruby versions, it's a bug.

This library may inadvertently work (or seem to work) on other Ruby
implementations, but support will only be provided for the versions listed
above.

If you would like this library to support another Ruby version, you may
volunteer to be a maintainer. Being a maintainer entails making sure all tests
run and pass on that implementation. When something breaks on your
implementation, you will be responsible for providing patches in a timely
fashion. If critical issues for a particular implementation exist at the time
of a major release, support for that Ruby version may be dropped.

[travis]: https://travis-ci.org/veverkap/pager_duty

## Versioning

This library aims to adhere to [Semantic Versioning 2.0.0][semver]. Violations
of this scheme should be reported as bugs. Specifically, if a minor or patch
version is released that breaks backward compatibility, that version should be
immediately yanked and/or a new version should be immediately released that
restores compatibility. Breaking changes to the public API will only be
introduced with new major versions. As a result of this policy, you can (and
should) specify a dependency on this gem using the [Pessimistic Version
Constraint][pvc] with two digits of precision. For example:

    spec.add_dependency 'pager_duty', '~> 3.0'

The changes made between versions can be seen on the [project releases page][releases].

[semver]: http://semver.org/
[pvc]: http://guides.rubygems.org/patterns/#pessimistic-version-constraint
[releases]: https://github.com/veverkap/pager_duty/releases

## License

Copyright (c) 2017 Patrick Veverka

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
