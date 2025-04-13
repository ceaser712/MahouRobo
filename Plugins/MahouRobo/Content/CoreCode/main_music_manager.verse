
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Fortnite.com/Teams }
using { /UnrealEngine.com/Temporary/Diagnostics }

main_music_manager := class(creative_device, event_listener):

    @editable NormalMusicPlayer : audio_player_device = audio_player_device{}
    @editable BossMusicPlayer : audio_player_device = audio_player_device{}
    

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        GetGlobalBus().Subscribe("Small Kaiju Phase","MainMusicPlayer", Self)
        GetGlobalBus().Subscribe("Boss Transition Phase","MainMusicPlayer", Self)
        GetGlobalBus().Subscribe("Big Kaiju Phase","MainMusicPlayer", Self)

    OnEvent<override>(EventName: string, Data:eventdata): void =
        if(EventName = "Small Kaiju Phase"):
            NormalMusicPlayer.Play()
            Print("Normal Music Playing")
        if(EventName = "Boss Transition Phase"):
            NormalMusicPlayer.Stop()
        if(EventName = "Big Kaiju Phase"):
            BossMusicPlayer.Play()