using Toybox.Application as App;
using Toybox.Lang;
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
    var workoutName = App.getApp().getProperty("workout_name");
    var workoutStart = App.getApp().getProperty("workout_start");
    var message = Ui.loadResource(Rez.Strings.nextWorkoutString) + workoutName + "\n" + formatDate(parseDate(workoutStart));
    var view = View.findDrawableById("message");
    if (_updated) {
      message += Ui.loadResource(Rez.Strings.updatedString);
    }
    if (!(Toybox has :PersistedContent)) {
      message = Ui.loadResource(Rez.Strings.deviceCannotDownload) + "\n" + message;
    }
    view.setText(message);
  }

  function formatDate(moment) {
    var info = Gregorian.info(moment, Time.FORMAT_MEDIUM);
    info.min = info.min.format("%02d");
    info.hour = info.hour.format("%02d");
    var now = Time.now();
    var checkInfo = Gregorian.info(now, Time.FORMAT_MEDIUM);
    if (sameDay(info, checkInfo)) {
      return Lang.format("$1$:$2$ $3$", [
        info.hour,
        info.min,
        Ui.loadResource(Rez.Strings.today)
      ]);
    }
    var oneDay = new Time.Duration(Gregorian.SECONDS_PER_DAY);
    checkInfo = Gregorian.info(now.add(oneDay), Time.FORMAT_MEDIUM);
    if (sameDay(info, checkInfo)) {
      return Lang.format("$1$:$2$ $3$", [
        info.hour,
        info.min,
        Ui.loadResource(Rez.Strings.tomorrow)
      ]);
    }
    return Lang.format("$1$:$2$ $3$ $4$ $5$", [
      info.hour,
      info.min,
      info.day_of_week,
      info.day,
      info.month
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
