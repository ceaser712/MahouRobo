
using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Game }
using { /Fortnite.com/Teams }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using {/Verse.org/Concurrency}
using { /Verse.org }
using {/UnrealEngine.com/Temporary/SpatialMath}
using{ CoreCode}
# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
teams_manager := class(creative_device,event_listener):
    @editable TeamSelect:conversation_device = conversation_device{}
    @editable var TeamLoadouts : []item_granter_device = array{}
    
    @editable LobbySelector: class_and_team_selector_device = class_and_team_selector_device{}
    @editable RobotSelector: class_and_team_selector_device = class_and_team_selector_device{}
    @editable MagicalGirlSelector: class_and_team_selector_device = class_and_team_selector_device{}

    @editable var PreTeamSpawnPads : []player_spawner_device = array{}
    @editable var RobotTeamSpawnPads : []player_spawner_device = array{}
    @editable var MagicalGirlSpawnPads : []player_spawner_device = array{}

    var Teams : []team = array{}
    
    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void =

        GetGlobalBus().Subscribe("RoundStart","timer_manager", Self)
        GetGlobalBus().Subscribe("PlayerJoined","timer_manager", Self)
        TeamSelect.OnConversationEvent.Subscribe(OnPlayerChoseTeam)
        set Teams = GetPlayspace().GetTeamCollection().GetTeams()

    OnEvent<override>(EventName: string, Data:eventdata) : void =
        if (EventName = "RoundStart"):
            for(Player:GetPlayspace().GetPlayers()):
                if(PlayerAgent := agent[Player]):
                    spawn{StartTeamSelection(Player)}
        if (EventName = "PlayerJoined"):
            Print("Player Found Joined in ")
                if(MaybeAgent:=Data.Agent?):
                    spawn{StartTeamSelection(MaybeAgent)}

    TeleportToRandomPad(Player: agent, SpawnPads:[]player_spawner_device): void =
        if (SpawnPads.Length > 0):
            Shuffled := Random.Shuffle(SpawnPads)
            if (pad := Shuffled[0]):
                PadLocation:=pad.GetTransform()
                if(Char:=Player.GetFortCharacter[]):
                    if(Char.TeleportTo[PadLocation.Translation, rotation{}]):

    StartTeamSelection(PlayerAgent:agent)<suspends>:void=
        Print("Starting Team Selection in 5 Seconds")
        #LobbySelector.ChangeTeamAndClass(PlayerAgent)
        TeleportToRandomPad(PlayerAgent,PreTeamSpawnPads)
        TeamSelect.InitiateConversation(PlayerAgent)

    OnPlayerChoseTeam(Player:agent, Index:int):void=
        Print("PlayerChose Team: {Index}")
        if(GetPlayspace().GetTeamCollection().AddToTeam[Player,Teams[Index]]):
            if(Index = 1):
                MagicalGirlSelector.ChangeTeamAndClass(Player)
                TeleportToRandomPad(Player, MagicalGirlSpawnPads)
            if(Index = 2):
                RobotSelector.ChangeTeamAndClass(Player)
                TeleportToRandomPad(Player, RobotTeamSpawnPads)
            AssignTeamLoadout(Player)

    AssignTeamLoadout(InPlayer : agent) : void = 
        teamCollection := GetPlayspace().GetTeamCollection()
        n := Min(Teams.Length, TeamLoadouts.Length)
        for (i := 0..n):
            if (teamCollection.IsOnTeam[InPlayer, Teams[i]]):
                if (loadout := TeamLoadouts[i]):
                    loadout.GrantItem(InPlayer)
