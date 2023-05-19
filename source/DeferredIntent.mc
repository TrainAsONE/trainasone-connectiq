// Code from Garmin to workaround System.exitTo(intent) issue in 645 firmware (SDK 3.0.3)

import Toybox.System;
import Toybox.Timer;
import Toybox.WatchUi;

class DeferredIntent {
  private var _data as Intent;
  private var _controller as WorkoutMenuDelegate;
  private var _timer as Timer.Timer;

  function initialize(controller as WorkoutMenuDelegate, data as Intent) {
    _controller = controller;
    _data = data;
    _timer = new Timer.Timer();
    _timer.start(method(:onTimer), 200, false);
  }

  function onTimer() as Void {
    _controller.handleDeferredIntent(_data);
  }
}

/*
// Calling example
public function handleDownloadResponse( data ) {
  // Clear the confirmation from the page stack
  WatchUi.popView( WatchUi.SLIDE_IMMEDIATE );
  // Kick off the kludge transaction
  _activeTransaction = new self.DeferredIntent( self, data );
}

// This is fired by the kludge transaction
public function handleIntent( data ) {
  _activeTransaction = null;
  if ( data != null ) {
    System.exitTo( data.toIntent() );
  } else {
    handleError( -1000 );
  }
}
*/
