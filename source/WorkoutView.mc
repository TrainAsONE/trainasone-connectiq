using Toybox.Application as App;
using Toybox.Lang;
using Toybox.Graphics;
using Toybox.Time.Gregorian;
using Toybox.Time;
using Toybox.WatchUi as Ui;

class WorkoutView extends Ui.View {

  private var _updated;

  function initialize(updated) {
    _updated = updated;
    View.initialize();
  }

  function onLayout(dc) {
    setLayout(Rez.Layouts.WorkoutLayout(dc));
    var summary = App.getApp().getProperty(TaoConstants.OBJ_SUMMARY);
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
    var view = View.findDrawableById("message");
    if (_updated) {
      message += Ui.loadResource(Rez.Strings.updatedString);
    }
    // Graphics.Dc.getHeight() fails with "Could not find symbol mHeight", presumably as we have not displayed yet
    var deviceSettings = System.getDeviceSettings();
    var height = deviceSettings.screenHeight;
    var centre = deviceSettings.screenWidth / 2;
    if (height <= 148) {
      view.setLocation(centre, 62);
      view.setFont(Graphics.FONT_SMALL);
    } else {
      view.setLocation(centre, 75);
      view.setFont(Graphics.FONT_MEDIUM);
    }
    view.setText(message);
  }

  function formatDistance(distance) {
    var displayPreferences = App.getApp().getProperty(TaoConstants.OBJ_SUMMARY)["displayPreferences"];
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
