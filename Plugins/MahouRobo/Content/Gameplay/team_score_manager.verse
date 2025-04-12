
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

    IntToMessage<localizes>(I : int) : message = "{I}"

    var Teams : []team = array{}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void =
        GetGlobalBus().Subscribe("RoundEnd","team_score_manager", Self)
        GetGlobalBus().Subscribe("PlayerEliminatedKaiju","team_score_manager", Self)
        GetGlobalBus().Subscribe("PlayerEliminatedPlayer","team_score_manager", Self)
        ClearScores()
       
    ClearScores(): void = 
        n := GetPlayspace().GetTeamCollection().GetTeams().Length
        set Scores =
            for (i := 0..n):
                0

        for(Hud:HudMessages):
            Hud.SetText(IntToMessage(0))
            Hud.Show()

    OnEvent<override>(EventName: string, Data:eventdata) : void =
        case (EventName):
            "PlayerEliminatedPlayer"=>
                if(MaybeAgentMap:=Data.AgentMap?, Agent:= MaybeAgentMap["killer"]):
                    AwardTeamPoints(Agent,1)
            "PlayerEliminatedKaiju" =>
                if(MaybeAgentMap:=Data.AgentMap?, Agent:= MaybeAgentMap["killer"], Points:= Data.ValueI):
                    AwardTeamPoints(Agent,Points)
            "RoundEnd" =>
                EndGame()
            _ => # default


    AwardTeamPoints(Agent:agent, Points:int):void=
        set Teams = GetPlayspace().GetTeamCollection().GetTeams()
        Print("Awarding Team Points")

        teamCollection := GetPlayspace().GetTeamCollection()
        if(teamCollection.IsOnTeam[Agent, Teams[0]]):
            GivePoints(0, Points)
                UpdateHud(0)

        if(teamCollection.IsOnTeam[Agent, Teams[1]]):
            GivePoints(1, Points)
                UpdateHud(1)

    GivePoints(InTeamIndex : int, InPoints : int) : void = 
        i := InTeamIndex
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


    
    UpdateHud(InTeamIndex : int) : void =
        i := InTeamIndex
        if (hudMessage := HudMessages[i]):
            if (score := Scores[i]):
                hudMessage.SetText(IntToMessage(score))
            else:
                Print("UpdateHud got team {InTeamIndex} (must be 1..{Scores.Length})")
        else:
            Print("team_score_manager missing a HUD Message Device for team {InTeamIndex}")

    
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
