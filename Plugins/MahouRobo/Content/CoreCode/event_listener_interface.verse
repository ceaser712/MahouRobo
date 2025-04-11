
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
event_listener<public> := interface:
    OnEvent<public>(EventName: string, Data: eventdata): void

listener_wrapper := class:
    Id: string
    Handler: event_listener