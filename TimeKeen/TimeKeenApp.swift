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
      let start = userDefaults.clockInDate
      let breakStart = userDefaults.breakStart
      let breaks = userDefaults.breaks
      let context = container.mainContext
      let currentTimeEntryViewModel = CurrentTimeEntryViewModel(context: context, clockedInAt: start, startedBreakAt: breakStart, withBreaks: breaks, userDefaults: userDefaults, quickActionProvider: appDelegate.quickActionProvider)
      let viewModel = ContentViewModel(currentTimeEntryViewModel: currentTimeEntryViewModel)
      
      ContentView(viewModel: viewModel)
        .modelContainer(container)
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
  
  static let clockInQuickAction =
    UIApplicationShortcutItem(type: QuickAction.clockIn.rawValue,
                              localizedTitle: NSLocalizedString("Clock In", comment: "Quick action title for clocking in"),
                              localizedSubtitle: NSLocalizedString("Clock in now", comment: "Quick action sub-title for clocking in"),
                              icon: UIApplicationShortcutIcon(systemImageName: "arrowshape.turn.up.backward.badge.clock.fill.rtl"))
  
  static let clockOutQuickAction =
    UIApplicationShortcutItem(type: QuickAction.clockOut.rawValue,
                              localizedTitle: NSLocalizedString("Clock Out", comment: "Quick action title for clocking out"),
                              localizedSubtitle: NSLocalizedString("Clock out now", comment: "Quick action sub-title for clocking out"),
                              icon: UIApplicationShortcutIcon(systemImageName: "arrowshape.turn.up.backward.badge.clock.fill"))
  
  static let startBreakQuickAction =
    UIApplicationShortcutItem(type: QuickAction.startBreak.rawValue,
                              localizedTitle: NSLocalizedString("Take a Break", comment: "Quick action title for taking a break"),
                              localizedSubtitle: NSLocalizedString("Take a break now", comment: "Quick action sub-title for taking a break"),
                              icon: UIApplicationShortcutIcon(systemImageName: "pause.fill"))
  
  static let endBreakQuickAction =
    UIApplicationShortcutItem(type: QuickAction.endBreak.rawValue,
                              localizedTitle: NSLocalizedString("End Break", comment: "Quick action title for going back to work"),
                              localizedSubtitle: NSLocalizedString("Go back to work", comment: "Quick action sub-title for going back to work"),
                              icon: UIApplicationShortcutIcon(systemImageName: "play.fill"))

  func updateQuickActions(currentTimeEntryViewModel: CurrentTimeEntryViewModel) {
    UIApplication.shared.shortcutItems = switch currentTimeEntryViewModel.clockInState {
    case .clockedOut: [TimeKeenApp.clockInQuickAction]
    case .clockedInWorking:
      [TimeKeenApp.clockOutQuickAction, TimeKeenApp.startBreakQuickAction]
    case .clockedInTakingABreak:
      [TimeKeenApp.endBreakQuickAction]
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
