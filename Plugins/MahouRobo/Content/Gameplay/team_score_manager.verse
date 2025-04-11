
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { CoreCode }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
team_score_manager := class(creative_device,event_listener):

    var Scores : []int = array{}

    @editable
    var EliminationManagers : []elimination_manager_device = array{}

    @editable
    var HudMessages : []hud_message_device = array{}

    @editable
    var GameEnders : []end_game_device = array{}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void =
        GetGlobalBus().Subscribe("RoundEnd","team_score_manager", Self)
        for (EliminationManager : EliminationManagers):
            EliminationManager.EliminationEvent.Subscribe(OnElimination)

        n := GetPlayspace().GetTeamCollection().GetTeams().Length
        set Scores =
            for (i := 0..n):
                0
        for (i := 0..n):
            UpdateHud(i+1)
    
    GivePoints(InTeamIndex : int, InPoints : int) : void = 
        i := InTeamIndex - 1
        if (var score : int := Scores[i]):
            set score += InPoints
            if (set Scores[i] = score):
                return
        Print("GivePoints got team {InTeamIndex} (must be 1..{Scores.Length})")
    
    GetWinningTeam() : int =
        var t : int = 0
        var sc : int = 0
        for (i := 0..Scores.Length):
            if (ts := Scores[i]):
                if (ts > sc):
                    set t = i
                    set sc = ts
                else if (ts = sc):
                    set t = 0
        return t

    OnElimination(InEliminator : ?agent):void =
        if (not InEliminator?):
            return
        teamCollection := GetPlayspace().GetTeamCollection()
        teams := teamCollection.GetTeams()
        n := teams.Length
        for (i := 0..n):
            if (teamCollection.IsOnTeam[InEliminator?, teams[i]]):
                GivePoints(i + 1, 1)
                UpdateHud(i + 1)

    IntToMessage<localizes>(I : int) : message = "{I}"
    
    UpdateHud(InTeamIndex : int) : void =
        i := InTeamIndex - 1
        if (hudMessage := HudMessages[i]):
            if (score := Scores[i]):
                hudMessage.SetText(IntToMessage(score))
            else:
                Print("UpdateHud got team {InTeamIndex} (must be 1..{Scores.Length})")
        else:
            Print("team_score_manager missing a HUD Message Device for team {InTeamIndex}")

    OnEvent<override>(EventName: string, Data:eventdata) : void =
        case (EventName):
            "RoundEnd" =>
                EndGame()
            _ => # default
    
    EndGame() : void =
        WinningTeam := GetWinningTeam()
        if (WinningTeam = 0):
            Print("Draw or tiebreaker NYI")
            return
        
        teamCollection := GetPlayspace().GetTeamCollection()
        teams := teamCollection.GetTeams()
        if (Team := teams[WinningTeam - 1]):
            if (Agents := teamCollection.GetAgents[Team]):
                if (Agent := Agents[0]):
                    if (GameEnder := GameEnders[WinningTeam - 1]):
                        GameEnder.Activate(Agent)
                    else:
                        Print("team_score_manager missing an End Game Device for team {WinningTeam}")
                else:
                    Print("EndGame: No agents in team")
            else:
                Print("EndGame: tried to win with nonexistent team {WinningTeam}")
        else:
            Print("EndGame: tried to win with nonexistent team {WinningTeam}")
