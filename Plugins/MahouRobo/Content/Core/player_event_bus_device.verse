using { /Fortnite.com/Playspaces }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Game }
using { Core }


elimination_callback := class():
    Player: agent
    Handle(Result: elimination_result): void = HandleElimination(Player, Result)

   
HandleElimination(Player: agent, Result: elimination_result): void =
    Victim := Result.EliminatedCharacter
    if (MaybeKiller := Result.EliminatingCharacter?):
        if (MaybeKiller = Victim):
            GetGlobalBus().Notify("PlayerSelfEliminated", Player)
        else if (VictimAgent := Victim.GetAgent[], KillerAgent := MaybeKiller.GetAgent[]):
            GetGlobalBus().Notify("PlayerEliminatedPlayer", map{
                "killer" => KillerAgent,
                "victim" => VictimAgent
            })
    else:
        GetGlobalBus().Notify("PlayerEliminatedCreature", map{
            "killer" => Player
        })

player_event_manager := class(creative_device):

    OnBegin<override>()<suspends>: void =
        Playspace := GetPlayspace()
        Playspace.PlayerAddedEvent().Subscribe(OnPlayerAdded)
        Playspace.PlayerRemovedEvent().Subscribe(OnPlayerLeft)

    OnPlayerAdded(Player: agent): void =
        spawn:
            OnPlayerJoined(Player)

    OnPlayerJoined(Player: agent)<suspends>: void =
        Print("Player Joined:")
        GetGlobalBus().Notify("PlayerJoined", Player)

        # Safe character bind with delay
        Sleep(0.2)
        if (Character := Player.GetFortCharacter[]):
            CharacterElimCallback := elimination_callback{ Player := Player }
            Character.EliminatedEvent().Subscribe(CharacterElimCallback.Handle)

    OnPlayerLeft(Player: agent): void =
        Print("Player Left Match")
        GetGlobalBus().Notify("PlayerLeft", Player)

    OnPlayspaceElimination(Result: elimination_result): void =
        # Global catch if needed
        Print("Playspace Elimination triggered")

   