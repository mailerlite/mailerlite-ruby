<a href="https://www.mailerlite.com"><img src="https://app.mailerlite.com/assets/images/logo-color.png" width="200px"/></a>

# MailerLite Ruby SDK

[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE)

## Getting started

For more information about MailerLite API, please visit the [following link:](https://developers.mailerlite.com/docs/#mailerlite-api)

### Authentication

API keys are a quick way to implement machine-to-machine authentication without any direct inputs from a human beyond initial setup.

For more information how to obtain an API key visit the [following link](https://developers.mailerlite.com/docs/#mailerlite-api)

## Table of Contents

- [MailerLite Ruby SDK](#mailerlite-ruby-sdk)
  - [Getting started](#getting-started)
    - [Authentication](#authentication)
  - [Table of Contents](#table-of-contents)
  - [Installation](#installation)
  - [Usage](#usage)
    - [MailerLite Client](#mailerlite-client)
  - [Subscribers](#subscribers)
    - [List all subscribers](#list-all-subscribers)
    - [Create a subscriber](#create-a-subscriber)
    - [Update a subscriber](#update-a-subscriber)
    - [Get a subscriber](#get-a-subscriber)
    - [Delete a subscriber](#delete-a-subscriber)
  - [Groups](#groups)
    - [List all groups](#list-all-groups)
    - [Create a group](#create-a-group)
    - [Update a group](#update-a-group)
    - [Delete a group](#delete-a-group)
    - [Get subscribers belonging to a group](#get-subscribers-belonging-to-a-group)
    - [Assign subscriber to a group](#assign-subscriber-to-a-group)
    - [Unassign subscriber from a group](#unassign-subscriber-from-a-group)
  - [Segments](#segments)
    - [List all segments](#list-all-segments)
    - [Update a segment](#update-a-segment)
    - [Delete a segment](#delete-a-segment)
    - [Get subscribers belonging to a segment](#get-subscribers-belonging-to-a-segment)
  - [Fields](#fields)
    - [List all fields](#list-all-fields)
    - [Create a field](#create-a-field)
    - [Update a field](#update-a-field)
    - [Delete a field](#delete-a-field)
  - [Automations](#automations)
    - [List all automations](#list-all-automations)
    - [Get an automation](#get-an-automation)
    - [Get subscribers activity for an automation](#get-subscribers-activity-for-an-automation)
  - [Campaigns](#campaigns)
    - [List all campaigns](#list-all-campaigns)
    - [Get a campaign](#get-a-campaign)
    - [Create a campaign](#create-a-campaign)
    - [Update a campaign](#update-a-campaign)
    - [Schedule a campaign](#schedule-a-campaign)
    - [Cancel a campaign](#cancel-a-campaign)
    - [Delete a campaign](#delete-a-campaign)
    - [Get subscribers activity for a campaign](#get-subscribers-activity-for-a-campaign)
  - [Forms](#forms)
    - [List all forms](#list-all-forms)
    - [Get a form](#get-a-form)
    - [Update a form](#update-a-form)
    - [Delete a form](#delete-a-form)
    - [Get subscribers who signed up to a specific form](#get-subscribers-who-signed-up-to-a-specific-form)
  - [Batching](#batching)
    - [Create a new batch](#create-a-new-batch)
  - [Webhooks](#webhooks)
    - [List all webhooks](#list-all-webhooks)
    - [Get a webhook](#get-a-webhook)
    - [Create a webhook](#create-a-webhook)
    - [Update a webhook](#update-a-webhook)
    - [Delete a webhook](#delete-a-webhook)
  - [Timezones](#timezones)
    - [Get a list of timezones](#get-a-list-of-timezones)
  - [Campaign languages](#campaign-languages)
    - [Get a list of languages](#get-a-list-of-languages)

## Setup

```bash
gem install mailerlite-ruby
```

You will have to initalize it in your Ruby file with `require "mailerlite-ruby"`.

# Usage

This SDK requires that you either have `.env` file with `MAILERLITE_API_TOKEN` env variable or that your variable is enabled system wide (useful for Docker/Kubernetes). The example of how `MAILERLITE_API_TOKEN` should look like is in `.env.example`.

## Subscribers

<a name="subscribers"></a>

### List all subscribers

<a name="get-a-list-of-subscribers"></a>

```ruby
require "mailerlite-ruby"

# Intialize the class
subscribers = MailerLite::Subscribers.new

subscribers.fetch(filter: { status: 'active' })
```

### Create a subscriber

<a name="create-a-subscriber"></a>

```ruby
require "mailerlite-ruby"

# Intialize the class
subscribers = MailerLite::Subscribers.new

subscribers.create(email:'some@email.com', fields: {'name': 'John', 'last_name': 'Doe'}, ip_address:'1.2.3.4', optin_ip:'1.2.3.4')
```

### Update a subscriber

<a name="update-a-subscriber"></a>

```ruby
require "mailerlite-ruby"

# Intialize the class
subscribers = MailerLite::Subscribers.new

subscribers.update(email:'some@email.com', fields: {'name': 'John', 'last_name': 'Doe'}, ip_address:'1.2.3.4', optin_ip:'1.2.3.4')
```

### Get a subscriber

<a name="get-a-subscriber"></a>

```ruby
require "mailerlite-ruby"

# Intialize the class
subscribers = MailerLite::Subscribers.new

subscribers.get('some@email.com')
```

### Delete a subscriber

<a name="delete-a-subscriber"></a>

```ruby
require "mailerlite-ruby"

# Intialize the class
subscribers = MailerLite::Subscribers.new

subscriber_id = 1234567890

subscribers.delete(subscriber_id)
```

## Groups

<a name="groups"></a>

### List all groups

<a name="list-all-groups"></a>

```ruby
require "mailerlite-ruby"

# Intialize the class
groups = MailerLite::Groups.new

groups.list(limit:10, page:1, filter:{'name': 'My'}, sort:'name')
```

### Create a group

<a name="create-a-group"></a>

```ruby
require "mailerlite-ruby"

# Intialize the class
groups = MailerLite::Groups.new

groups.create(name:'Group Name')
```

### Update a group

<a name="update-a-group"></a>

```ruby
require "mailerlite-ruby"

# Intialize the class
groups = MailerLite::Groups.new

groups.update(group_id:1234567, name:'My New Group')
```

### Delete a group

<a name="delete-a-group"></a>

```ruby
require "mailerlite-ruby"

# Intialize the class
groups = MailerLite::Groups.new

group_id = 1234567

groups.delete(group_id)
```

### Get subscribers belonging to a group

<a name="get-subscribers-belonging-to-a-group"></a>

```ruby
require "mailerlite-ruby"

# Intialize the class
groups = MailerLite::Groups.new

groups.get_subscribers(group_id:1234567, page:1, limit:10, filter:{'status': 'active'})
```

### Assign subscriber to a group

<a name="assign-subscribers-to-a-group"></a>

```ruby
require "mailerlite-ruby"

# Intialize the class
groups = MailerLite::Groups.new

subscribers.assign_subscriber(subscriber_id:111222, group_id:1234567)
```

### Unassign subscriber from a group

<a name="unassign-subscribers-from-a-group"></a>

```ruby
require "mailerlite-ruby"

# Intialize the class
groups = MailerLite::Groups.new

subscribers.unassign_subscriber(subscriber_id:111222, group_id:1234567)
```

## Segments

<a name="segments"></a>

### List all segments

<a name="list-all-segments"></a>

```ruby
require "mailerlite-ruby"

# Intialize the class
segments = MailerLite::Segments.new

segments.list(limit:10, page:1)
```

### Update a segment

<a name="update-a-segment"></a>

```ruby
require "mailerlite-ruby"

# Intialize the class
segments = MailerLite::Segments.new

segments.update(segment_id: 123456, name:'My New Segment Name')
```

### Delete a segment

<a name="delete-a-segment"></a>

```ruby
require "mailerlite-ruby"

# Intialize the class
segments = MailerLite::Segments.new
segment_id = 123456

segments.delete(segment_id)
```

### Get subscribers belonging to a segment

<a name="get-subscribers-belonging-to-a-segment"></a>

```ruby
require "mailerlite-ruby"

# Intialize the class
segments = MailerLite::Segments.new

segments.get_subscribers(segment_id:123456, limit:10, filter:{'status': 'active'})
```

## Fields

<a name="fields"></a>

### List all fields

<a name="list-all-fields"></a>

```ruby
require "mailerlite-ruby"

# Intialize the class
fields = MailerLite::Fields.new

fields.get(limit:10, page:1, sort:'name', filter:{'keyword': 'abc', 'type': 'text'})
```

### Create a field

<a name="create-a-field"></a>

```ruby
require "mailerlite-ruby"

# Intialize the class
fields = MailerLite::Fields.new

fields.create(name:'My Field', type:'text')
```

### Update a field

<a name="update-a-field"></a>

```ruby
require "mailerlite-ruby"

# Intialize the class
fields = MailerLite::Fields.new

fields.update(field_id:123345, name:'My New Field')
```

### Delete a field

<a name="delete-a-field"></a>

```ruby
require "mailerlite-ruby"

# Intialize the class
fields = MailerLite::Fields.new

field_id = 123456

fields.delete(field_id)
```

## Automations

<a name="automations"></a>

### List all automations

<a name="list-all-automations"></a>

```ruby
require "mailerlite-ruby"

# Intialize the class
automations = MailerLite::Automations.new

automations.get(limit:10, page:1, filter:{'status': true, 'name': 'some name', 'group': 123456})
```

### Get an automation

<a name="get-an-automation"></a>

```ruby
require "mailerlite-ruby"

# Intialize the class
automations = MailerLite::Automations.new

automation_id = 123456

automations.fetch(automation_id)
```

### Get subscribers activity for an automation

<a name="get-subscribers-activity-for-an-automation"></a>

```ruby
require "mailerlite-ruby"

# Intialize the class
automations = MailerLite::Automations.new

automations.get_subscriber_activity(automation_id:123456, page:1, limit:10, filter:{'status': 'active', 'date_from': '2022-12-20', 'date_to': '2022-12-31'})
```

## Campaigns

<a name="campaigns"></a>

### List all campaigns

<a name="list-all-campaigns"></a>

```ruby
require "mailerlite-ruby"

# Intialize the class
campaigns = MailerLite::Campaigns.new

campaigns.get(limit:10, page:1, filter:{'status': 'ready', 'type': 'regular'})
```

### Get a campaign

<a name="get-a-campaign"></a>

```ruby
require "mailerlite-ruby"

# Intialize the class
campaigns = MailerLite::Campaigns.new

campaigns.fetch(campaign_id:123456)
```

### Create a campaign

<a name="create-a-campaign"></a>

```ruby
require "mailerlite-ruby"

# Intialize the class
campaigns = MailerLite::Campaigns.new

campaigns.create(
    name: "Test Campaign",
    language_id: 1,
    type: "regular",
    emails: [{
        "subject": "This is a test campaign",
        "from_name": "Test Man",
        "from": "testuser@mailerlite.com",
        "content": "Hi there, this is a test campaign!"
    }]
  )
```

### Update a campaign

<a name="update-a-campaign"></a>

```ruby
require "mailerlite-ruby"

# Intialize the class
campaigns = MailerLite::Campaigns.new

campaigns.update(
  campaign_id: 1233455, 
  name: "New Campaign Name",
  language_id: 2,
  emails: [{
      "subject": "This is a test campaign",
      "from_name": "Test Man",
      "from": "testuser@mailerlite.com",
      "content": "Hi there, this is a test campaign!"
  }]
  )
```

### Schedule a campaign

<a name="schedule-a-campaign"></a>

```ruby
require "mailerlite-ruby"

# Intialize the class
campaigns = MailerLite::Campaigns.new

campaigns.schedule(
  campaign_id: 123456,
  delivery: "scheduled",
  schedule: {
      "date": "2022-12-31",
      "hours": "22",
      "minutes": "00"
  }
)
```

### Cancel a campaign

<a name="cancel-a-campaign"></a>

```ruby
require "mailerlite-ruby"

# Intialize the class
campaigns = MailerLite::Campaigns.new

campaign_id = 123456

campaigns.cancel(campaign_id)
```

### Delete a campaign

<a name="cancel-a-campaign"></a>

```ruby
require "mailerlite-ruby"

# Intialize the class
campaigns = MailerLite::Campaigns.new

campaign_id = 123456

campaigns.delete(campaign_id)
```

### Get subscribers activity for a campaign

<a name="get-subscribers-activity-for-an-campaign"></a>

```ruby
require "mailerlite-ruby"

# Intialize the class
campaigns = MailerLite::Campaigns.new

campaign_id = 123456

campaigns.activity(campaign_id)
```

## Forms

<a name="forms"></a>

### List all forms

<a name="list-all-forms"></a>

```ruby
require "mailerlite-ruby"

# Intialize the class
forms = MailerLite::Forms.new

forms.list(limit:10, page:1, sort:'name', filter:{'name': 'form name'})
```

### Get a form

<a name="get-a-form"></a>

```ruby
require "mailerlite-ruby"

# Intialize the class
forms = MailerLite::Forms.new

form_id = 123456

forms.fetch(form_id)
```

### Update a form

<a name="update-a-form"></a>

```ruby
require "mailerlite-ruby"

# Intialize the class
forms = MailerLite::Forms.new

forms.update(form_id:123456, name: 'My form Name')
```

### Delete a form

<a name="cancel-a-form"></a>

```ruby
require "mailerlite-ruby"

# Intialize the class
forms = MailerLite::Forms.new

form_id = 123456

forms.delete(form_id)
```

### Get subscribers who signed up to a specific form

<a name="get-subscribers-who-signed-up-to-a-specific-form"></a>

```ruby
require "mailerlite-ruby"

# Intialize the class
forms = MailerLite::Forms.new

forms.fetch_subscribers(form_id:123345, page:1, limit:10, filter:{'status': 'active'})
```

## Batching

<a name="batching"></a>

### Create a new batch

<a name="create-a-new-batch"></a>

```ruby
require "mailerlite-ruby"

# Intialize the class
batch = MailerLite::Batch.new

batch.request(
          requests: [
            { method: 'GET', path: 'api/subscribers/list' },
            { method: 'GET', path: 'api/campaigns/list' }
          ]
        )
```

## Webhooks

<a name="webhooks"></a>

### List all webhooks

<a name="list-all-webhooks"></a>

```ruby
require "mailerlite-ruby"

# Intialize the class
subscribers = MailerLite::Subscribers.new

webhooks.list()
```

### Get a webhook

<a name="get-a-webhook"></a>

```ruby
require "mailerlite-ruby"

# Intialize the class
subscribers = MailerLite::Subscribers.new

webhook_id = 123456

webhooks.get(webhook_id)
```

### Create a webhook

<a name="create-a-webhook"></a>

```ruby
require "mailerlite-ruby"

# Intialize the class
webhooks = MailerLite::Webhooks.new

webhooks.create(
  events:[
    'subscriber.created',
    'subscriber.updated',
    'subscriber.unsubscribed'
  ], 
  url:'https://my-url.com',
  name: 'Webhook name'
)
```

### Update a webhook

<a name="update-a-webhook"></a>

```ruby
require "mailerlite-ruby"

# Intialize the class
webhooks = MailerLite::Webhooks.new

webhooks.update(
  webhook_id: 123456, 
  events:[
    'subscriber.created',
    'subscriber.updated',
    'subscriber.unsubscribed'
  ], 
  url:'https://my-url.com',
  name: 'Webhook name',
  enabled: false
)
```

### Delete a webhook

<a name="cancel-a-webhook"></a>

```ruby
require "mailerlite-ruby"

# Intialize the class
webhooks = MailerLite::Webhooks.new

webhook_id = 123456

webhooks.delete(webhook_id)
```

## Timezones

<a name="timezones"></a>

### Get a list of timezones

<a name="get-a-list-of-timezones"></a>

```ruby
require "mailerlite-ruby"

# Intialize the class
timezones = MailerLite::Timezones.new

timezones.list()
```

## Campaign languages

<a name="languages"></a>

### Get a list of languages

<a name="get-a-list-of-languages"></a>

```ruby
require "mailerlite-ruby"

# Intialize the class
campaigns = MailerLite::Campaigns.new

campaigns.languages()
```

# Testing

```bash
bundle i 
bundle exec rspec spec/*rspec.rb
```

To run tests you would need to install gems using bundle and then run rspec via bundle to run all tests.
The fixtures for the test have been recorded using vcr and are available in the ./fixtures directory

# Generate Docs

```bash
bundle i 
bundle exec yardoc 'lib/**/*.rb'
```

This will generate html docs in the doc directory which can be opened up in any browser. Navigate to index.html and open it up.