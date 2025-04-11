
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

    var CurrentPhase: int = 0

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        GlobalBus := GetGlobalBus()
        GlobalBus.Subscribe("RoundStart", "kaiju_spawn_manager", Self)

    PickSpawner(Spawners: []npc_spawner_device): npc_spawner_device =
        # TODO pick the one farthest from any player
        I := GetRandomInt(0, Spawners.Length - 1)
        if (Spawner := Spawners[I]):
            Print("Spawner {I}")
            return Spawner
        Print("No spawner {I}")
        return npc_spawner_device{}

    SpawnTask(Phase: int, Spawners: []npc_spawner_device, Interval: float)<suspends> : void =
        loop:
            if (CurrentPhase = Phase):
                Spawner := PickSpawner(Spawners)
                Spawner.Spawn()
                Sleep(Interval)
            else:
                break
        
    OnEvent<override>(EventName: string, Data: eventdata): void =
        case (EventName):
            "RoundStart" =>
                set CurrentPhase = 1
                spawn:
                    SpawnTask(1, SmallSpawners, SmallInterval)
                Print("Start spawning small")
            "MidPhaseStart" =>
                set CurrentPhase = 2
                spawn:
                    SpawnTask(2, MediumSpawners, MediumInterval)
                Print("Start spawning medium")
                # TODO make them all explode or something
                for (Spawner : SmallSpawners):
                    Spawner.DespawnAll(false)
            "BossPhaseStart" =>
                set CurrentPhase = 3
                BossSpawner.Spawn()
                
                # TODO make them all explode or something
                for (Spawner : MediumSpawners):
                    Spawner.DespawnAll(false)
            _ => # default