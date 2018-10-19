using Toybox.Application as App;
using Toybox.Lang;
using Toybox.Graphics;
using Toybox.Time.Gregorian;
using Toybox.Time;
using Toybox.WatchUi as Ui;

class WorkoutView extends Ui.View {

  private var mModel;

  function initialize() {
    View.initialize();
    mModel = Application.getApp().model;
  }

  function onLayout(dc) {
    setLayout(Rez.Layouts.StandardLayout(dc));
    // Graphics.Dc.getHeight() fails with "Could not find symbol mHeight", presumably as we have not displayed yet
    var deviceSettings = System.getDeviceSettings();
    var height = deviceSettings.screenHeight;
    var width = deviceSettings.screenWidth;
    var centre = width / 2;
    // System.println("display: " + width + "x" + height);
    var view = View.findDrawableById("message");

    // Not a good way to handle this this.
    // On the other hand the odds on Garmin releasing new devices with low resolution
    // screens where width is an odd numbers of pixels...
    view.setLocation(centre, height <= 148 ? 62 : 75); // vivoactive
    view.setFont(width == 215 ? Graphics.FONT_MEDIUM : Graphics.FONT_SMALL);

    view.setText(buildMessageFromWorkout());
  }

  function buildMessageFromWorkout() {
    if (!mModel.hasWorkout()) {
      return Ui.loadResource(mModel.isExternalSchedule() ? Rez.Strings.noWorkoutExternalSchedule : Rez.Strings.noWorkout);
    }
    var summary = mModel.workoutSummary;
    var details = "";
    var distance = summary["distance"];
    if (distance) {
      details += formatDistance(distance);
    }
    var duration = summary["duration"];
    if (duration) {
      if (!details.equals("")) {
        details += ", ";
      }
      details += formatDuration(duration);
    }

    var message = Lang.format(Ui.loadResource(Rez.Strings.nextWorkoutString), [ summary["name"], details, formatDate(parseDate(summary["start"]))]);
    var extra = "";
    if (summary["temperature"] != null) {
      extra += formatTemperature(summary["temperature"]) + " ";
    }
    if (summary["undulation"] != null) {
      extra += summary["undulation"].format("%0.1f") + "U ";
    }
    if (mModel.updated) {
      extra += "* ";
    }

    if (!extra.equals("")) {
      message += "\n(" + extra.substring(0, extra.length() - 1) + ")";
    }
    return message;
  }

  function formatDistance(distance) {
    var displayPreferences = mModel.getDisplayPreferences();
    var units;
    if (displayPreferences["distancesInMiles"]) {
      distance = distance * 0.621371192 / 1000;
      units = Ui.loadResource(Rez.Strings.unitsMiles);
    } else {
      distance = distance / 1000;
      units = Ui.loadResource(Rez.Strings.unitsKm);
    }
    return Lang.format("$1$ $2$", [ distance.format("%0.1f"), units]);
  }

  function formatDuration(duration) {
    var units = Ui.loadResource(Rez.Strings.unitsMinutes);
    return Lang.format("$1$ $2$", [ duration / 60, units]);
  }

  function formatTemperature(temp) {
    var displayPreferences = mModel.getDisplayPreferences();
    var units;
    if (displayPreferences["temperaturesInFahrenheit"]) {
      temp = temp * 9 / 5 + 32;
      temp = temp.format("%d");
      units = Ui.loadResource(Rez.Strings.unitsFahrenheit);
    } else {
      temp = temp.format("%0.1f");
      units = Ui.loadResource(Rez.Strings.unitsCelsius);
    }
    return Lang.format("$1$$2$", [ temp, units]);
  }

  function formatDate(moment) {
    var now = Time.now();
    var info = Gregorian.info(moment, Time.FORMAT_MEDIUM);
    info.min = info.min.format("%02d");
    info.hour = info.hour.format("%02d");

    var oneDay = new Time.Duration(Gregorian.SECONDS_PER_DAY);
    var minusOneDay = new Time.Duration(-Gregorian.SECONDS_PER_DAY);

    var dayName;
    if (sameDay(info, Gregorian.info(now, Time.FORMAT_MEDIUM))) {
      dayName = Ui.loadResource(Rez.Strings.today);
    } else if (sameDay(info, Gregorian.info(now.add(oneDay), Time.FORMAT_MEDIUM))) {
      dayName = Ui.loadResource(Rez.Strings.tomorrow);
    } else if (sameDay(info, Gregorian.info(now.add(minusOneDay), Time.FORMAT_MEDIUM))) {
      dayName = Ui.loadResource(Rez.Strings.yesterday);
    } else {
      dayName = Lang.format("$1$ $2$ $3$", [
        info.day_of_week,
        info.day,
        info.month
      ]);
    }
    return Lang.format("$1$:$2$ $3$", [
      info.hour,
      info.min,
      dayName
    ]);
  }

  function parseDate(string) {
    // We want to handle ISO8601 UTC dates only: eg 2017-09-22T11:30:00Z
    if (string == null) {
      return null;
    }
    if (string.length() != 20) {
      return null;
    }
    return Gregorian.moment({
      :year   => string.substring( 0,  4).toNumber(),
      :month  => string.substring( 5,  7).toNumber(),
      :day    => string.substring( 8, 10).toNumber(),
      :hour   => string.substring(11, 13).toNumber(),
      :minute => string.substring(14, 16).toNumber(),
      :second => string.substring(17, 19).toNumber()
    });
  }

  function sameDay(moment1, moment2) {
    return moment1.day == moment2.day && moment1.month.equals(moment2.month) && moment1.year == moment2.year;
  }

}
