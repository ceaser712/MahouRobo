using { /Fortnite.com/AI }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Animation/PlayAnimation }
using { /Verse.org/Simulation }
using { /Verse.org/Assets }
using { /Fortnite.com/Game }
using { /UnrealEngine.com/Temporary/SpatialMath }
 
# A Verse-authored NPC Behavior that can be used within an NPC Character Definition or an NPC Spawner device's NPC Behavior Script Override.
BehaviorKaijuMd := class(NPC_Kaiju):
    @editable health : float := 500.0
    @editable projectile_speed : float := 20.0
    @editable projectile_damage : float := 5.0
    @editable move_speed : float := 20.0

    var Attack1 : animation_sequence = (/anigab@fortnite.com/MahouRobo/Kaiju:)Yeti_Anim_EnemyArmature_Attack

    # This function runs when the NPC is spawned in the world and ready to follow a behavior.
    OnBegin<override>()<suspends>:void=
        set point_value = 5
        if:
            NPCAgent := GetAgent[]
            NPCChar := NPCAgent.GetFortCharacter[]
        then:
            NPCChar.EliminatedEvent().Subscribe(OnKaijuEliminated)
            NPCChar.SetHealth(health)
            NPCSpawnPoint := NPCChar.GetTransform().Translation
            loop:
                Sleep(0.1)
                if (NewTarget := HelperFunc.FindNearestTarget[NPCChar], NewLocation := NewTarget.GetTransform()):
                    spawn{MoveToTarget(NewLocation)}
                    Sleep(0.46)
    
    MoveToTarget<override>(NewLocation:transform)<suspends>:logic =
        if:
            NPCAgent := GetAgent[]
            NPCChar := NPCAgent.GetFortCharacter[]
            NPCNav := NPCChar.GetNavigatable[]
            NPCFocus := NPCChar.GetFocusInterface[]
        then:
            NPCSpawnPoint := NPCChar.GetTransform().Translation
            loop:
                Sleep(0.1)
                    spawn{NPCFocus.MaintainFocus(NewLocation.Translation)}
                    NavTarget := MakeNavigationTarget(NewLocation.Translation)
                    NavResult:= NPCNav.NavigateTo(NavTarget, ?MovementType := movement_types.Running, ?ReachRadius := reach_radius)
                    if(NavResult = navigation_result.Reached or NavResult = navigation_result.PartiallyReached):
                        spawn{PlayAttackAnimation()}
                        Sleep(attack_recovery)
                    return true
        else:
            return false
    
    PlayAttackAnimation<override>()<suspends>:logic = 
        if:
            NPCAgent := GetAgent[]
            NPCChar := NPCAgent.GetFortCharacter[]
            NPCAnim := NPCChar.GetPlayAnimationController[]
        then:
            NPCAnim.Play(Attack1)
            return true
        else:
            return false


    OnKaijuEliminated<override>(Result:elimination_result):void=
        (super:)OnKaijuEliminated(Result)

    # This function runs when the NPC is despawned or eliminated from the world.
    OnEnd<override>():void=
        # TODO: Replace this with your code
        Print("Goodbye, NPC!")