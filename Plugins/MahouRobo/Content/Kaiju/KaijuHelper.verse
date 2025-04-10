using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

KaijuHelper := class(creative_device):

    FindNearestTarget(FC : fort_character)<decides><transacts> : fort_character =
        var PossibleTarget : ?fort_character = false
        var CheckRange : float = 5000.0
        for(Player : GetPlayspace().GetPlayers(), PlayerFC := Player.GetFortCharacter[]):
            if:
                DistanceDifference := Distance(PlayerFC.GetTransform().Translation, FC.GetTransform().Translation) < CheckRange
                not PlayerFC = FC
            then:
                set PossibleTarget = option{PlayerFC}
                set CheckRange = DistanceDifference
        return PossibleTarget?