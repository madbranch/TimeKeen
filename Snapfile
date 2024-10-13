# Uncomment the lines below you want to change by removing the # in the beginning

# A list of devices you want to take the screenshots from
devices([
  # 6.9" Display 
  "iPhone 16 Plus",
])

ios_version("18.0")

languages([
  "en",
  "fr",
])

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

# This flag is broken. It doesn't work when set to true
concurrent_simulators(false)

# For more information about all available options run
# fastlane action snapshot
