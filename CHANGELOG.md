## [2.1.0] - Unreleased
- Add the `Emails` class for the emails built with the simple editor: get an email, its HTML and its blocks, insert, update, delete, move and validate blocks, update and validate the design settings, save a template, and list, save and restore versions
- Add `BrandStyles#get` and `Files#list`
- Add `Campaigns::EDITOR_SIMPLE`, and document `editor` and `template_id` for the emails of `Campaigns#create`
- Add the optional `idempotency_key` argument to the email writes
- The new methods return an `HTTP::Response` with `api_error` (a `MailerLite::ApiError` with `status`, `code`, `etag`, `errors` and `api_message`) and `idempotent_replay?`. They do not raise for an API error

## [2.0.0] - 2024-12-11
- *BREAKING CHANGE* - Please check the README file, dotenv is now optional
- *BREAKING CHANGE* - Updated the minimal required Ruby version from 2.5 to 3.1

## [1.0.6] - 2024-12-06
- Page parameter to cursor pagination fix

## [1.0.5] - 2024-03-12
- Update constant name

## [1.0.4] - 2023-11-20
- Update subscribers update
- Add forget subscriber method

## [1.0.3] - 2023-06-02
- Documentation update
- mailerlite.rb missing version

## [1.0.2] - 2023-03-22
- Gemfile.lock removed

## [1.0.1] - 2023-03-22
- Version update

## [1.0.0] - 2023-03-06
- Initial release