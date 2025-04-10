
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
    @editable ZoneProp: creative_prop 
    @editable Team : TeamEnum = TeamEnum.Everyone

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
    
    SelectDefendZone(teamData : TeamEnum): void=
        if (Count := DefendZoneData.Length - 1 > 0):

            teamCollection := GetPlayspace().GetTeamCollection()
            selectedTeam := GetTeamFromEnum(teamData)
            var index : int = GetRandomInt(0, Count)
                
            if (defendZone := DefendZoneData[index]):
                case(teamData):
                    TeamEnum.Robots =>
                        defendZone.ZoneProp.SetMaterial(RobotMaterial)
                        if(firstAgent := teamCollection.GetAgents[selectedTeam?][0]):
                            defendZone.CaptureZone.GiveControl(firstAgent)
                        
                    TeamEnum.MagicalGirls =>
                        defendZone.ZoneProp.SetMaterial(MagicalGirlMaterial)
                        if(firstAgent := teamCollection.GetAgents[selectedTeam?][0]):
                            defendZone.CaptureZone.GiveControl(firstAgent)

                    _ =>
                        Print("DefendZone: No team data found for event")
