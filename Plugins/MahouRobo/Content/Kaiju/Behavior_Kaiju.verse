using { /Fortnite.com/AI }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Animation/PlayAnimation }
using { /Verse.org/Simulation }
using { /Verse.org/Assets }
using { /UnrealEngine.com/Temporary/SpatialMath }
 
# A Verse-authored NPC Behavior that can be used within an NPC Character Definition or an NPC Spawner device's NPC Behavior Script Override.
NPC_Kaiju := class(npc_behavior):
    @editable attack_recovery : float := 0.46
    @editable reach_radius : float := 150.0

    HelperFunc : KaijuHelper = KaijuHelper{}

    # This function runs when the NPC is spawned in the world and ready to follow a behavior.
    OnBegin<override>()<suspends>:void=
        if:
            NPCAgent := GetAgent[]
            NPCChar := NPCAgent.GetFortCharacter[]
            NPCNav := NPCChar.GetNavigatable[]
            NPCFocus := NPCChar.GetFocusInterface[]
            NPCAnim := NPCChar.GetPlayAnimationController[]
        then:
            NPCSpawnPoint := NPCChar.GetTransform().Translation
            loop:
                Sleep(0.1)
                
                if (NewTarget := HelperFunc.FindNearestTarget[NPCChar], NewAgent := NewTarget.GetTransform()):
                    spawn{MoveToTarget(NewAgent)}
                    spawn{NPCFocus.MaintainFocus(NewAgent.Translation)}
                    NavTarget := MakeNavigationTarget(NewAgent.Translation)
                    NavResult:= NPCNav.NavigateTo(NavTarget, ?MovementType := movement_types.Running, ?ReachRadius := reach_radius, ?AllowPartialPath:= false)
                    if(NavResult = navigation_result.Reached):
                        spawn{PlayAttackAnimation()}
                        Sleep(attack_recovery)
    
    MoveToTarget(NewLocation:transform)<suspends>:logic = false
    PlayAttackAnimation()<suspends>:logic = false

    # This function runs when the NPC is despawned or eliminated from the world.
    OnEnd<override>():void=
        # TODO: Replace this with your code
        Print("Goodbye, NPC!")