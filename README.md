# Opsgenie Alert Tagging

Opsgenie Alert Tagging updates Opgenies alerts with their relevant tags based on the time and date each alert was created at.

This was a manual process which required a human to type in relevant tags within the UI of each alert.
This has been created to automate this process.
Future iterations of this will ensure that the program will run daily via a Github action.

### Getting started

clone the repo:

```
$ git clone git@github.com:dxw/opsgenie-alert-tagging.git
```

run
```
$ bundle install
```

run tests with
```
$ bundle exec rspec
```

### Environment Variables

Ensure the follwoing required environment variables are set in a `.env` file:

- `OPSGENIE_API_KEY`: Osgenie API key. DevOps to generate this for you (needs admin access)

### Documentation

Opsgenie API Documentation is found here https://docs.opsgenie.com/docs/alert-api

GOVUK bank holiday API Documentation is found here https://www.api.gov.uk/gds/bank-holidays/#bank-holidays


### Running

To tag alerts for a specific date, run:

```
$ bundle exec rake opsgenie_alert_tagging:add_tags[<date>]
```

Where `<date>` is the date string in the format `2021-10-10`.

By running the command without a date, this will default to yesterday's date

```
$ bundle exec rake opsgenie_alert_tagging:add_tags
```

View the updated alert with it's tags in the UI
