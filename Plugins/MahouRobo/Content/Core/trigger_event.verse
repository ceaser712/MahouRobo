
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
trigger_event := class(creative_device):
    @editable Button: button_device = button_device{}
    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        Button.InteractedWithEvent.Subscribe(TestAgent)
        
    TestAgent(Agent:agent):void=
        Print("Hello, world!")
        FireEvent()

    FireEvent(): void =
        GetGlobalBus().Notify("MyEvent", false)