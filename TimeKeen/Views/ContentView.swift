import SwiftUI

struct ContentView: View {
  @Environment(\.managedObjectContext) private var viewContext
  @ObservedObject var viewModel: ContentViewModel
  
  init(viewModel: ContentViewModel) {
    self.viewModel = viewModel
  }
  
  var body: some View {
    NavigationView {
      VStack {
        CurrentTimeEntryView(viewModel: viewModel.currentTimeEntryViewModel)
      }
      .navigationTitle("Time Keen")
      .toolbar {
        ToolbarItem(placement: .bottomBar) {
          Button {
          } label: {
            Image(systemName: "gear")
          }
        }
        ToolbarItem(placement: .status) {
          Button {
          } label: {
            Image(systemName: "plus")
          }
        }
        ToolbarItem(placement: .bottomBar) {
          Button {
          } label: {
            Image(systemName: "list.bullet")
          }
        }
      }
    }
    .padding()
    .onAppear {
      UIDatePicker.appearance().minuteInterval = 15
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    let persistenceController = PersistenceController(inMemory: true)
    let currentTimeEntryViewModel = CurrentTimeEntryViewModel(context: persistenceController.container.viewContext)
    let viewModel = ContentViewModel(currentTimeEntryViewModel: currentTimeEntryViewModel)
    ContentView(viewModel: viewModel)
      .environment(\.managedObjectContext, persistenceController.container.viewContext)
  }
}
