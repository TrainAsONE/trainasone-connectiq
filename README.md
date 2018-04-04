# trainasone-connectiq
TrainAsONE Connect IQ app

This is a simple Connect IQ app to download workouts from the
https://trainasone.com AI running coach.

It is available in the Garmin Store as
https://apps.garmin.com/en-US/apps/dfbebe0d-1cff-471d-afc0-3cb0be0c89c3

Requirements
- Garmin device or simulator
- ConnectIQ 2.x & advanced workouts required for workout download
- ClientId and ClientSecret from garmin@trainasone.com

Current functionality
- Authenticate against TrainAsONE server via OAuth2
- Indicate next workout details (including distance & duration)
- Download next workout to device
  - Run next planned workout
  - Refetch next planned workout
  - Login as different TrainAsONE user

Target devices for full functionality (ConnectIQ 2.x with PersistedContent)
- D2 Charlie
- Fenix 5
- Fenix 5S
- Fenix 5X
- Fenix Chronos
- Forerunner 735xt
- Forerunner 935
- Quatix 5
- Vivoactive 3 (If Garmin enable PersistedContent)

When run on other devices it should still show the next workout, but
will not be able to download to the device.

To build
- Install Eclipse with Garmin ConnectIQ plugin and configure
- Checkout this repository
- Copy source/Config.mc.template to source/Config.mc
- Obtain ClientId and ClientSecret from garmin@trainasone.com
- Make the world a better place (hoo!)

This is still very much a work in progress. It runs as a widget.

Source formatting preferences
- 2 character spaces
- Use spaces rather than tabs
- Unix line endings

Releasing
- Update version in source/Version.mc
- Copy manifest-downloadcapable.xml to manifest.xml, run App Export Wizard, upload generated .iq as TrainAsONE
- Copy manifest-allwatches.xml to manifest.xml, run App Export Wizard, save generated .iq as TrainAsONE-lite

