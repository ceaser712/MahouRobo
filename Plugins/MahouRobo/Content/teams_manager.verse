
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
    @editable RobotEmblemVFX: visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable MagicalGirlEmblemVFX: visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable RemoverVFX: visual_effect_powerup_device = visual_effect_powerup_device{}

    @editable RobotHitVFX: creative_prop_asset = DefaultCreativePropAsset
    @editable MagicalGirlHitVFX: creative_prop_asset = DefaultCreativePropAsset


    @editable TeamSelect:conversation_device = conversation_device{}
    @editable var TeamLoadouts : []item_granter_device = array{}
    
    @editable LobbySelector: class_and_team_selector_device = class_and_team_selector_device{}
    @editable RobotSelector: class_and_team_selector_device = class_and_team_selector_device{}
    @editable MagicalGirlSelector: class_and_team_selector_device = class_and_team_selector_device{}

    @editable var PreTeamSpawnPads : []player_spawner_device = array{}
    @editable var RobotTeamSpawnPads : []player_spawner_device = array{}
    @editable var MagicalGirlSpawnPads : []player_spawner_device = array{}

    @editable MagicalGirlSelectAudio : audio_player_device = audio_player_device{}
    @editable RobotSelectAudio : audio_player_device = audio_player_device{}

    var Teams : []team = array{}
    
    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void =

        GetGlobalBus().Subscribe("RoundStart","timer_manager", Self)
        GetGlobalBus().Subscribe("PlayerJoined","timer_manager", Self)
        GetGlobalBus().Subscribe("PlayerTakenDamage","team_manager", Self)
        TeamSelect.OnConversationEvent.Subscribe(OnPlayerChoseTeam)
        
        set Teams = Self.GetPlayspace().GetTeamCollection().GetTeams()

    OnEvent<override>(EventName: string, Data:eventdata) : void =
        if (EventName = "RoundStart"):
            for(Player:GetPlayspace().GetPlayers()):
                if(PlayerAgent := agent[Player]):
                    spawn{StartTeamSelection(Player)}
        if (EventName = "PlayerJoined"):
            Print("Player Found Joined in ")
                if(MaybeAgent:=Data.Agent?):
                    spawn{StartTeamSelection(MaybeAgent)}
        if(EventName = "PlayerTakenDamage"):
            if(MaybeAgent:=Data.Agent?):
                spawn{DealDamageFX(MaybeAgent)}

    DealDamageFX(Agent:agent)<suspends>:void=
        teamCollection := Self.GetPlayspace().GetTeamCollection()
        if(FortChar:= Agent.GetFortCharacter[]):
            if(teamCollection.IsOnTeam[Agent, Teams[0]]):
                RO:=SpawnProp(RobotHitVFX,FortChar.GetTransform().Translation, rotation{})
                Sleep(0.3)
                if (SpawnedProp := RO(0)?):
                    spawn{DisposeProp(SpawnedProp)}
            if(teamCollection.IsOnTeam[Agent, Teams[1]]):
                RO:=SpawnProp(MagicalGirlHitVFX,FortChar.GetTransform().Translation, rotation{})
                Sleep(0.3)
                if (SpawnedProp := RO(0)?):
                    spawn{DisposeProp(SpawnedProp)}

    DisposeProp(V:creative_prop)<suspends>:void=
        V.Dispose()

    TeleportToRandomPad(Player: agent, SpawnPads:[]player_spawner_device): void =
        if (SpawnPads.Length > 0):
            Shuffled := Random.Shuffle(SpawnPads)
            if (pad := Shuffled[0]):
                PadLocation:=pad.GetTransform()
                if(Char:=Player.GetFortCharacter[]):
                    if(Char.TeleportTo[PadLocation.Translation, rotation{}]):

    StartTeamSelection(PlayerAgent:agent)<suspends>:void=
        LobbySelector.ChangeTeamAndClass(PlayerAgent)
        TeleportToRandomPad(PlayerAgent,PreTeamSpawnPads)
        TeamSelect.InitiateConversation(PlayerAgent)

    OnPlayerChoseTeam(Player:agent, Index:int):void=

        Print("HowManyTeams {Teams.Length}")
        if(Index = 1):
            Print("Player Chose Robots")
            RobotSelector.ChangeTeamAndClass(Player)
            TeleportToRandomPad(Player, RobotTeamSpawnPads)
            AssignTeamLoadout(Player)
            RobotEmblemVFX.Pickup(Player)
            RobotSelectAudio.Play(Player)

        if(Index = 2):
            Print("Player Chose Magical Girls")
            MagicalGirlSelector.ChangeTeamAndClass(Player)
            TeleportToRandomPad(Player, MagicalGirlSpawnPads)
            MagicalGirlEmblemVFX.Pickup(Player)
            AssignTeamLoadout(Player)
            MagicalGirlSelectAudio.Play(Player)

        for(i := 0..Teams.Length):
            TeamCollection:=Self.GetPlayspace().GetTeamCollection()
                if(TeamCollection.IsOnTeam[Player,Teams[i]]):
                    Print("Player is on Team {i}")
               
    AssignTeamLoadout(InPlayer : agent) : void = 
        teamCollection := Self.GetPlayspace().GetTeamCollection()
        if(teamCollection.IsOnTeam[InPlayer, Teams[0]]):
            if (loadout := TeamLoadouts[0]):
                loadout.GrantItem(InPlayer)
        if(teamCollection.IsOnTeam[InPlayer, Teams[1]]):
            if (loadout := TeamLoadouts[1]):
                loadout.GrantItem(InPlayer)
