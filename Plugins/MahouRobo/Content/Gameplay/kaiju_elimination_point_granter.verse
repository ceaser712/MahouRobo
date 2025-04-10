
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
kaiju_elimination_point_granter := class(creative_device):

    @editable
    var KaijuEliminationManager : elimination_manager_device = elimination_manager_device{}

    @editable
    var Scores : []score_manager_device = array{}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void =
        KaijuEliminationManager.EliminationEvent.Subscribe(OnElimination)

    OnElimination(InEliminator : ?agent):void =
        if (not InEliminator?):
            return
        teamCollection := GetPlayspace().GetTeamCollection()
        teams := teamCollection.GetTeams()
        n := Min(teams.Length, Scores.Length)
        for (i := 0..n):
            if (teamCollection.IsOnTeam[InEliminator?, teams[i]]):
                if (score := Scores[i]):
                    score.Activate()
