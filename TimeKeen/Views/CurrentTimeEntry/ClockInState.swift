enum ClockInState {
  case clockedOut
  case clockedIn(BreakState)
}
