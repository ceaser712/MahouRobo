
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { CoreCode }
using { /Verse.org/Concurrency }
using { /Verse.org/Random }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
kaiju_spawn_manager := class(creative_device,event_listener):

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
        GlobalBus.Subscribe("RoundStart", "kaiju_spawn_manager", Self)
        GlobalBus.Subscribe("MidPhaseStart", "kaiju_spawn_manager", Self)
        GlobalBus.Subscribe("BossPhaseStart", "kaiju_spawn_manager", Self)
        for (Spawner:SmallSpawners):
            Spawner.SpawnedEvent.Subscribe(OnSpawn)
            Spawner.EliminatedEvent.Subscribe(OnElimination)
        for (Spawner:MediumSpawners):
            Spawner.SpawnedEvent.Subscribe(OnSpawn)
            Spawner.EliminatedEvent.Subscribe(OnElimination)
        BossSpawner.SpawnedEvent.Subscribe(OnSpawn)
        BossSpawner.EliminatedEvent.Subscribe(OnElimination)

        # spawn:
        #     TestPhaseAdvance()

    OnSpawn(NewKaiju: agent):void =
        set NumKaiju += 1
        # Print("OnSpawn {NumKaiju}")

    OnElimination(Elimination: device_ai_interaction_result): void =
        set NumKaiju -= 1
        # Print("OnElimination {NumKaiju}")

    PickSpawner(Spawners: []npc_spawner_device): npc_spawner_device =
        # TODO pick the one farthest from any player
        I := GetRandomInt(0, Spawners.Length - 1)
        if (Spawner := Spawners[I]):
            # Print("Spawner {I}")
            return Spawner
        Print("No spawner {I}")
        return npc_spawner_device{}

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
        
    TestPhaseAdvance()<suspends> : void =
        PhaseEvents := array{"", "MidPhaseStart", "BossPhaseStart"}
        loop:
            if (NextPhaseEvent := PhaseEvents[CurrentPhase]):
                Sleep(10.0)
                GetGlobalBus().Notify(NextPhaseEvent, eventdata{})
            else:
                break

    OnEvent<override>(EventName: string, Data: eventdata): void =
        case (EventName):
            "RoundStart" =>
                set CurrentPhase = 1
                spawn:
                    SpawnTask(1, SmallSpawners, SmallInterval, SmallLimit)

                # Print("Start spawning small")

            "MidPhaseStart" =>
                set CurrentPhase = 2
                spawn:
                    SpawnTask(2, MediumSpawners, MediumInterval, MediumLimit)

                # Print("Start spawning medium")

                # TODO make them all explode or something
                for (Spawner : SmallSpawners):
                    Spawner.DespawnAll(false)
            "BossPhaseStart" =>
                set CurrentPhase = 3
                BossSpawner.Spawn()
                
                # Print("Spawn boss")

                # TODO make them all explode or something
                for (Spawner : MediumSpawners):
                    Spawner.DespawnAll(false)
            _ => # default