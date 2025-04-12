
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

debug_buttons:=class():
    @editable DebugButton: button_device = button_device{}
    @editable DebugEvent: string = ""
# A Verse-authored creative device that can be placed in a level
debug_manager := class(creative_device):
    @editable DebugButtons: []debug_buttons = array{}
    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        for(Button:DebugButtons):
            Button.DebugButton.InteractedWithEvent.SubscribeAgent(OnButtonInteract, Button.DebugEvent)

    OnButtonInteract(Agent: agent, Msg: string): void =
        Print("Triggering Debug. Message: {Msg}")
        GetGlobalBus().Notify(Msg, eventdata{Msg:= option{Msg}})