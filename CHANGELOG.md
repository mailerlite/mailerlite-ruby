## [Unreleased]
- Add `Automations#create`, `#update`, `#delete`, `#copy`, `#enable`, `#disable`, `#test`, `#add_subscribers`, `#readd`, `#add_activity_to_group`, `#cancel_activity` and `#skip_activity_delay`
- Add the `AutomationTriggers`, `AutomationSteps`, `AutomationEmails`, `AutomationTemplates` and `AutomationReports` classes
- Add `Subscribers#activity_log` and `Groups#import_subscribers`
- Add the missing documented params to `Subscribers#fetch`, `Subscribers#create`, `Groups#get_subscribers`, `Segments#list`, `Segments#update` and `Automations#get`
- `Segments#get_subscribers` takes `cursor`. The API ignores `after`, so it always returned the first page
- `Groups#get_subscribers` and `Segments#list` send their params in the query string, not in a JSON body on a GET
- `Automations#get_subscriber_activity` takes `filter[:search]`, sent as `filter[search]`. The old `filter[:keyword]` is now sent as `filter[search]` too; the API rejected `filter[keyword]` with a 400
- `AutomationReports#step_subscribers` and `#trigger_subscribers` send an Array `filter[:id]` as one comma-separated value
- `Automations#get_subscriber_activity` takes `with_subscribers: true` to include each run's subscriber. It sends `with_subscribers=1` only when true, because the API turns it on for any value

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