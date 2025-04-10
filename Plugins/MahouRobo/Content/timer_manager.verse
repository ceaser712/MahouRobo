
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using {CoreCode}

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
timer_manager<public> := class(creative_device,event_listener):
    @editable Duration: float = 1800.0
    @editable Timer: timer_device = timer_device{}
    var CancelTimer: logic = false
    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        GetGlobalBus().Subscribe("RoundStart","timer_manager", Self)
        GetGlobalBus().Subscribe("RoundEnd","timer_manager", Self)
    
    OnEvent<override>(EventName: string, Data:any): void =
        Print("Received Event: {EventName}")
        if (EventName = "RoundStart"):
            set CancelTimer = false
            spawn{StartTimer()}
        else if (EventName = "RoundEnd"):
            set CancelTimer = true

    StartTimer()<suspends>: void =
        GetGlobalBus().Notify("TimerStarted",eventdata{})
        Timer.SetActiveDuration(Duration)
        Timer.StartForAll()
        var Remaining: float = Duration
        loop:
            if(CancelTimer?):
                Print("Timer canceled")
                GetGlobalBus().Notify("TimerCanceled",eventdata{})
                Timer.ResetForAll()
                break
            if(Remaining <= 0.0):
                Print("Timer complete")
                GetGlobalBus().Notify("TimerCompleted",eventdata{})
                Timer.ResetForAll()
                break
            Print("Timer: {Remaining} seconds left")
            Sleep(1.0)
            set Remaining = Remaining - 1.0
