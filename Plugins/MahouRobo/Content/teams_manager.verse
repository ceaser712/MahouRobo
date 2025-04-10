
using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Game }
using { /Fortnite.com/Teams }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using{ CoreCode}
# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
teams_manager := class(creative_device,event_listener):
    @editable TeamSelect:conversation_device = conversation_device{}
    @editable
    var TeamLoadouts : []item_granter_device = array{}

    @editable
    var Spawners : []player_spawner_device = array{}

    @editable
    var TeamSelectPopup: popup_dialog_device = popup_dialog_device{}

    var Teams : []team = array{}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void =
        TeamSelect.OnConversationEvent.Subscribe(OnPlayerChoseTeam)
        
        set Teams = GetPlayspace().GetTeamCollection().GetTeams()
        TeamSelectPopup.RespondingButtonEvent.Subscribe(OnTeamSelectButtonClick)
        for (Spawner : Spawners):
            Spawner.SpawnedEvent.Subscribe(OnPlayerSpawn)

    OnEvent<override>(EventName: string, Data:eventdata) : void =
        case (EventName):
            "RoundStart" =>
                for(Player:GetPlayspace().GetPlayers()):
                    TeamSelect.InitiateConversation(Player)
            "PlayerJoined" =>
                if(MaybeAgent:=Data.Agent?):
                    TeamSelect.InitiateConversation(MaybeAgent)
            _ => # default

    OnPlayerChoseTeam(Player:agent, Index:int):void=
        Print("PlayerChose Team: {Index}")

    OnPlayerSpawn(InPlayer : agent) : void = 
        TeamSelect.InitiateConversation(InPlayer)
        teamCollection := GetPlayspace().GetTeamCollection()
        n := Min(Teams.Length, TeamLoadouts.Length)
        for (i := 0..n):
            if (teamCollection.IsOnTeam[InPlayer, Teams[i]]):
                if (loadout := TeamLoadouts[i]):
                    loadout.GrantItem(InPlayer)

    OnTeamSelectButtonClick(InAgent : agent, InResponse : int) : void =
        TeamIndex := InResponse + 1
        Print("Selected team {TeamIndex}")
        if (Team := Teams[InResponse]):
            if (GetPlayspace().GetTeamCollection().AddToTeam[InAgent, Team]):
                return
        Print("Team {TeamIndex} is not a team")