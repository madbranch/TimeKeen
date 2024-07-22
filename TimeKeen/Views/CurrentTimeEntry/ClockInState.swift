enum ClockInState: Equatable {
  case clockedOut
  case clockedIn(BreakState)
}
