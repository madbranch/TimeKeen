import SwiftUI

struct TimeEntrySharingView: View {
  @Bindable var viewModel: TimeEntrySharingViewModel
  
  init(viewModel: TimeEntrySharingViewModel) {
    self.viewModel = viewModel
  }
  
  var body: some View {
    VStack {
      Text("Export")
        .font(.headline)
      Text("Export all time entries from the selected period in time.")
        .font(.subheadline)
      DatePicker("From", selection: $viewModel.from, in: ...viewModel.to, displayedComponents: [.date])
        .datePickerStyle(.compact)
      DatePicker("To", selection: $viewModel.to, in: viewModel.from..., displayedComponents: [.date])
        .datePickerStyle(.compact)
      Spacer()
      Button(action: {
        print("Export!")
      }) {
        Label("Export", systemImage: "square.and.arrow.up")
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.borderedProminent)
      .controlSize(.large)
    }
    .padding()
    .presentationDetents([.medium])
  }
}
