import Toybox.Application;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Math;
import Toybox.Time.Gregorian;
import Toybox.Time;
import Toybox.WatchUi;

(:glance)
class WorkoutFormatter {
  private var mModel as TaoModel;

  function initialize() {
    mModel = Application.getApp().model;
  }

  function buildMessageFromWorkout() as String {
    if (mModel.accessToken == null) {
      return WatchUi.loadResource(Rez.Strings.selectToConnect);
    }
    var serverMessage = mModel.getMessage();
    if (!mModel.hasWorkout()) {
      return serverMessage != null
        ? serverMessage
        : WatchUi.loadResource(
            mModel.isExternalSchedule()
              ? Rez.Strings.workoutNoWorkoutExternalSchedule
              : Rez.Strings.workoutNoWorkout
          );
    }

    var displayPreferences = mModel.getDisplayPreferences();
    var details = serverMessage != null ? serverMessage + "\n" : "";

    var distance = mModel.lookupWorkoutSummary("distance") as Float?;
    if (distance != null && distance > 0.0) {
      details += formatDistance(distance, displayPreferences);
    }
    var duration = mModel.lookupWorkoutSummary("duration") as Number?;
    if (duration) {
      if (!details.equals("")) {
        details += ", ";
      }
      details += formatDuration(duration);
    }

    var message = Lang.format(
      WatchUi.loadResource(Rez.Strings.workoutNextWorkoutString),
      [
        mModel.getName(),
        details,
        formatDate(parseDate(mModel.lookupWorkoutSummary("start"))),
      ]
    );
    var extra = "";
    var temperature = mModel.lookupWorkoutSummary("temperature") as Float?;
    if (temperature != null) {
      extra += formatTemperature(temperature, displayPreferences) + " ";
    }
    var undulation = mModel.lookupWorkoutSummary("undulation") as Float?;
    if (undulation != null) {
      extra += undulation.format("%0.1f") + "U ";
    }
    if (mModel.updated) {
      extra += "* ";
    }

    if (!extra.equals("")) {
      message += "\n(" + extra.substring(0, extra.length() - 1) + ")";
    }
    return message;
  }

  function formatDistance(
    distance as Float?,
    displayPreferences as Dictionary<String>
  ) as String {
    var units = ""; // Fake init to placate false positive "Variable units may not have been initialized in all code paths"
    var format = "%0.0f";
    switch (displayPreferences["distanceUnit"] as String) {
      case "MILE":
        distance = (distance * 0.621371192) / 1000;
        format = "%0.1f";
        units = WatchUi.loadResource(Rez.Strings.unitsMiles);
        break;
      case "METRE":
        units = WatchUi.loadResource(Rez.Strings.unitsMetres);
        break;
      case "CENTIMETRE":
        distance = distance * 100;
        units = WatchUi.loadResource(Rez.Strings.unitsCentimetres);
        break;
      case "MILLIMETRE":
        distance = distance * 1000;
        units = WatchUi.loadResource(Rez.Strings.unitsMillimetres);
        break;
      case "FOOT":
        distance = (distance / 1000) * 0.621371192 * 5280;
        units = WatchUi.loadResource(Rez.Strings.unitsFeet);
        break;
      case "PARSEC":
        distance = distance / (3.2407792896664 * Math.pow(10, 17));
        units = WatchUi.loadResource(Rez.Strings.unitsParsecs);
        format = "%0.2e";
        break;
      case "KILOMETRE":
      default:
        distance = distance / 1000;
        format = "%0.1f";
        units = WatchUi.loadResource(Rez.Strings.unitsKilometres);
        break;
    }
    return Lang.format("$1$ $2$", [distance.format(format), units]);
  }

  function formatDuration(duration as Number) as String {
    var units = WatchUi.loadResource(Rez.Strings.unitsMinutes);
    return Lang.format("$1$ $2$", [duration / 60, units]);
  }

  function formatTemperature(
    temp as Float,
    displayPreferences as Dictionary<String, String or Number or Boolean>
  ) as String {
    var units;
    if (displayPreferences["temperaturesInFahrenheit"]) {
      temp = (temp * 9) / 5 + 32;
      temp = temp.format("%d");
      units = WatchUi.loadResource(Rez.Strings.unitsFahrenheit);
    } else {
      temp = temp.format("%0.1f");
      units = WatchUi.loadResource(Rez.Strings.unitsCelsius);
    }
    return Lang.format("$1$$2$", [temp, units]);
  }

  function formatDate(moment as Moment) as String {
    var now = Time.now();
    var info = Gregorian.info(moment, Time.FORMAT_MEDIUM);
    var oneDay = new Time.Duration(Gregorian.SECONDS_PER_DAY);
    var minusOneDay = new Time.Duration(-Gregorian.SECONDS_PER_DAY);

    var dayName;
    if (isSameDay(info, Gregorian.info(now, Time.FORMAT_MEDIUM))) {
      dayName = WatchUi.loadResource(Rez.Strings.dayToday);
    } else if (
      isSameDay(info, Gregorian.info(now.add(oneDay), Time.FORMAT_MEDIUM))
    ) {
      dayName = WatchUi.loadResource(Rez.Strings.dayTomorrow);
    } else if (
      isSameDay(info, Gregorian.info(now.add(minusOneDay), Time.FORMAT_MEDIUM))
    ) {
      dayName = WatchUi.loadResource(Rez.Strings.dayYesterday);
    } else {
      dayName = Lang.format("$1$ $2$ $3$", [
        info.day_of_week,
        info.day,
        info.month,
      ]);
    }
    return Lang.format("$1$:$2$ $3$", [
      info.hour.format("%02d"),
      info.min.format("%02d"),
      dayName,
    ]);
  }

  function parseDate(string as String?) as Moment? {
    // We want to handle ISO8601 UTC dates only: eg 2017-09-22T11:30:00Z
    if (string == null) {
      return null;
    }
    if (string.length() != 20) {
      return null;
    }
    return Gregorian.moment({
      :year => string.substring(0, 4).toNumber(),
      :month => string.substring(5, 7).toNumber(),
      :day => string.substring(8, 10).toNumber(),
      :hour => string.substring(11, 13).toNumber(),
      :minute => string.substring(14, 16).toNumber(),
      :second => string.substring(17, 19).toNumber(),
    });
  }

  function isSameDay(moment1 as Info, moment2 as Info) as Boolean {
    return (
      moment1.day == moment2.day &&
      moment1.month.equals(moment2.month) &&
      moment1.year == moment2.year
    );
  }
}
