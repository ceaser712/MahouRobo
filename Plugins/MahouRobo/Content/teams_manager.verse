
using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Game }
using { /Fortnite.com/Teams }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
teams_manager := class(creative_device):

    @editable
    var TeamLoadouts : []item_granter_device = array{}

    @editable
    var Spawners : []player_spawner_device = array{}

    @editable
    var TeamSelectPopup: popup_dialog_device = popup_dialog_device{}

    var Teams : []team = array{}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void =
        set Teams = GetPlayspace().GetTeamCollection().GetTeams()
        TeamSelectPopup.RespondingButtonEvent.Subscribe(OnTeamSelectButtonClick)
        for (Spawner : Spawners):
            Spawner.SpawnedEvent.Subscribe(OnPlayerSpawn)

    OnPlayerSpawn(InPlayer : agent) : void = 
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