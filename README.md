# trainasone-connectiq
TrainAsONE Connect IQ app

This is a prototype Connect IQ app to download workouts from the
https://trainasone.com AI running coach. It is *extremely* barebones.

Requirements
- Garmin device or simulator with ConnectIQ 2.x & advanced workouts (see below)
- Allocated ClientId and ClientSecret from garmin@trainasone.com

Current functionality
- Authenticate against TrainAsONE server
- Download next planned workout to device

Target devices (not all tested yet)
- D2 Charlie
- Fenix 5
- Fenix 5S
- Fenix 5X
- Fenix Chronos
- Forerunner 735xt
- Forerunner 935
- Quatix 5
- Vivoactive 3

To build
- Install Eclipse with Garmin ConnectIQ plugin and configure
- Checkout this repository
- Copy source/Config.mc.template to source/Config.mc
- Obtain ClientId and ClientSecret from garmin@trainasone.com
- Make the world a better plan (hoo!)
