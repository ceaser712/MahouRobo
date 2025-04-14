using { /Fortnite.com/AI }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Animation/PlayAnimation }
using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }
using { /Verse.org/Assets }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Game }
using {CoreCode}
using { /Fortnite.com/Devices }

KaijuState:= enum { Idle, Patrolling, Chasing, Attacking, Retreating }
kaiju_damaged_callback := class():
    Player: agent
    Handle(Result: damage_result): void = HandleDamaged(Player, Result)
    
HandleDamaged(Player:agent, Result:damage_result):void=
    Victim := Player
    GetGlobalBus().Notify("KaijuTakenDamage",eventdata{Agent:=option{Player}})


KaijuBehaviourTag:= class(tag){}
# A Verse-authored NPC Behavior that can be used within an NPC Character Definition or an NPC Spawner device's NPC Behavior Script Override.
NPC_Kaiju := class(npc_behavior):
    var PatrolPOIs: []vector3 = array{
    vector3{X := 17323.0, Y := 2811.0, Z := 1152.0},
    vector3{X:= 26360.956507,Y:= 2889.451123,Z:= 364.222638},
    vector3{X:= 28402.892908,Y:= 7901.451123,Z:= 42.871678},
    vector3{X:=20174.892908,Y:=-2110.548877,Z:=1156.039311},
    vector3{X:=20202.892908,Y:=8185.451123,Z:=1157.784396},
    vector3{X:=18350.892908,Y:=3173.451123,Z:=1160.403645},
    vector3{X:=14886.892908,Y:=-3266.548877,Z:=1156.086841},
    vector3{X:=14978.892908,Y:=9909.451123,Z:=1156.022538},
    vector3{X:=13126.892908,Y:=4897.451123,Z:=1156.960242},
    vector3{X:=12606.892908,Y:=1153.451123,Z:=1156.022538},
    vector3{X:=28374.892908,Y:=-2394.548877,Z:=74.906102}}

    @editable CentralPoint: vector3 = vector3{X := 17323.0, Y := 2811.0, Z := 1152.0}
    @editable var point_value : int := 10
    var currentState: KaijuState = KaijuState.Idle
    @editable attack_recovery : float := 1.46
    @editable attack_delay_variance : float := 0.5  # How much +/- variance to apply
    @editable reach_radius : float := 300.0
    var lastTargetLocation : vector3 = vector3{X := 0.0, Y := 0.0, Z := 0.0}
    var isMoving : logic = false
    var HelperFunc<public> : KaijuHelper = KaijuHelper{}

    # This function runs when the NPC is spawned in the world and ready to follow a behavior.
    OnBegin<override>()<suspends>:void=
        if:
            NPCAgent := GetAgent[]
            NPCChar := NPCAgent.GetFortCharacter[]
        then:
            KaijuDamageCallback := kaiju_damaged_callback{ Player := NPCAgent }
            NPCChar.DamagedEvent().Subscribe(KaijuDamageCallback.Handle)
        
    OnKaijuEliminated<public>(Result:elimination_result):void=
        Victim := Result.EliminatedCharacter
        if (MaybeKiller := Result.EliminatingCharacter?):
            if (MaybeKiller = Victim):
                
            else if (VictimAgent := Victim.GetAgent[], KillerAgent := MaybeKiller.GetAgent[]):
                GetGlobalBus().Notify("PlayerEliminatedKaiju", eventdata{ValueI:= point_value ,AgentMap := option{map{
                    "killer" => KillerAgent,
                    "victim" => VictimAgent
                }}})

    MoveToTarget<public>(NewLocation:vector3)<suspends>:logic = false
    PlayAttackAnimation<public>()<suspends>:logic = false
    

    # This function runs when the NPC is despawned or eliminated from the world.
    OnEnd<override>():void=
        # TODO: Replace this with your code
        Print("Goodbye, NPC!")