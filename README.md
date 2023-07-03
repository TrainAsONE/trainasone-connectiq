# trainasone-connectiq
TrainAsONE Connect IQ app

This is a simple Connect IQ app to download workouts from the
https://trainasone.com AI running coach.

It is available in the Garmin Store as
https://apps.garmin.com/en-US/apps/dfbebe0d-1cff-471d-afc0-3cb0be0c89c3

## Requirements
- Garmin device or simulator
- ConnectIQ 2.4, PersistedContent and advanced workouts required for workout download
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

## Supported devices

### Download capable
- Captain Marvel
- D2 Charlie
- D2 Delta
- D2 Delta PX
- D2 Delta S
- D2 Mac1
- Darth Vader
- Descent G1
- Descent Mk1
- Descent Mk2 (glance)
- Descent Mk2s (glance)
- Enduro
- Epix (Gen 2)
- fenix 5
- fenix 5 plus
- fenix 5S
- fenix 5S plus
- fenix 5X
- fenix 5X plus
- fenix 6 (glance)
- fenix 6 Pro (glance)
- fenix 6S (glance)
- fenix 6S Pro (glance)
- fenix 6X Pro (glance)
- fenix 7 (glance)
- fenix 7S (glance)
- fenix 7X (glance)
- fenix Chronos
- First Avenger
- Forerunner 55 (glance)
- Forerunner 245 (glance)
- Forerunner 245 Music (glance)
- Forerunner 255 (glance)
- Forerunner 255 Music (glance)
- Forerunner 255s (glance)
- Forerunner 255s Music (glance)
- Forerunner 265 (glance)
- Forerunner 265s (glance)
- Forerunner 645 (glance)
- Forerunner 645 Music (glance)
- Forerunner 735XT
- Forerunner 745 (glance)
- Forerunner 935
- Forerunner 945 (glance)
- Forerunner 945 LTEglance)
- Forerunner 955
- Forerunner 965
- Instinct 2
- Instinct 2S
- Instinct 2X
- Instinct Crossover
- MARQ Adventurer (glance)
- MARQ Athlete (glance)
- MARQ Aviator (glance)
- MARQ Captain (glance)
- MARQ Commander (glance)
- MARQ Driver (glance)
- MARQ Expedition (glance)
- MARQ Golfer (glance)
- MARQ 2 (glance)
- MARQ 2 Aviator (glance)
- Rey
- Venu 2 (glance)
- Venu 2 Plus (glance)
- Venu 2S (glance)
- Venu D
- Venu Mercedes Benz
- Venu Sq 2
- Venu Sq 2 Music
- vivoactive 4
- vivoactive 4S

### Can download, but not start workout
- Venu Sq
- Venu Sq Music

### Not download capable
- D2 Air
- D2 Air x10
- D2 Bravo
- D2 Bravo Titanium
- fenix 3
- fenix 3 HR
- Forerunner 230
- Forerunner 235
- Forerunner 630
- Forerunner 920XT
- Venu
- vivoactive
- vivoactive 3
- vivoactive 3 Mercedes Benz
- vivoactive 3 Music
- vivoactive 3 Music LTE
- vivoactive HR


When run on non download capable devices it should still show the next workout
and allow ajusting the workout preferences.

## To build
- Install Visual Studio with Garmin ConnectIQ plugin and configure
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
- Copy manifest-downloadcapable.xml to manifest.xml, run Application Export Wizard, upload generated .iq as TrainAsONE
- Copy manifest-allwatches.xml to manifest.xml, run Application Export Wizard, save generated .iq as TrainAsONE-lite
