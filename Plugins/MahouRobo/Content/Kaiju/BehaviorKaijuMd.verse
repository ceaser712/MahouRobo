using { /Fortnite.com/AI }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Animation/PlayAnimation }
using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }
using { /Verse.org/Assets }
using { /Fortnite.com/Game }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Devices }
using {CoreCode}
using { /Verse.org/Random }
# A Verse-authored NPC Behavior that can be used within an NPC Character Definition or an NPC Spawner device's NPC Behavior Script Override.
BehaviorKaijuMd := class(NPC_Kaiju):
    var isTargetInRange : logic = false
    @editable projectile_speed : float := 20.0
    @editable projectile_damage : float := 5.0
    @editable move_speed : float := 20.0
    var Attack1 : animation_sequence = (/anigab@fortnite.com/MahouRobo/Kaiju:)Yeti_Anim_EnemyArmature_Attack

    # This function runs when the NPC is spawned in the world and ready to follow a behavior.
    OnBegin<override>()<suspends>:void =
        (super:)OnBegin()
        Sleep(0.5)
        set point_value = 5
    
        if:
            NPCAgent := GetAgent[]
            NPCChar := NPCAgent.GetFortCharacter[]
        then:
            NPCChar.EliminatedEvent().Subscribe(OnKaijuEliminated)
            spawn { StartPatrolBehavior(1500.0, 5.0) }
            spawn { MovementLoop() }

    MovementLoop()<suspends>:void =
        
        loop:
            Sleep(GetRandomFloat(1.0, 3.0))  # Desync
            if:
                NPCAgent := GetAgent[]
                NPCChar := NPCAgent.GetFortCharacter[]
                NPCLOC := NPCChar.GetTransform()
                NPCLOCT := NPCLOC.Translation
            then:
                if (isMoving?):
                    return
                if (NewTarget := HelperFunc.FindNearestTargetPosition[NPCLOCT]):
                        DistanceMoved := Distance(lastTargetLocation, NewTarget)
                        if (DistanceMoved > 100.0):
                            set lastTargetLocation = NewTarget
                            spawn { DoMoveToTarget(NewTarget) }

    DoMoveToTarget(NewLocation:vector3)<suspends>:void =
        set isMoving = true
        spawn{MoveToTarget(NewLocation)}  # Call and ignore result
        set isMoving = false

    MoveToTarget<override>(NewLocation:vector3)<suspends>:logic =
        if:
            NPCAgent := GetAgent[]
            NPCChar := NPCAgent.GetFortCharacter[]
            NPCNav := NPCChar.GetNavigatable[]
            NPCFocus := NPCChar.GetFocusInterface[]
        then:
            NavTarget := MakeNavigationTarget(NewLocation)
            NavResult := NPCNav.NavigateTo(
                NavTarget,
                ?MovementType := movement_types.Running,
                ?ReachRadius := 150.0,
                ?AllowPartialPath := true
            )
            return true
        return false
    
    StartPatrolBehavior(PatrolRadius: float, DelayBetweenMoves: float)<suspends>: void =
        loop:
            if:
                NPCAgent := GetAgent[]
                NPCChar := NPCAgent.GetFortCharacter[]
            then:
                if (currentState = KaijuState.Idle or currentState = KaijuState.Patrolling):
                    if(not HelperFunc.AnyPlayerNearby(NPCAgent, 3000.0)?):
                        set currentState = KaijuState.Patrolling
                        CurrentLocation := NPCChar.GetTransform().Translation
                        PatrolPoint := HelperFunc.GetRandomNearbyLocation(CurrentLocation, PatrolRadius)
                        spawn { MoveToTarget(PatrolPoint) }
                        Sleep(DelayBetweenMoves)
                    else:
                        set currentState = KaijuState.Chasing
            Sleep(1.0)

    PlayAttackAnimation<override>()<suspends>:logic =
        if:
            NPCAgent := GetAgent[]
            NPCChar := NPCAgent.GetFortCharacter[]
            NPCAnim := NPCChar.GetPlayAnimationController[]
        then:
            # Wait before attacking to add unpredictability
            Delay := GetRandomFloat(0.1, attack_delay_variance)
            Sleep(Delay)
    
            result := NPCAnim.PlayAndAwait(Attack1)
    
            if (result = play_animation_result.Completed):
                set lastTargetLocation = vector3{X := 0.0, Y := 0.0, Z := 0.0}
                GetGlobalBus().Notify(
                    "MedKaijuAttacked",
                    eventdata{
                        Agent := option{NPCAgent},
                        ValueFA := option{array{450.0, 120.0}}
                    }
                )
                return true
            else:
                return false
        else:
            return false


    OnKaijuEliminated<override>(Result:elimination_result):void=
        (super:)OnKaijuEliminated(Result)

    # This function runs when the NPC is despawned or eliminated from the world.
    OnEnd<override>():void=
        # TODO: Replace this with your code
        Print("Goodbye, NPC!")