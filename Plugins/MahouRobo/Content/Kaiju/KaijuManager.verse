
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
KaijuManager := class(creative_device):

    @editable small_kaiju_spawner : npc_spawner_device = npc_spawner_device{}
    @editable medium_kaiju_spawner : npc_spawner_device = npc_spawner_device{}
    @editable big_kaiju_spawner : npc_spawner_device = npc_spawner_device{}
    @editable waypoint_list : []creative_prop = array{}

    var BigKaiju : NPC_Kaiju = NPC_Kaiju{}

    # Get the big kaiju and tell it to move to the next zone
    BigKaijuNextZone(index : int):void=
        if (Target := waypoint_list[index].GetTransform()):
            Print("Waypoint valid! Moving!")
            spawn:
                BigKaiju.MoveToTarget(Target)
    
    # 'Register' the big kaiju when it spawns in
    OnBigKaijuSpawn(Agent : agent):void=
        Print("Big Kaiju spawned in!")
        if:
            FortChar := Agent.GetFortCharacter[]
            
        if (ValidKaiju := NPC_Kaiju[Agent]):
            set BigKaiju = ValidKaiju
            Print("Big Kaiju ID'ed and registered!")

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        big_kaiju_spawner.SpawnedEvent.Subscribe(OnBigKaijuSpawn)
        var Counter : int = 0
        loop:
            Sleep(10.0)
            Print("Moving to waypoint: " + ToString(Counter))
            BigKaijuNextZone(Counter)
            set Counter += 1
            if (Counter >= waypoint_list.Length):
                Print("End of array reached!")
                set Counter = 0
            
