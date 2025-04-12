using { /Fortnite.com/AI }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Animation/PlayAnimation }
using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }
using { /Verse.org/Assets }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Game }
using {CoreCode}

KaijuBehaviourTag:= class(tag){}
# A Verse-authored NPC Behavior that can be used within an NPC Character Definition or an NPC Spawner device's NPC Behavior Script Override.
NPC_Kaiju := class(npc_behavior):
    @editable var point_value : int := 10
    @editable attack_recovery : float := 1.46
    @editable attack_delay_variance : float := 0.5  # How much +/- variance to apply
    @editable reach_radius : float := 300.0
    var lastTargetLocation : vector3 = vector3{X := 0.0, Y := 0.0, Z := 0.0}
    var isMoving : logic = false
    var HelperFunc<public> : KaijuHelper = KaijuHelper{}

    # This function runs when the NPC is spawned in the world and ready to follow a behavior.
    OnBegin<override>()<suspends>:void={}
      
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