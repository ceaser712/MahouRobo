
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

    var Teams : []team = array{}
    
    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void =
        GetGlobalBus().Subscribe("RoundStart","timer_manager", Self)
        GetGlobalBus().Subscribe("PlayerJoined","timer_manager", Self)
        TeamSelect.OnConversationEvent.Subscribe(OnPlayerChoseTeam)
        
        set Teams = GetPlayspace().GetTeamCollection().GetTeams()
        #for (Spawner : Spawners):
            #Spawner.SpawnedEvent.Subscribe(OnPlayerSpawn)

    OnEvent<override>(EventName: string, Data:eventdata) : void =
        if (EventName = "RoundStart"):
                spawn{StartTeamSelection()}
        if (EventName = "PlayerJoined"):
            Print("Player Found Joined in ")
                if(MaybeAgent:=Data.Agent?):
                    TeamSelect.InitiateConversation(MaybeAgent)

    StartTeamSelection()<suspends>:void=
        Print("Starting Team Selection in 5 Seconds")
        for(Player:GetPlayspace().GetPlayers()):
            if(PlayerAgent := agent[Player]):
                TeamSelect.InitiateConversation(PlayerAgent)

    OnPlayerChoseTeam(Player:agent, Index:int):void=
        Print("PlayerChose Team: {Index}")
        if(GetPlayspace().GetTeamCollection().AddToTeam[Player,Teams[Index-1]]):
            AssignTeamLoadout(Player)

    AssignTeamLoadout(InPlayer : agent) : void = 
        teamCollection := GetPlayspace().GetTeamCollection()
        n := Min(Teams.Length, TeamLoadouts.Length)
        for (i := 0..n):
            if (teamCollection.IsOnTeam[InPlayer, Teams[i]]):
                if (loadout := TeamLoadouts[i]):
                    loadout.GrantItem(InPlayer)
