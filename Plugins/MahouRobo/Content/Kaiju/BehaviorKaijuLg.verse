using { /Fortnite.com/AI }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Animation/PlayAnimation }
using { /Verse.org/Simulation }
using { /Verse.org/Assets }

 
# A Verse-authored NPC Behavior that can be used within an NPC Character Definition or an NPC Spawner device's NPC Behavior Script Override.
BehaviorKaijuLg := class(npc_behavior):
    HelperFunc : KaijuHelper = KaijuHelper{}
    var Attack1 : animation_sequence = (/anigab@fortnite.com/MahouRobo/Kaiju:)Giant_Anim_EnemyArmature_Attack

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
                if (NewTarget := HelperFunc.FindNearestTarget[NPCChar], NewAgent := NewTarget.GetAgent[]):
                    spawn{NPCFocus.MaintainFocus(NewAgent)}
                    NavTarget := MakeNavigationTarget(NewAgent)
                    NPCNav.NavigateTo(NavTarget, ?MovementType := movement_types.Running, ?ReachRadius := 150.0)
                    NPCAnim.Play(Attack1)
                    Sleep(0.46)
                

    # This function runs when the NPC is despawned or eliminated from the world.
    OnEnd<override>():void=
        # TODO: Replace this with your code
        Print("Goodbye, NPC!")