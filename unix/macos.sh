#!/bin/bash /bin/zsh
# Refer to https://macos-defaults.com/

# Keep Alive Root
while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
done 2>/dev/null &

printf "[System Preferences]: Starting\n"

# Set computer name (as done via System Preferences → Sharing)
printf "🔧 Set Computer Name"
read -r computer_name
sudo scutil --set ComputerName "$computer_name"
printf "🔧 Set Local Hostname"
read -r host_name
sudo scutil --set HostName "$host_name"

# Close any open System Preferences panes, to prevent them from overriding
# settings we're about to change
osascript -e 'Tell Application "System Preferences" to quit'

printf "[System Preferences]: COMPLETE\n"
printf "[System Preferences]: Note that some of these changes require a logout/restart to take effect.\n"

##########################################
# Dock
##########################################

printf "⚙️ Configure Dock...\n"

# Position (default value: bottom)
defaults write com.apple.dock "orientation" -string "right" && killall Dock

# Icon size (default value: 48)
defaults write com.apple.dock "tilesize" -int "36" && killall Dock

# Autohide (default value: false)
defaults write com.apple.dock "autohide" -bool "false" && killall Dock

# Show recents (default value: true)
defaults write com.apple.dock "show-recents" -bool "false" && killall Dock

# Minimize animation effect (default value: genie)
defaults write com.apple.dock "mineffect" -string "genie" && killall Dock

# Scroll to Exposé app (default value: false)
defaults write com.apple.dock "scroll-to-open" -bool "false" && killall Dock

# Spring loading for Dock items (default value: false)
defaults write com.apple.dock "enable-spring-load-actions-on-all-items" -bool "false" && killall Dock

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
defaults read com.apple.dock wvous-tl-corner -int 0
defaults read com.apple.dock wvous-tl-modifier -int 0

# Top right screen corner → Mission Control
defaults read com.apple.dock wvous-tr-corner -int 2
defaults read com.apple.dock wvous-tr-modifier -int 0

# # Bottom left screen corner → Launchpad
defaults read com.apple.dock wvous-bl-corner -int 11
defaults read com.apple.dock wvous-bl-modifier -int 0

# # Bottom right screen corner → Mission Control
defaults read com.apple.dock wvous-br-corner -int 2
defaults read com.apple.dock wvous-br-modifier -int 0

##########################################################
# Finder
##########################################################

# Quit (default value: false)
defaults write com.apple.finder "QuitMenuItem" -bool "false" && killall Finder

# Show extensions (default value: false)
defaults write NSGlobalDomain "AppleShowAllExtensions" -bool "true" && killall Finder

# Show hidden files (default value: false)
defaults write com.apple.finder "AppleShowAllFiles" -bool "false" && killall Finder

# Path bar (default value: false)
defaults write com.apple.finder "ShowPathbar" -bool "false" && killall Finder

# Default view style (default value: icnv)
defaults write com.apple.finder "FXPreferredViewStyle" -string "clmv" && killall Finder

# Keep folders on top (default value: false)
defaults write com.apple.finder "_FXSortFoldersFirst" -bool "true" && killall Finder

# Open folders destination (default value: true)
defaults write com.apple.finder "FinderSpawnTab" -bool "true" && killall Finder

# Default search scope (default value: SCev)
defaults write com.apple.finder "FXDefaultSearchScope" -string "SCev" && killall Finder

# Empty bin items after 30 days (default value: false)
defaults write com.apple.finder "FXRemoveOldTrashItems" -bool "true" && killall Finder

# Changing file extension warning (default value: true)
defaults write com.apple.finder "FXEnableExtensionChangeWarning" -bool "false" && killall Finder

# Title bar icons (default value: false)
defaults write com.apple.universalaccess "showWindowTitlebarIcons" -bool "false" && killall Finder

# Toolbar title rollover delay (default value: 0.5)
defaults write NSGlobalDomain "NSToolbarTitleViewRolloverDelay" -float "0" && killall Finder

# Sidebar icon size (default value: 2)
defaults write NSGlobalDomain "NSTableViewDefaultSizeMode" -int "2" && killall Finder

##########################################################
# Desktop
##########################################################

# Keep folders on top (default value: false)
defaults write com.apple.finder "_FXSortFoldersFirstOnDesktop" -bool "true" && killall Finder

# Show all icons (default value: true)
defaults write com.apple.finder "CreateDesktop" -bool "true" && killall Finder

# Show hard disks on desktop (default value: false)
defaults write com.apple.finder "ShowHardDrivesOnDesktop" -bool "false" && killall Finder

# Show external disks (default value: true)
defaults write com.apple.finder "ShowExternalHardDrivesOnDesktop" -bool "true" && killall Finder

# Show removable media (default value: true)
defaults write com.apple.finder "ShowRemovableMediaOnDesktop" -bool "true" && killall Finder

# Show connected servers (default value: false)
defaults write com.apple.finder "ShowMountedServersOnDesktop" -bool "true" && killall Finder

##########################################################
# Menu Bar
##########################################################

# Flash clock time separators (default value: false)
defaults write com.apple.menuextra.clock "FlashDateSeparators" -bool "false" && killall SystemUIServer

# Digital clock format
defaults write com.apple.menuextra.clock "DateFormat" -string "\"EEE d MMM HH:mm\""

##########################################################
# Mouse
##########################################################

# Enable mouse acceleration (default value: false)
defaults write NSGlobalDomain com.apple.mouse.linear -bool "false"

# Set movement speed of the mouse cursor (default value: 1.0)
defaults write NSGlobalDomain com.apple.mouse.scaling -float "1"

# Focus Follows Mouse (default value: false)
defaults write com.apple.Terminal "FocusFollowsMouse" -bool "false" && killall Terminal

##########################################################
# Trackpad
##########################################################

# Click weight (threshold) (default value: 1)
defaults write com.apple.AppleMultitouchTrackpad "FirstClickThreshold" -int "1"

# Dragging with drag lock (default value: false)
defaults write com.apple.AppleMultitouchTrackpad "DragLock" -bool "false"

# Dragging without drag lock (default value: false)
defaults write com.apple.AppleMultitouchTrackpad "Dragging" -bool "false"

# Dragging with three finger drag (default value: false)
defaults write com.apple.AppleMultitouchTrackpad "TrackpadThreeFingerDrag" -bool "false"

##########################################################
# Keyboard
##########################################################

# Key held down behavior (default value: true)
defaults write NSGlobalDomain "ApplePressAndHoldEnabled" -bool "true"

# Fn/🌐 key usage (default value: 0, 0: nothing, 1: input source, 2: Emoji & Symbols, 3: Dictation)
defaults write com.apple.HIToolbox AppleFnUsageType -int "1"

##########################################################
# General UI/UX
##########################################################

# Function keys behavior (default value: false)
defaults write NSGlobalDomain com.apple.keyboard.fnState -bool false

# Enable moving focus with Tab and Shift Tab (default value: 0)
defaults write NSGlobalDomain AppleKeyboardUIMode -int "2"

# Toggle language indicator (default value: true)
defaults write kCFPreferencesAnyApplication TSMLanguageIndicatorEnabled -bool "true"

# Close confirm changes popup (default value: true)
defaults write NSGlobalDomain "NSCloseAlwaysConfirmsChanges" -bool "true"

# Keep windows when quitting an application (default value: true)
defaults write NSGlobalDomain "NSQuitAlwaysKeepsWindow" -bool "true"

##########################################################
# Mission Control
##########################################################

# Rearrange automatically (default value: true)
defaults write com.apple.dock "mru-spaces" -bool "true" && killall Dock

# Group windows by application (default value: false)
defaults write com.apple.dock "expose-group-apps" -bool "true" && killall Dock

# Switch to Space with open windows (default value: true)
defaults write NSGlobalDomain "AppleSpacesSwitchOnActivate" -bool "true" && killall Dock

# Spaces span all displays (default value: false)
defaults write com.apple.spaces "spans-displays" -bool "false" && killall SystemUIServer

##########################################################
# TextEdit
##########################################################

# Enable rich text (default value: true)
defaults write com.apple.TextEdit "RichText" -bool "true" && killall TextEdit

# Smart quotes (default value: true)
defaults write com.apple.TextEdit "SmartQuotes" -bool "true" && killall TextEdit

##########################################################
# Activity Monitor
##########################################################

# Update Frequency (default value: 5)
defaults write com.apple.ActivityMonitor "UpdatePeriod" -int "2" && killall Activity\ Monitor

# Dock Icon type (default value: 0)
defaults write com.apple.ActivityMonitor "IconType" -int "0" && killall Activity\ Monitor

##########################################################
# Screenshots
##########################################################

# Disable shadow (default value: false)
defaults write com.apple.screencapture "disable-shadow" -bool "false"

# Include date (default value: true)
defaults write com.apple.screencapture "include-date" -bool "false"

# Location (default value: Desktop)
defaults write com.apple.screencapture "location" -string "$HOME/Documents" && killall SystemUIServer

# Display thumbnail (default value: true)
defaults write com.apple.screencapture "show-thumbnail" -bool "true"

# Choose screenshot format (default value: png)
defaults write com.apple.screencapture "type" -string "png"

##########################################################
# Time Machine
##########################################################

# When a new disk is connected, system does not prompt to ask if you want to use it as a backup volume (default value: false)
defaults write com.apple.TimeMachine "DoNotOfferNewDisksForBackup" -bool "false"

##########################################################
# Apple Intelligence
##########################################################

# Activate Apple Intelligence (default value: true)
defaults write com.apple.CloudSubscriptionFeatures.optIn "545129924" -bool "true"

##########################################################
# Safari
##########################################################

# Show full URL (default value: false)
defaults write com.apple.Safari "ShowFullURLInSmartSearchField" -bool "false" && killall Safari

##########################################################
# Messages
##########################################################

# Show Subject Field (default value: false)
defaults write com.apple.MobileSMS "MMSShowSubject" -bool "false" && killall Messages

##########################################################
# Music
##########################################################

# Show song notifications (default value: true)
defaults write com.apple.Music "userWantsPlaybackNotifications" -bool "false" && killall Music

##########################################################
# Launch Services
##########################################################

# Application quarantine message (default value: true)
defaults write com.apple.LaunchServices "LSQuarantine" -bool "false"

##########################################################
# Feedback Assistant
##########################################################

# Autogather large files when submitting a feedback report (default value: true)
defaults write com.apple.appleseed.FeedbackAssistant "Autogather" -bool "true"

##########################################################
# Help Menu
##########################################################

# Enable behind other windows (default value: false)
defaults write com.apple.helpviewer "DevMode" -bool "false"
