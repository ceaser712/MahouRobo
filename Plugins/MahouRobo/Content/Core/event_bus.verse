
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
using { /Verse.org/Simulation }

event_bus := class:
    var Listeners: [string][]event_listener = map{}

    Subscribe(EventName: string, Listener: event_listener): void =
        if (Current := Listeners[EventName]):
            # Create a new array with existing + new listener
            if(set Listeners[EventName] = Current + array{Listener}):
        else:
            # First listener for this event
            if(set Listeners[EventName] = array{Listener}):

    Notify(EventName: string): void =
        if (Handlers := Listeners[EventName]):
            for (Listener : Handlers):
                Listener.OnEvent(EventName)
