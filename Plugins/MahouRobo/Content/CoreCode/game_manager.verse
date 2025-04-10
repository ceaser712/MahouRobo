
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
game_manager := class(creative_device,event_listener):

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        GetGlobalBus().Subscribe("TimerCompleted","MyClass", Self)
        Sleep(0.5)
        GetGlobalBus().Notify("RoundStart", eventdata{})
        
    OnEvent<override>(EventName: string, Data:eventdata): void =
        Print("Received Event: {EventName}")