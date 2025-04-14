
using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { CoreCode }
using { /Verse.org/Concurrency }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/SpatialMath }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
kaiju_spawn_manager := class(creative_device,event_listener):

    @editable
    var IncomingMessage: hud_message_device = hud_message_device{}

    @editable
    var SmallSpawners: []npc_spawner_device = array{}

    @editable
    var MediumSpawners: []npc_spawner_device = array{}

    @editable
    var BossSpawner: npc_spawner_device = npc_spawner_device{}

    @editable
    var SmallInterval: float = 3.0

    @editable
    var MediumInterval: float = 5.0

    @editable
    var SmallLimit: int = 15

    @editable
    var MediumLimit: int = 15

    var NumKaiju: int = 0

    var CurrentPhase: int = 0

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        GlobalBus := GetGlobalBus()
        GlobalBus.Subscribe("Small Kaiju Phase", "kaiju_spawn_manager", Self)
        GlobalBus.Subscribe("Transition Phase", "kaiju_spawn_manager", Self)
        GlobalBus.Subscribe("Medium Kaiju Phase", "kaiju_spawn_manager", Self)
        GlobalBus.Subscribe("Boss Transition Phase", "kaiju_spawn_manager", Self)
        GlobalBus.Subscribe("Big Kaiju Phase", "kaiju_spawn_manager", Self)
        for (Spawner:SmallSpawners):
            Spawner.SpawnedEvent.Subscribe(OnSpawn)
            Spawner.EliminatedEvent.Subscribe(OnElimination)
        for (Spawner:MediumSpawners):
            Spawner.SpawnedEvent.Subscribe(OnSpawn)
            Spawner.EliminatedEvent.Subscribe(OnElimination)
        BossSpawner.SpawnedEvent.Subscribe(OnSpawn)
        BossSpawner.EliminatedEvent.Subscribe(OnElimination)

    OnSpawn(NewKaiju: agent):void =
        set NumKaiju += 1
        # Print("OnSpawn {NumKaiju}")

    OnElimination(Elimination: device_ai_interaction_result): void =
        set NumKaiju -= 1
        # Print("OnElimination {NumKaiju}")

    PickSpawner(Spawners: []npc_spawner_device): npc_spawner_device =
        var FarthestSpawner: npc_spawner_device = npc_spawner_device{}
        var FarthestSpawnerDistance: float = 0.0

        Players := GetPlayspace().GetPlayers()
        for (Spawner : Spawners):
            SpawnerLocation := Spawner.GetTransform().Translation
            var ClosestPlayerDistance: float := 1000000000.0
            for (Player : Players):
                if (Character := Player.GetFortCharacter[]):
                    PlayerLocation := Character.GetTransform().Translation
                    D := Distance(SpawnerLocation, PlayerLocation)
                    if (D < ClosestPlayerDistance):
                        set ClosestPlayerDistance = D
            if (ClosestPlayerDistance > FarthestSpawnerDistance):
                set FarthestSpawner = Spawner
                set FarthestSpawnerDistance = ClosestPlayerDistance

        return FarthestSpawner

    SpawnTask(Phase: int, Spawners: []npc_spawner_device, Interval: float, Limit: int)<suspends> : void =
        loop:
            if (CurrentPhase = Phase):
                if (NumKaiju < Limit):
                    Spawner := PickSpawner(Spawners)
                    Spawner.Spawn()
                Sleep(Interval)
            else:
                for (Spawner : Spawners):
                    Spawner.DespawnAll(false)
                break
    
    StringToMessage<localizes>(I : []char) : message = "{I}"
    
    OnEvent<override>(EventName: string, Data: eventdata): void =
        Print(EventName)
        case (EventName):
            "Small Kaiju Phase" =>
                IncomingMessage.SetText(StringToMessage("KAIJU INCOMING!"))
                IncomingMessage.Show()
                set CurrentPhase = 1
                Print("Entered Small Kaiju Phase Now Spawn them")
                spawn:
                    SpawnTask(1, SmallSpawners, SmallInterval, SmallLimit)

            "Transition Phase" =>
                set CurrentPhase = 2
                # TODO make them all explode or something
                for (Spawner : SmallSpawners):
                    Spawner.DespawnAll(false)

            "Medium Kaiju Phase" =>
                IncomingMessage.SetText(StringToMessage("BIGGER KAIJU INCOMING!"))
                IncomingMessage.Show()
                spawn:
                    SpawnTask(2, MediumSpawners, MediumInterval, MediumLimit)

            "Boss Transition Phase" =>
                set CurrentPhase = 3
                # TODO make them all explode or something
                for (Spawner : MediumSpawners):
                    Spawner.DespawnAll(false)

            "Big Kaiju Phase" =>
                IncomingMessage.SetText(StringToMessage("MASSIVE KAIJU INCOMING!"))
                BossSpawner.Spawn()
                
            _ => # default
                Print("kaiju_spawn_manager subscribed to unhandled event {EventName}")