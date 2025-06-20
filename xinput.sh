# This will list all devices. Grab the mouse ID.
xinput list

MOUSE_ID=12

# Change these obnoxious defaults
xinput set-prop $MOUSE_ID "libinput Natural Scrolling Enabled" 0
xinput set-prop $MOUSE_ID "libinput Tapping Enabled" 0

# Confirm they were changed
xinput list-props $MOUSE_ID
