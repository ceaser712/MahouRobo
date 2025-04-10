
using { /Fortnite.com/Devices }
using { /Fortnite.com/Teams }
using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /Verse.org/Assets }
using { /UnrealEngine.com/Temporary/Diagnostics }

TeamEnum := enum{Everyone, Robots, MagicalGirls}

defend_zone_data := class():
    @editable CaptureZone: capture_area_device
    @editable ZoneMaterial: creative_prop 
    @editable Team : TeamEnum = TeamEnum.Everyone

# A Verse-authored creative device that can be placed in a level
defend_zone_device := class(creative_device):

    @editable DefendZoneData: []defend_zone_data = array{}

    @editable RobotTeamIndex : int = 0
    @editable MagicalGirlsTeamIndex : int = 1

    @editable NeutralMaterial : material = material{}
    @editable RobotMaterial : material = material{}
    @editable MagicalGirlsMaterial : material = material{}

    OnBegin<override>()<suspends>:void=
        # Desable all capture zones
        for (defendZone : DefendZoneData):
            defendZone.CaptureZone.Disable()


    GetTeamFromEnum(teamData: TeamEnum)<decides>: team =
        teamCollection := GetPlayspace().GetTeamCollection()
        teamArray := teamCollection.GetTeams()
    
        case (teamData):
            TeamEnum.Robots =>
                if (t := teamArray[RobotTeamIndex]):
                    return t
                else:
                    fail
    
            TeamEnum.MagicalGirls =>
                if (t := teamArray[MagicalGirlsTeamIndex]):
                    return t
                else:
                    fail
    
            _ =>
                Print("DefendZone: No team data found for event")
                fail
    
    SelectDefendZone(teamData : TeamEnum): void=
        if (Count := DefendZoneData.Length - 1 > 0):

            teamCollection := GetPlayspace().GetTeamCollection()
            if(selectedTeam := GetTeamFromEnum[teamData]):
                var index : int = GetRandomInt(0, Count)
                
                if (defendZone := DefendZoneData[index]):
                    case(teamData):
                        TeamEnum.Robots =>
                            defendZone.ZoneMaterial.SetMaterial(RobotMaterial)
                            if(firstAgent := teamCollection.GetAgents[selectedTeam][0]):
                                defendZone.CaptureZone.GiveControl(firstAgent)
                            
                        TeamEnum.MagicalGirls =>
                            defendZone.ZoneMaterial.SetMaterial(MagicalGirlsMaterial)
                            if(firstAgent := teamCollection.GetAgents[selectedTeam][0]):
                                defendZone.CaptureZone.GiveControl(firstAgent)

                        _ =>
                            Print("DefendZone: No team data found for event")
