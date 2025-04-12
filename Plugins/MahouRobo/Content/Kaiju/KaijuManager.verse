
using { /Fortnite.com/Devices }
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
            spawn:
                BigKaiju.MoveToTarget(Target)
    
    # 'Register' the big kaiju when it spawns in
    OnBigKaijuSpawn(Agent : agent):void=
        if (ValidKaiju := NPC_Kaiju[Agent]):
            set BigKaiju = ValidKaiju

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        big_kaiju_spawner.SpawnedEvent.Subscribe(OnBigKaijuSpawn)
        Print("Spawning Large Kaiju...")
        var Counter : int = 0
        loop:
            Sleep(10.0)
            Print("Moving to next waypoint...")
            BigKaijuNextZone(Counter)
            set Counter += 1
            if (Counter >= waypoint_list.Length):
                set Counter = 0
            
