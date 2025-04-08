using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }

my_listener := class(creative_device,event_listener):

    OnBegin<override>():void =
        Print("Listener Device Active")
        notification_center := event_bus{}
        notification_center.Subscribe("GameStarted", Self)
        
    OnEvent<override>(EventName: string): void =
        Print("Received Event: {EventName}")