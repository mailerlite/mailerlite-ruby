<a href="https://www.mailerlite.com"></a>

MailerLite Ruby SDK

[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE.txt)

- [Installation](#installation)
  - [Setup](#setup)
- [Usage](#usage)

# Installation

## Setup

```bash
gem install mailerlite-ruby
```

You will have to initalize it in your Ruby file with `require "mailerlite-ruby"`.

# Usage

This SDK requires that you either have `.env` file with `MAILERLITE_API_TOKEN` env variable or that your variable is enabled system wide (useful for Docker/Kubernetes). The example of how `MAILERLITE_API_TOKEN` should look like is in `.env.example`.

# Testing

```bash
bundle i 
bundle exec rspec spec/*rspec.rb
```

To run tests you would need to install gems using bundle and then run rspec via bundle to run all tests.
The fixtures for the test have been recorded using vcr and are available in the ./fixtures directory