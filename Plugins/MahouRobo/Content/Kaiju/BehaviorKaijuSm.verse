using { /Fortnite.com/AI }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Animation/PlayAnimation }
using { /Verse.org/Simulation }
using { /Verse.org/Assets }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Game }
using {CoreCode}
using { /Verse.org/Random }
# A Verse-authored NPC Behavior that can be used within an NPC Character Definition or an NPC Spawner device's NPC Behavior Script Override.
BehaviorKaijuSm := class(NPC_Kaiju):
    var isTargetInRange : logic = false
    var lastTargetLocation : vector3 = vector3{X := 0.0, Y := 0.0, Z := 0.0}
    @editable health : float := 500.0
    @editable projectile_speed : float := 20.0
    @editable projectile_damage : float := 5.0
    @editable move_speed : float := 20.0

    @editable safe_distance : float := 1000.0        # Ideal distance from player
    @editable min_attack_distance : float := 400.0  # When to attack
    @editable retreat_distance : float := 600.0     # How far to back up when too close

    var Attack1 : animation_sequence = (/anigab@fortnite.com/MahouRobo/Kaiju:)Demon_Anim_EnemyArmature_Attack

    # This function runs when the NPC is spawned in the world and ready to follow a behavior.
    OnBegin<override>()<suspends>:void=
        Sleep(0.5)
        set point_value = 3

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
                    Sleep(attack_recovery)

    OnKaijuEliminated<override>(Result:elimination_result):void=
        (super:)OnKaijuEliminated(Result)
    
    MoveToTarget<override>(NewLocation:transform)<suspends>:logic =
        if:
            NPCAgent := GetAgent[]
            NPCChar := NPCAgent.GetFortCharacter[]
            NPCNav := NPCChar.GetNavigatable[]
            NPCFocus := NPCChar.GetFocusInterface[]
        then:
            PlayerPos := NewLocation.Translation
            MonsterPos := NPCChar.GetTransform().Translation
            ToPlayer := PlayerPos - MonsterPos
            DistanceToPlayer := ToPlayer.Length()
    
            spawn { NPCFocus.MaintainFocus(PlayerPos) }
    
            if (DistanceToPlayer <= min_attack_distance):
                spawn { PlayAttackAnimation() }
                return true  # Attack range
    
            if (DistanceToPlayer < safe_distance):
                Direction := ToPlayer / DistanceToPlayer
                RetreatOffset := Direction * retreat_distance
                RetreatPos := MonsterPos - RetreatOffset  # Move away from player
    
                NavTarget := MakeNavigationTarget(RetreatPos)
                NavResult := NPCNav.NavigateTo(NavTarget, ?MovementType := movement_types.Running, ?ReachRadius := 80.0, ?AllowPartialPath := true)
    
                return false  # Not in attack range, still retreating
            else:
                return false  # Far enough away, do nothing
        else:
            return false
    
    PlayAttackAnimation<override>()<suspends>:logic =
        if:
            NPCAgent := GetAgent[]
            NPCChar := NPCAgent.GetFortCharacter[]
            NPCAnim := NPCChar.GetPlayAnimationController[]
        then:
            Delay := GetRandomFloat(0.1, attack_delay_variance)
            Sleep(Delay)
    
            result := NPCAnim.PlayAndAwait(Attack1)
    
            if (result = play_animation_result.Completed):
                set lastTargetLocation = vector3{X := 0.0, Y := 0.0, Z := 0.0}
                GetGlobalBus().Notify(
                    "SmKaijuAttacked",
                    eventdata{
                        Agent := option{NPCAgent},
                        ValueFA := option{array{60.0, 60.0}}
                    }
                )
                return true
            else:
                return false
        else:
            return false


    # This function runs when the NPC is despawned or eliminated from the world.
    OnEnd<override>():void=
        # TODO: Replace this with your code
        Print("Goodbye, NPC!")