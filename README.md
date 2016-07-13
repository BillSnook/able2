A B L E 2

A Bluetooth LE scanner. Uses Core Data to capture data on peripherals encountered, and also data on individual sightings.

Save states

case Unknown        Not known, no device selected
case Invalid        Device has been selected but not all data is present or valid
case Unsaved        Data is valid and saveable but not saved
case Saved          Data is currently saved and usable
case Advertising    Data is curently being advertised

