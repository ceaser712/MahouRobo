using { /Fortnite.com/AI }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Game }
using { /Fortnite.com/Animation/PlayAnimation }
using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }
using { /Verse.org/Assets }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Game }
using { /Verse.org/Random }
using { CoreCode}
# A Verse-authored NPC Behavior that can be used within an NPC Character Definition or an NPC Spawner device's NPC Behavior Script Override.
BehaviorKaijuLg := class(NPC_Kaiju):
    @editable projectile_asset : creative_prop_asset = DefaultCreativePropAsset
    @editable projectile_speed : float = 5.0
    @editable projectile_damage : float = 5.0
    @editable move_speed : float = 20.0
    @editable waypoint_list : []creative_prop = array{}
    @editable waypoint_wait : float = 15.0

    var Attack1 : animation_sequence = (/anigab@fortnite.com/MahouRobo/Kaiju:)Giant_Anim_EnemyArmature_Attack

    # Fire projectile at targeted player
    FireProjectile()<suspends>:void =
        if:
            NPCAgent := GetAgent[]
            NPCChar := NPCAgent.GetFortCharacter[]
        then:
            MyPosition := NPCChar.GetTransform().Translation
            MyRotation := NPCChar.GetViewRotation()
            ForwardVec := MyRotation.GetLocalForward() * 400.0
            RangeVec := MyRotation.GetLocalForward() * 5000.0
            SpawnPos := MyPosition + ForwardVec + vector3{X := 0.0, Y := 0.0, Z := 100.0}
            EndPos := MyPosition + RangeVec
            if (NewProp := SpawnProp(projectile_asset, SpawnPos, IdentityRotation())(0)? ):
                race:
                    block:
                        NewProp.MoveTo(EndPos, IdentityRotation(), projectile_speed)
                        NewProp.Dispose()
                        return
                    DamageCheck(NewProp)
    
    # Projectile damage check and damage proc
    DamageCheck(Prop : creative_prop)<suspends>:void =
        loop:
            Sleep(0.1)
            for(Player : Prop.GetPlayspace().GetPlayers(), FC := Player.GetFortCharacter[]):
                if(Distance(FC.GetTransform().Translation, Prop.GetTransform().Translation) < 100.0):
                    FC.Damage(projectile_damage)
                    Prop.Dispose()

   
    OnBegin<override>()<suspends>:void =
        (super:)OnBegin()
        Sleep(0.5)
        set point_value = 5
        if:
            NPCAgent := GetAgent[]
            NPCChar := NPCAgent.GetFortCharacter[]
        then:
            NPCChar.EliminatedEvent().Subscribe(OnKaijuEliminated)
            spawn { MovementLoop() }

    MovementLoop()<suspends>:void =
        loop:
            Sleep(GetRandomFloat(3.0, 7.0)) # Desync

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
            PlayerPos := NewLocation
            MonsterPos := NPCChar.GetTransform().Translation
            ToPlayer := PlayerPos - MonsterPos
            DistanceToPlayer := ToPlayer.Length()
    
            if (DistanceToPlayer < 250.0):
                spawn { NPCFocus.MaintainFocus(PlayerPos) }
                spawn { PlayAttackAnimation() }
                return true
    
            Direction := ToPlayer / DistanceToPlayer
            StopShortDistance := 200.0
            TargetPos := PlayerPos - (Direction * StopShortDistance)
    
            spawn { NPCFocus.MaintainFocus(PlayerPos) }
    
            NavTarget := MakeNavigationTarget(TargetPos)
            NavResult := NPCNav.NavigateTo(
                NavTarget,
                ?MovementType := movement_types.Running,
                ?ReachRadius := 80.0,
                ?AllowPartialPath := true
            )
    
            if (NavResult = navigation_result.Reached):
                spawn { PlayAttackAnimation() }
                return true
            else:
                return false
        else:
            return false
    
    # Play defined attack animation
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
                    "LrgKaijuAttacked",
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

    # Event handler for elimination
    OnKaijuEliminated<override>(Result:elimination_result):void=
        (super:)OnKaijuEliminated(Result)

    # This function runs when the NPC is despawned or eliminated from the world.
    OnEnd<override>():void=
        Print("Big Kaiju despawned")