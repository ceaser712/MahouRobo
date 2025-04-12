
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using {CoreCode}
using { /Verse.org }
# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
explosives_pool := class(creative_device,event_listener):

    @editable Explosives: []explosive_device = array{}
    @editable Home: vector3 = vector3{}
    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        GetGlobalBus().Subscribe("MedKaijuAttacked","Explosives_pool", Self)
      
    TeleportToAndExplode(Instigator:agent,Location:vector3)<suspends>:void=
        if (Explosives.Length > 0):
            Shuffled := Random.Shuffle(Explosives)
            if (explosive := Shuffled[0]):
                RandomExplosive:=explosive
                Sleep(0.1)
                if(RandomExplosive.TeleportTo[Location,rotation{}]):
                    RandomExplosive.Explode(Instigator)
                Sleep(1.0)
                if(RandomExplosive.TeleportTo[Home,rotation{}]):
                    RandomExplosive.Reset()
                

    OnEvent<override>(EventName: string, Data:eventdata): void =
        if(EventName = "MedKaijuAttacked"):
            if(MaybeLocation:= Data.Location?, MaybeAgent:= Data.Agent?):
                spawn{TeleportToAndExplode(MaybeAgent,MaybeLocation)}