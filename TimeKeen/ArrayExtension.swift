
extension Array: Identifiable where Element: Hashable {
  public var id: Self { self }
}
