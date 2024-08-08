import SwiftUI
import SwiftData

enum QuickAction: String {
  case clockIn
  case clockOut
  case startBreak
  case endBreak
}

@Observable class QuickActionProvider {
  var quickAction: QuickAction?
}

@main
struct TimeKeenApp: App {
  let container: ModelContainer
  @Environment(\.scenePhase) var scenePhase
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  
  init() {
    do {
      container = try ModelContainer(for: TimeEntry.self, BreakEntry.self)
    } catch {
      fatalError("Failed to create ModelContainer for TimeEntry")
    }
  }
  
  var body: some Scene {
    WindowGroup {
      let userDefaults = SharedData.userDefaults ?? UserDefaults.standard
      let start = userDefaults.object(forKey: "ClockInDate") as? Date
      let breakStart = userDefaults.object(forKey: "BreakStart") as? Date
      let breaks = userDefaults.breaks
      let context = container.mainContext
      let currentTimeEntryViewModel = CurrentTimeEntryViewModel(context: context, clockedInAt: start, startedBreakAt: breakStart, withBreaks: breaks, userDefaults: userDefaults, quickActionProvider: appDelegate.quickActionProvider)
      let timeEntrySharingViewModel = TimeEntrySharingViewModel(context: context)
      let payPeriodListViewModel = PayPeriodListViewModel(timeEntrySharingViewModel: timeEntrySharingViewModel, context: context)
      let viewModel = ContentViewModel(currentTimeEntryViewModel: currentTimeEntryViewModel, payPeriodListViewModel: payPeriodListViewModel)
      
      ContentView(viewModel: viewModel)
        .onChange(of: scenePhase) { _, newPhase in
          switch newPhase {
          case .background:
            updateQuickActions(currentTimeEntryViewModel: currentTimeEntryViewModel)
          case .inactive:
            break
          case .active:
            break
          @unknown default:
            break
          }
        }
    }
  }
  
  static let clockInQuickAction = UIApplicationShortcutItem(type: QuickAction.clockIn.rawValue, localizedTitle: "Clock-In", localizedSubtitle: "Clock-in now", icon: UIApplicationShortcutIcon(systemImageName: "arrowshape.turn.up.backward.badge.clock.fill.rtl"))
  static let clockOutQuickAction = UIApplicationShortcutItem(type: QuickAction.clockOut.rawValue, localizedTitle: "Clock-Out", localizedSubtitle: "Clock-out now", icon: UIApplicationShortcutIcon(systemImageName: "arrowshape.turn.up.backward.badge.clock.fill"))
  static let startBreakQuickAction = UIApplicationShortcutItem(type: QuickAction.startBreak.rawValue, localizedTitle: "Start Break", localizedSubtitle: "Take a break now", icon: UIApplicationShortcutIcon(systemImageName: "pause.fill"))
  static let endBreakQuickAction = UIApplicationShortcutItem(type: QuickAction.endBreak.rawValue, localizedTitle: "End Break", localizedSubtitle: "Go back to work", icon: UIApplicationShortcutIcon(systemImageName: "play.fill"))

  func updateQuickActions(currentTimeEntryViewModel: CurrentTimeEntryViewModel) {
    UIApplication.shared.shortcutItems = switch currentTimeEntryViewModel.clockInState {
    case .clockedOut: [TimeKeenApp.clockInQuickAction]
    case .clockedIn(let breakState):
      switch breakState {
      case .takingABreak:
        [TimeKeenApp.endBreakQuickAction]
      case .working:
        [TimeKeenApp.clockOutQuickAction, TimeKeenApp.startBreakQuickAction]
      }
    }
  }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  var quickActionProvider = QuickActionProvider()
  
  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    if let type = options.shortcutItem?.type {
      quickActionProvider.quickAction = QuickAction(rawValue: type)
    } else {
      quickActionProvider.quickAction = nil
    }
    
    connectingSceneSession.userInfo = ["quickActionProvider": quickActionProvider]
    
    let sceneConfiguration = UISceneConfiguration(name: "Custom Configuration", sessionRole: connectingSceneSession.role)
    sceneConfiguration.delegateClass = SceneDelegate.self
    return sceneConfiguration
  }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
    if let quickActionProvider = windowScene.session.userInfo?["quickActionProvider"] as? QuickActionProvider {
      quickActionProvider.quickAction = QuickAction(rawValue: shortcutItem.type)
    }
  }
}
