using { /Verse.org/Simulation }

my_listener := class(event_listener):

    OnEvent<override>(EventName: string): void =
        Print("Received Event: {EventName}")

# Setup a listener and subscribe it
RegisterMyListener(): void =
    notification_center := event_bus{}
    my_instance := my_listener{}
    notification_center.Subscribe("GameStarted", my_instance)