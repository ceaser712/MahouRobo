
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Fortnite.com/Teams }
using { /UnrealEngine.com/Temporary/Diagnostics }

main_music_manager := class(creative_device, event_listener):

    @editable NormalMusicPlayer : audio_player_device = audio_player_device{}
    @editable BossMusicPlayer : audio_player_device = audio_player_device{}

    @editable WinMagicGirlMusicPlayer : audio_player_device = audio_player_device{}
    @editable LoseMagicGirlMusicPlayer : audio_player_device = audio_player_device{}

    @editable WinRobotMusicPlayer : audio_player_device = audio_player_device{}
    @editable LoseRobotMusicPlayer : audio_player_device = audio_player_device{}

    


    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        GetGlobalBus().Subscribe("Small Kaiju Phase","MainMusicPlayer", Self)
        GetGlobalBus().Subscribe("Boss Transition Phase","MainMusicPlayer", Self)
        GetGlobalBus().Subscribe("Big Kaiju Phase","MainMusicPlayer", Self)
        GetGlobalBus().Subscribe("RoundEndTie","MainMusicPlayer", Self)
        GetGlobalBus().Subscribe("RoundEndRobots","MainMusicPlayer", Self)
        GetGlobalBus().Subscribe("RoundEndMagicalGirls","MainMusicPlayer", Self)

    OnEvent<override>(EventName: string, Data:eventdata): void =
        if(EventName = "Small Kaiju Phase"):
            NormalMusicPlayer.Play()
            Print("Normal Music Playing")
        else if(EventName = "Boss Transition Phase"):
            NormalMusicPlayer.Stop()
        else if(EventName = "Big Kaiju Phase"):
            BossMusicPlayer.Play()

        else if(EventName = "RoundEndTie"):
            NormalMusicPlayer.Stop()
            BossMusicPlayer.Stop()

            WinMagicGirlMusicPlayer.Play()
            WinRobotMusicPlayer.Play()

        else if(EventName = "RoundEndRobots"):
            NormalMusicPlayer.Stop()
            BossMusicPlayer.Stop()

            WinRobotMusicPlayer.Play()
            LoseMagicGirlMusicPlayer.Play()
            
        else if(EventName = "RoundEndMagicalGirls"):
            NormalMusicPlayer.Stop()
            BossMusicPlayer.Stop()

            WinMagicGirlMusicPlayer.Play()
            LoseRobotMusicPlayer.Play()