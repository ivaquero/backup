#!/bin/bash /bin/zsh
# Keep Alive Root
while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
done 2>/dev/null &

printf "[System Preferences]: Starting\n"

# Set computer name (as done via System Preferences → Sharing)
printf "🔧 Set Computer Name"
read computer_name
sudo scutil --set ComputerName $computer_name
printf "🔧 Set Local Hostname"
read host_name
sudo scutil --set HostName $host_name

# Close any open System Preferences panes, to prevent them from overriding
# settings we're about to change
osascript -e 'Tell Application "System Preferences" to quit'

printf "[System Preferences]: COMPLETE\n"
printf "[System Preferences]: Note that some of these changes require a logout/restart to take effect.\n"

##########################################
# Dock
##########################################

printf "⚙️ Configure Dock...\n"
# Enable highlight hover effect for the grid view of a stack
defaults write com.apple.dock mouse-over-hilite-stack -bool true

# Set the icon size of Dock items to 36 pixels
defaults write com.apple.dock tilesize -int 36

# Change minimize/maximize window effect
defaults write com.apple.dock mineffect -string "genie"

# Minimize windows into their application's icon
defaults write com.apple.dock minimize-to-application -bool true

# Enable spring loading for all Dock items
defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

# Don't show indicator lights for open applications in the Dock
defaults write com.apple.dock show-process-indicators -bool false

# Show only open applications in the Dock
defaults write com.apple.dock static-only -bool true

# Don't animate opening applications from the Dock
defaults write com.apple.dock launchanim -bool false

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool false

# Make Dock icons of hidden applications translucent
defaults write com.apple.dock showhidden -bool true

# Don't show recent applications in Dock
defaults write com.apple.dock show-recents -bool false

# Remove the auto-hiding Dock delay
defaults write com.apple.dock autohide-delay -float 0

# Remove the animation when hiding/showing the Dock
defaults write com.apple.dock autohide-time-modifier -float 0

##########################################
# Dashboard
##########################################

printf "⚙️ Configure Dashboard...\n"
# Disable Dashboard
defaults write com.apple.dashboard mcx-disabled -bool true

# Don't show Dashboard as a Space
defaults write com.apple.dock dashboard-in-overlay -bool true

# Don't automatically rearrange spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

##########################################
# Hot Corners
##########################################

printf "⚙️ Configure Hot Corners...\n"
# Possible values:
#  0: no-op
#  2: Mission Control
#  3: Show application windows
#  4: Desktop
#  5: Start screen saver
#  6: Disable screen saver
#  7: Dashboard
# 10: Put display to sleep
# 11: Launchpad
# 12: Notification Center
# 13: Lock Screen

# Top left screen corner → DISABLED
# defaults read com.apple.dock wvous-tl-corner -int 1
# defaults read com.apple.dock wvous-tl-modifier -int 0

# # Top right screen corner → Mission Control Centre
# defaults read com.apple.dock wvous-tr-corner -int 2
# defaults read com.apple.dock wvous-tr-modifier -int 0

# # Bottom left screen corner → Launchpad
# defaults read com.apple.dock wvous-bl-corner -int 11
# defaults read com.apple.dock wvous-bl-modifier -int 0

# # Bottom right screen corner → Mission Control
# defaults read com.apple.dock wvous-br-corner -int 2
# defaults read com.apple.dock wvous-br-modifier -int 0

##########################################
# Finder
##########################################

printf "⚙️ Configure Finder...\n"
# allow quitting via ⌘ + Q; doing so will also hide desktop icons
defaults write com.apple.finder QuitMenuItem -bool true

# disable window animations and Get Info animations
defaults write com.apple.finder DisableAllAnimations -bool true

# Show icons for hard drives, servers, and removable media on the desktop
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool false

# Don't show hidden files by default
defaults write com.apple.finder AppleShowAllFiles -bool false

# Show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Don't show path bar
defaults write com.apple.finder ShowPathbar -bool false

# Don't display full POSIX path as Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool false

# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Use list view in all Finder windows by default
# Four-letter codes for the other view modes: `icnv`, `glyv`, `Nlsv`
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"

# Disable the warning before emptying the Trash
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Enable spring loading for directories
defaults write NSGlobalDomain com.apple.springing.enabled -bool true

# Remove the spring loading delay for directories
defaults write NSGlobalDomain com.apple.springing.delay -float 0

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Disable disk image verification
defaults write com.apple.frameworks.diskimages skip-verify -bool true
defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

# Don't automatically open a new Finder window when a volume is mounted
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool false
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool false
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool false

# Expand the following File Info panes:
# "General", "Open with", and "Sharing & Permissions"
defaults write com.apple.finder FXInfoPanesExpanded -dict \
    General -bool true \
    OpenWith -bool true \
    Privileges -bool true

# Set Tag Names
defaults write com.apple.finder FavoriteTagNames -array "" "TODO" "WIP" "DONE"

##########################################
# Input
##########################################

printf "⚙️ Configure Input...\n"
# Set language and text formats
# Note: if you're in the US, replace `EUR` with `USD`, `Centimeters` with
# `Inches`, `en_GB` with `en_US`, and `true` with `false`.
defaults write NSGlobalDomain AppleLanguages -array "en-US" "en"
defaults write NSGlobalDomain AppleLocale -string "zh_CN@currency=CN¥"
defaults write NSGlobalDomain AppleMeasurementUnits -string "Metric"
defaults write NSGlobalDomain AppleTemperatureUnit -string "Celsius"
defaults write NSGlobalDomain AppleMetricUnits -bool true

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Disable automatic period substitution as it's annoying when typing code
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Disable smart dashes as they're annoying when typing code
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disable automatic capitalization as it's annoying when typing code
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

##########################################
# Energy
##########################################

printf "⚙️ Configure Energy...\n"
# Enable lid wakeup
sudo pmset -a lidwake 1

# Sleep the display after 15 minutes
sudo pmset -a displaysleep 15

# Set standby delay to 24 hours (default is 1 hour)
sudo pmset -a standbydelay 86400

# Hibernation mode
# 0: Disable hibernation
# 3: Copy RAM to disk so the system state can still be restored in case of a power failure.
sudo pmset -a hibernatemode 0

# other options

# Disable machine sleep while charging
# sudo pmset -c sleep 0

# Set machine sleep to 5 minutes on battery
# sudo pmset -b sleep 5

# Restart automatically on power loss
# sudo pmset -a autorestart 1

# Restart automatically if the computer freezes
# sudo systemsetup -setrestartfreeze on

# Never go into computer sleep mode
# sudo systemsetup -setcomputersleep Off >/dev/null

##########################################
# General UI/UX
##########################################

printf "⚙️ Configure UI/UX...\n"
# Set sidebar icon size to medium
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2

# Always show scrollbars
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"
# Possible values: `WhenScrolling`, `Automatic` and `Always`

# Disable the over-the-top focus ring animation
defaults write NSGlobalDomain NSUseAnimatedFocusRing -bool false

# Disable the "Are you sure you want to open this application?" dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Automatically quit printer app once the print jobs complete
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
