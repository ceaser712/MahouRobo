using { /Fortnite.com/AI }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Animation/PlayAnimation }
using { /Verse.org/Simulation }
using { /Verse.org/Assets }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Game }
 
# A Verse-authored NPC Behavior that can be used within an NPC Character Definition or an NPC Spawner device's NPC Behavior Script Override.
BehaviorKaijuLg := class(NPC_Kaiju):
    @editable health : float = 500.0
    @editable projectile_asset : creative_prop_asset = DefaultCreativePropAsset
    @editable projectile_speed : float = 5.0
    @editable projectile_damage : float = 5.0
    @editable move_speed : float = 20.0

    var Attack1 : animation_sequence = (/anigab@fortnite.com/MahouRobo/Kaiju:)Giant_Anim_EnemyArmature_Attack

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
    
    DamageCheck(Prop : creative_prop)<suspends>:void =
        loop:
            Sleep(0.0)
            for(Player : Prop.GetPlayspace().GetPlayers(), FC := Player.GetFortCharacter[]):
                if(Distance(FC.GetTransform().Translation, Prop.GetTransform().Translation) < 100.0):
                    FC.Damage(projectile_damage)
                    Prop.Dispose()

   
    # This function runs when the NPC is spawned in the world and ready to follow a behavior.
    OnBegin<override>()<suspends>:void=
        if:
            NPCAgent := GetAgent[]
            NPCChar := NPCAgent.GetFortCharacter[]
        then:
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
                    if(NavResult = navigation_result.Reached):
                        spawn{PlayAttackAnimation()}
                        Sleep(attack_recovery)
                        FireProjectile()
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
                

    # This function runs when the NPC is despawned or eliminated from the world.
    OnEnd<override>():void=
        # TODO: Replace this with your code
        Print("Goodbye, NPC!")