import SwiftUI

struct PayPeriodDetails: View {
  @ObservedObject var viewModel: PayPeriodViewModel
  
  init(viewModel: PayPeriodViewModel) {
    self.viewModel = viewModel
  }

  var body: some View {
    Text("yo")
  }
}
