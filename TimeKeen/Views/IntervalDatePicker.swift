import SwiftUI

struct IntervalDatePicker: UIViewRepresentable {
  @Binding var selection: Date
  let minuteInterval: Int
  private let minimumDate: Date?
  private let maximumDate: Date?
  let displayedComponents: DatePickerComponents
  
  init(selection: Binding<Date>, minuteInterval: Int, displayedComponents: DatePickerComponents) {
    _selection = selection
    self.minuteInterval = minuteInterval
    minimumDate = nil
    maximumDate = nil
    self.displayedComponents = displayedComponents
  }
  
  init(selection: Binding<Date>, minuteInterval: Int, in range: PartialRangeThrough<Date>, displayedComponents: DatePickerComponents) {
    _selection = selection
    self.minuteInterval = minuteInterval
    minimumDate = nil
    maximumDate = range.upperBound
    self.displayedComponents = displayedComponents
  }
  
  init(selection: Binding<Date>, minuteInterval: Int, in range: PartialRangeFrom<Date>, displayedComponents: DatePickerComponents) {
    _selection = selection
    self.minuteInterval = minuteInterval
    minimumDate = range.lowerBound
    maximumDate = nil
    self.displayedComponents = displayedComponents
  }
  
  init(selection: Binding<Date>, minuteInterval: Int, in range: ClosedRange<Date>, displayedComponents: DatePickerComponents) {
    _selection = selection
    self.minuteInterval = minuteInterval
    minimumDate = range.lowerBound
    maximumDate = range.upperBound
    self.displayedComponents = displayedComponents
  }

  func makeCoordinator() -> Coordinator {
    return Coordinator(self)
  }
  
  func makeUIView(context: UIViewRepresentableContext<IntervalDatePicker>) -> UIDatePicker {
    let picker = UIDatePicker()
    picker.preferredDatePickerStyle = .compact
    // listen to changes coming from the date picker, and use them to update the state variable
    picker.addTarget(context.coordinator, action: #selector(Coordinator.dateChanged), for: .valueChanged)
    return picker
  }
  
  func updateUIView(_ picker: UIDatePicker, context: UIViewRepresentableContext<IntervalDatePicker>) {
    picker.minuteInterval = minuteInterval
    picker.date = selection
    picker.minimumDate = minimumDate
    picker.maximumDate = maximumDate
    
    switch displayedComponents {
    case .hourAndMinute:
      picker.datePickerMode = .time
    case .date:
      picker.datePickerMode = .date
    case [.hourAndMinute, .date]:
      picker.datePickerMode = .dateAndTime
    default:
      break
    }
  }
  
  class Coordinator {
    let datePicker: IntervalDatePicker
    init(_ datePicker: IntervalDatePicker) {
      self.datePicker = datePicker
    }
    
    @objc func dateChanged(_ sender: UIDatePicker) {
      datePicker.selection = sender.date
    }
  }
}
