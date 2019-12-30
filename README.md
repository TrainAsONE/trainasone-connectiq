# trainasone-connectiq
TrainAsONE Connect IQ app

This is a simple Connect IQ app to download workouts from the
https://trainasone.com AI running coach.

It is available in the Garmin Store as
https://apps.garmin.com/en-US/apps/dfbebe0d-1cff-471d-afc0-3cb0be0c89c3

## Requirements
- Garmin device or simulator
- ConnectIQ 2.x, PersistedContent and advanced workouts required for workout download
- ClientId and ClientSecret from garmin@trainasone.com

## Current functionality
- Authenticate against TrainAsONE server via OAuth2
- Indicate next workout details (including distance & duration)
- Download next workout to device
  - Run next planned workout
  - Refetch next planned workout
  - Login as different TrainAsONE user
  - Open TrainAsONE on mobile device
  - Set workout step target
  - Toggle adjust temperature and undulation and include run back step

## Target devices for full functionality (PersistedContent)
- D2 Charlie
- Fenix 5 range
- Fenix 6 range
- Fenix Chronos
- Forerunner 245
- Forerunner 645
- Forerunner 735xt
- Forerunner 935
- Forerunner 945
- Quatix 5

When run on other devices it should still show the next workout, but
will not be able to download to the device.

## To build
- Install Eclipse with Garmin ConnectIQ plugin and configure
- Checkout this repository
- Copy source/Config.mc.template to source/Config.mc
- Obtain ClientId and ClientSecret from garmin@trainasone.com
- Make the world a better place (hoo!)

This is still a work in progress. It runs as a widget.

## Workout files overview

The Garmin FIT format can be used to hold a workout description,
essentially a list of steps, each with a duration and target pace
or heart rate range. The Garmin Connect system can push workout
files all watches which support advanced workouts.

A subset of these watches can run Connect IQ apps, and a subset of
these support PersistedContent, which allows Connect IQ apps to
download FIT workout files and pass them to the watch to run.

## How does the app work

On startup the app checks if there is an OAuth2 token stored for
the current server host. If one is not found the user is redirected
to the TrainAsONE server on their phone to login and grant access,
which then returns a grant token back to the app. The app then
connects back to the TrainAsONE server to convert this grant token
to an access token, which is then stored.

The app then uses the access token to request a plannedWorkoutSummary
from the TrainAsONE server, which is a JSON object containing the
user's preferences and some summary data about their next workout
(These are merged into a single request to reduce the number of
network calls required).

If successful the workout summary is stored and if supported by
the watch the matching workout FIT file is also downloaded. The
summary is then shown to the user.

If the request fails an error message is shown with an option to
show any previously stored summary.

When displaying a workout the user can press the menu or select
buttons to select different options such as switching the workout
stop target from pace to heart rate, switching temperature adjustment
or logging in as a different TrainAsONE account.

## Source formatting preferences
- 2 character spaces
- Use spaces rather than tabs
- Unix line endings

## Releasing
- Update version in source/Version.mc
- Copy manifest-downloadcapable.xml to manifest.xml, run App Export Wizard, upload generated .iq as TrainAsONE
- Copy manifest-allwatches.xml to manifest.xml, run App Export Wizard, save generated .iq as TrainAsONE-lite
