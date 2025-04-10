
using { /Fortnite.com/Devices }
using { /Fortnite.com/Teams }
using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /Verse.org/Assets }
using { /UnrealEngine.com/Temporary/Diagnostics }
using {MaterialLibrary}
TeamEnum := enum{Everyone, Robots, MagicalGirls}

defend_zone_data := class():
    @editable CaptureZone: capture_area_device
    @editable ZoneProp: creative_prop = creative_prop{}
    @editable var Team : TeamEnum = TeamEnum.Everyone

# A Verse-authored creative device that can be placed in a level
defend_zone_device := class(creative_device):

    @editable DefendZoneData: []defend_zone_data = array{}

    @editable RobotTeamIndex : int = 0
    @editable MagicalGirlsTeamIndex : int = 1

    NeutralMaterial : Color_Flat_Master_material = Color_Flat_Master_material{}
    RobotMaterial : Color_Flat_Master_material = Color_Flat_Master_material{}
    MagicalGirlMaterial : Color_Flat_Master_material = Color_Flat_Master_material{}
    
    OnBegin<override>()<suspends>:void=
        # Desable all capture zones
        for (defendZone : DefendZoneData):
            defendZone.CaptureZone.Disable()

        # Set a random defend zone for each team
        SetRandomDefendZone(TeamEnum.MagicalGirls)
        SetRandomDefendZone(TeamEnum.Robots)


    GetTeamFromEnum(teamData: TeamEnum): ?team =
        teamCollection := GetPlayspace().GetTeamCollection()
        teamArray := teamCollection.GetTeams()
    
        case (teamData):
            TeamEnum.Robots =>
                if (t := teamArray[RobotTeamIndex]):
                    return option{t}
                else:
                    false
    
            TeamEnum.MagicalGirls =>
                if (t := teamArray[MagicalGirlsTeamIndex]):
                    return option{t}
                else:
                    false
    
            _ =>
                Print("DefendZone: No team data found for event")
                false


    GetAvailableDefendZones() : []defend_zone_data=
        var availableZones : []defend_zone_data = array{}
        
        for (defendZone : DefendZoneData):
            if (defendZone.Team = TeamEnum.Everyone):
                tempArray := array{defendZone}
                set availableZones = availableZones + tempArray

        return availableZones

    SetDefendZoneMaterial(defendZone : defend_zone_data, teamData : TeamEnum): void=
        case (teamData):
            TeamEnum.Robots =>
                defendZone.ZoneProp.SetMaterial(RobotMaterial)
            TeamEnum.MagicalGirls =>
                defendZone.ZoneProp.SetMaterial(MagicalGirlMaterial)
            _ =>
                defendZone.ZoneProp.SetMaterial(NeutralMaterial)

    GiveControlOfDefendZone(defendZone : defend_zone_data, teamData : TeamEnum): void=
        teamCollection := GetPlayspace().GetTeamCollection()
        selectedTeam := GetTeamFromEnum(teamData)

        if(firstAgent := teamCollection.GetAgents[selectedTeam?][0]):
            defendZone.CaptureZone.GiveControl(firstAgent)
                        
    ResetDefendZones(): void=
        for (defendZone : DefendZoneData):
            set defendZone.Team = TeamEnum.Everyone
            defendZone.ZoneProp.SetMaterial(NeutralMaterial)
            defendZone.CaptureZone.Reset()
            defendZone.CaptureZone.Disable()
    
    SetRandomDefendZone(teamData : TeamEnum): void=
        # Get all available defend zones
        availableZones := GetAvailableDefendZones()

        # Get a random index from the available zones
        if (Count := availableZones.Length - 1 > 0):

            var index : int = GetRandomInt(0, Count)
                
            if (defendZone := availableZones[index]):
                # Set the team data for the defend zone
                set defendZone.Team = teamData

                # Set the material of the defend zone based on the team
                SetDefendZoneMaterial(defendZone, teamData)

                # Enable the capture zone
                defendZone.CaptureZone.Enable()

                # Give control of the defend zone to the team
                GiveControlOfDefendZone(defendZone, teamData)

        else :
            Print("DefendZone: No defend zone found")
