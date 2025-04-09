using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }

my_listener := class(creative_device,event_listener):
    @editable Button: button_device = button_device{}
    OnBegin<override>():void =
        Print("Listener Device Active")
        GetGlobalBus().Subscribe("MyEvent","MyClass", Self)
        Button.InteractedWithEvent.Subscribe(TestAgent)

    TestAgent(Agent:agent):void=
        Print("Hello, world!")
        GetGlobalBus().Unsubscribe("MyEvent","MyClass")
        
    OnEvent<override>(EventName: string): void =
        Print("Received Event: {EventName}")