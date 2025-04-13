
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Fortnite.com/Teams }
using { /UnrealEngine.com/Temporary/Diagnostics }

TeamEnum := enum{Everyone, Robots, MagicalGirls}

audio_player_dataset := class():
    @editable AudioPlayer : audio_player_device = audio_player_device{}
    @editable ID : string = ""
    @editable Team : TeamEnum = TeamEnum.Everyone

    GetTeamString() : string =
        case(Team):
            TeamEnum.Everyone =>
                return "Everyone"
            TeamEnum.Robots =>
                return "Robots"
            TeamEnum.MagicalGirls =>
                return "MagicalGirls"

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.
# A Verse-authored creative device that can be placed in a level
sound_manager_device := class(creative_device, event_listener):

    @editable AudioData : []audio_player_dataset = array{}
    @editable RobotTeamIndex : int = 0
    @editable MagicalGirlsTeamIndex : int = 1
    var AudioDataMap : [string]audio_player_dataset = map{}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        #make a map of the audio players and their IDs
        for(AudioDataSet:AudioData):
            teamName := AudioDataSet.GetTeamString()
            if (set AudioDataMap[AudioDataSet.ID+teamName] = AudioDataSet):
                
        #subscribe each audio player to the event
        for(AudioDataSet:AudioData):
            teamName := AudioDataSet.GetTeamString()
            GetGlobalBus().Subscribe(AudioDataSet.ID,"AudioPlayerDataset", Self)

    OnEvent<override>(EventName: string, Data:eventdata): void =
        #check the map
        if(audioData := AudioDataMap[EventName+"Everyone"]):
                    teamCollection := GetPlayspace().GetTeamCollection()
                    teamArray := teamCollection.GetTeams()
                    if (robotTeam := teamArray[RobotTeamIndex]):
                        if(players := teamCollection.GetAgents[robotTeam]):
                            for(p : players):
                                audioData.AudioPlayer.Play(p)

        else if(audioData := AudioDataMap[EventName+"Robots"]):
            teamCollection := GetPlayspace().GetTeamCollection()
            teamArray := teamCollection.GetTeams()
            if (robotTeam := teamArray[RobotTeamIndex]):
                if(players := teamCollection.GetAgents[robotTeam]):
                    for(p : players):
                        audioData.AudioPlayer.Play(p)
                    
        else if(audioData := AudioDataMap[EventName+"MagicalGirls"]):
                teamCollection := GetPlayspace().GetTeamCollection()
                teamArray := teamCollection.GetTeams()
                if (magicGirlTeams := teamArray[MagicalGirlsTeamIndex]):
                    if(players := teamCollection.GetAgents[magicGirlTeams]):
                        for(p : players):
                            audioData.AudioPlayer.Play(p)

        else:
            Print("SoundManager: No audio player found for event {EventName}")
