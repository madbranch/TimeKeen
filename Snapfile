# Uncomment the lines below you want to change by removing the # in the beginning

# A list of devices you want to take the screenshots from
# devices([
#   "iPhone 8",
#   "iPhone 8 Plus",
#   "iPhone SE",
#   "iPhone X",
#   "iPad Pro (12.9-inch)",
#   "iPad Pro (9.7-inch)",
#   "Apple TV 1080p",
#   "Apple Watch Series 6 - 44mm"
# ])
devices([
  "iPhone 15",
  #"iPhone 15 Plus",
  #"iPhone 15 Pro",
  #"iPhone 15 Pro Max",
  #"iPhone SE (3rd Generation)"
])

languages([
  "en",
  #"fr"
])
# languages([
#   "en-US",
#   "de-DE",
#   "it-IT",
#   ["pt", "pt_BR"] # Portuguese with Brazilian locale
# ])

# The name of the scheme which contains the UI Tests
scheme("TimeKeenUISnapshots")

# Where should the resulting screenshots be stored?
output_directory("./screenshots")

# remove the '#' to clear all previously generated screenshots before creating new ones
clear_previous_screenshots(true)

# Remove the '#' to set the status bar to 9:41 AM, and show full battery and reception. See also override_status_bar_arguments for custom options.
# This is buggy, it's not working with iOS 17 simulators
# override_status_bar(true)

# Arguments to pass to the app on launch. See https://docs.fastlane.tools/actions/snapshot/#launch-arguments
launch_arguments(["enable-testing"])

dark_mode(false)

# For more information about all available options run
# fastlane action snapshot
