-- DOBUILD: 1
local this={}
local StrCode32=Fox.StrCode32
local IsTypeFunc=Tpp.IsTypeFunc
local IsTypeTable=Tpp.IsTypeTable
local IsTypeString=Tpp.IsTypeString
local IsTypeNumber=Tpp.IsTypeNumber
local GetGameObjectId=GameObject.GetGameObjectId
local GetGameObjectIdByIndex=GameObject.GetGameObjectIdByIndex
local GAME_OBJECT_TYPE_VEHICLE=TppGameObject.GAME_OBJECT_TYPE_VEHICLE
local NULL_ID=GameObject.NULL_ID
local SendCommand=GameObject.SendCommand
local DEBUG_StrCode32ToString=Tpp.DEBUG_StrCode32ToString
local questCp="quest_cp"
local EnemySubType=EnemySubType or{}

local function RENAMEsomeFunction(i)--tex NMC: cant actually find reference to function, it looks similar to setsolidertype/subtype
  local e={}
  for t,n in ipairs(i)do
    if IsTypeTable(n)then
      e[t]=RENAMEsomeFunction(n)
    else
      local n=GetGameObjectId(i[t])
      if n and n~=NULL_ID then
        e[n]=t
      end
    end
  end
  return e
end

function this.Messages()
  return Tpp.StrCode32Table{
    Player={{msg="RideHelicopterWithHuman",func=this._RideHelicopterWithHuman}},
    GameObject={
      {msg="Dead",func=this._OnDead},
      {msg="PlacedIntoVehicle",func=this._PlacedIntoVehicle},
      {msg="Damage",func=this._OnDamage},
      {msg="RoutePoint2",func=this._DoRoutePointMessage},
      {msg="LostControl",func=this._OnHeliBroken},
      {msg="VehicleBroken",func=this._OnVehicleBroken,option={isExecDemoPlaying=true}},
      {msg="WalkerGearBroken",func=this._OnWalkerGearBroken},
      {msg="ChangePhaseForAnnounce",func=this._AnnouncePhaseChange},
      {msg="InterrogateUpHero",func=function(gameId)
        local soldierType=this.GetSoldierType(gameId)
        if(soldierType~=EnemyType.TYPE_DD)then
          TppTrophy.Unlock(30)
        end
        PlayRecord.RegistPlayRecord"PLAYER_INTERROGATION"
      end}
    },
    Weather={
      {msg="Clock",sender="ShiftChangeAtNight",func=function(n,n)
        this.ShiftChangeByTime"shiftAtNight"
      end},
      {msg="Clock",sender="ShiftChangeAtMorning",func=function(n,n)
        this.ShiftChangeByTime"shiftAtMorning"
      end},
      {msg="Clock",sender="ShiftChangeAtMidNight",func=function(n,n)
        this.ShiftChangeByTime"shiftAtMidNight"
      end}
    }
  }
end
this.POWER_SETTING={
  "NO_KILL_WEAPON",
  "ARMOR",
  "SOFT_ARMOR",
  "SNIPER",
  "SHIELD",
  "MISSILE",
  "MG",
  "SHOTGUN",
  "SMG",
  "HELMET",
  "NVG",
  "GAS_MASK",
  "GUN_LIGHT",
  "STRONG_WEAPON",
  "STRONG_PATROL",
  "STRONG_NOTICE_TRANQ",
  "FULTON_SPECIAL",
  "FULTON_HIGH",
  "FULTON_LOW",
  "COMBAT_SPECIAL",
  "COMBAT_HIGH",
  "COMBAT_LOW",
  "STEALTH_SPECIAL",
  "STEALTH_HIGH",
  "STEALTH_LOW",
  "HOLDUP_SPECIAL",
  "HOLDUP_HIGH",
  "HOLDUP_LOW"
}
this.PHASE={SNEAK=0,CAUTION=1,EVASION=2,ALERT=3,MAX=4}
this.ROUTE_SET_TYPES={"sneak_day","sneak_night","caution","hold","travel","sneak_midnight","sleep"}
this.LIFE_STATUS={NORMAL=0,DEAD=1,DYING=2,SLEEP=3,FAINT=4}
this.ACTION_STATUS={NORMAL=0,FULTON_RECOVERD=1,HOLD_UP_STAND=2,HOLD_UP_CROWL=3,NOW_CARRYING=4}
this.SOLDIER_DEFINE_RESERVE_TABLE_NAME=Tpp.Enum{"lrrpTravelPlan","lrrpVehicle"}
this.TAKING_OVER_HOSTAGE_LIST={"hos_takingOver_0000","hos_takingOver_0001","hos_takingOver_0002","hos_takingOver_0003"}
this.ROUTE_SET_TYPETAG={}
this.subTypeOfCpTable={
  SOVIET_A={
    afgh_field_cp=true,
    afgh_remnants_cp=true,
    afgh_tent_cp=true,
    afgh_fieldEast_ob=true,
    afgh_fieldWest_ob=true,
    afgh_remnantsNorth_ob=true,
    afgh_tentEast_ob=true,
    afgh_tentNorth_ob=true,
    afgh_01_16_lrrp=true,
    afgh_29_20_lrrp=true,
    afgh_29_16_lrrp=true,
    afgh_village_cp=true,
    afgh_slopedTown_cp=true,
    afgh_commFacility_cp=true,
    afgh_enemyBase_cp=true,
    afgh_commWest_ob=true,
    afgh_ruinsNorth_ob=true,
    afgh_slopedWest_ob=true,
    afgh_villageEast_ob=true,
    afgh_villageEast_ob=true,
    afgh_villageNorth_ob=true,
    afgh_villageWest_ob=true,
    afgh_enemyEast_ob=true,
    afgh_01_13_lrrp=true,
    afgh_02_14_lrrp=true,
    afgh_32_01_lrrp=true,
    afgh_32_04_lrrp=true,
    afgh_32_14_lrrp=true,
    afgh_34_02_lrrp=true,
    afgh_34_13_lrrp=true,
    afgh_35_02_lrrp=true,
    afgh_35_14_lrrp=true,
    afgh_35_15_lrrp=true,
    afgh_36_04_lrrp=true,
    afgh_36_15_lrrp=true,
    afgh_36_06_lrrp=true
  },
  SOVIET_B={
    afgh_bridge_cp=true,
    afgh_fort_cp=true,
    afgh_cliffTown_cp=true,
    afgh_bridgeNorth_ob=true,
    afgh_bridgeWest_ob=true,
    afgh_cliffEast_ob=true,
    afgh_cliffSouth_ob=true,
    afgh_cliffWest_ob=true,
    afgh_enemyNorth_ob=true,
    afgh_fortSouth_ob=true,
    afgh_fortWest_ob=true,
    afgh_slopedEast_ob=true,
    afgh_powerPlant_cp=true,
    afgh_sovietBase_cp=true,
    afgh_plantSouth_ob=true,
    afgh_plantWest_ob=true,
    afgh_sovietSouth_ob=true,
    afgh_waterwayEast_ob=true,
    afgh_citadel_cp=true,
    afgh_citadelSouth_ob=true
  },
  PF_A={
    mafr_outland_cp=true,
    mafr_outlandEast_ob=true,
    mafr_outlandNorth_ob=true,
    mafr_01_20_lrrp=true,
    mafr_03_20_lrrp=true,
    mafr_flowStation_cp=true,
    mafr_swamp_cp=true,
    mafr_pfCamp_cp=true,
    mafr_savannah_cp=true,
    mafr_swampEast_ob=true,
    mafr_swampWest_ob=true,
    mafr_swampSouth_ob=true,
    mafr_pfCampEast_ob=true,
    mafr_pfCampNorth_ob=true,
    mafr_savannahEast_ob=true,
    mafr_chicoVilWest_ob=true,
    mafr_hillSouth_ob=true,
    mafr_02_21_lrrp=true,
    mafr_02_22_lrrp=true,
    mafr_05_23_lrrp=true,
    mafr_06_16_lrrp=true,
    mafr_06_22_lrrp=true,
    mafr_06_24_lrrp=true,
    mafr_13_15_lrrp=true,
    mafr_13_16_lrrp=true,
    mafr_13_24_lrrp=true,
    mafr_15_16_lrrp=true,
    mafr_15_23_lrrp=true,
    mafr_16_23_lrrp=true,
    mafr_16_24_lrrp=true,
    mafr_23_33_lrrp=true
  },
  PF_B={
    mafr_factory_cp=true,
    mafr_lab_cp=true,
    mafr_labWest_ob=true,
    mafr_19_29_lrrp=true
  },
  PF_C={
    mafr_banana_cp=true,
    mafr_diamond_cp=true,
    mafr_hill_cp=true,
    mafr_savannahNorth_ob=true,
    mafr_savannahWest_ob=true,
    mafr_bananaEast_ob=true,
    mafr_bananaSouth_ob=true,
    mafr_hillNorth_ob=true,
    mafr_hillWest_ob=true,
    mafr_hillWestNear_ob=true,
    mafr_factorySouth_ob=true,
    mafr_factoryWest_ob=true,
    mafr_diamondNorth_ob=true,
    mafr_diamondSouth_ob=true,
    mafr_diamondWest_ob=true,
    mafr_07_09_lrrp=true,
    mafr_07_24_lrrp=true,
    mafr_08_10_lrrp=true,
    mafr_08_25_lrrp=true,
    mafr_09_25_lrrp=true,
    mafr_10_11_lrrp=true,
    mafr_10_18_lrrp=true,
    mafr_10_26_lrrp=true,
    mafr_11_10_lrrp=true,
    mafr_11_12_lrrp=true,
    mafr_11_26_lrrp=true,
    mafr_12_14_lrrp=true,
    mafr_14_27_lrrp=true,
    mafr_17_27_lrrp=true,
    mafr_18_26_lrrp=true,
    mafr_27_30_lrrp=true
  }
}
this.subTypeOfCp={}
this.subTypeOfCpDefault={}--tex
for subType,cp in pairs(this.subTypeOfCpTable)do
  for cpName,bool in pairs(cp)do
    this.subTypeOfCp[cpName]=subType
    this.subTypeOfCpDefault[cpName]=subType--tex
  end
end
local TppEnemyBodyId=TppEnemyBodyId or{}
this.childBodyIdTable={TppEnemyBodyId.chd0_v00,TppEnemyBodyId.chd0_v01,TppEnemyBodyId.chd0_v02,TppEnemyBodyId.chd0_v03,TppEnemyBodyId.chd0_v05,TppEnemyBodyId.chd0_v06,TppEnemyBodyId.chd0_v07,TppEnemyBodyId.chd0_v08,TppEnemyBodyId.chd0_v09,TppEnemyBodyId.chd0_v10,TppEnemyBodyId.chd0_v11}
this.bodyIdTable={
  SOVIET_A={
    ASSAULT={TppEnemyBodyId.svs0_rfl_v00_a,TppEnemyBodyId.svs0_rfl_v00_a,TppEnemyBodyId.svs0_rfl_v01_a,TppEnemyBodyId.svs0_mcg_v00_a},
    ASSAULT_OB={TppEnemyBodyId.svs0_rfl_v02_a,TppEnemyBodyId.svs0_mcg_v02_a},
    SNIPER={TppEnemyBodyId.svs0_snp_v00_a},
    SHOTGUN={TppEnemyBodyId.svs0_rfl_v00_a,TppEnemyBodyId.svs0_rfl_v01_a},
    SHOTGUN_OB={TppEnemyBodyId.svs0_rfl_v02_a},
    MG={TppEnemyBodyId.svs0_mcg_v00_a,TppEnemyBodyId.svs0_mcg_v01_a},
    MG_OB={TppEnemyBodyId.svs0_mcg_v02_a},
    MISSILE={TppEnemyBodyId.svs0_rfl_v00_a},
    SHIELD={TppEnemyBodyId.svs0_rfl_v00_a},
    ARMOR={TppEnemyBodyId.sva0_v00_a},
    RADIO={TppEnemyBodyId.svs0_rdo_v00_a}
  },
  SOVIET_B={
    ASSAULT={TppEnemyBodyId.svs0_rfl_v00_b,TppEnemyBodyId.svs0_rfl_v00_b,TppEnemyBodyId.svs0_rfl_v01_b,TppEnemyBodyId.svs0_mcg_v00_b},
    ASSAULT_OB={TppEnemyBodyId.svs0_rfl_v02_b,TppEnemyBodyId.svs0_mcg_v02_b},
    SNIPER={TppEnemyBodyId.svs0_snp_v00_b},
    SHOTGUN={TppEnemyBodyId.svs0_rfl_v00_b,TppEnemyBodyId.svs0_rfl_v01_b},
    SHOTGUN_OB={TppEnemyBodyId.svs0_rfl_v02_b},
    MG={TppEnemyBodyId.svs0_mcg_v00_b,TppEnemyBodyId.svs0_mcg_v01_b},
    MG_OB={TppEnemyBodyId.svs0_mcg_v02_b},
    MISSILE={TppEnemyBodyId.svs0_rfl_v00_b},
    SHIELD={TppEnemyBodyId.svs0_rfl_v00_b},
    ARMOR={TppEnemyBodyId.sva0_v00_a},
    RADIO={TppEnemyBodyId.svs0_rdo_v00_b}
  },
  SOVIET_WILDCARD={
    ASSAULT={
      TppEnemyBodyId.svs0_unq_v010,
      TppEnemyBodyId.svs0_unq_v020,
      TppEnemyBodyId.svs0_unq_v070,
      TppEnemyBodyId.svs0_unq_v071,
      TppEnemyBodyId.svs0_unq_v072,
      TppEnemyBodyId.svs0_unq_v009,
      TppEnemyBodyId.svs0_unq_v060,
      TppEnemyBodyId.svs0_unq_v100,
      TppEnemyBodyId.svs0_unq_v420,
    },
    SNIPER={
      TppEnemyBodyId.svs0_unq_v020,
      TppEnemyBodyId.svs0_unq_v070,
      TppEnemyBodyId.svs0_unq_v071,
      TppEnemyBodyId.svs0_unq_v072,
      TppEnemyBodyId.svs0_unq_v009,
      TppEnemyBodyId.svs0_unq_v060,
      TppEnemyBodyId.svs0_unq_v100,
      TppEnemyBodyId.svs0_unq_v420,
      TppEnemyBodyId.svs0_unq_v010,
    },
    SHOTGUN={
      TppEnemyBodyId.svs0_unq_v070,
      TppEnemyBodyId.svs0_unq_v071,
      TppEnemyBodyId.svs0_unq_v072,
      TppEnemyBodyId.svs0_unq_v009,
      TppEnemyBodyId.svs0_unq_v060,
      TppEnemyBodyId.svs0_unq_v100,
      TppEnemyBodyId.svs0_unq_v420,
      TppEnemyBodyId.svs0_unq_v010,
      TppEnemyBodyId.svs0_unq_v020,
    },
    MG={
      TppEnemyBodyId.svs0_unq_v071,
      TppEnemyBodyId.svs0_unq_v072,
      TppEnemyBodyId.svs0_unq_v009,
      TppEnemyBodyId.svs0_unq_v060,
      TppEnemyBodyId.svs0_unq_v100,
      TppEnemyBodyId.svs0_unq_v420,
      TppEnemyBodyId.svs0_unq_v010,
      TppEnemyBodyId.svs0_unq_v020,
      TppEnemyBodyId.svs0_unq_v070,
    },
    MISSILE={
      TppEnemyBodyId.svs0_unq_v072,
      TppEnemyBodyId.svs0_unq_v009,
      TppEnemyBodyId.svs0_unq_v060,
      TppEnemyBodyId.svs0_unq_v100,
      TppEnemyBodyId.svs0_unq_v420,
      TppEnemyBodyId.svs0_unq_v010,
      TppEnemyBodyId.svs0_unq_v020,
      TppEnemyBodyId.svs0_unq_v070,
      TppEnemyBodyId.svs0_unq_v071,
    },
    SHIELD={
      TppEnemyBodyId.svs0_unq_v009,
      TppEnemyBodyId.svs0_unq_v060,
      TppEnemyBodyId.svs0_unq_v100,
      TppEnemyBodyId.svs0_unq_v420,
      TppEnemyBodyId.svs0_unq_v010,
      TppEnemyBodyId.svs0_unq_v020,
      TppEnemyBodyId.svs0_unq_v070,
      TppEnemyBodyId.svs0_unq_v071,
      TppEnemyBodyId.svs0_unq_v072,
    },
    ARMOR={TppEnemyBodyId.sva0_v00_a},
    RADIO={
      TppEnemyBodyId.svs0_unq_v060,
      TppEnemyBodyId.svs0_unq_v100,
      TppEnemyBodyId.svs0_unq_v420,
      TppEnemyBodyId.svs0_unq_v010,
      TppEnemyBodyId.svs0_unq_v020,
      TppEnemyBodyId.svs0_unq_v070,
      TppEnemyBodyId.svs0_unq_v071,
      TppEnemyBodyId.svs0_unq_v072,
      TppEnemyBodyId.svs0_unq_v009,
    }
  },
  PF_WILDCARD={
    ASSAULT={
      TppEnemyBodyId.pfs0_unq_v210,
      TppEnemyBodyId.pfs0_unq_v250,
      TppEnemyBodyId.pfs0_unq_v360,
      TppEnemyBodyId.pfs0_unq_v280,
      TppEnemyBodyId.pfs0_unq_v150,
      TppEnemyBodyId.pfs0_unq_v140,
      TppEnemyBodyId.pfs0_unq_v241,
      TppEnemyBodyId.pfs0_unq_v450,
      TppEnemyBodyId.pfs0_unq_v440,
    },
    SNIPER={
      TppEnemyBodyId.pfs0_unq_v250,
      TppEnemyBodyId.pfs0_unq_v360,
      TppEnemyBodyId.pfs0_unq_v280,
      TppEnemyBodyId.pfs0_unq_v150,
      TppEnemyBodyId.pfs0_unq_v140,
      TppEnemyBodyId.pfs0_unq_v241,
      TppEnemyBodyId.pfs0_unq_v450,
      TppEnemyBodyId.pfs0_unq_v440,
      TppEnemyBodyId.pfs0_unq_v210,
    },
    SHOTGUN={
      TppEnemyBodyId.pfs0_unq_v360,
      TppEnemyBodyId.pfs0_unq_v280,
      TppEnemyBodyId.pfs0_unq_v150,
      TppEnemyBodyId.pfs0_unq_v140,
      TppEnemyBodyId.pfs0_unq_v241,
      TppEnemyBodyId.pfs0_unq_v450,
      TppEnemyBodyId.pfs0_unq_v440,
      TppEnemyBodyId.pfs0_unq_v210,
      TppEnemyBodyId.pfs0_unq_v250,
    },
    MG={
      TppEnemyBodyId.pfs0_unq_v280,
      TppEnemyBodyId.pfs0_unq_v150,
      TppEnemyBodyId.pfs0_unq_v140,
      TppEnemyBodyId.pfs0_unq_v241,
      TppEnemyBodyId.pfs0_unq_v450,
      TppEnemyBodyId.pfs0_unq_v440,
      TppEnemyBodyId.pfs0_unq_v210,
      TppEnemyBodyId.pfs0_unq_v250,
      TppEnemyBodyId.pfs0_unq_v360,
    },
    MISSILE={
      TppEnemyBodyId.pfs0_unq_v150,
      TppEnemyBodyId.pfs0_unq_v140,
      TppEnemyBodyId.pfs0_unq_v241,
      TppEnemyBodyId.pfs0_unq_v450,
      TppEnemyBodyId.pfs0_unq_v440,
      TppEnemyBodyId.pfs0_unq_v210,
      TppEnemyBodyId.pfs0_unq_v250,
      TppEnemyBodyId.pfs0_unq_v360,
      TppEnemyBodyId.pfs0_unq_v280,
    },
    SHIELD={
      TppEnemyBodyId.pfs0_unq_v140,
      TppEnemyBodyId.pfs0_unq_v241,
      TppEnemyBodyId.pfs0_unq_v450,
      TppEnemyBodyId.pfs0_unq_v440,
      TppEnemyBodyId.pfs0_unq_v210,
      TppEnemyBodyId.pfs0_unq_v250,
      TppEnemyBodyId.pfs0_unq_v360,
      TppEnemyBodyId.pfs0_unq_v280,
      TppEnemyBodyId.pfs0_unq_v150,
    },
    ARMOR={TppEnemyBodyId.pfa0_v00_a,TppEnemyBodyId.pfa0_v00_b,TppEnemyBodyId.pfa0_v00_c},
    RADIO={
      TppEnemyBodyId.pfs0_unq_v241,
      TppEnemyBodyId.pfs0_unq_v450,
      TppEnemyBodyId.pfs0_unq_v440,
      TppEnemyBodyId.pfs0_unq_v210,
      TppEnemyBodyId.pfs0_unq_v250,
      TppEnemyBodyId.pfs0_unq_v360,
      TppEnemyBodyId.pfs0_unq_v280,
      TppEnemyBodyId.pfs0_unq_v150,
      TppEnemyBodyId.pfs0_unq_v140,
    },
  },
  PF_A={
    ASSAULT={TppEnemyBodyId.pfs0_rfl_v00_a,TppEnemyBodyId.pfs0_mcg_v00_a},
    ASSAULT_OB={TppEnemyBodyId.pfs0_rfl_v00_a,TppEnemyBodyId.pfs0_rfl_v01_a,TppEnemyBodyId.pfs0_mcg_v00_a},
    SNIPER={TppEnemyBodyId.pfs0_snp_v00_a},
    SHOTGUN={TppEnemyBodyId.pfs0_rfl_v00_a},
    SHOTGUN_OB={TppEnemyBodyId.pfs0_rfl_v00_a,TppEnemyBodyId.pfs0_rfl_v01_a},
    MG={TppEnemyBodyId.pfs0_mcg_v00_a},
    MISSILE={TppEnemyBodyId.pfs0_rfl_v00_a},
    SHIELD={TppEnemyBodyId.pfs0_rfl_v00_a},
    ARMOR={TppEnemyBodyId.pfa0_v00_b},
    RADIO={TppEnemyBodyId.pfs0_rdo_v00_a}
  },
  PF_B={
    ASSAULT={TppEnemyBodyId.pfs0_rfl_v00_b,TppEnemyBodyId.pfs0_mcg_v00_b},
    ASSAULT_OB={TppEnemyBodyId.pfs0_rfl_v00_b,TppEnemyBodyId.pfs0_rfl_v01_b,TppEnemyBodyId.pfs0_mcg_v00_b},
    SNIPER={TppEnemyBodyId.pfs0_snp_v00_b},
    SHOTGUN={TppEnemyBodyId.pfs0_rfl_v00_b},
    SHOTGUN_OB={TppEnemyBodyId.pfs0_rfl_v00_b,TppEnemyBodyId.pfs0_rfl_v01_b},
    MG={TppEnemyBodyId.pfs0_mcg_v00_b},
    MISSILE={TppEnemyBodyId.pfs0_rfl_v00_b},
    SHIELD={TppEnemyBodyId.pfs0_rfl_v00_b},
    ARMOR={TppEnemyBodyId.pfa0_v00_a},
    RADIO={TppEnemyBodyId.pfs0_rdo_v00_b}
  },
  PF_C={
    ASSAULT={TppEnemyBodyId.pfs0_rfl_v00_c,TppEnemyBodyId.pfs0_mcg_v00_c},
    ASSAULT_OB={TppEnemyBodyId.pfs0_rfl_v00_c,TppEnemyBodyId.pfs0_rfl_v01_c,TppEnemyBodyId.pfs0_mcg_v00_c},
    SNIPER={TppEnemyBodyId.pfs0_snp_v00_c},
    SHOTGUN={TppEnemyBodyId.pfs0_rfl_v00_c},
    SHOTGUN_OB={TppEnemyBodyId.pfs0_rfl_v00_c,TppEnemyBodyId.pfs0_rfl_v01_c},
    MG={TppEnemyBodyId.pfs0_mcg_v00_c},
    MISSILE={TppEnemyBodyId.pfs0_rfl_v00_c},
    SHIELD={TppEnemyBodyId.pfs0_rfl_v01_c},
    ARMOR={TppEnemyBodyId.pfa0_v00_c},
    RADIO={TppEnemyBodyId.pfs0_rdo_v00_c}
  },
  DD_A={ASSAULT={TppEnemyBodyId.dds3_main0_v00}},
  DD_FOB={ASSAULT={TppEnemyBodyId.dds5_main0_v00}},
  DD_PW={ASSAULT={TppEnemyBodyId.dds0_main1_v00}},
  SKULL_CYPR={ASSAULT={TppEnemyBodyId.wss0_main0_v00}},
  SKULL_AFGH={ASSAULT={TppEnemyBodyId.wss4_main0_v00}},
  CHILD={ASSAULT=this.childBodyIdTable}
}
this.weaponIdTable={
  SOVIET_A={
    NORMAL={
      HANDGUN=TppEquip.EQP_WP_East_hg_010,
      SMG=TppEquip.EQP_WP_East_sm_010,
      ASSAULT=TppEquip.EQP_WP_East_ar_010,
      SNIPER=TppEquip.EQP_WP_East_sr_011,
      SHOTGUN=TppEquip.EQP_WP_Com_sg_011,
      MG=TppEquip.EQP_WP_East_mg_010,
      MISSILE=TppEquip.EQP_WP_East_ms_010,
      SHIELD=TppEquip.EQP_SLD_SV
    },
    STRONG={
      HANDGUN=TppEquip.EQP_WP_East_hg_010,
      SMG=TppEquip.EQP_WP_East_sm_020,
      ASSAULT=TppEquip.EQP_WP_East_ar_030,
      SNIPER=TppEquip.EQP_WP_East_sr_020,
      SHOTGUN=TppEquip.EQP_WP_Com_sg_020,
      MG=TppEquip.EQP_WP_East_mg_010,
      MISSILE=TppEquip.EQP_WP_Com_ms_010,
      SHIELD=TppEquip.EQP_SLD_SV
    }
  },
  WILDCARD={--tex> dd max grades except for noted
    NORMAL={
      HANDGUN=TppEquip.EQP_WP_West_hg_030,--geist p3 machine pistol grade 4 - shows shotgun icon but clearly isnt,
      SMG=TppEquip.EQP_WP_West_sm_017,
      ASSAULT=TppEquip.EQP_WP_West_ar_057,
      SNIPER=TppEquip.EQP_WP_EX_sr_000,--molotok-68 grade 9
      SHOTGUN=TppEquip.EQP_WP_Com_sg_018,
      MG=TppEquip.EQP_WP_West_mg_021,--alm48 flashlight grade 4 --TppEquip.EQP_WP_West_mg_037,
      MISSILE=TppEquip.EQP_WP_Com_ms_010,
      SHIELD=TppEquip.EQP_SLD_DD_01,
    },
  },--<
  PF_A={
    NORMAL={
      HANDGUN=TppEquip.EQP_WP_West_hg_010,
      SMG=TppEquip.EQP_WP_West_sm_010,
      ASSAULT=TppEquip.EQP_WP_West_ar_010,
      SNIPER=TppEquip.EQP_WP_West_sr_011,
      SHOTGUN=TppEquip.EQP_WP_Com_sg_011,
      MG=TppEquip.EQP_WP_West_mg_010,
      MISSILE=TppEquip.EQP_WP_West_ms_010,
      SHIELD=TppEquip.EQP_SLD_PF_01
    },
    STRONG={
      HANDGUN=TppEquip.EQP_WP_West_hg_010,
      SMG=TppEquip.EQP_WP_West_sm_020,
      ASSAULT=TppEquip.EQP_WP_West_ar_020,
      SNIPER=TppEquip.EQP_WP_West_sr_020,
      SHOTGUN=TppEquip.EQP_WP_Com_sg_020,
      MG=TppEquip.EQP_WP_West_mg_010,
      MISSILE=TppEquip.EQP_WP_Com_ms_010,
      SHIELD=TppEquip.EQP_SLD_PF_01
    }
  },
  PF_B={
    NORMAL={
      HANDGUN=TppEquip.EQP_WP_West_hg_010,
      SMG=TppEquip.EQP_WP_West_sm_010,
      ASSAULT=TppEquip.EQP_WP_West_ar_010,
      SNIPER=TppEquip.EQP_WP_West_sr_011,
      SHOTGUN=TppEquip.EQP_WP_Com_sg_011,
      MG=TppEquip.EQP_WP_West_mg_010,
      MISSILE=TppEquip.EQP_WP_West_ms_010,
      SHIELD=TppEquip.EQP_SLD_PF_00
    },
    STRONG={
      HANDGUN=TppEquip.EQP_WP_West_hg_010,
      SMG=TppEquip.EQP_WP_West_sm_020,
      ASSAULT=TppEquip.EQP_WP_West_ar_020,
      SNIPER=TppEquip.EQP_WP_West_sr_020,
      SHOTGUN=TppEquip.EQP_WP_Com_sg_020,
      MG=TppEquip.EQP_WP_West_mg_010,
      MISSILE=TppEquip.EQP_WP_Com_ms_010,
      SHIELD=TppEquip.EQP_SLD_PF_00
    }
  },
  PF_C={
    NORMAL={
      HANDGUN=TppEquip.EQP_WP_West_hg_010,
      SMG=TppEquip.EQP_WP_West_sm_010,
      ASSAULT=TppEquip.EQP_WP_West_ar_010,
      SNIPER=TppEquip.EQP_WP_West_sr_011,
      SHOTGUN=TppEquip.EQP_WP_Com_sg_011,
      MG=TppEquip.EQP_WP_West_mg_010,
      MISSILE=TppEquip.EQP_WP_West_ms_010,
      SHIELD=TppEquip.EQP_SLD_PF_02
    },
    STRONG={
      HANDGUN=TppEquip.EQP_WP_West_hg_010,
      SMG=TppEquip.EQP_WP_West_sm_020,
      ASSAULT=TppEquip.EQP_WP_West_ar_020,
      SNIPER=TppEquip.EQP_WP_West_sr_020,
      SHOTGUN=TppEquip.EQP_WP_Com_sg_020,
      MG=TppEquip.EQP_WP_West_mg_010,
      MISSILE=TppEquip.EQP_WP_Com_ms_010,
      SHIELD=TppEquip.EQP_SLD_PF_02
    }
  },
  DD=nil,
  SKULL_CYPR={
    NORMAL={
      HANDGUN=TppEquip.EQP_WP_West_hg_020,
      SMG=TppEquip.EQP_WP_East_sm_030
    }
  },
  SKULL={
    NORMAL={
      HANDGUN=TppEquip.EQP_WP_West_hg_020,
      SMG=TppEquip.EQP_WP_West_sm_020,
      ASSAULT=TppEquip.EQP_WP_West_ar_030,
      SNIPER=TppEquip.EQP_WP_West_sr_020,
      SHOTGUN=TppEquip.EQP_WP_Com_sg_011,
      MG=TppEquip.EQP_WP_West_mg_020,
      MISSILE=TppEquip.EQP_WP_West_ms_010,
      SHIELD=TppEquip.EQP_SLD_PF_02},
    STRONG={
      HANDGUN=TppEquip.EQP_WP_West_hg_020,
      SMG=TppEquip.EQP_WP_West_sm_020,
      ASSAULT=TppEquip.EQP_WP_West_ar_030,
      SNIPER=TppEquip.EQP_WP_West_sr_020,
      SHOTGUN=TppEquip.EQP_WP_Com_sg_020,
      MG=TppEquip.EQP_WP_West_mg_020,
      MISSILE=TppEquip.EQP_WP_Com_ms_010,
      SHIELD=TppEquip.EQP_SLD_PF_02}},
  CHILD={
    NORMAL={
      HANDGUN=TppEquip.EQP_WP_East_hg_010,
      ASSAULT=TppEquip.EQP_WP_East_ar_020}
  }
}
this.gunLightWeaponIds={
  [TppEquip.EQP_WP_Com_sg_011]=TppEquip.EQP_WP_Com_sg_011_FL,
  [TppEquip.EQP_WP_Com_sg_020]=TppEquip.EQP_WP_Com_sg_020_FL,
  [TppEquip.EQP_WP_West_ar_010]=TppEquip.EQP_WP_West_ar_010_FL,
  [TppEquip.EQP_WP_West_ar_020]=TppEquip.EQP_WP_West_ar_020_FL,
  [TppEquip.EQP_WP_East_ar_010]=TppEquip.EQP_WP_East_ar_010_FL,
  [TppEquip.EQP_WP_East_ar_030]=TppEquip.EQP_WP_East_ar_030_FL
}
local MbsDevelopedEquipType=MbsDevelopedEquipType or{}
this.DDWeaponIdInfo={
  HANDGUN={{equipId=TppEquip.EQP_WP_West_hg_010}},
  SMG={
    {equipId=TppEquip.EQP_WP_East_sm_047,isNoKill=true,developedEquipType=MbsDevelopedEquipType.SM_2040_NOKILL,developId=2044},--grade7
    {equipId=TppEquip.EQP_WP_East_sm_045,isNoKill=true,developedEquipType=MbsDevelopedEquipType.SM_2040_NOKILL,developId=2043},--grade5
    {equipId=TppEquip.EQP_WP_East_sm_044,isNoKill=true,developedEquipType=MbsDevelopedEquipType.SM_2040_NOKILL,developId=2042},--grade4
    {equipId=TppEquip.EQP_WP_East_sm_043,isNoKill=true,developedEquipType=MbsDevelopedEquipType.SM_2040_NOKILL,developId=2041},--grade3
    {equipId=TppEquip.EQP_WP_East_sm_042,isNoKill=true,developedEquipType=MbsDevelopedEquipType.SM_2040_NOKILL,developId=2040},--grade2
    {equipId=TppEquip.EQP_WP_West_sm_017,developedEquipType=MbsDevelopedEquipType.SM_2014,developId=2014},--grade7
    {equipId=TppEquip.EQP_WP_West_sm_016,developedEquipType=MbsDevelopedEquipType.SM_2010,developId=2013},--grade6
    {equipId=TppEquip.EQP_WP_West_sm_015,developedEquipType=MbsDevelopedEquipType.SM_2010,developId=2012},--grade5
    {equipId=TppEquip.EQP_WP_West_sm_014,developedEquipType=MbsDevelopedEquipType.SM_2010,developId=2011},--grade4
    {equipId=TppEquip.EQP_WP_West_sm_010,developedEquipType=MbsDevelopedEquipType.SM_2010,developId=2010}--grade3
  },
  SHOTGUN={
    {equipId=TppEquip.EQP_WP_Com_sg_038,isNoKill=true,developedEquipType=MbsDevelopedEquipType.SG_4027_NOKILL,developId=4028},--grade8
    {equipId=TppEquip.EQP_WP_Com_sg_030,isNoKill=true,developedEquipType=MbsDevelopedEquipType.SG_4027_NOKILL,developId=4027},--grade7
    {equipId=TppEquip.EQP_WP_Com_sg_025,isNoKill=true,developedEquipType=MbsDevelopedEquipType.SG_4035_NOKILL,developId=4037},--grade5
    {equipId=TppEquip.EQP_WP_Com_sg_024,isNoKill=true,developedEquipType=MbsDevelopedEquipType.SG_4035_NOKILL,developId=4036},--grade4
    {equipId=TppEquip.EQP_WP_Com_sg_023,isNoKill=true,developedEquipType=MbsDevelopedEquipType.SG_4035_NOKILL,developId=4035},--grade3
    {equipId=TppEquip.EQP_WP_Com_sg_018,developedEquipType=MbsDevelopedEquipType.SG_4040,developId=4044},--grade8
    {equipId=TppEquip.EQP_WP_Com_sg_016,developedEquipType=MbsDevelopedEquipType.SG_4040,developId=4043},--grade6
    {equipId=TppEquip.EQP_WP_Com_sg_015,developedEquipType=MbsDevelopedEquipType.SG_4040,developId=4042},--grade5
    {equipId=TppEquip.EQP_WP_Com_sg_020,developedEquipType=MbsDevelopedEquipType.SG_4040,developId=4041},--grade4
    {equipId=TppEquip.EQP_WP_Com_sg_013,developedEquipType=MbsDevelopedEquipType.SG_4040,developId=4040},--grade3
    {equipId=TppEquip.EQP_WP_Com_sg_011,developedEquipType=MbsDevelopedEquipType.SG_4020,developId=4020}--grade2
  },
  ASSAULT={
    {equipId=TppEquip.EQP_WP_West_ar_077,isNoKill=true,developedEquipType=MbsDevelopedEquipType.AR_3060_NOKILL,developId=3064},--grade7
    {equipId=TppEquip.EQP_WP_West_ar_075,isNoKill=true,developedEquipType=MbsDevelopedEquipType.AR_3060_NOKILL,developId=3063},--grade5
    {equipId=TppEquip.EQP_WP_West_ar_070,isNoKill=true,developedEquipType=MbsDevelopedEquipType.AR_3060_NOKILL,developId=3062},--grade4
    {equipId=TppEquip.EQP_WP_West_ar_063,isNoKill=true,developedEquipType=MbsDevelopedEquipType.AR_3060_NOKILL,developId=3061},--grade3
    {equipId=TppEquip.EQP_WP_West_ar_060,isNoKill=true,developedEquipType=MbsDevelopedEquipType.AR_3060_NOKILL,developId=3060},--grade2
    {equipId=TppEquip.EQP_WP_West_ar_057,developedEquipType=MbsDevelopedEquipType.AR_3036,developId=3042},--grade7
    {equipId=TppEquip.EQP_WP_West_ar_050,developedEquipType=MbsDevelopedEquipType.AR_3036,developId=3038},--grade5
    {equipId=TppEquip.EQP_WP_West_ar_055,developedEquipType=MbsDevelopedEquipType.AR_3036,developId=3037},--grade4
    {equipId=TppEquip.EQP_WP_West_ar_010,developedEquipType=MbsDevelopedEquipType.AR_3036,developId=3036},--grade3
    {equipId=TppEquip.EQP_WP_West_ar_042,developedEquipType=MbsDevelopedEquipType.AR_3030,developId=3031},--grade2
    {equipId=TppEquip.EQP_WP_West_ar_040}
  },
  SNIPER={
    {equipId=TppEquip.EQP_WP_West_sr_048,isNoKill=true,developedEquipType=MbsDevelopedEquipType.SR_6037_NOKILL,developId=6039},--grade8
    {equipId=TppEquip.EQP_WP_West_sr_047,isNoKill=true,developedEquipType=MbsDevelopedEquipType.SR_6037_NOKILL,developId=6038},--grade7
    {equipId=TppEquip.EQP_WP_West_sr_037,isNoKill=true,developedEquipType=MbsDevelopedEquipType.SR_6037_NOKILL,developId=6037},--grade5
    {equipId=TppEquip.EQP_WP_East_sr_034,isNoKill=true,developedEquipType=MbsDevelopedEquipType.SR_6005_NOKILL,developId=6006},--grade4
    {equipId=TppEquip.EQP_WP_East_sr_033,isNoKill=true,developedEquipType=MbsDevelopedEquipType.SR_6005_NOKILL,developId=6008},--grade3
    {equipId=TppEquip.EQP_WP_East_sr_032,isNoKill=true,developedEquipType=MbsDevelopedEquipType.SR_6005_NOKILL,developId=6005},--grade2
    {equipId=TppEquip.EQP_WP_West_sr_027,developedEquipType=MbsDevelopedEquipType.SR_6030,developId=6033},--grade7
    {equipId=TppEquip.EQP_WP_West_sr_020,developedEquipType=MbsDevelopedEquipType.SR_6030,developId=6032},--grade5
    {equipId=TppEquip.EQP_WP_West_sr_014,developedEquipType=MbsDevelopedEquipType.SR_6030,developId=6031},--grade4
    {equipId=TppEquip.EQP_WP_West_sr_013,developedEquipType=MbsDevelopedEquipType.SR_6030,developId=6030},--grade3
    {equipId=TppEquip.EQP_WP_West_sr_011,developedEquipType=MbsDevelopedEquipType.SR_6010,developId=6010}--grade2
  },
  MG={
    {equipId=TppEquip.EQP_WP_West_mg_037,developedEquipType=MbsDevelopedEquipType.MG_7000,developId=7004},--grade7
    {equipId=TppEquip.EQP_WP_West_mg_030,developedEquipType=MbsDevelopedEquipType.MG_7000,developId=7003},--grad5
    {equipId=TppEquip.EQP_WP_West_mg_024,developedEquipType=MbsDevelopedEquipType.MG_7000,developId=7002},--grade4
    {equipId=TppEquip.EQP_WP_West_mg_023,developedEquipType=MbsDevelopedEquipType.MG_7000,developId=7001},--grade3
    {equipId=TppEquip.EQP_WP_West_mg_020,developedEquipType=MbsDevelopedEquipType.MG_7000,developId=7e3}--grade2
  },
  MISSILE={
    {equipId=TppEquip.EQP_WP_West_ms_020,isNoKill=true,developedEquipType=MbsDevelopedEquipType.MS_8013_NOKILL,developId=8013},--grade7
    {equipId=TppEquip.EQP_WP_Com_ms_026,developedEquipType=MbsDevelopedEquipType.MS_8020,developId=8023},--grade6
    {equipId=TppEquip.EQP_WP_Com_ms_020,developedEquipType=MbsDevelopedEquipType.MS_8020,developId=8022},--grade5
    {equipId=TppEquip.EQP_WP_Com_ms_024,developedEquipType=MbsDevelopedEquipType.MS_8020,developId=8021},--grade4
    {equipId=TppEquip.EQP_WP_Com_ms_023,developedEquipType=MbsDevelopedEquipType.MS_8020,developId=8020}--grade3
  },
  SHIELD={
    {equipId=TppEquip.EQP_SLD_DD,developedEquipType=MbsDevelopedEquipType.SD_9000,developId=9e3}--grade2
  },
  GRENADE={
    {equipId=TppEquip.EQP_SWP_Grenade_G05,developedEquipType=MbsDevelopedEquipType.GRENADE,developId=10045},--grade8
    {equipId=TppEquip.EQP_SWP_Grenade_G04,developedEquipType=MbsDevelopedEquipType.GRENADE,developId=10044},--grade5
    {equipId=TppEquip.EQP_SWP_Grenade_G03,developedEquipType=MbsDevelopedEquipType.GRENADE,developId=10043},--grade4
    {equipId=TppEquip.EQP_SWP_Grenade_G02,developedEquipType=MbsDevelopedEquipType.GRENADE,developId=10042},--grade3
    {equipId=TppEquip.EQP_SWP_Grenade_G01,developedEquipType=MbsDevelopedEquipType.GRENADE,developId=10041},--grade2
    {equipId=TppEquip.EQP_SWP_Grenade}
  },
  STUN_GRENADE={
    {equipId=TppEquip.EQP_SWP_StunGrenade_G03,isNoKill=true,developedEquipType=MbsDevelopedEquipType.STUN_GRENADE,developId=10063},--grade8
    {equipId=TppEquip.EQP_SWP_StunGrenade_G02,isNoKill=true,developedEquipType=MbsDevelopedEquipType.STUN_GRENADE,developId=10062},--grade5
    {equipId=TppEquip.EQP_SWP_StunGrenade_G01,isNoKill=true,developedEquipType=MbsDevelopedEquipType.STUN_GRENADE,developId=10061},--grade4
    {equipId=TppEquip.EQP_SWP_StunGrenade,isNoKill=true,developedEquipType=MbsDevelopedEquipType.STUN_GRENADE,developId=10060}--grade3
  },
  SNEAKING_SUIT={
    {equipId=6,isNoKill=true,developedEquipType=MbsDevelopedEquipType.SNEAKING_SUIT,developId=19042},--grade8 --RETAILPATCH: 1060 added>
    {equipId=5,isNoKill=true,developedEquipType=MbsDevelopedEquipType.SNEAKING_SUIT,developId=19057},--grade7
    {equipId=4,isNoKill=true,developedEquipType=MbsDevelopedEquipType.SNEAKING_SUIT,developId=19056},--grade6--<
    {equipId=3,isNoKill=true,developedEquipType=MbsDevelopedEquipType.SNEAKING_SUIT,developId=19052},--grade4
    {equipId=2,isNoKill=true,developedEquipType=MbsDevelopedEquipType.SNEAKING_SUIT,developId=19051},--grade3
    {equipId=1,isNoKill=true,developedEquipType=MbsDevelopedEquipType.SNEAKING_SUIT,developId=19050}--grade2
  },
  BATTLE_DRESS={
    {equipId=6,developedEquipType=MbsDevelopedEquipType.BATTLE_DRESS,developId=19043},--grade8--RETAILPATCH: 1060 added>
    {equipId=5,developedEquipType=MbsDevelopedEquipType.BATTLE_DRESS,developId=19059},--grade7
    {equipId=4,developedEquipType=MbsDevelopedEquipType.BATTLE_DRESS,developId=19058},--grade6<
    {equipId=3,developedEquipType=MbsDevelopedEquipType.BATTLE_DRESS,developId=19055},--grade5
    {equipId=2,developedEquipType=MbsDevelopedEquipType.BATTLE_DRESS,developId=19054},--grade4
    {equipId=1,developedEquipType=MbsDevelopedEquipType.BATTLE_DRESS,developId=19053}--grade3
  }
}
do
  this.ROUTE_SET_TYPETAG[StrCode32"day"]="day"
  this.ROUTE_SET_TYPETAG[StrCode32"night"]="night"
  this.ROUTE_SET_TYPETAG[StrCode32"caution"]="caution"
  this.ROUTE_SET_TYPETAG[StrCode32"hold"]="hold"
  this.ROUTE_SET_TYPETAG[StrCode32"travel"]="travel"
  this.ROUTE_SET_TYPETAG[StrCode32"new"]="new"
  this.ROUTE_SET_TYPETAG[StrCode32"old"]="old"
  this.ROUTE_SET_TYPETAG[StrCode32"midnight"]="midnight"
  this.ROUTE_SET_TYPETAG[StrCode32"sleep"]="sleep"
end
this.DEFAULT_HOLD_TIME=60
this.DEFAULT_TRAVEL_HOLD_TIME=15
this.DEFAULT_SLEEP_TIME=300
this.FOB_DD_SUIT_ATTCKER=1
this.FOB_DD_SUIT_SNEAKING=2
this.FOB_DD_SUIT_BTRDRS=3
this.FOB_PF_SUIT_ARMOR=4
function this._ConvertSoldierNameKeysToId(soldierTypes)
  local soldierNames={}
  local soldierTypesCopy={}
  Tpp.MergeTable(soldierTypesCopy,soldierTypes)
  for soldierName,soldierType in pairs(soldierTypesCopy)do
    if IsTypeString(soldierName)then
      local soldierId=GetGameObjectId("TppSoldier2",soldierName)
      if soldierId~=NULL_ID then
        table.insert(soldierNames,soldierName)
        soldierTypes[soldierId]=soldierType
      end
    end
  end
  for t,soldierName in ipairs(soldierNames)do
    soldierTypes[soldierName]=nil
  end
end
function this._SetUpSoldierTypes(soldierType,soldierIds)
  for a,soldierId in ipairs(soldierIds)do
    if IsTypeTable(soldierId)then
      this._SetUpSoldierTypes(soldierType,soldierId)
    else
      mvars.ene_soldierTypes[soldierId]=EnemyType["TYPE_"..soldierType]
    end
  end
end
function this.SetUpSoldierTypes(soldierTypes)
  for subTypes,soldierNames in pairs(soldierTypes)do
    this._SetUpSoldierTypes(subTypes,soldierNames)
  end
end
function this._SetUpSoldierSubTypes(subTypes,soldierNames)
  for a,soldierName in ipairs(soldierNames)do
    if IsTypeTable(soldierName)then
      this._SetUpSoldierSubTypes(subTypes,soldierName)
    else
      local soldierId=GetGameObjectId("TppSoldier2",soldierName)
      mvars.ene_soldierSubType[soldierId]=subTypes
    end
  end
end
function this.SetUpSoldierSubTypes(soldierSubTypes)
  for subTypes,soldierName in pairs(soldierSubTypes)do
    this._SetUpSoldierSubTypes(subTypes,soldierName)
  end
end
function this.SetUpPowerSettings(soldierPowerSettings)-- ==missionTable.enemy.soldierPowerSettings { soldierName={powerSetting...}...}
  mvars.ene_missionSoldierPowerSettings=soldierPowerSettings
  local missionRequireSettings={}
  for t,powerSettings in pairs(soldierPowerSettings)do
    for e,t in pairs(powerSettings)do
      local powerType=e
      if Tpp.IsTypeNumber(powerType)then
        powerType=t
      end
      missionRequireSettings[powerType]=true
    end
  end
  mvars.ene_missionRequiresPowerSettings=missionRequireSettings
end
function this.ApplyPowerSettingsOnInitialize()
  local missionSoldierPowerSettings=mvars.ene_missionSoldierPowerSettings
  for soldierName,powerSetting in pairs(missionSoldierPowerSettings)do
    local soldierId=GetGameObjectId(soldierName)
    if soldierId==NULL_ID then
    else
      this.ApplyPowerSetting(soldierId,powerSetting)
    end
  end
end
function this.DisablePowerSettings(loadout)
  local baseLoadout={ASSAULT=true,HANDGUN=true}
  mvars.ene_disablePowerSettings={}
  for t,category in ipairs(loadout)do
    if baseLoadout[category]then
    else
      mvars.ene_disablePowerSettings[category]=true
    end
  end
  if mvars.ene_disablePowerSettings.SMG then
    mvars.ene_disablePowerSettings.MISSILE=true
    mvars.ene_disablePowerSettings.SHIELD=true
  end
end
function this.SetUpPersonalAbilitySettings(settings)
  mvars.ene_missionSoldierPersonalAbilitySettings=settings
end
function this.ApplyPersonalAbilitySettingsOnInitialize()
  local abilitySettings=mvars.ene_missionSoldierPersonalAbilitySettings
  for soldierName,soldierAbilitySettings in pairs(abilitySettings)do
    local soldierId=GetGameObjectId(soldierName)
    if soldierId==NULL_ID then
    else
      this.ApplyPersonalAbilitySettings(soldierId,soldierAbilitySettings)
    end
  end
end
function this.SetSoldierType(soldierId,soldierType)
  mvars.ene_soldierTypes[soldierId]=soldierType
  GameObject.SendCommand(soldierId,{id="SetSoldier2Type",type=soldierType})
end

function this.GetSoldierType(soldierId)--tex> now pulls type for subtype> ORIG is below
  local soldierType = this._GetSoldierType(soldierId)

  --InfMenu.DebugPrint(Time.GetRawElapsedTimeSinceStartUp().." GetSoldierType Caller: " .. debug.getinfo(2).name.. " ".. debug.getinfo(2).source)
  if InfMain.IsForceSoldierSubType() then--tex WIP:
    --InfMenu.DebugPrint("GetSoldierType soldierTypeForced")--DEBUNOW
    local subType = this.GetSoldierSubType(soldierId,soldierType)
    local typeForSubType=InfMain.soldierTypeForSubtypes[subType]
    if typeForSubType~=soldierType then
      --InfMenu.DebugPrint("GetSoldierType for id: ".. soldierId .." ".. soldierType .." ~= "..typeForSubType .." of "..subType)
      if soldierId~=nil then
        mvars.ene_soldierTypes=mvars.ene_soldierTypes or {}
        mvars.ene_soldierTypes[soldierId]=soldierType
      end
      return typeForSubType
    end
  end

  if InfMain.IsDDBodyEquip(vars.missionCode) then
    local isFemale=GameObject.SendCommand(soldierId,{id="isFemale"})
    local bodyInfo=InfMain.GetCurrentDDBodyInfo(isFemale)
    if bodyInfo and bodyInfo.soldierSubType then
      return InfMain.soldierTypeForSubtypes[bodyInfo.soldierSubType]
    end
  end

  return soldierType
end--<
function this._GetSoldierType(soldierId)--tex was GetSoldierType
  local missionCode=TppMission.GetMissionID()
  if soldierId==nil or soldierId==NULL_ID then
    if missionCode==10080 or missionCode==11080 then
      return EnemyType.TYPE_PF
    end
    --NMC: used for quest enemies and a few story missions
    for n,soldierType in pairs(mvars.ene_soldierTypes)do
      if soldierType then
        return soldierType--NMC: no soliderid so just default to first type
      end
    end
  else
    --NMC: used for quest enemies and a few story missions
    if mvars.ene_soldierTypes then
      local soldierType=mvars.ene_soldierTypes[soldierId]
      if soldierType then
        return soldierType
      end
    end
  end

  if(missionCode==10150 or missionCode==10151)or missionCode==11151 then
    return EnemyType.TYPE_SKULL
  end
  local soldierType=EnemyType.TYPE_SOVIET
  if TppLocation.IsAfghan()then
    soldierType=EnemyType.TYPE_SOVIET
  elseif TppLocation.IsMiddleAfrica()then
    soldierType=EnemyType.TYPE_PF
  elseif TppLocation.IsMotherBase()or TppLocation.IsMBQF()then
    soldierType=EnemyType.TYPE_DD
  elseif TppLocation.IsCyprus()then
    soldierType=EnemyType.TYPE_SKULL
  end
  return soldierType
end
function this.SetSoldierSubType(soldierId,subType)
  mvars.ene_soldierSubType[soldierId]=subType
end
function this.GetSoldierSubType(soldierId,soldierType)
  if InfMain.IsForceSoldierSubType() then--tex WIP>
    local soldierType=GameObject.SendCommand(soldierId,{id="GetSoldier2Type"})
    return InfMain.enemySubTypes[gvars.forceSoldierSubType]
  end--<
  if InfMain.IsDDBodyEquip(vars.missionCode) then--tex>
    local isFemale=GameObject.SendCommand(soldierId,{id="isFemale"})
    local bodyInfo=InfMain.GetCurrentDDBodyInfo(isFemale)
    if bodyInfo and bodyInfo.soldierSubType then
      return bodyInfo.soldierSubType
    else
      return "DD_FOB"
    end
  end--<

  local missionCode=TppMission.GetMissionID()
  if missionCode==10115 or missionCode==11115 then
    return"DD_PW"
  end

  if TppMission.IsFOBMission(missionCode)or (missionCode==30050 and (InfMain.IsDDEquip(missionCode) or InfMain.IsDDBodyEquip(missionCode))) then--tex added ismbplay
    return"DD_FOB"
  end
  local soldierSubType=nil
  if mvars.ene_soldierSubType then
    soldierSubType=mvars.ene_soldierSubType[soldierId]
  end
  if soldierSubType==nil then
    soldierSubType=this.GetDefaultSoldierSubType(soldierType)
  end
  return soldierSubType
end
function this.GetCpSubType(cpId)
  if mvars.ene_soldierIDList then
    local soldierIdList=mvars.ene_soldierIDList[cpId]
    if soldierIdList~=nil then
      for soldierId,t in pairs(soldierIdList)do
        return this.GetSoldierSubType(soldierId)
      end
    end
  end
  if mvars.ene_cpList then
    local cp=mvars.ene_cpList[cpId]
    local cpSubType=this.subTypeOfCp[cp]
    if cpSubType~=nil then
      return cpSubType
    end
  end
  return this.GetSoldierSubType(nil)
end
function this.GetDefaultSoldierSubType(soldierType)
  if soldierType==nil then
    soldierType=this.GetSoldierType(nil)
  end
  if TppLocation.IsCyprus()then
    return"SKULL_CYPR"
  end
  if soldierType==EnemyType.TYPE_SOVIET then
    return"SOVIET_A"
  elseif soldierType==EnemyType.TYPE_PF then
    return"PF_A"
  elseif soldierType==EnemyType.TYPE_DD then
    return"DD_A"
  elseif soldierType==EnemyType.TYPE_SKULL then
    return"SKULL_AFGH"
  elseif soldierType==EnemyType.TYPE_CHILD then
    return"CHILD_A"
  else
    return"SOVIET_A"
  end
  return nil
end
function this._CreateDDWeaponIdTable(developedEquipGradeTable,soldierEquipGrade,isNoKillMode)
  local ddWeaponIdTable={NORMAL={}}
  local ddWeaponNormalTable=ddWeaponIdTable.NORMAL
  mvars.ene_ddWeaponCount=0
  ddWeaponNormalTable.IS_NOKILL={}
  local DDWeaponIdInfo=this.DDWeaponIdInfo
  for powerType,weaponInfo in pairs(DDWeaponIdInfo)do
    for n,value in ipairs(weaponInfo)do
      local addWeapon=false
      local developedEquipType=value.developedEquipType
      --      local developId=value.developId--tex DEBUG-->
      --      local developRank=TppMotherBaseManagement.GetEquipDevelopRank(developId)
      --      local developedGrade=developedEquipGradeTable[developedEquipType]
      --      if value.isNoKill~=true then
      --        InfMenu.DebugPrint("_CreateDDWeaponIdTable developId:"..tostring(developId).." developrank:"..tostring(developRank).." developedGrade:"..tostring(developedGrade).." soldierEquipGrade:"..tostring(soldierEquipGrade))--tex DEBUG: CULL:
      --      end--<

      if developedEquipType==nil then
        addWeapon=true
      elseif value.isNoKill and not isNoKillMode then
        addWeapon=false
      else
        local developId=value.developId
        local developRank=TppMotherBaseManagement.GetEquipDevelopRank(developId)

        local overrideDeveloped=false--tex>
        if InfMain.IsDDEquip() and Ivars.allowUndevelopedDDEquip:Is(0) then        
          --tex WORKAROUND developedEquipGradeTable is zeroed if mission is not motherbase
          if TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=developId} then
            overrideDeveloped=true
          end
        else
          overrideDeveloped=true
        end--<

        if(soldierEquipGrade>=developRank and (developedEquipGradeTable[developedEquipType]>=developRank or overrideDeveloped))then--tex added override
          addWeapon=true
        end
      end
      if addWeapon then
        mvars.ene_ddWeaponCount=mvars.ene_ddWeaponCount+1
        if ddWeaponNormalTable[powerType]then
        else
          ddWeaponNormalTable[powerType]=value.equipId
          if value.isNoKill then
            ddWeaponNormalTable.IS_NOKILL[powerType]=true
          end
        end
      end
    end
  end
  --  local ins=InfInspect.Inspect(ddWeaponIdTable)--tex DEBUG
  --  InfMenu.DebugPrint(ins)--<
  return ddWeaponIdTable
end
function this.GetDDWeaponCount()
  return mvars.ene_ddWeaponCount
end
function this.ClearDDParameter()
  this.weaponIdTable.DD=nil
end
function this.PrepareDDParameter(soldierEquipGrade,isNoKillMode)
  if TppMotherBaseManagement.GetMbsDevelopedEquipGradeTable==nil then
    this.weaponIdTable.DD={NORMAL={HANDGUN=TppEquip.EQP_WP_West_hg_010,ASSAULT=TppEquip.EQP_WP_West_ar_040}}
    return
  end

  local developedGradeTable=TppMotherBaseManagement.GetMbsDevelopedEquipGradeTable()
  soldierEquipGrade=soldierEquipGrade or 9999
  if gvars.ini_isTitleMode then
    this.ClearDDParameter()
  end
  if this.weaponIdTable.DD~=nil and not InfMain.IsDDEquip() then--tex rebuild if playtime cause we fsk wih soldiergrade TODO: call _CreateDDWeaponIdTable from equipgrade ivar
  else
    this.weaponIdTable.DD=this._CreateDDWeaponIdTable(developedGradeTable,soldierEquipGrade,isNoKillMode)
  end

  -- InfMenu.DebugPrint("PrepareDDParameter weaponIdTable.DD")--tex DEBUG
  -- local dd = this.weaponIdTable.DD
  -- local inss = InfInspect.Inspect(dd)
  -- InfMenu.DebugPrint(inss)--<
  local fultonGrade=developedGradeTable[MbsDevelopedEquipType.FULTON_16001]
  local wormholeGrade=developedGradeTable[MbsDevelopedEquipType.FULTON_16008]
  if fultonGrade>soldierEquipGrade then
    fultonGrade=soldierEquipGrade
  end
  if wormholeGrade>soldierEquipGrade then
    wormholeGrade=soldierEquipGrade
  end
  local fultonLevel=0
  if fultonGrade>=4 then
    fultonLevel=3
  elseif fultonGrade>=3 then
    fultonLevel=2
  elseif fultonGrade>=1 then
    fultonLevel=1
  end
  local wormholeLevel=false
  if wormholeGrade~=0 then
    wormholeLevel=true
  end
  this.weaponIdTable.DD.NORMAL.FULTON_LV=fultonLevel
  this.weaponIdTable.DD.NORMAL.WORMHOLE_FULTON=wormholeLevel
end
function this.SetUpDDParameter()
  if not GameObject.DoesGameObjectExistWithTypeName"TppSoldier2"then
    return
  end
  local typeCp={type="TppCommandPost2"}
  local command={id="SetFultonLevel",fultonLevel=this.weaponIdTable.DD.NORMAL.FULTON_LV,isWormHole=this.weaponIdTable.DD.NORMAL.WORMHOLE_FULTON}
  GameObject.SendCommand(typeCp,command)
  if(this.weaponIdTable.DD.NORMAL.SNEAKING_SUIT and this.weaponIdTable.DD.NORMAL.SNEAKING_SUIT>=3)
    or(this.weaponIdTable.DD.NORMAL.BATTLE_DRESS and this.weaponIdTable.DD.NORMAL.BATTLE_DRESS>=3)then
    if vars.missionCode~=30050 then--tex added check to stop this from interfering with player settings
      TppRevenge.SetHelmetAll()
    end
  end
  local grenadeId=this.weaponIdTable.DD.NORMAL.GRENADE or TppEquip.EQP_SWP_Grenade
  local stunId=this.weaponIdTable.DD.NORMAL.STUN_GRENADE or TppEquip.EQP_None
  GameObject.SendCommand({type="TppSoldier2"},{id="RegistGrenadeId",grenadeId=grenadeId,stunId=stunId})
end
function this.GetWeaponIdTable(soldierType,soldierSubType)
  --ORPHAN local n={}
  local weaponIdTable={}

  if InfMain.IsDDEquip() then--tex>
    return this.weaponIdTable.DD
  end--<
  if soldierSubType=="SOVIET_WILDCARD" or soldierSubType=="PF_WILDCARD"then--tex>
    return this.weaponIdTable.WILDCARD
  end--<

  if soldierType==EnemyType.TYPE_SOVIET then
    weaponIdTable=this.weaponIdTable.SOVIET_A
  elseif soldierType==EnemyType.TYPE_PF then
    weaponIdTable=this.weaponIdTable.PF_A
    if soldierSubType=="PF_B"then
      weaponIdTable=this.weaponIdTable.PF_B
    elseif soldierSubType=="PF_C"then
      weaponIdTable=this.weaponIdTable.PF_C
    end
  elseif soldierType==EnemyType.TYPE_DD then
    weaponIdTable=this.weaponIdTable.DD
  elseif soldierType==EnemyType.TYPE_SKULL then
    if soldierSubType=="SKULL_CYPR"then
      weaponIdTable=this.weaponIdTable.SKULL_CYPR
    else
      weaponIdTable=this.weaponIdTable.SKULL
    end
  elseif soldierType==EnemyType.TYPE_CHILD then
    weaponIdTable=this.weaponIdTable.CHILD
  else
    weaponIdTable=this.weaponIdTable.SOVIET_A
  end
  return weaponIdTable
end
function this.GetWeaponId(soldierId,config)
  local primary,secondary,tertiary
  local soldierType=this.GetSoldierType(soldierId)
  local soldierSubType=this.GetSoldierSubType(soldierId,soldierType)
  local missionCode=TppMission.GetMissionID()
  if(missionCode==10080 or missionCode==11080)and soldierType==EnemyType.TYPE_CHILD then
    return TppEquip.EQP_WP_Wood_ar_010,TppEquip.EQP_WP_West_hg_010,nil
  end
  local weaponIdTableFull=this.GetWeaponIdTable(soldierType,soldierSubType)
  if weaponIdTableFull==nil then
    return nil,nil,nil
  end
  local weaponIdTable={}
  if TppRevenge.IsUsingStrongWeapon()and weaponIdTableFull.STRONG then
    weaponIdTable=weaponIdTableFull.STRONG
  else
    weaponIdTable=weaponIdTableFull.NORMAL
  end
  tertiary=TppEquip.EQP_None
  secondary=weaponIdTable.HANDGUN
  local sniperIdTable={}
  if TppRevenge.IsUsingStrongSniper()and weaponIdTableFull.STRONG then
    sniperIdTable=weaponIdTableFull.STRONG
  else
    sniperIdTable=weaponIdTableFull.NORMAL
  end
  local missileIdTable={}
  if TppRevenge.IsUsingStrongMissile()and weaponIdTableFull.STRONG then
    missileIdTable=weaponIdTableFull.STRONG
  else
    missileIdTable=weaponIdTableFull.NORMAL
  end

  if config.SNIPER and sniperIdTable.SNIPER then
    primary=sniperIdTable.SNIPER
  elseif config.SHOTGUN and weaponIdTable.SHOTGUN then
    primary=weaponIdTable.SHOTGUN
  elseif config.MG and weaponIdTable.MG then
    primary=weaponIdTable.MG
  elseif config.SMG and weaponIdTable.SMG then
    primary=weaponIdTable.SMG
  else
    primary=weaponIdTable.ASSAULT
  end
  if config.SHIELD and weaponIdTable.SHIELD then
    tertiary=weaponIdTable.SHIELD
  elseif config.MISSILE and missileIdTable.MISSILE then
    tertiary=missileIdTable.MISSILE
  end
  if config.GUN_LIGHT then
    local gunWithLight=this.gunLightWeaponIds[primary]
    primary=gunWithLight or primary
  end
  return primary,secondary,tertiary
end
function this.GetBodyId(soldierId,soldierType,soldierSubType,soldierPowerSettings)
  local bodyId
  local bodyIdTable={}
  --InfMenu.DebugPrint("DBG:GetBodyId soldier:"..soldierId.." soldiertype:"..soldierType.." soldierSubType:"..soldierSubType)--tex DEBUG
  --tex>

  --<

  if soldierType==EnemyType.TYPE_SOVIET then
    bodyIdTable=this.bodyIdTable.SOVIET_A
    if soldierSubType=="SOVIET_B"then
      bodyIdTable=this.bodyIdTable.SOVIET_B
    end
    if soldierSubType=="SOVIET_WILDCARD" then--tex>
      bodyIdTable=this.bodyIdTable.SOVIET_WILDCARD
    end--<
  elseif soldierType==EnemyType.TYPE_PF then
    bodyIdTable=this.bodyIdTable.PF_A
    if soldierSubType=="PF_B"then
      bodyIdTable=this.bodyIdTable.PF_B
    elseif soldierSubType=="PF_C"then
      bodyIdTable=this.bodyIdTable.PF_C
    end
    if soldierSubType=="PF_WILDCARD" then--tex>
      bodyIdTable=this.bodyIdTable.PF_WILDCARD
    end--<
  elseif soldierType==EnemyType.TYPE_DD then
    bodyIdTable=this.bodyIdTable.DD_A
    if soldierSubType=="DD_FOB"then
      bodyIdTable=this.bodyIdTable.DD_FOB
    elseif soldierSubType=="DD_PW"then
      bodyIdTable=this.bodyIdTable.DD_PW
    end
  elseif soldierType==EnemyType.TYPE_SKULL then
    if this.bodyIdTable[soldierSubType]then
      bodyIdTable=this.bodyIdTable[soldierSubType]
    else
      bodyIdTable=this.bodyIdTable.SKULL_AFGH
    end
  elseif soldierType==EnemyType.TYPE_CHILD then
    bodyIdTable=this.bodyIdTable.CHILD
  else
    bodyIdTable=this.bodyIdTable.SOVIET_A
  end
  if bodyIdTable==nil then
    return nil
  end

  local _GetBodyId=function(selection,loadoutBodies)
    if#loadoutBodies==0 then
      return loadoutBodies[1]
    end
    return loadoutBodies[(selection%#loadoutBodies)+1]--NMC: looks like it uses the solider id to 'randomly'(ie each solider id is uniqe) choose (assuming theres multiple bodies in the input list)
  end

  if soldierPowerSettings.ARMOR and bodyIdTable.ARMOR then
    return _GetBodyId(soldierId,bodyIdTable.ARMOR)
  end
  if(mvars.ene_soldierLrrp[soldierId]or soldierPowerSettings.RADIO)and bodyIdTable.RADIO then
    return _GetBodyId(soldierId,bodyIdTable.RADIO)
  end
  if soldierPowerSettings.MISSILE and bodyIdTable.MISSILE then
    return _GetBodyId(soldierId,bodyIdTable.MISSILE)
  end
  if soldierPowerSettings.SHIELD and bodyIdTable.SHIELD then
    return _GetBodyId(soldierId,bodyIdTable.SHIELD)
  end
  if soldierPowerSettings.SNIPER and bodyIdTable.SNIPER then
    bodyId=_GetBodyId(soldierId,bodyIdTable.SNIPER)
  elseif soldierPowerSettings.SHOTGUN and bodyIdTable.SHOTGUN then
    if soldierPowerSettings.OB and bodyIdTable.SHOTGUN_OB then
      bodyId=_GetBodyId(soldierId,bodyIdTable.SHOTGUN_OB)
    else
      bodyId=_GetBodyId(soldierId,bodyIdTable.SHOTGUN)
    end
  elseif soldierPowerSettings.MG and bodyIdTable.MG then
    if soldierPowerSettings.OB and bodyIdTable.MG_OB then
      bodyId=_GetBodyId(soldierId,bodyIdTable.MG_OB)
    else
      bodyId=_GetBodyId(soldierId,bodyIdTable.MG)
    end
  elseif bodyIdTable.ASSAULT then
    if soldierPowerSettings.OB and bodyIdTable.ASSAULT_OB then
      bodyId=_GetBodyId(soldierId,bodyIdTable.ASSAULT_OB)
    else
      bodyId=_GetBodyId(soldierId,bodyIdTable.ASSAULT)
    end
  end
  --InfMenu.DebugPrint("DBG:GetBodyId soldier:"..soldierId.." soldiertype:"..soldierType.." soldierSubType:"..soldierSubType.. " bodyId:".. tostring(bodyId))--tex DEBUG
  return bodyId
end
function this.GetFaceId(n,enemyType,n,n)
  if enemyType==EnemyType.TYPE_SKULL then
    return EnemyFova.INVALID_FOVA_VALUE
  elseif enemyType==EnemyType.TYPE_DD then
    return EnemyFova.INVALID_FOVA_VALUE
  elseif enemyType==EnemyType.TYPE_CHILD then
    return 630
  end
  return nil
end
function this.GetBalaclavaFaceId(t,enemyType,t,config)
  if enemyType==EnemyType.TYPE_SKULL then
    return EnemyFova.NOT_USED_FOVA_VALUE
  elseif enemyType==EnemyType.TYPE_DD then
    if config.HELMET then
      return TppEnemyFaceId.dds_balaclava0
    else
      return TppEnemyFaceId.dds_balaclava2
    end
  end
  return nil
end
function this.IsSniper(soldierId)
  local config=mvars.ene_soldierPowerSettings[soldierId]
  if config~=nil and config.SNIPER then
    return true
  end
  return false
end
function this.IsMissile(soldierId)
  local config=mvars.ene_soldierPowerSettings[soldierId]
  if config~=nil and config.MISSILE then
    return true
  end
  return false
end
function this.IsShield(soldierId)
  local config=mvars.ene_soldierPowerSettings[soldierId]
  if config~=nil and config.SHIELD then
    return true
  end
  return false
end
function this.IsArmor(soldierId)
  local config=mvars.ene_soldierPowerSettings[soldierId]
  if config~=nil and config.ARMOR then
    return true
  end
  return false
end
function this.IsHelmet(soldierId)
  local config=mvars.ene_soldierPowerSettings[soldierId]
  if config~=nil and config.HELMET then
    return true
  end
  return false
end
function this.IsNVG(soldierId)
  local config=mvars.ene_soldierPowerSettings[soldierId]
  if config~=nil and config.NVG then
    return true
  end
  return false
end

function this.AddPowerSetting(soldierId,applySettings)
  local powerSettings=mvars.ene_soldierPowerSettings[soldierId]or{}
  for powerType,setting in pairs(applySettings)do
    powerSettings[powerType]=setting
  end
  this.ApplyPowerSetting(soldierId,powerSettings)
end

function this.ApplyPowerSetting(soldierId,powerSettings)
  if soldierId==NULL_ID then
    return
  end
  local soldierType=this.GetSoldierType(soldierId)
  local subTypeName=this.GetSoldierSubType(soldierId,soldierType)
  local powerLoadout={}
  for e,t in pairs(powerSettings)do--NMC: handles input of {"<POWER_TYPE>",...} and {<POWER_TYPE>=<powerSetting>,...}, does not care about actual values of setting in this func, just whether it's set or not
    if Tpp.IsTypeNumber(e)then
      powerLoadout[t]=true
  else
    powerLoadout[e]=t
  end
  end
  local checkLoadedPowers={SMG=true,MG=true,SHOTGUN=true,SNIPER=true,MISSILE=true,SHIELD=true}
  for powerType,t in pairs(checkLoadedPowers)do
    if powerLoadout[powerType]and not mvars.revenge_loadedEquip[powerType]then
      powerLoadout[powerType]=nil
    end
  end
  if soldierType==EnemyType.TYPE_SKULL then
    if subTypeName=="SKULL_CYPR"then
      powerLoadout.SNIPER=nil
      powerLoadout.SHOTGUN=nil
      powerLoadout.MG=nil
      powerLoadout.SMG=true
      powerLoadout.GUN_LIGHT=true
    else
      powerLoadout.HELMET=true
      powerLoadout.SOFT_ARMOR=true
    end
  end
  if powerLoadout.ARMOR and not TppRevenge.CanUseArmor(subTypeName)then
    powerLoadout.ARMOR=nil
  end
  if powerLoadout.QUEST_ARMOR then
    powerLoadout.ARMOR=true
  end

  if powerLoadout.ARMOR then
    powerLoadout.SNIPER=nil
    powerLoadout.SHIELD=nil
    powerLoadout.MISSILE=nil
    powerLoadout.SMG=nil
    if not powerLoadout.SHOTGUN and not powerLoadout.MG then
      if mvars.revenge_loadedEquip.MG then
        powerLoadout.MG=true
      elseif mvars.revenge_loadedEquip.SHOTGUN then
        powerLoadout.SHOTGUN=true
      end
    end
    if powerLoadout.MG then
      powerLoadout.SHOTGUN=nil
    end
    if powerLoadout.SHOTGUN then
      powerLoadout.MG=nil
    end
  end

  --  if powerLoadout.MISSILE or powerLoadout.SHIELD then--ORIG
  --    powerLoadout.SNIPER=nil
  --    powerLoadout.SHOTGUN=nil
  --    powerLoadout.MG=nil
  --    powerLoadout.SMG=true
  --  end
  if powerLoadout.SHIELD then--tex split from missile
    powerLoadout.SNIPER=nil
    powerLoadout.SHOTGUN=nil
    powerLoadout.MG=nil
    powerLoadout.SMG=true
  end
  if powerLoadout.MISSILE then--tex split from shield
    powerLoadout.SNIPER=nil
    powerLoadout.MG=nil
    if not powerLoadout.MISSILE_COMBO then--tex added CONFIG_TYPE to bypass, _ApplyRevengeToCp has control of SMG
      powerLoadout.SHOTGUN=nil
      powerLoadout.SMG=true
    end
  end
  --tex>mbDDHeadGear clear headgear
  if subTypeName=="DD_FOB"then
    if vars.missionCode==30050 and Ivars.mbDDHeadGear:Is(0) then
      powerLoadout.HELMET=nil
      powerLoadout.GAS_MASK=nil
      powerLoadout.NVG=nil
    end
  end --<

  if powerLoadout.GAS_MASK then
    if subTypeName~="DD_FOB"then
      if powerLoadout.HEADGEAR_COMBO then--tex> --gvars.allowHeadGearCombo>0 then--
        powerLoadout.NVG=nil
      else--tex< ORIG-v-
        powerLoadout.HELMET=nil
        powerLoadout.NVG=nil
      end
    end
  end
  if powerLoadout.NVG then
    if subTypeName~="DD_FOB"then
      if powerLoadout.HEADGEAR_COMBO then--tex>
        powerLoadout.GAS_MASK=nil
      else--tex< ORIG-v-
        powerLoadout.HELMET=nil
        powerLoadout.GAS_MASK=nil
      end
    end
  end
  if powerLoadout.HELMET then
    if subTypeName~="DD_FOB"then
      --tex>
      if powerLoadout.HEADGEAR_COMBO then
        if powerLoadout.GAS_MASK and powerLoadout.NVG then
          powerLoadout.NVG=nil
        end
      else--tex< ORIG-v-
        powerLoadout.GAS_MASK=nil
        powerLoadout.NVG=nil
      end
    end
  end
  mvars.ene_soldierPowerSettings[soldierId]=powerLoadout
  powerSettings=powerLoadout
  local wearEquipFlag=0
  local bodyId=this.GetBodyId(soldierId,soldierType,subTypeName,powerSettings)
  local faceId=this.GetFaceId(soldierId,soldierType,subTypeName,powerSettings)
  local balaclavaId=this.GetBalaclavaFaceId(soldierId,soldierType,subTypeName,powerSettings)
  local primaryId,secondaryId,tertiaryId=this.GetWeaponId(soldierId,powerSettings)
  if powerSettings.HELMET then
    wearEquipFlag=wearEquipFlag+WearEquip.HELMET
  end
  if powerSettings.GAS_MASK then
    wearEquipFlag=wearEquipFlag+WearEquip.GAS_MASK
  end
  if powerSettings.NVG then
    wearEquipFlag=wearEquipFlag+WearEquip.NVG
  end
  if powerSettings.SOFT_ARMOR then
    wearEquipFlag=wearEquipFlag+WearEquip.SOFT_ARMOR
  end
  if(primaryId~=nil or secondaryId~=nil)or tertiaryId~=nil then--RETAILBUG secondaryId (was named secondaryWeapon) had no declaration
    GameObject.SendCommand(soldierId,{id="SetEquipId",primary=primaryId,secondary=secondaryId,tertiary=tertiaryId})
  end
  GameObject.SendCommand(soldierId,{id="ChangeFova",bodyId=bodyId,faceId=faceId,balaclavaFaceId=balaclavaId})
  GameObject.SendCommand(soldierId,{id="SetWearEquip",flag=wearEquipFlag})
  local enemySubTypeForSubTypeName={
    SOVIET_A=EnemySubType.SOVIET_A,
    SOVIET_B=EnemySubType.SOVIET_B,
    PF_A=EnemySubType.PF_A,
    PF_B=EnemySubType.PF_B,
    PF_C=EnemySubType.PF_C,
    DD_A=EnemySubType.DD_A,
    DD_FOB=EnemySubType.DD_FOB,
    DD_PW=EnemySubType.DD_PW,
    CHILD_A=EnemySubType.CHILD_A,
    SKULL_AFGH=EnemySubType.SKULL_AFGH,
    SKULL_CYPR=EnemySubType.SKULL_CYPR
  }
  GameObject.SendCommand(soldierId,{id="SetSoldier2SubType",type=enemySubTypeForSubTypeName[subTypeName]})
end
function this.ApplyPersonalAbilitySettings(soldierId,abilitySettings)
  if soldierId==NULL_ID then
    return
  end
  mvars.ene_soldierPersonalAbilitySettings[soldierId]=abilitySettings
  GameObject.SendCommand(soldierId,{id="SetPersonalAbility",ability=abilitySettings})
end
function this.SetOccasionalChatList()
  if not GameObject.DoesGameObjectExistWithTypeName"TppSoldier2"then
    return
  end
  local conversationList={}
  table.insert(conversationList,"USSR_story_04")
  table.insert(conversationList,"USSR_story_05")
  table.insert(conversationList,"USSR_story_06")
  table.insert(conversationList,"USSR_story_07")
  table.insert(conversationList,"USSR_story_08")
  table.insert(conversationList,"USSR_story_15")
  table.insert(conversationList,"USSR_story_16")
  table.insert(conversationList,"USSR_story_17")
  table.insert(conversationList,"USSR_story_18")
  table.insert(conversationList,"USSR_story_19")
  table.insert(conversationList,"PF_story_01")
  table.insert(conversationList,"PF_story_04")
  table.insert(conversationList,"PF_story_05")
  table.insert(conversationList,"PF_story_06")
  table.insert(conversationList,"PF_story_07")
  table.insert(conversationList,"PF_story_08")
  table.insert(conversationList,"PF_story_12")
  table.insert(conversationList,"PF_story_13")
  table.insert(conversationList,"PF_story_14")
  table.insert(conversationList,"PF_story_15")
  table.insert(conversationList,"MB_story_07")
  table.insert(conversationList,"MB_story_08")
  table.insert(conversationList,"MB_story_18")
  table.insert(conversationList,"MB_story_19")
  local n=gvars.str_storySequence
  if n<TppDefine.STORY_SEQUENCE.CLEARD_RESCUE_HUEY then
    table.insert(conversationList,"USSR_story_01")
    table.insert(conversationList,"USSR_story_02")
    table.insert(conversationList,"USSR_story_03")
  end
  if not TppBuddyService.DidObtainBuddyType(BuddyType.QUIET)and not TppStory.IsMissionCleard(10050)then
    table.insert(conversationList,"USSR_story_10")
  end
  if n>=TppDefine.STORY_SEQUENCE.CLEARD_FIND_THE_SECRET_WEAPON then
    table.insert(conversationList,"USSR_story_11")
  end
  if n>=TppDefine.STORY_SEQUENCE.CLEARD_FIND_THE_SECRET_WEAPON and n<TppDefine.STORY_SEQUENCE.CLEARD_RESCUE_HUEY then
    table.insert(conversationList,"USSR_story_12")
    table.insert(conversationList,"USSR_story_13")
  end
  if n>=TppDefine.STORY_SEQUENCE.CLEARD_FIND_THE_SECRET_WEAPON and n<TppDefine.STORY_SEQUENCE.CLEARD_SKULLFACE then
    table.insert(conversationList,"USSR_story_14")
  end
  if n>=TppDefine.STORY_SEQUENCE.CLEARD_DESTROY_THE_FLOW_STATION and n<TppDefine.STORY_SEQUENCE.CLEARD_METALLIC_ARCHAEA then
    table.insert(conversationList,"PF_story_02")
  end
  if n>=TppDefine.STORY_SEQUENCE.CLEARD_DESTROY_THE_FLOW_STATION and n<TppDefine.STORY_SEQUENCE.CLEARD_ELIMINATE_THE_COMMANDER then
    table.insert(conversationList,"PF_story_03")
  end
  if n>=TppDefine.STORY_SEQUENCE.CLEARD_DESTROY_THE_FLOW_STATION and n<TppDefine.STORY_SEQUENCE.CLEARD_SKULLFACE then
    table.insert(conversationList,"PF_story_09")
  end
  if n>=TppDefine.STORY_SEQUENCE.CLEARD_DESTROY_THE_FLOW_STATION and n<TppDefine.STORY_SEQUENCE.CLEARD_CODE_TALKER then
    table.insert(conversationList,"PF_story_10")
  end
  if n>=TppDefine.STORY_SEQUENCE.CLEARD_DESTROY_THE_FLOW_STATION then
    table.insert(conversationList,"PF_story_11")
  end
  if(n>=TppDefine.STORY_SEQUENCE.CLEARD_FIND_THE_SECRET_WEAPON and TppResult.GetTotalNeutralizeCount()<10)and TppResult.IsTotalPlayStyleStealth()then
    table.insert(conversationList,"MB_story_01")
  end
  if n>=TppDefine.STORY_SEQUENCE.CLEARD_FIND_THE_SECRET_WEAPON and TppMotherBaseManagement.GetOgrePoint()>=5e4 then
    table.insert(conversationList,"MB_story_02")
  end
  if TppMotherBaseManagement.IsOpenedSection{section="Security"}and TppMotherBaseManagement.GetSectionLv{section="Security"}<20 then
    table.insert(conversationList,"MB_story_03")
  end
  if n>=TppDefine.STORY_SEQUENCE.CLEARD_ELIMINATE_THE_POWS and n<TppDefine.STORY_SEQUENCE.CLEARD_MURDER_INFECTORS then
    table.insert(conversationList,"MB_story_04")
  end
  if TppTerminal.IsBuiltAnimalPlatform()then
    table.insert(conversationList,"MB_story_05")
  end
  if TppBuddyService.DidObtainBuddyType(BuddyType.QUIET)and not TppBuddyService.IsDeadBuddyType(BuddyType.QUIET)then
    table.insert(conversationList,"MB_story_09")
  end
  if(TppBuddyService.DidObtainBuddyType(BuddyType.DOG)and not TppBuddyService.CanSortieBuddyType(BuddyType.DOG))and not TppBuddyService.IsDeadBuddyType(BuddyType.DOG)then
    table.insert(conversationList,"MB_story_10")
  end
  if(TppBuddyService.DidObtainBuddyType(BuddyType.DOG)and TppBuddyService.CanSortieBuddyType(BuddyType.DOG))and not TppBuddyService.IsDeadBuddyType(BuddyType.DOG)then
    table.insert(conversationList,"MB_story_11")
  end
  if TppMotherBaseManagement.IsPandemicEventMode()then
    table.insert(conversationList,"MB_story_12")
  end
  if n>=TppDefine.STORY_SEQUENCE.CLEARD_OKB_ZERO and n<TppDefine.STORY_SEQUENCE.CLEARD_MURDER_INFECTORS then
    table.insert(conversationList,"MB_story_13")
  end
  if n>=TppDefine.STORY_SEQUENCE.CLEARD_OKB_ZERO then
    table.insert(conversationList,"MB_story_14")
  end
  if n>=TppDefine.STORY_SEQUENCE.CLEARD_MURDER_INFECTORS then
    table.insert(conversationList,"MB_story_15")
  end
  if gvars.pazLookedPictureCount>=1 and gvars.pazLookedPictureCount<10 then
    table.insert(conversationList,"MB_story_16")
  end
  if TppDemo.IsPlayedMBEventDemo"DecisionHuey"then
    table.insert(conversationList,"MB_story_17")
  end
  if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.FULTON)==1 then
    table.insert(conversationList,"USSR_revenge_01")
    table.insert(conversationList,"PF_revenge_01")
  end
  if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.FULTON)>=2 then
    table.insert(conversationList,"USSR_revenge_02")
    table.insert(conversationList,"PF_revenge_02")
  end
  if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.COMBAT)==1 then
    table.insert(conversationList,"USSR_revenge_03")
    table.insert(conversationList,"PF_revenge_03")
  end
  if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.COMBAT)==2 then
    table.insert(conversationList,"USSR_revenge_04")
    table.insert(conversationList,"PF_revenge_04")
  end
  if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.COMBAT)==3 then
    table.insert(conversationList,"USSR_revenge_05")
    table.insert(conversationList,"PF_revenge_05")
  end
  if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.STEALTH)==1 then
    table.insert(conversationList,"USSR_revenge_06")
    table.insert(conversationList,"PF_revenge_06")
  end
  if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.STEALTH)==2 then
    table.insert(conversationList,"USSR_revenge_07")
    table.insert(conversationList,"PF_revenge_07")
  end
  if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.HEAD_SHOT)==0 and TppRevenge.GetRevengePoint(TppRevenge.REVENGE_TYPE.HEAD_SHOT)>=50 then
    table.insert(conversationList,"USSR_revenge_08")
    table.insert(conversationList,"PF_revenge_08")
  end
  if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.VEHICLE)==0 and TppRevenge.GetRevengePoint(TppRevenge.REVENGE_TYPE.VEHICLE)>=50 then
    table.insert(conversationList,"USSR_revenge_09")
    table.insert(conversationList,"PF_revenge_09")
  end
  if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.VEHICLE)==0 and TppRevenge.GetRevengePoint(TppRevenge.REVENGE_TYPE.VEHICLE)>=50 then
    table.insert(conversationList,"USSR_revenge_10")
    table.insert(conversationList,"PF_revenge_10")
  end
  if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.LONG_RANGE)==0 and TppRevenge.GetRevengePoint(TppRevenge.REVENGE_TYPE.LONG_RANGE)>=50 then
    table.insert(conversationList,"USSR_revenge_11")
    table.insert(conversationList,"PF_revenge_11")
  end
  if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.NIGHT_S)==0 and TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.NIGHT_C)==0 then
    if TppRevenge.GetRevengePoint(TppRevenge.REVENGE_TYPE.NIGHT_S)>=50 or TppRevenge.GetRevengePoint(TppRevenge.REVENGE_TYPE.NIGHT_C)>=50 then
      table.insert(conversationList,"USSR_revenge_12")
      table.insert(conversationList,"PF_revenge_12")
    end
  end
  if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.STEALTH)==3 and TppRevenge.GetRevengePoint(TppRevenge.REVENGE_TYPE.TRANQ)>0 then
    table.insert(conversationList,"USSR_revenge_13")
    table.insert(conversationList,"PF_revenge_13")
  end
  if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.STEALTH)>=3 then
    if not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.MINE)then
      table.insert(conversationList,"USSR_counter_01")
      table.insert(conversationList,"PF_counter_01")
    end
  end
  if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.HEAD_SHOT)>=1 and TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.HEAD_SHOT)<=9 then
    if not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.HELMET)then
      table.insert(conversationList,"USSR_counter_03")
      table.insert(conversationList,"PF_counter_03")
    end
  end
  if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.HEAD_SHOT)==10 then
    if not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.HELMET)then
      table.insert(conversationList,"USSR_counter_04")
      table.insert(conversationList,"PF_counter_04")
    end
  end
  if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.COMBAT)>=1 then
    if not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.SOFT_ARMOR)then
      table.insert(conversationList,"USSR_counter_05")
      table.insert(conversationList,"PF_counter_05")
    end
  end
  if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.COMBAT)>=1 then
    if not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.SHIELD)then
      table.insert(conversationList,"USSR_counter_06")
      table.insert(conversationList,"PF_counter_06")
    end
  end
  if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.NIGHT_S)>=1 then
    if not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.NVG)then
      table.insert(conversationList,"USSR_counter_07")
      table.insert(conversationList,"PF_counter_07")
    end
  end
  if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.NIGHT_C)>=1 then
    if not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.GUN_LIGHT)then
      table.insert(conversationList,"USSR_counter_08")
      table.insert(conversationList,"PF_counter_08")
    end
  end
  if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.COMBAT)>=3 then
    if not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.ARMOR)then
      table.insert(conversationList,"USSR_counter_10")
      table.insert(conversationList,"PF_counter_10")
    end
  end
  if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.COMBAT)>=3 then
    table.insert(conversationList,"USSR_counter_11")
    table.insert(conversationList,"PF_counter_11")
  end
  if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.COMBAT)>=3 then
    table.insert(conversationList,"USSR_counter_12")
    table.insert(conversationList,"PF_counter_12")
  end
  if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.COMBAT)>=3 then
    table.insert(conversationList,"USSR_counter_13")
    table.insert(conversationList,"PF_counter_13")
  end
  if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.COMBAT)>=3 then
    table.insert(conversationList,"USSR_counter_14")
    table.insert(conversationList,"PF_counter_14")
  end
  if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.COMBAT)>=3 then
    if not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.SHOTGUN)or not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.MG)then
      table.insert(conversationList,"USSR_counter_15")
      table.insert(conversationList,"PF_counter_15")
    end
  end
  if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.LONG_RANGE)>=2 then
    if not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.SNIPER)then
      table.insert(conversationList,"USSR_counter_16")
      table.insert(conversationList,"PF_counter_16")
    end
  end
  if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.VEHICLE)==1 then
    if not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.MISSILE)then
      table.insert(conversationList,"USSR_counter_17")
      table.insert(conversationList,"PF_counter_17")
    end
  end
  if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.VEHICLE)>=2 then
    if not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.MISSILE)then
      table.insert(conversationList,"USSR_counter_18")
      table.insert(conversationList,"PF_counter_18")
    end
  end
  if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.STEALTH)>=2 then
    if not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.DECOY)then
      table.insert(conversationList,"USSR_counter_19")
      table.insert(conversationList,"PF_counter_19")
    end
  end
  if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.STEALTH)>=1 then
    if not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.CAMERA)then
      table.insert(conversationList,"USSR_counter_20")
      table.insert(conversationList,"PF_counter_20")
    end
  end
  if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.COMBAT)>=3 then
    table.insert(conversationList,"USSR_counter_22")
  end
  local typeSoldier={type="TppSoldier2"}
  GameObject.SendCommand(typeSoldier,{id="SetConversationList",list=conversationList})
end
function this.SetSaluteVoiceList()
  if not GameObject.DoesGameObjectExistWithTypeName"TppSoldier2"then
    return
  end
  local highList={}
  local highOnceList={}
  local midList={}
  local midOnceList={}
  local lowList={}
  local lowOnceList={}

  table.insert(lowList,"EVF010")
  table.insert(lowList,"salute0180")
  table.insert(lowList,"salute0220")
  table.insert(lowList,"salute0310")
  table.insert(lowList,"salute0320")

  table.insert(midList,"salute0410")
  table.insert(midList,"salute0420")

  local storySequence=gvars.str_storySequence
  if TppMotherBaseManagement.GetOgrePoint()>=5e4 then
    table.insert(highOnceList,"salute0080")
  elseif Player.GetSmallFlyLevel()>=5 then
    table.insert(highOnceList,"salute0050")
  elseif Player.GetSmallFlyLevel()>=3 then
    table.insert(highOnceList,"salute0040")
  else
    table.insert(highOnceList,"salute0060")
  end
  local staffcount=TppMotherBaseManagement.GetStaffCount()
  local staffLimit=0
  staffLimit=staffLimit+TppMotherBaseManagement.GetSectionStaffCountLimit{section=TppMotherBaseManagementConst.SECTION_COMBAT}
  staffLimit=staffLimit+TppMotherBaseManagement.GetSectionStaffCountLimit{section=TppMotherBaseManagementConst.SECTION_DEVELOP}
  staffLimit=staffLimit+TppMotherBaseManagement.GetSectionStaffCountLimit{section=TppMotherBaseManagementConst.SECTION_BASE_DEV}
  staffLimit=staffLimit+TppMotherBaseManagement.GetSectionStaffCountLimit{section=TppMotherBaseManagementConst.SECTION_SUPPORT}
  staffLimit=staffLimit+TppMotherBaseManagement.GetSectionStaffCountLimit{section=TppMotherBaseManagementConst.SECTION_SPY}
  staffLimit=staffLimit+TppMotherBaseManagement.GetSectionStaffCountLimit{section=TppMotherBaseManagementConst.SECTION_MEDICAL}
  staffLimit=staffLimit+TppMotherBaseManagement.GetSectionStaffCountLimit{section=TppMotherBaseManagementConst.SECTION_SECURITY}
  local percentageFull=staffcount/staffLimit
  if percentageFull<.2 then
    table.insert(lowList,"salute0100")
  elseif percentageFull<.4 then
    table.insert(lowList,"salute0090")
  elseif percentageFull>.8 then
    table.insert(lowList,"salute0120")
  end
  if TppMotherBaseManagement.GetGmp()<0 then
    table.insert(lowList,"salute0150")
  end
  if TppMotherBaseManagement.GetDevelopableEquipCount()>8 then
    table.insert(lowList,"salute0160")
  end
  if(TppMotherBaseManagement.GetResourceUsableCount{resource="CommonMetal"}<500 or TppMotherBaseManagement.GetResourceUsableCount{resource="FuelResource"}<200)or TppMotherBaseManagement.GetResourceUsableCount{resource="BioticResource"}<200 then
    table.insert(lowList,"salute0170")
  end
  if TppMotherBaseManagement.IsBuiltFirstFob()then
    table.insert(lowList,"salute0190")
  end
  if TppTerminal.IsReleaseSection"Combat"then
    table.insert(lowList,"salute0200")
  end
  if TppMotherBaseManagement.IsOpenedSectionFunc{sectionFuncId=TppMotherBaseManagementConst.SECTION_FUNC_ID_SUPPORT_BATTLE}then
    local n=TppMotherBaseManagement.GetSectionFuncRank{sectionFuncId=TppMotherBaseManagementConst.SECTION_FUNC_ID_SUPPORT_BATTLE}
    if n>=TppMotherBaseManagementConst.SECTION_FUNC_RANK_E then
      table.insert(lowList,"salute0230")
    end
  end
  if(TppBuddyService.DidObtainBuddyType(BuddyType.DOG)and not TppBuddyService.CanSortieBuddyType(BuddyType.DOG))and not TppBuddyService.IsDeadBuddyType(BuddyType.DOG)then
    table.insert(lowList,"salute0240")
  end
  if(TppBuddyService.DidObtainBuddyType(BuddyType.QUIET)and not TppBuddyService.CanSortieBuddyType(BuddyType.QUIET))and not TppBuddyService.IsDeadBuddyType(BuddyType.QUIET)then
    table.insert(lowList,"salute0250")
  end
  if TppMotherBaseManagement.GetResourceUsableCount{resource="Plant2000"}<100 or TppMotherBaseManagement.GetResourceUsableCount{resource="Plant2005"}<100 then
    table.insert(lowList,"salute0260")
  end
  if storySequence==TppDefine.STORY_SEQUENCE.CLEARD_TAKE_OUT_THE_CONVOY then
    table.insert(midList,"salute0270")
  end
  if TppMotherBaseManagement.IsPandemicEventMode()or storySequence==TppDefine.STORY_SEQUENCE.CLEARD_FLAG_MISSIONS_BEFORE_MURDER_INFECTORS then
    table.insert(midList,"salute0280")
  end
  if storySequence==TppDefine.STORY_SEQUENCE.CLEARD_ELIMINATE_THE_POWS then
    table.insert(midList,"salute0290")
  end
  if TppTerminal.IsBuiltAnimalPlatform()then
    table.insert(lowList,"salute0300")
  end
  if storySequence==TppDefine.STORY_SEQUENCE.CLEARD_RESCUE_INTEL_AGENTS then
    table.insert(midList,"salute0330")
  end
  if storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_METALLIC_ARCHAEA and storySequence<=TppDefine.STORY_SEQUENCE.CLEARD_OKB_ZERO then
    table.insert(midList,"salute0340")
  end
  if storySequence==TppDefine.STORY_SEQUENCE.CLEARD_MURDER_INFECTORS then
    table.insert(midList,"salute0350")
    table.insert(midList,"salute0360")
  end
  if storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_THE_TRUTH then
    table.insert(lowList,"salute0370")
  end
  if TppUiCommand.IsBirthDay()then
    table.insert(highList,"salute0380")
  end
  local saluteVoiceList={high={normal=highList,once=highOnceList},mid={normal=midList,once=midOnceList},low={normal=lowList,once=lowOnceList}}
  local typeSoldier={type="TppSoldier2"}
  GameObject.SendCommand(typeSoldier,{id="SetSaluteVoiceList",list=saluteVoiceList})
end
function this.RequestLoadWalkerGearEquip()
  TppEquip.RequestLoadToEquipMissionBlock{TppEquip.EQP_WP_West_hg_010}
end
function this.SetSoldier2CommonPackageLabel(e)
  mvars.ene_soldier2CommonBlockPackageLabel=e
end
function this.AssignUniqueStaffType(info)
  if not IsTypeTable(info)then
    return
  end
  local locatorName=info.locaterName
  local gameObjectId=info.gameObjectId
  local uniqueStaffTypeId=info.uniqueStaffTypeId
  local alreadyExistParam=info.alreadyExistParam
  if not IsTypeNumber(uniqueStaffTypeId)then
    return
  end
  if(not IsTypeNumber(gameObjectId))and(not IsTypeString(locatorName))then
    return
  end
  local gameId
  if IsTypeNumber(gameObjectId)then
    gameId=gameObjectId
  elseif IsTypeString(locatorName)then
    gameId=GetGameObjectId(locatorName)
  end
  if not TppDefine.IGNORE_EXIST_STAFF_CHECK[uniqueStaffTypeId]then
    if TppMotherBaseManagement.IsExistStaff{uniqueTypeId=uniqueStaffTypeId}then
      if alreadyExistParam then
        local staffInfo={gameObjectId=gameId}
        for n,t in pairs(alreadyExistParam)do
          staffInfo[n]=t
        end
        TppMotherBaseManagement.RegenerateGameObjectStaffParameter(staffInfo)
        return
      else
        return
      end
    end
  end
  if gameId~=NULL_ID then
    TppMotherBaseManagement.RegenerateGameObjectStaffParameter{gameObjectId=gameId,staffType="Unique",uniqueTypeId=uniqueStaffTypeId}
  end
end
function this.IsActiveSoldierInRange(pos,range)
  local command={id="IsActiveSoldierInRange",position=pos,range=range}
  return SendCommand({type="TppSoldier2"},command)
end
function this._SetOutOfArea(soldierNames,outOfAreaList)
  if IsTypeTable(soldierNames)then
    for a,soldierNames in ipairs(soldierNames)do
      this._SetOutOfArea(soldierNames,outOfAreaList)
    end
  else
    local soldierId=GetGameObjectId("TppSoldier2",soldierNames)
    table.insert(outOfAreaList,soldierId)
  end
end
function this.SetOutOfArea(soldierNames,isOut)
  local soldiers={}
  this._SetOutOfArea(soldierNames,soldiers)
  local command={id="SetOutOfArea",soldiers=soldiers,isOut=isOut}
  SendCommand({type="TppSoldier2"},command)
end
function this.SetEliminateTargets(_targetList,exceptTable)
  mvars.ene_eliminateTargetList={}
  mvars.ene_eliminateHelicopterList={}
  mvars.ene_eliminateVehicleList={}
  mvars.ene_eliminateWalkerGearList={}
  local validTargetList={}
  if Tpp.IsTypeTable(exceptTable)then
    if Tpp.IsTypeTable(exceptTable.exceptMissionClearCheck)then
      for n,e in pairs(exceptTable.exceptMissionClearCheck)do
        validTargetList[e]=true
      end
    end
  end
  for t,targetName in pairs(_targetList)do
    local gameId=GetGameObjectId(targetName)
    if gameId~=NULL_ID then
      if Tpp.IsSoldier(gameId)then
        if not validTargetList[targetName]then
          mvars.ene_eliminateTargetList[gameId]=targetName
        end
        this.RegistHoldRecoveredState(targetName)
        this.SetTargetOption(targetName)
      elseif Tpp.IsEnemyHelicopter(gameId)then
        if not validTargetList[targetName]then
          mvars.ene_eliminateHelicopterList[gameId]=targetName
        end
      elseif Tpp.IsVehicle(gameId)then
        if not validTargetList[targetName]then
          mvars.ene_eliminateVehicleList[gameId]=targetName
        end
        this.RegistHoldRecoveredState(targetName)
        this.RegistHoldBrokenState(targetName)
      elseif Tpp.IsEnemyWalkerGear(gameId)then
        if not validTargetList[targetName]then
          mvars.ene_eliminateWalkerGearList[gameId]=targetName
        end
        this.RegistHoldRecoveredState(targetName)
      end
      if validTargetList[targetName]then
      end
    end
  end
end
function this.DeleteEliminateTargetSetting(soldierName)
  if not mvars.ene_eliminateTargetList then
    return
  end
  local soldierId=GetGameObjectId(soldierName)
  if soldierId==NULL_ID then
    return
  end
  if mvars.ene_eliminateTargetList[soldierId]then
    mvars.ene_eliminateTargetList[soldierId]=nil
    local tppSolder2=GetGameObjectId("TppSoldier2",soldierName)
    if tppSolder2==NULL_ID then
    else
      SendCommand(tppSolder2,{id="ResetSoldier2Flag"})
    end
  elseif mvars.ene_eliminateHelicopterList[soldierId]then
    mvars.ene_eliminateHelicopterList[soldierId]=nil
  elseif mvars.ene_eliminateVehicleList[soldierId]then
    mvars.ene_eliminateVehicleList[soldierId]=nil
  elseif mvars.ene_eliminateWalkerGearList[soldierId]then
    mvars.ene_eliminateWalkerGearList[soldierId]=nil
  else
    return
  end
  return true
end
function this.SetRescueTargets(rescueTargetNames,rescueTargetOptions)
  mvars.ene_rescueTargetList={}
  mvars.ene_rescueTargetOptions=rescueTargetOptions or{}
  for t,name in pairs(rescueTargetNames)do
    local gameId=GetGameObjectId(name)
    if gameId~=NULL_ID then
      mvars.ene_rescueTargetList[gameId]=name
      this.RegistHoldRecoveredState(name)
    end
  end
end
function this.SetVipHostage(names)--NMC: ORPHAN aparently
  this.SetRescueTargets(names)
end
function this.SetExcludeHostage(e)
  mvars.ene_excludeHostageGameObjectId=GetGameObjectId(e)
end
function this.GetAllHostages()
  local hostageObjectTypes={"TppHostage2","TppHostageUnique","TppHostageUnique2"}
  local NPC_STATE_DISABLE=TppGameObject.NPC_STATE_DISABLE
  local hostageIdList={}
  for e,hostageObjectType in ipairs(hostageObjectTypes)do
    local max=1
    local i=0
    while i<max do
      local gameId=GetGameObjectIdByIndex(hostageObjectType,i)
      if gameId==NULL_ID then
        break
      end
      if max==1 then
        max=SendCommand({type=hostageObjectType},{id="GetMaxInstanceCount"})
        if not max or max<1 then
          break
        end
      end
      local addToList=true
      if mvars.ene_excludeHostageGameObjectId and mvars.ene_excludeHostageGameObjectId==gameId then
        addToList=false
      end
      if addToList then
        local lifeStatus=SendCommand(gameId,{id="GetLifeStatus"})
        local status=SendCommand(gameId,{id="GetStatus"})
        if(status~=NPC_STATE_DISABLE)and(lifeStatus~=TppGameObject.NPC_LIFE_STATE_DEAD)then
          table.insert(hostageIdList,gameId)
        end
      end
      i=i+1
    end
  end
  return hostageIdList
end
function this.GetAllActiveEnemyWalkerGear()
  local r={}
  local tppCommonWalkerGear=1
  local i=0
  while i<tppCommonWalkerGear do
    local t=GetGameObjectIdByIndex("TppCommonWalkerGear2",i)
    if t==NULL_ID then
      break
    end
    if tppCommonWalkerGear==1 then
      tppCommonWalkerGear=SendCommand({type="TppCommonWalkerGear2"},{id="GetMaxInstanceCount"})
      if not tppCommonWalkerGear or tppCommonWalkerGear<1 then
        break
      end
    end
    local isBroken=SendCommand(t,{id="IsBroken"})
    local isFultonCaptured=SendCommand(t,{id="IsFultonCaptured"})
    if(isBroken==false)and(isFultonCaptured==false)then
      table.insert(r,t)
    end
    i=i+1
  end
  return r
end
function this.SetChildTargets(n)
  mvars.ene_childTargetList={}
  for t,n in pairs(n)do
    local t=GetGameObjectId(n)
    if t~=NULL_ID then
      mvars.ene_childTargetList[t]=n
      this.SetTargetOption(n)
    end
  end
end
function this.SetTargetOption(e)
  local e=GetGameObjectId(e)
  if e==NULL_ID then
  else
    SendCommand(e,{id="SetVip"})
    SendCommand(e,{id="SetForceRealize"})
    SendCommand(e,{id="SetIgnoreSupportBlastInUnreal",enabled=true})
  end
end
function this.LetCpHasTarget(e,t)
  local n
  if IsTypeNumber(e)then
    n=e
  elseif IsTypeString(e)then
    n=GetGameObjectId(e)
  else
    return
  end
  if n==NULL_ID then
    return
  end
  GameObject.SendCommand(n,{id="SetCpMissionTarget",enable=t})
end
function this.GetPhase(cpName)
  local cpId=GetGameObjectId(cpName)
  return SendCommand(cpId,{id="GetPhase",cpName=cpName})
end
function this.GetPhaseByCPID(cpId)
  return SendCommand(cpId,{id="GetPhase",cpName=mvars.ene_cpList[cpId]})
end
function this.GetLifeStatus(gameId)
  if not gameId then
    return
  end
  if IsTypeString(gameId)then
    gameId=GameObject.GetGameObjectId(gameId)
  end
  return SendCommand(gameId,{id="GetLifeStatus"})
end
function this.GetActionStatus(gameId)
  if not gameId then
    return
  end
  if IsTypeString(gameId)then
    gameId=GameObject.GetGameObjectId(gameId)
  end
  return SendCommand(gameId,{id="GetActionStatus"})
end
function this.GetStatus(nameOrId)
  local gameId
  if IsTypeString(nameOrId)then
    gameId=GetGameObjectId(nameOrId)
  else
    gameId=nameOrId
  end
  if gameId~=NULL_ID then
    return SendCommand(gameId,{id="GetStatus"})
  else
    return
  end
end
function this.IsEliminated(gameId)
  local lifeStatus=this.GetLifeStatus(gameId)
  local status=this.GetStatus(gameId)
  return this._IsEliminated(lifeStatus,status)
end
function this.IsNeutralized(gameId)
  local lifeStatus=this.GetLifeStatus(gameId)
  local status=this.GetStatus(gameId)
  return this._IsNeutralized(lifeStatus,status)
end
function this.IsRecovered(nameOrId)
  if not mvars.ene_recoverdStateIndexByName then
    return
  end
  local index
  if IsTypeString(nameOrId)then
    index=mvars.ene_recoverdStateIndexByName[nameOrId]
  elseif IsTypeNumber(nameOrId)then
    index=mvars.ene_recoverdStateIndexByGameObjectId[nameOrId]
  end
  if index then
    return svars.ene_isRecovered[index]
  end
end
function this.ChangeLifeState(stateInfo)
  if not Tpp.IsTypeTable(stateInfo)then
    return"Support table only"
  end
  local lifeState=stateInfo.lifeState
  local minIndex=0
  local maxIndex=4
  if not((lifeState>minIndex)and(lifeState<maxIndex))then
    return"lifeState must be index"
  end
  local targetName=stateInfo.targetName
  if not IsTypeString(targetName)then
    return"targetName must be string"
  end
  local gameId=GetGameObjectId(targetName)
  if gameId~=NULL_ID then
    GameObject.SendCommand(gameId,{id="ChangeLifeState",state=lifeState})
  else
    return"Cannot get gameObjectId. targetName = "..tostring(targetName)
  end
end
function this.SetSneakRoute(e,s,t,i)
  if not e then
    return
  end
  if IsTypeString(e)then
    e=GameObject.GetGameObjectId(e)
  end
  t=t or 0
  local r=false
  if Tpp.IsTypeTable(i)then
    r=i.isRelaxed
  end
  if e~=NULL_ID then
    SendCommand(e,{id="SetSneakRoute",route=s,point=t,isRelaxed=r})
  end
end
function this.UnsetSneakRoute(e)
  if not e then
    return
  end
  if IsTypeString(e)then
    e=GameObject.GetGameObjectId(e)
  end
  if e~=NULL_ID then
    SendCommand(e,{id="SetSneakRoute",route=""})
  end
end
function this.SetCautionRoute(e,i,t,r)
  if not e then
    return
  end
  if IsTypeString(e)then
    e=GameObject.GetGameObjectId(e)
  end
  t=t or 0
  if e~=NULL_ID then
    SendCommand(e,{id="SetCautionRoute",route=i,point=t})
  end
end
function this.UnsetCautionRoute(e)
  if not e then
    return
  end
  if IsTypeString(e)then
    e=GameObject.GetGameObjectId(e)
  end
  if e~=NULL_ID then
    SendCommand(e,{id="SetCautionRoute",route=""})
  end
end
function this.SetAlertRoute(e,i,t,r)
  if not e then
    return
  end
  if IsTypeString(e)then
    e=GameObject.GetGameObjectId(e)
  end
  t=t or 0
  if e~=NULL_ID then
    SendCommand(e,{id="SetAlertRoute",enabled=true,route=i,point=t})
  end
end
function this.UnsetAlertRoute(e)
  if not e then
    return
  end
  if IsTypeString(e)then
    e=GameObject.GetGameObjectId(e)
  end
  if e~=NULL_ID then
    SendCommand(e,{id="SetAlertRoute",enabled=false,route=""})
  end
end
function this.RegistRoutePointMessage(e)
  if not IsTypeTable(e)then
    return
  end
  mvars.ene_routePointMessage=mvars.ene_routePointMessage or{}
  mvars.ene_routePointMessage.main=mvars.ene_routePointMessage.main or{}
  mvars.ene_routePointMessage.sequence=mvars.ene_routePointMessage.sequence or{}
  local n={}
  n[StrCode32"GameObject"]=Tpp.StrCode32Table(e.messages)
  local n=(Tpp.MakeMessageExecTable(n))[StrCode32"GameObject"]
  local e=e.sequenceName
  if e then
    mvars.ene_routePointMessage.sequence[e]=mvars.ene_routePointMessage.sequence[e]or{}
    Tpp.MergeTable(mvars.ene_routePointMessage.sequence[e],n,true)
  else
    Tpp.MergeTable(mvars.ene_routePointMessage.main,n,true)
  end
end
function this.IsBaseCp(e)
  if not mvars.ene_baseCpList then
    return
  end
  return mvars.ene_baseCpList[e]
end
function this.IsOuterBaseCp(e)
  if not mvars.ene_outerBaseCpList then
    return
  end
  return mvars.ene_outerBaseCpList[e]
end
function this.ChangeRouteSets(t,a)
  mvars.ene_routeSetsTemporary=mvars.ene_routeSets
  mvars.ene_routeSetsPriorityTemporary=mvars.ene_routeSetsPriority
  this.MergeRouteSetDefine(t)
  mvars.ene_routeSets={}
  mvars.ene_routeSetsPriority={}
  mvars.ene_routeSetsFixedShiftChange={}
  this.UpdateRouteSet(mvars.ene_routeSetsDefine)
  local t={{{"old","immediately"},{"new","immediately"}}}
  for e,a in pairs(mvars.ene_cpList)do
    SendCommand(e,{id="ChangeRouteSets"})
    SendCommand(e,{id="ShiftChange",schedule=t})
  end
end
function this.InitialRouteSetGroup(e)
  local t=GetGameObjectId(e.cpName)
  local o=e.groupName
  if not IsTypeTable(e.soldierList)then
    return
  end
  local i={}
  for n,e in pairs(e.soldierList)do
    local e=GetGameObjectId(e)
    if e~=NULL_ID then
      i[n]=e
    end
  end
  if t==NULL_ID then
    return
  end
  SendCommand(t,{id="AssignSneakRouteGroup",soldiers=i,group=o})
end
function this.RegisterHoldTime(e,n)
  local e=GetGameObjectId(e)
  if e==NULL_ID then
    return
  end
  mvars.ene_holdTimes[e]=n
end
function this.ChangeHoldTime(n,t)
  local n=GetGameObjectId(n)
  if n==NULL_ID then
    return
  end
  mvars.ene_holdTimes[n]=t
  this.MakeShiftChangeTable()
end
function this.RegisterSleepTime(e,n)
  local e=GetGameObjectId(e)
  if e==NULL_ID then
    return
  end
  mvars.ene_sleepTimes[e]=n
end
function this.ChangeSleepTime(n,t)
  local n=GetGameObjectId(n)
  if n==NULL_ID then
    return
  end
  mvars.ene_sleepTimes[n]=t
  this.MakeShiftChangeTable()
end
function this.NoShifhtChangeGruopSetting(e,n)
  local e=GetGameObjectId(e)
  if e==NULL_ID then
    return
  end
  mvars.ene_noShiftChangeGroupSetting[e]=mvars.ene_noShiftChangeGroupSetting[e]or{}
  mvars.ene_noShiftChangeGroupSetting[e][StrCode32(n)]=true
end
function this.RegisterCombatSetting(t)
  local function i(t,e)
    local n={}
    for e,a in pairs(e)do
      n[e]=a
      if t[e]then
        n[e]=t[e]
      end
    end
    return n
  end
  if not IsTypeTable(t)then
    return
  end
  for n,e in pairs(t)do
    if e.USE_COMMON_COMBAT and mvars.loc_locationCommonCombat then
      if mvars.loc_locationCommonCombat[n]then
        if e.combatAreaList then
          e.combatAreaList=i(e.combatAreaList,mvars.loc_locationCommonCombat[n].combatAreaList)
        else
          e=mvars.loc_locationCommonCombat[n]
        end
      end
    end
    if e.combatAreaList and IsTypeTable(e.combatAreaList)then
      for t,e in pairs(e.combatAreaList)do
        for t,e in pairs(e)do
          if e.guardTargetName and e.locatorSetName then
            TppCombatLocatorProvider.RegisterCombatLocatorSetToCpforLua{cpName=n,locatorSetName=e.guardTargetName}
            TppCombatLocatorProvider.RegisterCombatLocatorSetToCpforLua{cpName=n,locatorSetName=e.locatorSetName}
          end
        end
      end
      local t={type="TppCommandPost2"}
      local e={id="SetCombatArea",cpName=n,combatAreaList=e.combatAreaList}
      GameObject.SendCommand(t,e)
    else
      for t,e in ipairs(e)do
        TppCombatLocatorProvider.RegisterCombatLocatorSetToCpforLua{cpName=n,locatorSetName=e}
      end
    end
  end
end
function this.SetEnable(e)
  if IsTypeString(e)then
    e=GameObject.GetGameObjectId(e)
  end
  if e~=NULL_ID then
    SendCommand(e,{id="SetEnabled",enabled=true})
  end
end
function this.SetDisable(e,t)
  if IsTypeString(e)then
    e=GameObject.GetGameObjectId(e)
  end
  if e~=NULL_ID then
    SendCommand(e,{id="SetEnabled",enabled=false,noAssignRoute=t})
  end
end
function this.SetEnableRestrictNotice(e)
  if IsTypeString(e)then
    e=GameObject.GetGameObjectId(e)
  end
  if e~=NULL_ID then
    SendCommand(e,{id="SetRestrictNotice",enabled=true})
  end
end
function this.SetDisableRestrictNotice(e)
  if IsTypeString(e)then
    e=GameObject.GetGameObjectId(e)
  end
  if e~=NULL_ID then
    SendCommand(e,{id="SetRestrictNotice",enabled=false})
  end
end
function this.RealizeParasiteSquad()
  if not IsTypeTable(mvars.ene_parasiteSquadList)then
    return
  end
  for t,soldierName in pairs(mvars.ene_parasiteSquadList)do
    local e=GetGameObjectId("TppParasite2",soldierName)
    if e~=NULL_ID then
      SendCommand(e,{id="Realize"})
    end
  end
end
function this.UnRealizeParasiteSquad()
  if not IsTypeTable(mvars.ene_parasiteSquadList)then
    return
  end
  for t,soldierName in pairs(mvars.ene_parasiteSquadList)do
    local e=GetGameObjectId("TppParasite2",soldierName)
    if e~=NULL_ID then
      SendCommand(e,{id="Unrealize"})
    end
  end
end
function this.OnAllocate(missionTable)
  this.SetMaxSoldierStateCount(TppDefine.DEFAULT_SOLDIER_STATE_COUNT)
  if missionTable.enemy then
    this.SetMaxSoldierStateCount(missionTable.enemy.MAX_SOLDIER_STATE_COUNT)
  end
  if TppCommandPost2 then
    TppCommandPost2.SetSVarsKeyNames{names="cpNames",flags="cpFlags"}
  end
  TppSoldier2.SetSVarsKeyNames{
    name="solName",
    state="solState",
    flagAndStance="solFlagAndStance",
    weapon="solWeapon",
    location="solLocation",
    marker="solMarker",
    fovaSeed="solFovaSeed",
    faceFova="solFaceFova",
    bodyFova="solBodyFova",
    cp="solCp",
    cpRoute="solCpRoute",
    scriptSneakRoute="solScriptSneakRoute",
    scriptCautionRoute="solScriptCautionRoute",
    scriptAlertRoute="solScriptAlertRoute",
    routeNodeIndex="solRouteNodeIndex",
    routeEventIndex="solRouteEventIndex",
    travelName="solTravelName",
    travelStepIndex="solTravelStepIndex",
    optionalNamesName="solOptName",
    optionalParam1Name="solOptParam1",
    optionalParam2Name="solOptParam2",
    passengerInfoName="passengerInfoName",
    passengerFlagName="passengerFlagName",
    passengerNameName="passengerNameName",
    noticeObjectType="noticeObjectType",
    noticeObjectPosition="noticeObjectPosition",
    noticeObjectOwnerName="noticeObjectOwnerName",
    noticeObjectOwnerId="noticeObjectOwnerId",
    noticeObjectAttachId="noticeObjectAttachId",
    randomSeed="solRandomSeed"
  }
  if TppSoldierFace~=nil then
    if TppSoldierFace.ConvertFova2PathToFovaFile~=nil then
      TppSoldierFace.ConvertFova2PathToFovaFile()
    end
  end
  if TppHostage2 then
    if TppHostage2.SetSVarsKeyNames2 then
      TppHostage2.SetSVarsKeyNames2{name="hosName",state="hosState",flagAndStance="hosFlagAndStance",weapon="hosWeapon",location="hosLocation",marker="hosMarker",fovaSeed="hosFovaSeed",faceFova="hosFaceFova",bodyFova="hosBodyFova",scriptSneakRoute="hosScriptSneakRoute",routeNodeIndex="hosRouteNodeIndex",routeEventIndex="hosRouteEventIndex",optionalParam1Name="hosOptParam1",optionalParam2Name="hosOptParam2",randomSeed="hosRandomSeed"}
    end
  end
  mvars.ene_disablePowerSettings={}
  mvars.ene_soldierTypes={}
  if missionTable.enemy then
    if missionTable.enemy.syncRouteTable and SyncRouteManager then
      SyncRouteManager.Create(missionTable.enemy.syncRouteTable)
    end
    if missionTable.enemy.OnAllocate then
      missionTable.enemy.OnAllocate()
    end
    mvars.ene_funcRouteSetPriority=missionTable.enemy.GetRouteSetPriority
    if missionTable.enemy.hostageDefine then
      mvars.ene_hostageDefine=missionTable.enemy.hostageDefine
    end
    if missionTable.enemy.vehicleDefine then
      mvars.ene_vehicleDefine=missionTable.enemy.vehicleDefine
    end
    if missionTable.enemy.vehicleSettings then--ORPHANED:
      this.RegistVehicleSettings(missionTable.enemy.vehicleSettings)
    end
    if IsTypeTable(missionTable.enemy.disablePowerSettings)then
      this.DisablePowerSettings(missionTable.enemy.disablePowerSettings)
    end
    if missionTable.enemy.soldierTypes then
      this.SetUpSoldierTypes(missionTable.enemy.soldierTypes)
    end
  end
  mvars.ene_soldierPowerSettings={}
  mvars.ene_missionSoldierPowerSettings={}
  mvars.ene_missionRequiresPowerSettings={}
  mvars.ene_soldierPersonalAbilitySettings={}
  mvars.ene_missionSoldierPersonalAbilitySettings={}
  mvars.ene_soldier2CommonBlockPackageLabel="default"
  mvars.ene_questTargetList={}
  mvars.ene_questVehicleList={}
  mvars.ene_questGetLoadedFaceTable={}
  mvars.ene_questArmorId=0
  mvars.ene_questBalaclavaId=0
  mvars.ene_isQuestSetup=false
  mvars.ene_isQuestHeli=false
end
function this.DeclareSVars(missionTable)
  local uavCount=0
  local missionId=TppMission.GetMissionID()
  if TppMission.IsFOBMission(missionId)then
    uavCount=TppDefine.MAX_UAV_COUNT
  end
  local cpCount=0
  if missionTable.enemy then
    local soldierDefine=missionTable.enemy.soldierDefine
    if soldierDefine~=nil then
      for e,e in pairs(soldierDefine)do
        cpCount=cpCount+1
      end
    end
  end
  if cpCount==1 then
    cpCount=2
  end
  mvars.ene_cpCount=cpCount
  local svarList={
    {name="cpNames",arraySize=cpCount,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="cpFlags",arraySize=cpCount,type=TppScriptVars.TYPE_UINT8,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="solName",arraySize=mvars.ene_maxSoldierStateCount,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="solState",arraySize=mvars.ene_maxSoldierStateCount,type=TppScriptVars.TYPE_UINT8,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="solFlagAndStance",arraySize=mvars.ene_maxSoldierStateCount,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="solWeapon",arraySize=mvars.ene_maxSoldierStateCount,type=TppScriptVars.TYPE_UINT16,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="solLocation",arraySize=mvars.ene_maxSoldierStateCount*4,type=TppScriptVars.TYPE_FLOAT,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="solMarker",arraySize=mvars.ene_maxSoldierStateCount,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_RETRY},
    {name="solFovaSeed",arraySize=mvars.ene_maxSoldierStateCount,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="solFaceFova",arraySize=mvars.ene_maxSoldierStateCount,type=TppScriptVars.TYPE_UINT16,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="solBodyFova",arraySize=mvars.ene_maxSoldierStateCount,type=TppScriptVars.TYPE_UINT16,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="solCp",arraySize=mvars.ene_maxSoldierStateCount,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="solCpRoute",arraySize=mvars.ene_maxSoldierStateCount,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="solScriptSneakRoute",arraySize=mvars.ene_maxSoldierStateCount,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="solScriptCautionRoute",arraySize=mvars.ene_maxSoldierStateCount,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="solScriptAlertRoute",arraySize=mvars.ene_maxSoldierStateCount,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="solRouteNodeIndex",arraySize=mvars.ene_maxSoldierStateCount,type=TppScriptVars.TYPE_UINT16,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="solRouteEventIndex",arraySize=mvars.ene_maxSoldierStateCount,type=TppScriptVars.TYPE_UINT16,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="solTravelName",arraySize=mvars.ene_maxSoldierStateCount,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="solTravelStepIndex",arraySize=mvars.ene_maxSoldierStateCount,type=TppScriptVars.TYPE_UINT8,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="solOptName",arraySize=TppDefine.DEFAULT_SOLDIER_OPTION_VARS_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="solOptParam1",arraySize=TppDefine.DEFAULT_SOLDIER_OPTION_VARS_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="solOptParam2",arraySize=TppDefine.DEFAULT_SOLDIER_OPTION_VARS_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="passengerInfoName",arraySize=TppDefine.DEFAULT_PASSAGE_INFO_COUNT,type=TppScriptVars.TYPE_UINT16,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="passengerFlagName",arraySize=TppDefine.DEFAULT_PASSAGE_FLAG_COUNT,type=TppScriptVars.TYPE_UINT16,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="passengerNameName",arraySize=TppDefine.DEFAULT_PASSAGE_FLAG_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="passengerVehicleNameName",arraySize=TppDefine.DEFAULT_PASSAGE_INFO_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="noticeObjectType",arraySize=TppDefine.DEFAULT_NOTICE_INFO_COUNT,type=TppScriptVars.TYPE_UINT8,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="noticeObjectPosition",arraySize=TppDefine.DEFAULT_NOTICE_INFO_COUNT*3,type=TppScriptVars.TYPE_FLOAT,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="noticeObjectOwnerName",arraySize=TppDefine.DEFAULT_NOTICE_INFO_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="noticeObjectOwnerId",arraySize=TppDefine.DEFAULT_NOTICE_INFO_COUNT,type=TppScriptVars.TYPE_UINT16,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="noticeObjectAttachId",arraySize=TppDefine.DEFAULT_NOTICE_INFO_COUNT,type=TppScriptVars.TYPE_UINT16,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="solRandomSeed",arraySize=1,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="hosName",arraySize=TppDefine.DEFAULT_HOSTAGE_STATE_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="hosState",arraySize=TppDefine.DEFAULT_HOSTAGE_STATE_COUNT,type=TppScriptVars.TYPE_UINT8,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="hosFlagAndStance",arraySize=TppDefine.DEFAULT_HOSTAGE_STATE_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="hosWeapon",arraySize=TppDefine.DEFAULT_HOSTAGE_STATE_COUNT,type=TppScriptVars.TYPE_UINT16,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="hosLocation",arraySize=TppDefine.DEFAULT_HOSTAGE_STATE_COUNT*4,type=TppScriptVars.TYPE_FLOAT,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="hosMarker",arraySize=TppDefine.DEFAULT_HOSTAGE_STATE_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_RETRY},
    {name="hosFovaSeed",arraySize=TppDefine.DEFAULT_HOSTAGE_STATE_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="hosFaceFova",arraySize=TppDefine.DEFAULT_HOSTAGE_STATE_COUNT,type=TppScriptVars.TYPE_UINT16,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="hosBodyFova",arraySize=TppDefine.DEFAULT_HOSTAGE_STATE_COUNT,type=TppScriptVars.TYPE_UINT16,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="hosScriptSneakRoute",arraySize=TppDefine.DEFAULT_HOSTAGE_STATE_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="hosRouteNodeIndex",arraySize=TppDefine.DEFAULT_HOSTAGE_STATE_COUNT,type=TppScriptVars.TYPE_UINT16,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="hosRouteEventIndex",arraySize=TppDefine.DEFAULT_HOSTAGE_STATE_COUNT,type=TppScriptVars.TYPE_UINT16,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="hosOptParam1",arraySize=TppDefine.DEFAULT_HOSTAGE_STATE_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="hosOptParam2",arraySize=TppDefine.DEFAULT_HOSTAGE_STATE_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="hosRandomSeed",arraySize=TppDefine.DEFAULT_HOSTAGE_STATE_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="enemyHeliName",arraySize=TppDefine.DEFAULT_ENEMY_HELI_STATE_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="enemyHeliLocation",arraySize=TppDefine.DEFAULT_ENEMY_HELI_STATE_COUNT*4,type=TppScriptVars.TYPE_FLOAT,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="enemyHeliCp",arraySize=TppDefine.DEFAULT_ENEMY_HELI_STATE_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="enemyHeliFlag",arraySize=TppDefine.DEFAULT_ENEMY_HELI_STATE_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="enemyHeliSneakRoute",arraySize=TppDefine.DEFAULT_ENEMY_HELI_STATE_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="enemyHeliCautionRoute",arraySize=TppDefine.DEFAULT_ENEMY_HELI_STATE_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="enemyHeliAlertRoute",arraySize=TppDefine.DEFAULT_ENEMY_HELI_STATE_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="enemyHeliRouteNodeIndex",arraySize=TppDefine.DEFAULT_ENEMY_HELI_STATE_COUNT,type=TppScriptVars.TYPE_UINT16,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="enemyHeliRouteEventIndex",arraySize=TppDefine.DEFAULT_ENEMY_HELI_STATE_COUNT,type=TppScriptVars.TYPE_UINT16,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="enemyHeliMarker",arraySize=TppDefine.DEFAULT_ENEMY_HELI_STATE_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_RETRY},
    {name="enemyHeliLife",arraySize=TppDefine.DEFAULT_ENEMY_HELI_STATE_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="ene_wkrg_name",arraySize=4,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="ene_wkrg_life",arraySize=4,type=TppScriptVars.TYPE_UINT16,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="ene_wkrg_partslife",arraySize=4*24,type=TppScriptVars.TYPE_UINT8,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="ene_wkrg_location",arraySize=4*4,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="ene_wkrg_bulletleft",arraySize=4*2,type=TppScriptVars.TYPE_UINT16,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="ene_wkrg_marker",arraySize=4*2,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_RETRY},
    {name="ene_holdRecoveredStateName",arraySize=TppDefine.MAX_HOLD_RECOVERED_STATE_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="ene_isRecovered",arraySize=TppDefine.MAX_HOLD_RECOVERED_STATE_COUNT,type=TppScriptVars.TYPE_BOOL,value=false,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="ene_holdBrokenStateName",arraySize=TppDefine.MAX_HOLD_VEHICLE_BROKEN_STATE_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="ene_isVehicleBroken",arraySize=TppDefine.MAX_HOLD_VEHICLE_BROKEN_STATE_COUNT,type=TppScriptVars.TYPE_BOOL,value=false,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="liquidLifeStatus",arraySize=1,type=TppScriptVars.TYPE_UINT8,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="liquidMarker",arraySize=1,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_RETRY},
    {name="uavName",arraySize=uavCount,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="uavIsDead",arraySize=uavCount,type=TppScriptVars.TYPE_UINT8,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="uavMarker",arraySize=uavCount,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_RETRY},
    {name="uavCp",arraySize=uavCount,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="uavPatrolRoute",arraySize=uavCount,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="uavCombatRoute",arraySize=uavCount,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="securityCameraCp",arraySize=TppDefine.MAX_SECURITY_CAMERA_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    {name="securityCameraMarker",arraySize=TppDefine.MAX_SECURITY_CAMERA_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_RETRY},
    {name="securityCameraFlag",arraySize=TppDefine.MAX_SECURITY_CAMERA_COUNT,type=TppScriptVars.TYPE_UINT8,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
    nil
  }
  if Vehicle.svars then
    local e=Vehicle.instanceCountMax
    if mvars.ene_vehicleDefine and mvars.ene_vehicleDefine.instanceCount then
      e=mvars.ene_vehicleDefine.instanceCount
    end
    Tpp.ApendArray(svarList,Vehicle.svars{instanceCount=e})
  end
  return svarList
end
function this.ResetSoldier2CommonBlockPackageLabel()
  gvars.ene_soldier2CommonPackageLabelIndex=TppDefine.DEFAULT_SOLIDER2_COMMON_PACKAGE
end
function this.RegisterSoldier2CommonMotionPackagePath(n)
  local t=TppDefine.SOLIDER2_COMMON_PACK[n]
  local a=TppDefine.SOLIDER2_COMMON_PACK_PREREQUISITES[n]
  if t then
    if IsTypeString(n)then
      gvars.ene_soldier2CommonPackageLabelIndex=StrCode32(n)
    else
      gvars.ene_soldier2CommonPackageLabelIndex=n
    end
  else
    t=TppDefine.SOLIDER2_COMMON_PACK.default
    a=TppDefine.SOLIDER2_COMMON_PACK_PREREQUISITES.default
    this.ResetSoldier2CommonBlockPackageLabel()
  end
  TppSoldier2CommonBlockController.SetPackagePathWithPrerequisites{path=t,prerequisites=a}
end
function this.IsRequiredToLoadSpecialSolider2CommonBlock()
  if StrCode32(mvars.ene_soldier2CommonBlockPackageLabel)~=TppDefine.DEFAULT_SOLIDER2_COMMON_PACKAGE then
    return true
  else
    return false
  end
end
function this.IsRequiredToLoadDefaultSoldier2CommonPackage()
  local e=StrCode32(mvars.ene_soldier2CommonBlockPackageLabel)
  if(e==TppDefine.DEFAULT_SOLIDER2_COMMON_PACKAGE)then
    return true
  else
    return false
  end
end
function this.IsLoadedDefaultSoldier2CommonPackage()
  if gvars.ene_soldier2CommonPackageLabelIndex==TppDefine.DEFAULT_SOLIDER2_COMMON_PACKAGE then
    return true
  else
    return false
  end
end
function this.LoadSoldier2CommonBlock()
  this.RegisterSoldier2CommonMotionPackagePath(mvars.ene_soldier2CommonBlockPackageLabel)
  while not TppSoldier2CommonBlockController.IsReady()do
    coroutine.yield()
  end
end
function this.UnloadSoldier2CommonBlock()
  TppSoldier2CommonBlockController.SetPackagePathWithPrerequisites{}
end
function this.SetMaxSoldierStateCount(e)
  if Tpp.IsTypeNumber(e)and(e>0)then
    mvars.ene_maxSoldierStateCount=e
  end
end
function this.RestoreOnMissionStart2()
  local t=0
  local a=0
  if EnemyFova~=nil then
    if EnemyFova.INVALID_FOVA_VALUE~=nil then
      t=EnemyFova.INVALID_FOVA_VALUE
      a=EnemyFova.INVALID_FOVA_VALUE
    end
  end
  local n=0
  if mvars.ene_cpList~=nil then
    for t,e in pairs(mvars.ene_cpList)do
      if n<mvars.ene_cpCount then
        svars.cpNames[n]=StrCode32(e)
        svars.cpFlags[n]=0
        n=n+1
      end
    end
  end
  for e=0,mvars.ene_maxSoldierStateCount-1 do
    svars.solName[e]=0
    svars.solState[e]=0
    svars.solFlagAndStance[e]=0
    svars.solWeapon[e]=0
    svars.solLocation[e*4+0]=0
    svars.solLocation[e*4+1]=0
    svars.solLocation[e*4+2]=0
    svars.solLocation[e*4+3]=0
    svars.solMarker[e]=0
    svars.solFovaSeed[e]=0
    svars.solFaceFova[e]=t
    svars.solBodyFova[e]=a
    svars.solCp[e]=0
    svars.solCpRoute[e]=GsRoute.ROUTE_ID_EMPTY
    svars.solScriptSneakRoute[e]=GsRoute.ROUTE_ID_EMPTY
    svars.solScriptCautionRoute[e]=GsRoute.ROUTE_ID_EMPTY
    svars.solScriptAlertRoute[e]=GsRoute.ROUTE_ID_EMPTY
    svars.solRouteNodeIndex[e]=0
    svars.solRouteEventIndex[e]=0
    svars.solTravelName[e]=0
    svars.solTravelStepIndex[e]=0
  end
  for e=0,TppDefine.DEFAULT_SOLDIER_OPTION_VARS_COUNT-1 do
    svars.solOptName[e]=0
    svars.solOptParam1[e]=0
    svars.solOptParam2[e]=0
  end
  if svars.passengerInfoName~=nil then
    for e=0,TppDefine.DEFAULT_PASSAGE_INFO_COUNT-1 do
      svars.passengerInfoName[e]=0
    end
  end
  if svars.passengerFlagName~=nil then
    for e=0,TppDefine.DEFAULT_PASSAGE_FLAG_COUNT-1 do
      svars.passengerFlagName[e]=0
    end
  end
  if svars.passengerNameName~=nil then
    for e=0,TppDefine.DEFAULT_PASSAGE_FLAG_COUNT-1 do
      svars.passengerNameName[e]=0
    end
  end
  if svars.passengerNameName~=nil then
    for e=0,TppDefine.DEFAULT_PASSAGE_FLAG_COUNT-1 do
      svars.passengerNameName[e]=0
    end
  end
  this._RestoreOnMissionStart_Hostage2()
  for e=0,TppDefine.DEFAULT_ENEMY_HELI_STATE_COUNT-1 do
    svars.enemyHeliName=0
    svars.enemyHeliLocation[0]=0
    svars.enemyHeliLocation[1]=0
    svars.enemyHeliLocation[2]=0
    svars.enemyHeliLocation[3]=0
    svars.enemyHeliCp=0
    svars.enemyHeliFlag=0
    svars.enemyHeliSneakRoute=0
    svars.enemyHeliCautionRoute=0
    svars.enemyHeliAlertRoute=0
    svars.enemyHeliRouteNodeIndex=0
    svars.enemyHeliRouteEventIndex=0
    svars.enemyHeliMarker=0
    svars.enemyHeliLife=0
  end
  for e=0,TppDefine.MAX_SECURITY_CAMERA_COUNT-1 do
    svars.securityCameraCp[e]=0
    svars.securityCameraMarker[e]=0
    svars.securityCameraFlag[e]=0
  end
end
function this.RestoreOnContinueFromCheckPoint2()
  do
    local e={type="TppCommandPost2"}
    SendCommand(e,{id="RestoreFromSVars"})
  end
  if GameObject.GetGameObjectIdByIndex("TppSoldier2",0)~=NULL_ID then
    local e={type="TppSoldier2"}
    SendCommand(e,{id="RestoreFromSVars"})
  end
  this._RestoreOnContinueFromCheckPoint_Hostage2()
  if GameObject.GetGameObjectIdByIndex("TppEnemyHeli",0)~=NULL_ID then
    local typeHeli={type="TppEnemyHeli"}
    SendCommand(typeHeli,{id="RestoreFromSVars"})
  end
  if GameObject.GetGameObjectIdByIndex("TppVehicle2",0)~=NULL_ID then
    SendCommand({type="TppVehicle2"},{id="RestoreFromSVars"})
  end
  if GameObject.GetGameObjectIdByIndex("TppCommonWalkerGear2",0)~=NULL_ID then
    SendCommand({type="TppCommonWalkerGear2"},{id="RestoreFromSVars"})
  end
  if GameObject.GetGameObjectIdByIndex("TppLiquid2",0)~=NULL_ID then
    SendCommand({type="TppLiquid2"},{id="RestoreFromSVars"})
  end
  if GameObject.GetGameObjectIdByIndex("TppUav",0)~=NULL_ID then
    SendCommand({type="TppUav"},{id="RestoreFromSVars"})
  end
  if GameObject.GetGameObjectIdByIndex("TppSecurityCamera2",0)~=NULL_ID then
    SendCommand({type="TppSecurityCamera2"},{id="RestoreFromSVars"})
  end
end
function this.RestoreOnContinueFromCheckPoint()
  this._RestoreOnContinueFromCheckPoint_Hostage()
end
function this.RestoreOnMissionStart()
  this._RestoreOnMissionStart_Hostage()
end
function this.StoreSVars(_markerOnly)
  local markerOnly=false
  if _markerOnly then
    markerOnly=true
  end
  do
    local tppCommandPost={type="TppCommandPost2"}
    SendCommand(tppCommandPost,{id="StoreToSVars"})
  end
  if GameObject.GetGameObjectIdByIndex("TppSoldier2",0)~=NULL_ID then
    local tppSoldier={type="TppSoldier2"}
    SendCommand(tppSoldier,{id="StoreToSVars",markerOnly=markerOnly})
  end
  this._StoreSVars_Hostage(markerOnly)
  if GameObject.GetGameObjectIdByIndex("TppEnemyHeli",0)~=NULL_ID then
    SendCommand({type="TppEnemyHeli"},{id="StoreToSVars"})
  end
  if GameObject.GetGameObjectIdByIndex("TppVehicle2",0)~=NULL_ID then
    SendCommand({type="TppVehicle2"},{id="StoreToSVars"})
  end
  if GameObject.GetGameObjectIdByIndex("TppCommonWalkerGear2",0)~=NULL_ID then
    SendCommand({type="TppCommonWalkerGear2"},{id="StoreToSVars"})
  end
  if GameObject.GetGameObjectIdByIndex("TppLiquid2",0)~=NULL_ID then
    SendCommand({type="TppLiquid2"},{id="StoreToSVars"})
  end
  if GameObject.GetGameObjectIdByIndex("TppUav",0)~=NULL_ID then
    SendCommand({type="TppUav"},{id="StoreToSVars"})
  end
  if GameObject.GetGameObjectIdByIndex("TppSecurityCamera2",0)~=NULL_ID then
    SendCommand({type="TppSecurityCamera2"},{id="StoreToSVars"})
  end
end
function this.PreMissionLoad(missionCode,currentMissionCode)
  this.InitializeHostage2()
  TppEneFova.PreMissionLoad(missionCode,currentMissionCode)
end
function this.InitializeHostage2()
  if TppHostage2.ClearHostageType then
    TppHostage2.ClearHostageType()
  end
  if TppHostage2.ClearUniquePartsPath then
    TppHostage2.ClearUniquePartsPath()
  end
end
function this.Init(missionTable)
  mvars.ene_routeAnimationGaniPathTable={
    {"SoldierLookWatch","/Assets/tpp/motion/SI_game/fani/bodies/enem/enemasr/enemasr_s_pat_idl_act_a.gani"},
    {"SoldierWipeFace","/Assets/tpp/motion/SI_game/fani/bodies/enem/enemasr/enemasr_s_pat_idl_act_d.gani"},
    {"SoldierYawn","/Assets/tpp/motion/SI_game/fani/bodies/enem/enemasr/enemasr_s_pat_idl_act_f.gani"},
    {"SoldierSneeze","/Assets/tpp/motion/SI_game/fani/bodies/enem/enemasr/enemasr_s_pat_idl_act_g.gani"},
    {"SoldierFootStep","/Assets/tpp/motion/SI_game/fani/bodies/enem/enemasr/enemasr_s_pat_idl_act_h.gani"},
    {"SoldierCough","/Assets/tpp/motion/SI_game/fani/bodies/enem/enemasr/enemasr_s_pat_idl_act_i.gani"},
    {"SoldierScratchHead","/Assets/tpp/motion/SI_game/fani/bodies/enem/enemasr/enemasr_s_pat_idl_act_o.gani"},
    {"SoldierHungry","/Assets/tpp/motion/SI_game/fani/bodies/enem/enemasr/enemasr_s_pat_idl_act_p.gani"},
    nil
  }
  mvars.ene_eliminateTargetList={}
  mvars.ene_routeSets={}
  mvars.ene_noShiftChangeGroupSetting={}
  this.messageExecTable=Tpp.MakeMessageExecTable(this.Messages())
  this.RegistCommonRoutePointMessage()
  if missionTable.enemy then
    if missionTable.enemy.parasiteSquadList then
      mvars.ene_parasiteSquadList=missionTable.enemy.parasiteSquadList
    end
    if missionTable.enemy.USE_COMMON_REINFORCE_PLAN then
      mvars.ene_useCommonReinforcePlan=true
    end
  end
  if mvars.loc_locationCommonTravelPlans then
    mvars.ene_lrrpNumberDefine={}
    for cpName,enum in pairs(mvars.loc_locationCommonTravelPlans.lrrpNumberDefine)do
      mvars.ene_lrrpNumberDefine[cpName]=enum
    end
    mvars.ene_cpLinkDefine=this.MakeCpLinkDefineTable(mvars.ene_lrrpNumberDefine,mvars.loc_locationCommonTravelPlans.cpLinkMatrix)
    mvars.ene_defaultTravelRouteGroup=mvars.loc_locationCommonTravelPlans.defaultTravelRouteGroup
    local lrrpNumberDefine
    if missionTable.enemy and missionTable.enemy.lrrpNumberDefine then
      lrrpNumberDefine=missionTable.enemy.lrrpNumberDefine
    end
    if lrrpNumberDefine then
      for cpName,enum in ipairs(missionTable.enemy.lrrpNumberDefine)do
        local endEnum=#mvars.ene_lrrpNumberDefine+1
        mvars.ene_lrrpNumberDefine[endEnum]=enum
        mvars.ene_lrrpNumberDefine[enum]=endEnum
      end
    end
    if missionTable.enemy and missionTable.enemy.cpLink then
      local cpLink=missionTable.enemy.cpLink
      for e,n in pairs(cpLink)do
        mvars.ene_cpLinkDefine[e]=mvars.ene_cpLinkDefine[e]or{}
        for a,n in ipairs(mvars.ene_lrrpNumberDefine)do
          mvars.ene_cpLinkDefine[n]=mvars.ene_cpLinkDefine[n]or{}
          if cpLink[e][n]then
            mvars.ene_cpLinkDefine[e][n]=true
            mvars.ene_cpLinkDefine[n][e]=true
          else
            mvars.ene_cpLinkDefine[e][n]=false
            mvars.ene_cpLinkDefine[n][e]=false
          end
        end
      end
    end
  end
  local skullFultonable
  local storySeq=TppStory.GetCurrentStorySequence()
  if storySeq>=TppDefine.STORY_SEQUENCE.CLEARD_METALLIC_ARCHAEA then
    skullFultonable=true
  else
    skullFultonable=false
  end
  local skullTypes={"TppBossQuiet2","TppParasite2"}
  for n,skullType in ipairs(skullTypes)do
    if GameObject.DoesGameObjectExistWithTypeName(skullType)then
      GameObject.SendCommand({type=skullType},{id="SetFultonEnabled",enabled=skullFultonable})
    end
  end
end
function this.RegistCommonRoutePointMessage()
end
function this.OnReload(n)
  this.messageExecTable=Tpp.MakeMessageExecTable(this.Messages())
  this.RegistCommonRoutePointMessage()
  if n.enemy then
    this.SetUpCommandPost()
    this.SetUpSwitchRouteFunc()
  end
end
function this.OnMessage(sender,messageId,arg0,arg1,arg2,arg3,strLogText)
  Tpp.DoMessage(this.messageExecTable,TppMission.CheckMessageOption,sender,messageId,arg0,arg1,arg2,arg3,strLogText)
end
--IN: missionTable.enemy.soldierDefine
function this.DefineSoldiers(soldierDefine)
  mvars.ene_soldierDefine={}
  Tpp.MergeTable(mvars.ene_soldierDefine,soldierDefine,true)

  mvars.ene_soldierIDList={}
  mvars.ene_cpList={}
  mvars.ene_baseCpList={}
  mvars.ene_outerBaseCpList={}
  mvars.ene_holdTimes={}
  mvars.ene_sleepTimes={}
  mvars.ene_lrrpTravelPlan={}
  mvars.ene_lrrpVehicle={}
  for cpName,cpDefine in pairs(soldierDefine)do
    local cpId=GetGameObjectId(cpName)
    if cpId==NULL_ID then
    else
      mvars.ene_cpList[cpId]=cpName
      mvars.ene_holdTimes[cpId]=this.DEFAULT_HOLD_TIME
      mvars.ene_sleepTimes[cpId]=this.DEFAULT_SLEEP_TIME
      mvars.ene_soldierIDList[cpId]={}
      if cpDefine.lrrpTravelPlan then
        mvars.ene_lrrpTravelPlan[cpId]=cpDefine.lrrpTravelPlan
      end
      if cpDefine.lrrpVehicle then
        mvars.ene_lrrpVehicle[cpId]=cpDefine.lrrpVehicle
      end
      for k,v in pairs(cpDefine)do
        if IsTypeString(k)then
          if not this.SOLDIER_DEFINE_RESERVE_TABLE_NAME[k]then
          end
        else
          local soldierId=GetGameObjectId(v)
          if soldierId==NULL_ID then
          else
            mvars.ene_soldierIDList[cpId][soldierId]=k
          end
        end
      end
    end
  end
end
function this.SetUpSoldiers()
  if not IsTypeTable(mvars.ene_soldierDefine)then
    return
  end

  InfMain.RandomizeCpSubTypeTable()--tex

  local missionId=TppMission.GetMissionID()
  for cpName,soldierList in pairs(mvars.ene_soldierDefine)do
    local cpId=GetGameObjectId(cpName)
    if cpId==NULL_ID then
    else
      if string.sub(cpName,-4)=="lrrp"then
        SendCommand(cpId,{id="SetLrrpCp"})
      end
      local cpType=string.sub(cpName,-2)
      if cpType=="ob"then
        GameObject.SendCommand(cpId,{id="SetOuterBaseCp"})
        mvars.ene_outerBaseCpList[cpId]=true
      end
      if cpType=="cp"then
        local addCpIntelTrap=true
        if cpName=="mafr_outland_child_cp"then
          addCpIntelTrap=false
        end
        if addCpIntelTrap then
          this.AddCpIntelTrapTable(cpName)
          mvars.ene_baseCpList[cpId]=true
        end
      end
      TppEmblem.SetUpCpEmblemTag(cpName,cpId)
      if mvars.loc_locationSiren then
        local locationSiren=mvars.loc_locationSiren[cpName]
        if locationSiren then
          SendCommand(cpId,{id="SetCpSirenType",type=locationSiren.sirenType,pos=locationSiren.pos})
        end
      end
      local setCpType
      if(missionId==10150 or missionId==10151)or missionId==11151 then
        setCpType={id="SetCpType",type=CpType.TYPE_AMERICA}
      elseif TppLocation.IsAfghan()then
        setCpType={id="SetCpType",type=CpType.TYPE_SOVIET}
      elseif TppLocation.IsMiddleAfrica()then
        setCpType={id="SetCpType",type=CpType.TYPE_AFRIKAANS}
      elseif TppLocation.IsMotherBase()or TppLocation.IsMBQF()then
        setCpType={id="SetCpType",type=CpType.TYPE_AMERICA}
      end
      if setCpType then
        GameObject.SendCommand(cpId,setCpType)
      end
    end
  end
  for t,cpName in pairs(mvars.ene_cpList)do
    if mvars.ene_baseCpList[t]then
      local soldierList=mvars.ene_soldierDefine[cpName]
      for t,soldierName in ipairs(soldierList)do
        local soldierId=GetGameObjectId(soldierName)
        if soldierId==NULL_ID then
        else
          SendCommand(soldierId,{id="AddRouteAssignMember"})
        end
      end
    end
  end
  for i,cpName in pairs(mvars.ene_cpList)do
    if not mvars.ene_baseCpList[i]then
      local cpSoldiers=mvars.ene_soldierDefine[cpName]
      for t,soldierName in ipairs(cpSoldiers)do
        local soldierId=GetGameObjectId(soldierName)
        if soldierId==NULL_ID then
        else
          SendCommand(soldierId,{id="AddRouteAssignMember"})
        end
      end
    end
  end
  this.AssignSoldiersToCP()
end
function this.AssignSoldiersToCP()
  local forceSubType=InfMain.enemySubTypes[gvars.forceSoldierSubType]--tex WIP
  if InfMain.IsForceSoldierSubType() then
    --TppUiCommand.AnnounceLogView("AssignSoldiersToCP:")--DEBUG CULL
    for cp, subType in pairs(this.subTypeOfCp)do
      --TppUiCommand.AnnounceLogView("AssignSoldiersToCPuu:")--DEBUG CULL
      this.subTypeOfCp[cp]=forceSubType
    end
  end
  local missionCode=TppMission.GetMissionID()
  this._ConvertSoldierNameKeysToId(mvars.ene_soldierTypes)
  mvars.ene_soldierSubType=mvars.ene_soldierSubType or{}
  --gvars.soldierTypeForced=gvars.soldierTypeForced or {}--tex WIP
  mvars.ene_soldierLrrp=mvars.ene_soldierLrrp or{}
  local subTypeOfCp=this.subTypeOfCp
  for cpId,soldierIds in pairs(mvars.ene_soldierIDList)do
    local cp=mvars.ene_cpList[cpId]
    local cpSubType=subTypeOfCp[cp]
    local isChild=false
    for soldierId,p in pairs(soldierIds)do
      --      if InfMain.IsForceSoldierSubType() then--tex> WIP TODO: Why is this hanging FOB?
      --        --InfMenu.DebugPrint("assigncp IsForceSoldierSubType soldierid:"..soldierId)
      --        --   gvars.soldierTypeForced[soldierId]=true
      --        --  InfMenu.DebugPrint("assigncp gvars.soldierTypeForced[soldierId ".. tostring(gvars.soldierTypeForced[soldierId]) )
      --        mvars.ene_soldierSubType[soldierId]=forceSubType
      --      end--<
      SendCommand(soldierId,{id="SetCommandPost",cp=cp})
      if mvars.ene_lrrpTravelPlan[cpId]then
        SendCommand(soldierId,{id="SetLrrp",travelPlan=mvars.ene_lrrpTravelPlan[cpId]})
        mvars.ene_soldierLrrp[soldierId]=true
        if mvars.ene_lrrpVehicle[cpId]then
          local lrrpVehicle=GameObject.GetGameObjectId("TppVehicle2",mvars.ene_lrrpVehicle[cpId])
          local command={id="SetRelativeVehicle",targetId=lrrpVehicle,rideFromBeginning=true}
          SendCommand(soldierId,command)
        end
      end
      local command
      local soldierType=this.GetSoldierType(soldierId)
      if InfMain.IsForceSoldierSubType() then--tex> WIP:
        this.SetSoldierType(soldierId,soldierType)--tex does a setsoldiertype
      end--<
      command={id="SetSoldier2Type",type=soldierType}
      SendCommand(soldierId,command)
      if(soldierType~=EnemyType.TYPE_SKULL and soldierType~=EnemyType.TYPE_CHILD)and cpSubType then
        mvars.ene_soldierSubType[soldierId]=cpSubType
      end
      if missionCode~=10080 and missionCode~=11080 then
        if soldierType==EnemyType.TYPE_CHILD then
          isChild=true
        end
      end
    end--for cp,soldier
    if isChild then
      SendCommand(cpId,{id="SetChildCp"})
    end
  end
end
function this.InitCpGroups()
  mvars.ene_cpGroups={}
end
function this.RegistCpGroups(n)
  this.SetCommonCpGroups()
  if IsTypeTable(n)then
    for e,n in pairs(n)do
      mvars.ene_cpGroups[e]=mvars.ene_cpGroups[e]or{}
      for t,n in pairs(n)do
        table.insert(mvars.ene_cpGroups[e],n)
      end
    end
  end
end
function this.SetCommonCpGroups()
  if not IsTypeTable(mvars.loc_locationCommonCpGroups)then
    return
  end
  for n,t in pairs(mvars.loc_locationCommonCpGroups)do
    if IsTypeTable(t)then
      mvars.ene_cpGroups[n]={}
      for e,a in pairs(mvars.ene_soldierDefine)do
        if t[e]then
          table.insert(mvars.ene_cpGroups[n],e)
        end
      end
    end
  end
end
function this.SetCpGroups()
  local t={type="TppCommandPost2"}
  local e={id="SetCpGroups",cpGroups=mvars.ene_cpGroups}
  SendCommand(t,e)
end
function this.RegistVehicleSettings(vehicleSettings)--missionTable.enemy.vehicleSettings ORPHANED: VERIFY:
  if not IsTypeTable(vehicleSettings)then
    return
end
mvars.ene_vehicleSettings=vehicleSettings
local instanceCount=0
for e,e in pairs(vehicleSettings)do
  instanceCount=instanceCount+1
end
mvars.ene_vehicleDefine=mvars.ene_vehicleDefine or{}
mvars.ene_vehicleDefine.instanceCount=instanceCount
end
--NMC vehicleSpawnList = *_enemy.lua .VEHICLE_SPAWN_LIST
function this.SpawnVehicles(vehicleSpawnList)
  for t,spawnInfo in ipairs(vehicleSpawnList)do
    this.SpawnVehicle(spawnInfo)
  end
end
function this.SpawnVehicle(spawnInfo)
  if not IsTypeTable(spawnInfo)then
    return
  end
  if spawnInfo.id~="Spawn"then
    spawnInfo.id="Spawn"
  end
  local locator=spawnInfo.locator
  if not locator then
    return
  end
  local e=GameObject.SendCommand({type="TppVehicle2"},spawnInfo)
  if not e then
  end
end
function this.RespawnVehicle(spawnInfo)
  if not IsTypeTable(spawnInfo)then
    return
  end
  if spawnInfo.id~="Respawn"then
    spawnInfo.id="Respawn"
  end
  local n=spawnInfo.name
  if not n then
    return
  end
  local e=GameObject.SendCommand({type="TppVehicle2"},spawnInfo)
  if not e then
  end
end
function this.DespawnVehicles(despawnList)
  for t,spawnInfo in ipairs(despawnList)do
    this.DespawnVehicle(spawnInfo)
  end
end
function this.DespawnVehicle(spawnInfo)
  if not IsTypeTable(spawnInfo)then
    return
  end
  if spawnInfo.id~="Despawn"then
    spawnInfo.id="Despawn"
  end
  local locator=spawnInfo.locator
  if not locator then
    return
  end
  local e=GameObject.SendCommand({type="TppVehicle2"},spawnInfo)
  if not e then
  end
end
function this.SetUpVehicles()--ORPHANED
  if mvars.ene_vehicleSettings==nil then
    return
end
for locator,e in pairs(mvars.ene_vehicleSettings)do
  if(IsTypeString(locator)and IsTypeTable(e))and e.type then
    local command={id="Spawn",locator=locator,type=e.type}
    if e.subType then
      command.subType=e.subType
    end
    SendCommand({type="TppVehicle2"},command)
  end
end
end
function this.AddCpIntelTrapTable(e)
  mvars.ene_cpIntelTrapTable=mvars.ene_cpIntelTrapTable or{}
  mvars.ene_cpIntelTrapTable[e]="trap_intel_"..e
end
function this.GetCpIntelTrapTable()
  return mvars.ene_cpIntelTrapTable
end
function this.GetCurrentRouteSetType(routeTypeStr32,phase,r)
  local SetForTime=function(n,timeOfDay)
    if not timeOfDay then
      timeOfDay=TppClock.GetTimeOfDayIncludeMidNight()
    end
    local e="sneak"..("_"..timeOfDay)
    if n then
      local n=not next(mvars.ene_routeSets[n].sneak_midnight)
      if e=="sneak_midnight"and n then
        e="sneak_night"end
    end
    return e
  end
  if routeTypeStr32==0 then
    routeTypeStr32=false
  end
  local routeSetType
  if routeTypeStr32 then
    local routeSetType=this.ROUTE_SET_TYPETAG[routeTypeStr32]
    if routeSetType=="travel"then
      return"travel"
    end
    if routeSetType=="hold"then
      return"hold"
    end
    if routeSetType=="sleep"then
      return"sleep"
    end
    if phase==this.PHASE.SNEAK then
      routeSetType=SetForTime(r,routeSetType)
    else
      routeSetType="caution"
    end
  else
    if phase==this.PHASE.SNEAK then
      routeSetType=SetForTime(r)
    else
      routeSetType="caution"end
  end
  return routeSetType
end
function this.GetPrioritizedRouteTable(e,n,t,r)
  local i={}
  local a=t[e]
  if not IsTypeTable(a)then
    return
  end
  if mvars.ene_funcRouteSetPriority then
    i=mvars.ene_funcRouteSetPriority(e,n,t,r)
  else
    local t=0
    for a,e in ipairs(a)do
      if n[e]then
        local e=#n[e]
        if e>t then
          t=e
        end
      end
    end
    local e=1
    for r=1,t do
      for a,t in ipairs(a)do
        local n=n[t]
        if n then
          local n=n[r]
          if n and Tpp.IsTypeTable(n)then
            i[e]=n
            e=e+1
          end
        end
      end
    end
    for r=1,t do
      for a,t in ipairs(a)do
        local n=n[t]
        if n then
          local n=n[r]
          if n and not Tpp.IsTypeTable(n)then
            i[e]=n
            e=e+1
          end
        end
      end
    end
  end
  return i
end
function this.RouteSelector(cpId,i,a)
  local t=mvars.ene_routeSets[cpId]
  if t==nil then
    return{"dummyRoute"}
  end
  if a==StrCode32"immediately"then
    if i==StrCode32"old"then
      local t=this.GetCurrentRouteSetType(nil,this.GetPhaseByCPID(cpId),cpId)
      return this.GetPrioritizedRouteTable(cpId,mvars.ene_routeSetsTemporary[cpId][t],mvars.ene_routeSetsPriorityTemporary)
    else
      local a=this.GetCurrentRouteSetType(nil,this.GetPhaseByCPID(cpId),cpId)
      return this.GetPrioritizedRouteTable(cpId,t[a],mvars.ene_routeSetsPriority)
    end
  end
  if a==StrCode32"SYS_Sneak"then
    local i=this.GetCurrentRouteSetType(nil,this.PHASE.SNEAK,cpId)
    return this.GetPrioritizedRouteTable(cpId,t[i],mvars.ene_routeSetsPriority,a)
  end
  if a==StrCode32"SYS_Caution"then
    local i=this.GetCurrentRouteSetType(nil,this.PHASE.CAUTION,cpId)
    return this.GetPrioritizedRouteTable(cpId,t[i],mvars.ene_routeSetsPriority,a)
  end
  local i=this.GetCurrentRouteSetType(i,this.GetPhaseByCPID(cpId),cpId)
  local a=t[i][a]
  if a then
    return a
  else
    if i=="hold"then
      local a=this.GetCurrentRouteSetType(nil,this.GetPhaseByCPID(cpId),cpId)
      return this.GetPrioritizedRouteTable(cpId,t[a],mvars.ene_routeSetsPriority)
    else
      local a=this.GetCurrentRouteSetType(nil,this.GetPhaseByCPID(cpId),cpId)
      return this.GetPrioritizedRouteTable(cpId,t[a],mvars.ene_routeSetsPriority)
    end
  end
end
this.STR32_CAN_USE_SEARCH_LIGHT=StrCode32"CanUseSearchLight"
this.STR32_CAN_NOT_USE_SEARCH_LIGHT=StrCode32"CanNotUseSearchLight"
this.STR32_IS_GIMMICK_BROKEN=StrCode32"IsGimmickBroken"
this.STR32_IS_NOT_GIMMICK_BROKEN=StrCode32"IsNotGimmickBroken"
function this.SetUpSwitchRouteFunc()
  if not GameObject.DoesGameObjectExistWithTypeName"TppSoldier2"then
    return
  end
  SendCommand({type="TppSoldier2"},{id="SetSwitchRouteFunc",func=this.SwitchRouteFunc})
end
function this.SwitchRouteFunc(a,RENAMEgimmickState,gimmickName,a,a)
  if RENAMEgimmickState==this.STR32_CAN_USE_SEARCH_LIGHT then
    local gimmickId=mvars.gim_gimmackNameStrCode32Table[gimmickName]
    if TppGimmick.IsBroken{gimmickId=gimmickId}then
      return false
    else
      if TppClock.GetTimeOfDay()~="night"then
        return false
      end
      return true
    end
  end
  if RENAMEgimmickState==this.STR32_CAN_NOT_USE_SEARCH_LIGHT then
    local gimmickId=mvars.gim_gimmackNameStrCode32Table[gimmickName]
    if TppGimmick.IsBroken{gimmickId=gimmickId}then
      return true
    else
      if TppClock.GetTimeOfDay()~="night"then
        return true
      end
      return false
    end
  end
  if RENAMEgimmickState==this.STR32_IS_GIMMICK_BROKEN then
    local gimmickId=mvars.gim_gimmackNameStrCode32Table[gimmickName]
    if TppGimmick.IsBroken{gimmickId=gimmickId}then
      return true
    else
      return false
    end
  end
  if RENAMEgimmickState==this.STR32_IS_NOT_GIMMICK_BROKEN then
    local gimmickId=mvars.gim_gimmackNameStrCode32Table[gimmickName]
    if TppGimmick.IsBroken{gimmickId=gimmickId}then
      return false
    else
      return true
    end
  end
  return true
end
function this.SetUpCommandPost()
  if not IsTypeTable(mvars.ene_soldierIDList)then
    return
  end
  for cpId,a in pairs(mvars.ene_cpList)do
    SendCommand(cpId,{id="SetRouteSelector",func=this.RouteSelector})
  end
end
function this.RegisterRouteAnimation()
  if TppRouteAnimationCollector then
    TppRouteAnimationCollector.ClearGaniPath()
    TppRouteAnimationCollector.RegisterGaniPath(mvars.ene_routeAnimationGaniPathTable)
  end
end
function this.MergeRouteSetDefine(o)
  local function i(n,t)
    if t.priority then
      mvars.ene_routeSetsDefine[n].priority={}
      mvars.ene_routeSetsDefine[n].fixedShiftChangeGroup={}
      for e=1,#(t.priority)do
        mvars.ene_routeSetsDefine[n].priority[e]=t.priority[e]
      end
    end
    if t.fixedShiftChangeGroup then
      for e=1,#(t.fixedShiftChangeGroup)do
        mvars.ene_routeSetsDefine[n].fixedShiftChangeGroup[e]=t.fixedShiftChangeGroup[e]
      end
    end
    for a,e in pairs(this.ROUTE_SET_TYPES)do
      mvars.ene_routeSetsDefine[n][e]=mvars.ene_routeSetsDefine[n][e]or{}
      if t[e]then
        for t,a in pairs(t[e])do
          mvars.ene_routeSetsDefine[n][e][t]={}
          if IsTypeTable(a)then
            for i,a in ipairs(a)do
              mvars.ene_routeSetsDefine[n][e][t][i]=a
            end
          end
        end
      end
    end
  end
  for e,t in pairs(o)do
    mvars.ene_routeSetsDefine[e]=mvars.ene_routeSetsDefine[e]or{}
    local t=t
    if t.walkergearpark then
      local e=GetGameObjectId(e)SendCommand(e,{id="SetWalkerGearParkRoute",routes=t.walkergearpark})
    end
    if mvars.loc_locationCommonRouteSets then
      if mvars.loc_locationCommonRouteSets[e]then
        if mvars.loc_locationCommonRouteSets[e].outofrain then
          local a=GetGameObjectId(e)
          if t.outofrain then
            SendCommand(a,{id="SetOutOfRainRoute",routes=t.outofrain})
          else
            SendCommand(a,{id="SetOutOfRainRoute",routes=mvars.loc_locationCommonRouteSets[e].outofrain})
          end
        end
      end
      if t.USE_COMMON_ROUTE_SETS then
        if mvars.loc_locationCommonRouteSets[e]then
          i(e,mvars.loc_locationCommonRouteSets[e])
        end
      end
    end
    i(e,t)
  end
end
function this.UpdateRouteSet(n)
  for n,t in pairs(n)do
    local n=GetGameObjectId(n)
    if n==NULL_ID then
    else
      mvars.ene_routeSets[n]=mvars.ene_routeSets[n]or{}
      if t.priority then
        mvars.ene_routeSetsPriority[n]={}
        mvars.ene_routeSetsFixedShiftChange[n]={}
        for e=1,#(t.priority)do
          mvars.ene_routeSetsPriority[n][e]=StrCode32(t.priority[e])
        end
      end
      if t.fixedShiftChangeGroup then
        for e=1,#(t.fixedShiftChangeGroup)do
          mvars.ene_routeSetsFixedShiftChange[n][StrCode32(t.fixedShiftChangeGroup[e])]=e
        end
      end
      if mvars.ene_noShiftChangeGroupSetting[n]then
        for t,e in pairs(mvars.ene_noShiftChangeGroupSetting[n])do
          mvars.ene_routeSetsFixedShiftChange[n][t]=e
        end
      end
      for a,e in pairs(this.ROUTE_SET_TYPES)do
        mvars.ene_routeSets[n][e]=mvars.ene_routeSets[n][e]or{}
        if t[e]then
          for t,a in pairs(t[e])do
            mvars.ene_routeSets[n][e][StrCode32(t)]=mvars.ene_routeSets[n][e][StrCode32(t)]or{}
            if type(a)=="number"then
            else
              for a,i in ipairs(a)do
                mvars.ene_routeSets[n][e][StrCode32(t)][a]=i
              end
            end
          end
        end
      end
    end
  end
end
function this.RegisterRouteSet(n)
  mvars.ene_routeSetsDefine={}
  this.MergeRouteSetDefine(n)
  mvars.ene_routeSets={}
  mvars.ene_routeSetsPriority={}
  mvars.ene_routeSetsFixedShiftChange={}
  this.UpdateRouteSet(mvars.ene_routeSetsDefine)
  TppClock.RegisterClockMessage("ShiftChangeAtNight",TppClock.DAY_TO_NIGHT)
  TppClock.RegisterClockMessage("ShiftChangeAtMorning",TppClock.NIGHT_TO_DAY)
  TppClock.RegisterClockMessage("ShiftChangeAtMidNight",TppClock.NIGHT_TO_MIDNIGHT)
end
function this._InsertShiftChangeUnit(t,a,n)
  for e,i in pairs(mvars.ene_shiftChangeTable[t])do
    if n[e]and next(n[e])then
      if n[e].hold then
        mvars.ene_shiftChangeTable[t][e][a*2-1]={n[e].start,n[e].hold,holdTime=n[e].holdTime}
        mvars.ene_shiftChangeTable[t][e][a*2]={n[e].hold,n[e].goal}
      else
        mvars.ene_shiftChangeTable[t][e][a*2-1]={n[e].start,n[e].goal}
        mvars.ene_shiftChangeTable[t][e][a*2]="dummy"end
    end
  end
end
function this._GetShiftChangeRouteGroup(n,r,a,l,p,i,s,t)
  local e=(r-a)+1
  local o=a
  if t[n[a]]then
    e=o
  else
    local i=0
    for a=1,a do
      if t[n[a]]then
        i=i+1
      end
    end
    e=e+i
    local a=0
    for i=e,r do
      if t[n[i]]then
        a=a+1
      end
    end
    e=e-a
    local a=e
    local i=0
    local r=t[n[a]]
    while r do
      i=i+1
      a=a-1
      r=t[n[a]]
    end
    e=e-i
  end
  local a=n[e]
  local t="default"if l[i]then
    t=i
  end
  local e=nil
  if s then
    e="default"if p[i]then
      e=i
    end
  end
  local n=n[o]
  return a,t,e,n
end
function this._MakeShiftChangeUnit(t,a,n,r,o,_,T,d,i,c,l)
  if mvars.ene_noShiftChangeGroupSetting[t]and mvars.ene_noShiftChangeGroupSetting[t][n]then
    return nil
  end
  local n,i,e,a=this._GetShiftChangeRouteGroup(a,d,i,r,_,n,o,l)
  local e={}
  for n,t in pairs(mvars.ene_shiftChangeTable[t])do
    e[n]={}
  end
  if(i~="default")or(IsTypeTable(r[StrCode32"default"])and next(r[StrCode32"default"]))then
    e.shiftAtNight.start={"day",n}
    e.shiftAtNight.hold={"hold",i}
    e.shiftAtNight.holdTime=mvars.ene_holdTimes[t]
    e.shiftAtNight.goal={"night",a}
    e.shiftAtMorning.hold={"hold",i}
    e.shiftAtMorning.holdTime=mvars.ene_holdTimes[t]
    e.shiftAtMorning.goal={"day",a}
  else
    e.shiftAtNight.start={"day",n}
    e.shiftAtNight.goal={"night",a}
    e.shiftAtMorning.goal={"day",a}
  end
  if o then
    e.shiftAtMidNight.start={"night",n}
    e.shiftAtMidNight.hold={"sleep",i}
    e.shiftAtMidNight.holdTime=mvars.ene_sleepTimes[t]
    if T then
      e.shiftAtMidNight.goal={"midnight",a}
    else
      e.shiftAtMidNight.goal={"night",n}
    end
    e.shiftAtMorning.start={"midnight",n}
  else
    e.shiftAtMorning.start={"night",n}
  end
  return e
end
function this.MakeShiftChangeTable()
  mvars.ene_shiftChangeTable={}
  for n,a in pairs(mvars.ene_routeSetsPriority)do
    if not IsTypeTable(a)then
      return
    end
    local i=false
    local o=false
    if next(mvars.ene_routeSets[n].sleep)then
      mvars.ene_shiftChangeTable[n]={shiftAtNight={},shiftAtMorning={},shiftAtMidNight={}}i=true
      if next(mvars.ene_routeSets[n].sneak_midnight)then
        o=true
      end
    else
      mvars.ene_shiftChangeTable[n]={shiftAtNight={},shiftAtMorning={}}
    end
    local p=mvars.ene_routeSets[n].hold
    local s=nil
    if i then
      s=mvars.ene_routeSets[n].sleep
    end
    local t=1
    local l=#a
    for _,d in ipairs(a)do
      local r
      r=this._MakeShiftChangeUnit(n,a,d,p,i,s,o,l,_,t,mvars.ene_routeSetsFixedShiftChange[n])
      if r then
        this._InsertShiftChangeUnit(n,t,r)t=t+1
      end
    end
  end
end
function this.ShiftChangeByTime(t)
  if TppLocation.IsMotherBase()or TppLocation.IsMBQF()then
    return
  end
  if not IsTypeTable(mvars.ene_shiftChangeTable)then
    return
  end
  for cpId,schedules in pairs(mvars.ene_shiftChangeTable)do
    if schedules[t]then
      SendCommand(cpId,{id="ShiftChange",schedule=schedules[t]})
    end
  end
end
local function CloserToPlayerThanDistSqr(checkDistSqr,playerPosition,gameId)
  local position=SendCommand(gameId,{id="GetPosition"})
  local dirVector=playerPosition-position
  local distSqr=dirVector:GetLengthSqr()
  if distSqr>checkDistSqr then
    return false
  else
    return true
  end
end
function this.MakeCpLinkDefineTable(t,e)
  local n={}
  for a=1,#e do
    local i=Tpp.SplitString(e[a],"	")
    local e=t[a]
    if e then
      n[e]=n[e]or{}
      for a,i in pairs(i)do
        local t=t[a]
        if t then
          n[e][t]=n[e][t]or{}
          local a=false
          if tonumber(i)>0 then
            a=true
          end
          n[e][t]=a
        end
      end
    end
  end
  return n
end
function this.MakeReinforceTravelPlan(lrrpNumberDefine,cpLinkDefine,locationName,toCp,n)
  if not Tpp.IsTypeTable(n)then
    return
  end
  local a=cpLinkDefine[toCp]
  if a==nil then
    return
  end
  mvars.ene_travelPlans=mvars.ene_travelPlans or{}
  local r=0
  for r,fromCp in pairs(n)do
    if mvars.ene_soldierDefine[fromCp]then
      if a[fromCp]then
        local lrrpNumToCp=lrrpNumberDefine[toCp]
        local lrrpNumFromCp=lrrpNumberDefine[fromCp]
        local reinforcePlan="rp_"..(toCp..("_From_"..fromCp))
        mvars.ene_travelPlans[reinforcePlan]=mvars.ene_travelPlans[reinforcePlan]or{}
        local  lrrpRoute=string.format("rp_%02dto%02d",lrrpNumFromCp,lrrpNumToCp)
        local lrrpCp=this.GetFormattedLrrpCpNameByLrrpNum(lrrpNumToCp,lrrpNumFromCp,locationName,lrrpNumberDefine)
        mvars.ene_travelPlans[reinforcePlan]={{cp=lrrpCp,routeGroup={"travel",lrrpRoute}},{cp=toCp,finishTravel=true}}
        mvars.ene_reinforcePlans[reinforcePlan]={{toCp=toCp,fromCp=fromCp,type="respawn"}}
      end
    end
  end
end
function this.MakeTravelPlanTable(lrrpNumberDefine,cpLinkDefine,locationName,planName,cpPlans,holdTime)
  if((not Tpp.IsTypeTable(cpPlans)or not Tpp.IsTypeTable(cpPlans[1]))or not Tpp.IsTypeString(planName))or(cpPlans[1].cp==nil and cpPlans[1].base==nil)then
    return
  end
  mvars.ene_travelPlans=mvars.ene_travelPlans or{}
  mvars.ene_travelPlans[planName]=mvars.ene_travelPlans[planName]or{}
  local travelPlan=mvars.ene_travelPlans[planName]
  local numCpPlans=#cpPlans
  local r,i
  if(not cpPlans.ONE_WAY)and cpPlans[#cpPlans].base then
    r=cpPlans[#cpPlans]
  end
  for n=1,numCpPlans do
    local oneWay
    if cpPlans.ONE_WAY and(n==numCpPlans)then
      oneWay=true
    end
    if cpPlans[n].base then
      if n==1 then
        i=cpPlans[n]
      else
        r=cpPlans[n-1]
        i=cpPlans[n]
      end
      this.AddLinkedBaseTravelCourse(lrrpNumberDefine,cpLinkDefine,locationName,holdTime,travelPlan,r,i,oneWay)
    elseif cpPlans[n].cp then
      local plan=cpPlans[n]
      if IsTypeTable(plan)then
        this.AddTravelCourse(travelPlan,plan,oneWay)
      end
    end
  end
end
function this.AddLinkedBaseTravelCourse(lrrpNumberDefine,cpLinkDefine,locationName,holdTime,travelPlan,a,t,d)
  local n
  if a and a.base then
    n=a.base
  end
  local a=t.base
  local o=false
  if n then
    o=cpLinkDefine[n][a]
  end
  if o then
    local lrrpCpName,n=this.GetFormattedLrrpCpName(n,a,locationName,lrrpNumberDefine)
    local n={cp=lrrpCpName,routeGroup={"travel",n}}
    this.AddTravelCourse(travelPlan,n)
  elseif n==nil then
  end
  local wait
  if t.wait then
    wait=t.wait
  else
    wait=holdTime
  end
  local routeGroup
  if t.routeGroup and Tpp.IsTypeTable(t.routeGroup)then
    routeGroup={t.routeGroup[1],t.routeGroup[2]}
  else
    local t
    local e=mvars.ene_defaultTravelRouteGroup
    if((e and o)and e[n])and Tpp.IsTypeTable(e[n][a])then
      t=e[n][a]
    end
    if t then
      routeGroup={t[1],t[2]}
    else
      routeGroup={"travel","lrrpHold"}
    end
  end
  local n={cp=a,routeGroup=routeGroup,wait=wait}
  this.AddTravelCourse(travelPlan,n,d)
end
function this.GetFormattedLrrpCpNameByLrrpNum(lrrpNumToCp,lrrpNumFromCp,locationName,lrrpNumberDefine)
  local t,a
  if lrrpNumToCp<lrrpNumFromCp then
    t=lrrpNumToCp
    a=lrrpNumFromCp
  else
    t=lrrpNumFromCp
    a=lrrpNumToCp
  end
  local lrrpCpName=string.format("%s_%02d_%02d_lrrp",locationName,t,a)
  local e=string.format("lrrp_%02dto%02d",lrrpNumToCp,lrrpNumFromCp)
  return lrrpCpName,e
end
function this.GetFormattedLrrpCpName(a,t,locationName,lrrpNumberDefine)
  local lrrpNumToCp=lrrpNumberDefine[a]
  local lrrpNumFromCp=lrrpNumberDefine[t]
  return this.GetFormattedLrrpCpNameByLrrpNum(lrrpNumToCp,lrrpNumFromCp,locationName,lrrpNumberDefine)
end
function this.AddTravelCourse(travelPlan,plan,oneWay)
  if oneWay then
    plan.finishTravel=true
  else
    plan.finishTravel=nil
  end
  table.insert(travelPlan,plan)
end
--REF travelPlans
--={
--  travelArea1_02 = {
--    { cp="afgh_21_28_lrrp",     routeGroup={ "travel", "lrrp_28to21" }, },
--    ...
--  },
--  travelvillageEast = {
--    { base = "afgh_villageEast_ob", },
--    ...
--   },
--}
function this.SetTravelPlans(travelPlans)--missionTable.enemy.travelPlans
  mvars.ene_reinforcePlans={}
  mvars.ene_travelPlans={}
  if mvars.loc_locationCommonTravelPlans then
    local locationName=TppLocation.GetLocationName()
    if locationName then
      local lrrpNumberDefine=mvars.ene_lrrpNumberDefine
      local cpLinkDefine=mvars.ene_cpLinkDefine
      for planName,cpPlans in pairs(travelPlans)do
        this.MakeTravelPlanTable(lrrpNumberDefine,cpLinkDefine,locationName,planName,cpPlans,this.DEFAULT_TRAVEL_HOLD_TIME)
      end
      local reinforceTravelPlan=mvars.loc_locationCommonTravelPlans.reinforceTravelPlan
      if mvars.ene_useCommonReinforcePlan and reinforceTravelPlan then
        for cpName,i in pairs(reinforceTravelPlan)do
          if mvars.ene_soldierDefine[cpName]then
            this.MakeReinforceTravelPlan(lrrpNumberDefine,cpLinkDefine,locationName,cpName,i)
          end
        end
      end
    end
  else
    mvars.ene_travelPlans=travelPlans
  end
  SendCommand({type="TppSoldier2"},{id="SetTravelPlan",travelPlan=mvars.ene_travelPlans})
  if next(mvars.ene_reinforcePlans)then
    SendCommand({type="TppCommandPost2"},{id="SetReinforcePlan",reinforcePlan=mvars.ene_reinforcePlans})
  end
end
function this.RegistHoldBrokenState(n)
  if not IsTypeString(n)then
    return
  end
  local t=GetGameObjectId(n)
  if t==NULL_ID then
    return
  end
  local e=this.AddBrokenStateList(n)
  if not e then
    return
  end
  mvars.ene_vehicleBrokenStateIndexByName=mvars.ene_vehicleBrokenStateIndexByName or{}
  mvars.ene_vehicleBrokenStateIndexByName[n]=e
  mvars.ene_vehicleBrokenStateIndexByGameObjectId=mvars.ene_vehicleBrokenStateIndexByGameObjectId or{}
  mvars.ene_vehicleBrokenStateIndexByGameObjectId[t]=e
end
function this.AddBrokenStateList(n)
  local e
  local a=StrCode32(n)
  for n=0,(TppDefine.MAX_HOLD_VEHICLE_BROKEN_STATE_COUNT-1)do
    local t=svars.ene_holdBrokenStateName[n]
    if(t==0)or(t==a)then
      e=n
      break
    end
  end
  if e then
    svars.ene_holdBrokenStateName[e]=a
    return e
  else
    return
  end
end
function this._OnHeliBroken(gameId,state)
  if state==StrCode32"Start"then
    this.PlayTargetEliminatedRadio(gameId)
  end
end
function this._OnVehicleBroken(vehicleId,state)
  this.SetVehicleBroken(vehicleId)
  if state==StrCode32"End"then
    this.PlayTargetEliminatedRadio(vehicleId)
  end
end
function this._OnWalkerGearBroken(walkerId,state)
  if state==StrCode32"End"then
    this.PlayTargetEliminatedRadio(walkerId)
  end
end
function this.SetVehicleBroken(vehicleId)
  if not mvars.ene_vehicleBrokenStateIndexByGameObjectId then
    return
  end
  local brokenStateIndex=mvars.ene_vehicleBrokenStateIndexByGameObjectId[vehicleId]
  if brokenStateIndex then
    svars.ene_isVehicleBroken[brokenStateIndex]=true
  end
end
function this.IsVehicleBroken(vehicleNameOrId)
  local vehicleId
  if IsTypeString(vehicleNameOrId)then
    vehicleId=mvars.ene_vehicleBrokenStateIndexByName[vehicleNameOrId]
  elseif IsTypeNumber(vehicleNameOrId)then
    vehicleId=mvars.ene_vehicleBrokenStateIndexByGameObjectId[vehicleNameOrId]
  end
  if vehicleId then
    return svars.ene_isVehicleBroken[vehicleId]
  end
end
function this.IsVehicleAlive(vehicleNameOrId)
  local vehicleId
  if IsTypeString(vehicleNameOrId)then
    vehicleId=GetGameObjectId(vehicleNameOrId)
  elseif IsTypeNumber(vehicleNameOrId)then
    vehicleId=vehicleNameOrId
  end
  if vehicleId==NULL_ID then
    return
  end
  return SendCommand(vehicleId,{id="IsAlive"})
end
function this.PlayTargetRescuedRadio(gameId)
  local isEliminateTarget=this.IsEliminateTarget(gameId)
  local isRescueTarget=this.IsRescueTarget(gameId)
  if isEliminateTarget then
    TppRadio.PlayCommonRadio(TppDefine.COMMON_RADIO.TARGET_ELIMINATED)
  elseif isRescueTarget then
    TppRadio.PlayCommonRadio(TppDefine.COMMON_RADIO.TARGET_RECOVERED)
  end
end
function this.PlayTargetEliminatedRadio(gameId)
  local isEliminateTarget=this.IsEliminateTarget(gameId)
  if isEliminateTarget then
    TppRadio.PlayCommonRadio(TppDefine.COMMON_RADIO.TARGET_ELIMINATED)
  end
end
function this.RegistHoldRecoveredState(name)
  if not IsTypeString(name)then
    return
  end
  local gameId=GetGameObjectId(name)
  if gameId==NULL_ID then
    return
  end
  local index=this.AddRecoveredStateList(name)
  if not index then
    return
  end
  mvars.ene_recoverdStateIndexByName=mvars.ene_recoverdStateIndexByName or{}
  mvars.ene_recoverdStateIndexByName[name]=index
  mvars.ene_recoverdStateIndexByGameObjectId=mvars.ene_recoverdStateIndexByGameObjectId or{}
  mvars.ene_recoverdStateIndexByGameObjectId[gameId]=index
end
function this.AddRecoveredStateList(name)
  local index
  local strCodeName=StrCode32(name)
  for i=0,(TppDefine.MAX_HOLD_RECOVERED_STATE_COUNT-1)do
    local holdRecoveredStateName=svars.ene_holdRecoveredStateName[i]
    if(holdRecoveredStateName==0)or(holdRecoveredStateName==strCodeName)then
      index=i
      break
    end
  end
  if index then
    svars.ene_holdRecoveredStateName[index]=strCodeName
    return index
  else
    return
  end
end
function this.SetRecovered(gameId)
  if not mvars.ene_recoverdStateIndexByGameObjectId then
    return
  end
  local index=mvars.ene_recoverdStateIndexByGameObjectId[gameId]
  if index then
    svars.ene_isRecovered[index]=true
  end
end
function this.ExecuteOnRecoveredCallback(gameId,r,i,t,a,o,s)
  if not mvars.ene_recoverdStateIndexByGameObjectId then
    return
  end
  local recoverdStateIndex=mvars.ene_recoverdStateIndexByGameObjectId[gameId]
  if not recoverdStateIndex then
    return
  end
  local OnRecovered
  if TppMission.systemCallbacks and TppMission.systemCallbacks.OnRecovered then
    OnRecovered=TppMission.systemCallbacks.OnRecovered
  end
  if not OnRecovered then
    return
  end
  if not TppMission.CheckMissionState(true,false,true,false)then
    return
  end
  OnRecovered(gameId,r,i,t,a,o,s)
end
local RENAMErescueDistSqr=10*10
function this.CheckAllVipClear(n)
  return this.CheckAllTargetClear(n)
end
function this.CheckAllTargetClear(n)
  local mvars=mvars
  local thisLocal=this--NMC: tihs pattern is used in two functions in other files. why? is it really that performant?
  local playerPosition=Vector3(vars.playerPosX,vars.playerPosY,vars.playerPosZ)
  TppHelicopter.SetNewestPassengerTable()
  local t={
    {mvars.ene_eliminateTargetList,thisLocal.CheckSoldierEliminateTarget,"EliminateTargetSoldier"},
    {mvars.ene_eliminateHelicopterList,thisLocal.CheckHelicopterEliminateTarget,"EliminateTargetHelicopter"},
    {mvars.ene_eliminateVehicleList,thisLocal.CheckVehicleEliminateTarget,"EliminateTargetVehicle"},
    {mvars.ene_eliminateWalkerGearList,thisLocal.CheckWalkerGearEliminateTarget,"EliminateTargetWalkerGear"},
    {mvars.ene_childTargetList,thisLocal.CheckRescueTarget,"childTarget"}
  }
  if mvars.ene_rescueTargetOptions then
    if not mvars.ene_rescueTargetOptions.orCheck then
      table.insert(t,{mvars.ene_rescueTargetList,thisLocal.CheckRescueTarget,"RescueTarget"})
    end
  end
  for e=1,#t do
    local e,n,t=t[e][1],t[e][2],t[e][3]
    if IsTypeTable(e)and next(e)then
      for e,t in pairs(e)do
        if not n(e,playerPosition,t)then
          return false
        end
      end
    end
  end
  if mvars.ene_rescueTargetOptions and mvars.ene_rescueTargetOptions.orCheck then
    local t=false
    for gameId,i in pairs(mvars.ene_rescueTargetList)do
      if thisLocal.CheckRescueTarget(gameId,playerPosition,i)then
        t=true
      end
    end
    return t
  end
  return true
end
function this.CheckSoldierEliminateTarget(gameId,i,a)
  local lifeStatus=SendCommand(gameId,{id="GetLifeStatus"})
  local status=SendCommand(gameId,{id="GetStatus"})
  if this._IsEliminated(lifeStatus,status)then
    return true
  elseif this._IsNeutralized(lifeStatus,status)then
    if CloserToPlayerThanDistSqr(RENAMErescueDistSqr,i,gameId)then
      return true
    else
      return false
    end
  end
  return false
end
function this.CheckHelicopterEliminateTarget(heliId,n,n)
  local isBroken=GameObject.SendCommand(heliId,{id="IsBroken"})
  if isBroken then
    return true
  else
    return false
  end
end
function this.CheckVehicleEliminateTarget(vehicleId,t,t)
  if this.IsRecovered(vehicleId)then
    return true
  elseif this.IsVehicleBroken(vehicleId)then
    return true
  else
    return false
  end
end
function this.CheckWalkerGearEliminateTarget(walkerId,n,n)
  local isBroken=GameObject.SendCommand(walkerId,{id="IsBroken"})
  if isBroken then
    return true
  elseif GameObject.SendCommand(walkerId,{id="IsFultonCaptured"})then
    return true
  else
    return false
  end
end
function this.CheckRescueTarget(gameId,playerPosition,a)
  if this.IsRecovered(gameId)then
    return true
  elseif CloserToPlayerThanDistSqr(RENAMErescueDistSqr,playerPosition,gameId)then
    return true
  elseif TppHelicopter.IsInHelicopter(gameId)then
    return true
  else
    return false
  end
end
function this.FultonRecoverOnMissionGameEnd()
  if mvars.ene_soldierIDList==nil then
    return
  end
  local playerPosition=Vector3(vars.playerPosX,vars.playerPosY,vars.playerPosZ)
  local checkDist=10
  local missionCode=TppMission.GetMissionID()
  if TppMission.IsFOBMission(missionCode)then
    checkDist=0
  end
  local distSqr=checkDist*checkDist
  local isHeli
  if Tpp.IsHelicopter(vars.playerVehicleGameObjectId)then
    isHeli=false
  else
    isHeli=true
  end
  local activeEnemyWalkerGearIdList=this.GetAllActiveEnemyWalkerGear()
  for t,gameId in pairs(activeEnemyWalkerGearIdList)do
    if CloserToPlayerThanDistSqr(distSqr,playerPosition,gameId)then
      local command={id="GetResourceId"}
      local resourceId=GameObject.SendCommand(gameId,command)
      TppTerminal.OnFulton(gameId,nil,nil,resourceId,true,isHeli,PlayerInfo.GetLocalPlayerIndex())
    end
  end
  TppHelicopter.SetNewestPassengerTable()
  TppTerminal.OnRecoverByHelicopterAlreadyGetPassengerList()
  for cpId,soldierIds in pairs(mvars.ene_soldierIDList)do
    for soldierId,r in pairs(soldierIds)do
      if CloserToPlayerThanDistSqr(distSqr,playerPosition,soldierId)and(not this.IsQuestNpc(soldierId))then
        this.AutoFultonRecoverNeutralizedTarget(soldierId,isHeli)
      end
    end
  end
  local hostageIdList=this.GetAllHostages()
  for r,hostageId in pairs(hostageIdList)do
    if((not TppHelicopter.IsInHelicopter(hostageId))and CloserToPlayerThanDistSqr(distSqr,playerPosition,hostageId))and(not this.IsQuestNpc(hostageId))then
      local staffId=TppMotherBaseManagement.GetStaffIdFromGameObject{gameObjectId=hostageId}
      TppTerminal.OnFulton(hostageId,nil,nil,staffId,true,isHeli,PlayerInfo.GetLocalPlayerIndex())
    end
  end
  TppHelicopter.ClearPassengerTable()
end
function this.AutoFultonRecoverNeutralizedTarget(gameId,a)
  local lifeStatus=SendCommand(gameId,{id="GetLifeStatus"})
  if lifeStatus==this.LIFE_STATUS.SLEEP or lifeStatus==this.LIFE_STATUS.FAINT then
    local staffId
    staffId=TppMotherBaseManagement.GetStaffIdFromGameObject{gameObjectId=gameId}
    TppTerminal.OnFulton(gameId,nil,nil,staffId,nil,a,PlayerInfo.GetLocalPlayerIndex())
  end
end
function this.CheckQuestTargetOnOutOfActiveArea(n)
  if not IsTypeTable(n)then
    return
  end
  local playerPosition=Vector3(vars.playerPosX,vars.playerPosY,vars.playerPosZ)
  local checkDist=10
  local distSqr=checkDist*checkDist
  local recovered=false
  for n,n in pairs(n)do
    local gameId=GetGameObjectId(soliderName)--RETAILBUG: TODO: investigate, soldiername was undefined assume its supposed to be key name - n, but there's no lua references to this. add an debug announcelog, grab a hostage and see what happens when you go out of hotzone (reuirees a mission with one) and out of mission area (all actual missions  have them)
    if gameId~=NULL_ID then
      if CloserToPlayerThanDistSqr(distSqr,playerPosition,gameId)then
        recovered=true
        this.AutoFultonRecoverNeutralizedTarget(gameId)
      end
    end
  end
  return recovered
end
function this.ChangeRouteUsingGimmick(route,a,gameId,a)
  local gimmickId=TppGimmick.GetRouteConnectedGimmickId(route)
  if(gimmickId~=nil)and TppGimmick.IsBroken{gimmickId=gimmickId}then
    local cpId
    for _cpId,soldierIds in pairs(mvars.ene_soldierIDList)do
      if soldierIds[gameId]then
        cpId=_cpId
        break
      end
    end
    if cpId then
      local command={id="SetRouteEnabled",routes={route},enabled=false}
      SendCommand(cpId,command)
    end
  else
    mvars.ene_usingGimmickRouteEnemyList=mvars.ene_usingGimmickRouteEnemyList or{}
    mvars.ene_usingGimmickRouteEnemyList[route]=mvars.ene_usingGimmickRouteEnemyList[route]or{}
    mvars.ene_usingGimmickRouteEnemyList[route]=gameId
    SendCommand(gameId,{id="SetSneakRoute",route=route})
  end
end
function this.DisableUseGimmickRouteOnShiftChange(a,e)
  if not IsTypeTable(e)then
    return
  end
  if mvars.ene_usingGimmickRouteEnemyList==nil then
    return
  end
  for t,route in pairs(e)do
    local strCodeRoute=StrCode32(route)
    local gameId=mvars.ene_usingGimmickRouteEnemyList[strCodeRoute]
    if gameId then
      SendCommand(gameId,{id="SetSneakRoute",route=""})
    end
    local gimmickId=mvars.gim_routeGimmickConnectTable[StrCode32(route)]
    if(gimmickId~=nil)and TppGimmick.IsBroken{gimmickId=gimmickId}then
      local command={id="SetRouteEnabled",routes={route},enabled=false}
      SendCommand(a,command)
    end
  end
end
function this.IsEliminateTarget(gameId)
  local isTarget=mvars.ene_eliminateTargetList and mvars.ene_eliminateTargetList[gameId]
  local isHeliTarget=mvars.ene_eliminateHelicopterList and mvars.ene_eliminateHelicopterList[gameId]
  local isVehicleTarget=mvars.ene_eliminateVehicleList and mvars.ene_eliminateVehicleList[gameId]
  local isWalkerTarget=mvars.ene_eliminateWalkerGearList and mvars.ene_eliminateWalkerGearList[gameId]
  local isEliminateTarget=((isTarget or isHeliTarget)or isVehicleTarget)or isWalkerTarget
  return isEliminateTarget
end
function this.IsRescueTarget(gameId)
  local isRescueTarget=mvars.ene_rescueTargetList and mvars.ene_rescueTargetList[gameId]
  return isRescueTarget
end
function this.IsChildTarget(gameId)
  local isChildTarget=mvars.ene_childTargetList and mvars.ene_childTargetList[gameId]
  return isChildTarget
end
function this.IsChildHostage(gameId)
  if IsTypeString(gameId)then
    gameId=GameObject.GetGameObjectId(gameId)
  end
  local isChild=GameObject.SendCommand(gameId,{id="IsChild"})
  return isChild
end
function this.IsFemaleHostage(gameId)
  if IsTypeString(gameId)then
    gameId=GameObject.GetGameObjectId(gameId)
  end
  local isFemale=GameObject.SendCommand(gameId,{id="isFemale"})
  return isFemale
end
function this.AddTakingOverHostage(gameId)
  local typeIndex=GameObject.GetTypeIndex(gameId)
  if(typeIndex~=TppGameObject.GAME_OBJECT_TYPE_HOSTAGE2)then
    return
  end
  if this.IsRecovered(gameId)then
    return
  end
  if TppHelicopter.IsInHelicopter(gameId)then
    return
  end
  if mvars.ene_ignoreTakingOverHostage and mvars.ene_ignoreTakingOverHostage[gameId]then
    return
  end
  if this.IsRescueTarget(gameId)then
    return
  end
  local markerEnabled=SendCommand(gameId,{id="GetMarkerEnabled"})
  if markerEnabled then
    this._AddTakingOverHostage(gameId)
  end
end
function this._AddTakingOverHostage(hostageId)
  if gvars.ene_takingOverHostageCount>=TppDefine.MAX_TAKING_OVER_HOSTAGE_COUNT then
    return
  end
  local takingOverHostageCount=gvars.ene_takingOverHostageCount
  local position=SendCommand(hostageId,{id="GetPosition"})
  local upperStaffId,lowerStffId=SendCommand(hostageId,{id="GetStaffId",divided=true})
  local faceId=SendCommand(hostageId,{id="GetFaceId"})
  local keepFlagValue=SendCommand(hostageId,{id="GetKeepFlagValue"})
  gvars.ene_takingOverHostagePositions[takingOverHostageCount*3+0]=position:GetX()
  gvars.ene_takingOverHostagePositions[takingOverHostageCount*3+1]=position:GetY()
  gvars.ene_takingOverHostagePositions[takingOverHostageCount*3+2]=position:GetZ()
  gvars.ene_takingOverHostageStaffIdsUpper[takingOverHostageCount]=upperStaffId
  gvars.ene_takingOverHostageStaffIdsLower[takingOverHostageCount]=lowerStffId
  gvars.ene_takingOverHostageFaceIds[takingOverHostageCount]=faceId
  gvars.ene_takingOverHostageFlags[takingOverHostageCount]=keepFlagValue
  gvars.ene_takingOverHostageCount=gvars.ene_takingOverHostageCount+1
end
function this.IsNeedHostageTakingOver(e)
  if TppMission.IsSysMissionId(vars.missionCode)then
    return false
  end
  if TppMission.IsHelicopterSpace(e)then
    return false
  end
  if(TppLocation.IsAfghan()or TppLocation.IsMiddleAfrica())then
    return true
  else
    return false
  end
end
function this.ResetTakingOverHostageInfo()
  gvars.ene_takingOverHostageCount=0
  for e=0,TppDefine.MAX_TAKING_OVER_HOSTAGE_COUNT-1 do
    for n=0,2 do
      gvars.ene_takingOverHostagePositions[e*3+n]=0
    end
    gvars.ene_takingOverHostageStaffIdsUpper[e]=0
    gvars.ene_takingOverHostageStaffIdsLower[e]=0
    gvars.ene_takingOverHostageFaceIds[e]=0
    gvars.ene_takingOverHostageFlags[e]=0
  end
end
function this.SpawnTakingOverHostage(n)
  if not IsTypeTable(n)then
    return
  end
  for n,t in ipairs(n)do
    this._SpawnTakingOverHostage(n-1,t)
  end
end
function this._SpawnTakingOverHostage(t,e)
  local e=GetGameObjectId(e)
  if e==NULL_ID then
    return
  end
  if t<gvars.ene_takingOverHostageCount then
    local i=gvars.ene_takingOverHostageStaffIdsUpper[infoIndex]--RETAILBUG: orphaned
    local a=gvars.ene_takingOverHostageStaffIdsLower[infoIndex]
    SendCommand(e,{id="SetStaffId",divided=true,staffId=i,staffId2=a})
    if TppMission.IsMissionStart()then
      SendCommand(e,{id="SetEnabled",enabled=true})
      local a=Vector3(gvars.ene_takingOverHostagePositions[t*3],gvars.ene_takingOverHostagePositions[t*3+1],gvars.ene_takingOverHostagePositions[t*3+2])
      SendCommand(e,{id="Warp",position=a})
      SendCommand(e,{id="SetFaceId",faceId=gvars.ene_takingOverHostageFaceIds[t]})
      SendCommand(e,{id="SetKeepFlagValue",keepFlagValue=gvars.ene_takingOverHostageFlags[t]})
    end
  else
    SendCommand(e,{id="SetEnabled",enabled=false})
  end
end
function this.SetIgnoreTakingOverHostage(e)
  if not IsTypeTable(e)then
    return
  end
  mvars.ene_ignoreTakingOverHostage=mvars.ene_ignoreTakingOverHostage or{}
  for n,e in ipairs(e)do
    local e=GetGameObjectId(e)
    if e~=NULL_ID then
      mvars.ene_ignoreTakingOverHostage[e]=true
    else
      return
    end
  end
end
function this.SetIgnoreDisableNpc(npcId,enable)
  local gameId
  if IsTypeNumber(npcId)then
    gameId=npcId
  elseif IsTypeString(npcId)then
    gameId=GetGameObjectId(npcId)
  else
    return
  end
  if gameId==NULL_ID then
    return
  end
  SendCommand(gameId,{id="SetIgnoreDisableNpc",enable=enable})
  return true
end

--REF: NpcEntrypointsetting
--    [Fox.StrCode32"lz_drp_swamp_I0000|rt_drp_swamp_I_0000"]={
--      [EntryBuddyType.VEHICLE]={Vector3(6.412,-5.952,294.757),TppMath.DegreeToRadian(-153.76)},
--      [EntryBuddyType.BUDDY]={Vector3(2.113,-5.436,299.302),-153.76}}
--      }
function this.NPCEntryPointSetting(settings)
  local npcsEntryPoints=settings[gvars.heli_missionStartRoute]
  if not npcsEntryPoints then
    return
  end
  for entryBuddyType,t in pairs(npcsEntryPoints)do
    local pos,rotY=t[1],t[2]
    TppBuddyService.SetMissionEntryPosition(entryBuddyType,pos)
    TppBuddyService.SetMissionEntryRotationY(entryBuddyType,rotY)
  end
end
function this.SetupQuestEnemy()
  local t="quest_cp"
  local n="gt_quest_0000"
  if mvars.ene_soldierDefine.quest_cp==nil then
    return
  end
  for n,soldierName in ipairs(mvars.ene_soldierDefine.quest_cp)do
    local soldierId=GameObject.GetGameObjectId("TppSoldier2",soldierName)
    if soldierId~=NULL_ID then
      GameObject.SendCommand(soldierId,{id="SetEnabled",enabled=false})
    end
  end
  TppCombatLocatorProvider.RegisterCombatLocatorSetToCpforLua{cpName=t,locatorSetName=n}
end
function this.OnAllocateQuest(body,face,a)
  local function SetAndConvertExtendFova(body,face)
    local fovaSetType="SetNone"
    if IsTypeTable(face)and IsTypeTable(body)then
      TppSoldierFace.SetAndConvertExtendFova{face=face,body=body}
      fovaSetType="SetFaceAndBody"
    elseif IsTypeTable(face)then
      TppSoldierFace.SetAndConvertExtendFova{face=face}
      fovaSetType="SetFace"
    elseif IsTypeTable(body)then
      TppSoldierFace.SetAndConvertExtendFova{body=body}
      fovaSetType="SetBody"
    end
    return fovaSetType
  end
  if face==nil and body==nil then
    return
  end
  a=a or false
  if a==false then
    local command
    local fovaSetType=SetAndConvertExtendFova(body,face)
    if fovaSetType=="SetFaceAndBody"then
      command={id="InitializeAndAllocateExtendFova",face=face,body=body}
    elseif fovaSetType=="SetFace"then
      command={id="InitializeAndAllocateExtendFova",face=face}
    elseif fovaSetType=="SetBody"then
      command={id="InitializeAndAllocateExtendFova",body=body}
    end
    GameObject.SendCommand({type="TppSoldier2"},command)
    GameObject.SendCommand({type="TppCorpse"},command)
  else
    if body then
      local hostageBodyTable={}
      for t,e in ipairs(body)do
        local t=e[1]
        if IsTypeNumber(t)then
          table.insert(hostageBodyTable,e[1])
        end
      end
      TppSoldierFace.SetBodyFovaUserType{hostage=hostageBodyTable}--RETAILBUG: hostageBodyTable is named and not minified in retail, and from context I suspect the table minified to n is what was intended, this is only called from mtbs_enemy, and with an empty table so as far as i can see it's not used (faces are though), however it does in OnAllocateQuestFova
    end
    --    if body then --ORIG, for ref for retailbug
    --      local n={}
    --      for t,e in ipairs(body)do
    --        local t=e[1]
    --        if IsTypeNumber(t)then
    --          table.insert(n,e[1])
    --        end
    --      end
    --      TppSoldierFace.SetBodyFovaUserType{hostage=hostageBodyTable}--RETAILBUG:
    --    end
    local fovaSetType=SetAndConvertExtendFova(body,face)
    if fovaSetType=="SetFaceAndBody"then
      TppSoldierFace.ReserveExtendFovaForHostage{face=face,body=body}
    elseif fovaSetType=="SetFace"then
      TppSoldierFace.ReserveExtendFovaForHostage{face=face}
    elseif fovaSetType=="SetBody"then
      TppSoldierFace.ReserveExtendFovaForHostage{body=body}
    end
  end
end
function this.OnAllocateQuestFova(questTable)
  local faces={}
  local bodies={}
  local setBody=false
  local setFace=false
  local setHostageBody=false
  local setHostageFace=false
  mvars.ene_questArmorId=0
  mvars.ene_questBalaclavaId=0
  if questTable.isQuestBalaclava==true then
    local balaclava={}
    if TppLocation.IsAfghan()then
      mvars.ene_questBalaclavaId=TppDefine.QUEST_FACE_ID_LIST.AFGH_BALACLAVA
    elseif TppLocation.IsMiddleAfrica()then
      mvars.ene_questBalaclavaId=TppDefine.QUEST_FACE_ID_LIST.MAFR_BALACLAVA
    end
    mvars.ene_questGetLoadedFaceTable=TppSoldierFace.GetLoadedFaceTable{}
    if mvars.ene_questGetLoadedFaceTable~=nil then
      local loadedFaceCount=#mvars.ene_questGetLoadedFaceTable
      if mvars.ene_questBalaclavaId~=0 and loadedFaceCount>0 then
        balaclava={mvars.ene_questBalaclavaId,TppDefine.QUEST_ENEMY_MAX,0}
        table.insert(faces,balaclava)
        setFace=true
      end
    end
  end
  if questTable.isQuestArmor==true then
    local armor={}
    if TppLocation.IsAfghan()then
      mvars.ene_questArmorId=TppDefine.QUEST_BODY_ID_LIST.AFGH_ARMOR
    elseif TppLocation.IsMiddleAfrica()then
      if questTable.soldierSubType=="PF_A"then
        mvars.ene_questArmorId=TppDefine.QUEST_BODY_ID_LIST.MAFR_ARMOR_CFA
      elseif questTable.soldierSubType=="PF_B"then
        mvars.ene_questArmorId=TppDefine.QUEST_BODY_ID_LIST.MAFR_ARMOR_ZRS
      elseif questTable.soldierSubType=="PF_C"then
        mvars.ene_questArmorId=TppDefine.QUEST_BODY_ID_LIST.MAFR_ARMOR_RC
      end
    end
    if mvars.ene_questArmorId~=0 then
      armor={mvars.ene_questArmorId,TppDefine.QUEST_ENEMY_MAX,0}
      table.insert(bodies,armor)
      setBody=true
    end
  end
  if(questTable.enemyList and Tpp.IsTypeTable(questTable.enemyList))and next(questTable.enemyList)then
    for n,enemyDef in pairs(questTable.enemyList)do
      if enemyDef.enemyName then
        if enemyDef.bodyId then
          local n=1
          local  body={enemyDef.bodyId,n,0}
          table.insert(bodies,body)
          setBody=true
        end
        if enemyDef.faceId then
          local n=1
          local face={enemyDef.faceId,n,0}
          table.insert(faces,face)
          setFace=true
        end
      end
    end
  end
  if(questTable.hostageList and Tpp.IsTypeTable(questTable.hostageList))and next(questTable.hostageList)then
    for n,hostageDef in pairs(questTable.hostageList)do
      if hostageDef.hostageName then
        if hostageDef.bodyId then
          local n=1
          local body={hostageDef.bodyId,0,n}
          table.insert(bodies,body)
          setHostageBody=true
        end
        if hostageDef.faceId then
          local n=1
          local face={hostageDef.faceId,0,n}
          table.insert(faces,face)
          setHostageFace=true
        end
        if hostageDef.isFaceRandom then
          local faceId=TppQuest.GetRandomFaceId()
          if faceId then
            local n=1
            local face={faceId,0,n}
            table.insert(faces,face)
            setHostageFace=true
          end
        end
      end
    end
  end
  if setHostageBody==true then
    local hostageBodyTable={}
    local setBodyTable=false
    for a,n in ipairs(bodies)do
      if n[3]>=1 then
        local n=n[1]
        if IsTypeNumber(n)then
          table.insert(hostageBodyTable,n)
          setBodyTable=true
        end
      end
    end
    if setBodyTable==true then
      TppSoldierFace.SetBodyFovaUserType{hostage=hostageBodyTable}--RETAILBUG: same as in OnAllocateQuest, probably supposed to be table t
    end
  end
  local setFovaType="SetNone"
  if((setBody==true or setFace==true)or setHostageBody==true)or setHostageFace==true then
    local wantSetBody=setBody or setHostageBody
    local wantSetFace=setFace or setHostageFace
    if wantSetBody==true and wantSetFace==true then
      TppSoldierFace.SetAndConvertExtendFova{face=faces,body=bodies}
      setFovaType="SetFaceAndBody"
    elseif wantSetFace==true then
      TppSoldierFace.SetAndConvertExtendFova{face=faces}
      setFovaType="SetFace"
    elseif wantSetBody==true then
      TppSoldierFace.SetAndConvertExtendFova{body=bodies}
      setFovaType="SetBody"
    end
  end
  local command
  if setBody==true or setFace==true then
    if setFovaType=="SetFaceAndBody"then
      command={id="InitializeAndAllocateExtendFova",face=faces,body=bodies}
    elseif setFovaType=="SetFace"then
      command={id="InitializeAndAllocateExtendFova",face=faces}
    elseif setFovaType=="SetBody"then
      command={id="InitializeAndAllocateExtendFova",body=bodies}
    end
    if command then
      GameObject.SendCommand({type="TppSoldier2"},command)
      GameObject.SendCommand({type="TppCorpse"},command)
    end
  end
  if setHostageBody==true or setHostageFace==true then
    if setFovaType=="SetFaceAndBody"then
      TppSoldierFace.ReserveExtendFovaForHostage{face=faces,body=bodies}
    elseif setFovaType=="SetFace"then
      TppSoldierFace.ReserveExtendFovaForHostage{face=faces}
    elseif setFovaType=="SetBody"then
      TppSoldierFace.ReserveExtendFovaForHostage{body=bodies}
    end
  end
  local heliList=questTable.heliList
  if(heliList and Tpp.IsTypeTable(heliList))and next(heliList)then
    this.LoadQuestHeli(heliList[1].coloringType)
  end
end
function this.OnActivateQuest(questTable)
  if questTable==nil then
    return
  end
  if mvars.ene_isQuestSetup==false then
    mvars.ene_questTargetList={}
    mvars.ene_questVehicleList={}
  end
  local isQuestSetup=false
  if(questTable.targetList and Tpp.IsTypeTable(questTable.targetList))and next(questTable.targetList)then
    this.SetupActivateQuestTarget(questTable.targetList)
    isQuestSetup=true
  end
  if(questTable.vehicleList and Tpp.IsTypeTable(questTable.vehicleList))and next(questTable.vehicleList)then
    this.SetupActivateQuestVehicle(questTable.vehicleList,questTable.targetList)
    isQuestSetup=true
  end
  if(questTable.heliList and Tpp.IsTypeTable(questTable.heliList))and next(questTable.heliList)then
    this.SetupActivateQuestHeli(questTable.heliList)
    isQuestSetup=true
  end
  if(questTable.cpList and Tpp.IsTypeTable(questTable.cpList))and next(questTable.cpList)then
    this.SetupActivateQuestCp(questTable.cpList)
    isQuestSetup=true
  end
  if(questTable.enemyList and Tpp.IsTypeTable(questTable.enemyList))and next(questTable.enemyList)then
    this.SetupActivateQuestEnemy(questTable.enemyList)
    isQuestSetup=true
  end
  if questTable.isQuestZombie==true then
    local tppSoldier={type="TppSoldier2"}
    GameObject.SendCommand(tppSoldier,{id="RegistSwarmEffect"})
    isQuestSetup=true
  end
  if(questTable.hostageList and Tpp.IsTypeTable(questTable.hostageList))and next(questTable.hostageList)then
    this.SetupActivateQuestHostage(questTable.hostageList)
    isQuestSetup=true
  end
  if isQuestSetup==true then
    mvars.ene_isQuestSetup=true
  end
end
function this.SetupActivateQuestTarget(targetList)--quest lua quest table .targetList
  if mvars.ene_isQuestSetup==false then
    for n,targetName in pairs(targetList)do
      local targetId=targetName
      if IsTypeString(targetId)then
        targetId=GameObject.GetGameObjectId(targetId)
      end
      if targetId==NULL_ID then
      else
        this.SetQuestEnemy(targetId,true)
        TppMarker.SetQuestMarker(targetName)
      end
    end
end
end
function this.SetupActivateQuestVehicle(vehicleList,targetList)
  if mvars.ene_isQuestSetup==false then
    mvars.ene_questVehicleList={}
    this.SpawnVehicles(vehicleList)
    --InfMenu.DebugPrint"OnActivateQuest vehicleList"--DEBUG
    for a,vehicleInfo in ipairs(vehicleList)do
      if vehicleInfo.locator then
        local command={id="Despawn",locator=vehicleInfo.locator}
        table.insert(mvars.ene_questVehicleList,command)
      end
      for a,t in ipairs(targetList)do
        if vehicleInfo.locator==t then
          this.SetQuestEnemy(vehicleInfo.locator,true)
          TppMarker.SetQuestMarker(vehicleInfo.locator)
        else
          this.SetQuestEnemy(vehicleInfo.locator,false)
        end
      end
    end
  end
end
function this.SetupActivateQuestHeli(heliList)
  if mvars.ene_isQuestSetup==false then
    if not this.IsQuestHeli()then
      return
    end
    local hasHeli=false
    for n,listItem in ipairs(heliList)do
      if listItem.routeName then
        local heli=GameObject.GetGameObjectId(TppReinforceBlock.REINFORCE_HELI_NAME)
        if heli==NULL_ID then
        else
          GameObject.SendCommand(heli,{id="RequestRoute",route=listItem.routeName})
          GameObject.SendCommand(heli,{id="DisablePullOut"})
          hasHeli=true
          this.SetQuestEnemy(heli,false)
        end
      end
    end
    if hasHeli==true then
      this.ActivateQuestHeli(heliList.coloringType)
    end
  end
end
function this.SetupActivateQuestCp(cpList)--quest lua QUEST_TABLE .cpList
  if mvars.ene_isQuestSetup==false then
    for name,listItem in pairs(cpList)do
      if not listItem.cpName then
      else
        local cpId=listItem.cpName
        if IsTypeString(cpId)then
          cpId=GameObject.GetGameObjectId(cpId)
        end
        if cpId==NULL_ID then
        else
          if listItem.isNormalCp==true then
            GameObject.SendCommand(cpId,{id="SetNormalCp"})
          end
          if listItem.isOuterBaseCp==true then
            GameObject.SendCommand(cpId,{id="SetOuterBaseCp"})
          end
          if listItem.isMarchCp==true then
            GameObject.SendCommand(cpId,{id="SetMarchCp"})
          end
          if((listItem.cpPosition_x and listItem.cpPosition_y)and listItem.cpPosition_z)and listItem.cpPosition_r then
            GameObject.SendCommand(cpId,{id="SetCpPosition",x=listItem.cpPosition_x,y=listItem.cpPosition_y,z=listItem.cpPosition_z,r=listItem.cpPosition_r})
          end
          if listItem.gtName then
            if((not listItem.gtPosition_x or not listItem.gtPosition_y)or not listItem.gtPosition_z)or not listItem.gtPosition_r then
            end
            local tppCommandPost={type="TppCommandPost2"}
            local xPos=listItem.gtPosition_x or listItem.cpPosition_x
            local yPos=listItem.gtPosition_y or listItem.cpPosition_y
            local zPos=listItem.gtPosition_z or listItem.cpPosition_z
            local rot=listItem.gtPosition_r or listItem.cpPosition_r
            GameObject.SendCommand(tppCommandPost,{id="SetLocatorPosition",name=listItem.gtName,x=xPos,y=yPos,z=zPos,r=rot})
          end
        end
      end
    end
end
end
function this.SetupActivateQuestEnemy(enemyList)--NMC: from <quest>.lua .QUEST_TABLE.enemyList
  local i=1
  local function Setup(enemyDef,r)
    local soldierId=enemyDef.enemyName
    if IsTypeString(soldierId)then
      soldierId=GameObject.GetGameObjectId(soldierId)
    end
    if soldierId==NULL_ID then
    else
      if r==false then
        if mvars.ene_isQuestSetup==false then
          if enemyDef.soldierType then
            this.SetSoldierType(soldierId,enemyDef.soldierType)
          end
          if enemyDef.soldierSubType then
            this.SetSoldierSubType(soldierId,enemyDef.soldierSubType)
          else
            if TppLocation.IsMiddleAfrica()then
            end
          end
          local a=true
          if enemyDef.powerSetting then
            for n,powerType in ipairs(enemyDef.powerSetting)do
              if powerType=="QUEST_ARMOR"then
                if mvars.ene_questArmorId==0 then
                  a=false
                end
              end
            end
          end
          if a==true then
            local powerSetting=enemyDef.powerSetting or{nil}
            this.ApplyPowerSetting(soldierId,powerSetting)
          else
            this.ApplyPowerSetting(soldierId,{nil})
          end
          if enemyDef.cpName then
            GameObject.SendCommand(soldierId,{id="SetCommandPost",cp=enemyDef.cpName})
          end
          if(enemyDef.staffTypeId or enemyDef.skill)or enemyDef.uniqueTypeId then
            local staffTypeId=enemyDef.staffTypeId or TppDefine.STAFF_TYPE_ID.NORMAL
            local skill=enemyDef.skill or false
            local uniqueTypeId=enemyDef.uniqueTypeId or false
            if skill==false and uniqueTypeId==false then
              TppMotherBaseManagement.RegenerateGameObjectStaffParameter{gameObjectId=soldierId,staffTypeId=staffTypeId}
            elseif skill~=false and IsTypeString(skill)then
              TppMotherBaseManagement.RegenerateGameObjectStaffParameter{gameObjectId=soldierId,staffTypeId=staffTypeId,skill=skill}
            elseif uniqueTypeId~=false then
              TppMotherBaseManagement.RegenerateGameObjectStaffParameter{gameObjectId=soldierId,staffType="Unique",uniqueTypeId=uniqueTypeId}
            end
          else
            if mvars.ene_questTargetList[soldierId]then
              TppMotherBaseManagement.RegenerateGameObjectQuestStaffParameter{gameObjectId=soldierId}
            end
          end
          if enemyDef.voiceType then
            if((enemyDef.voiceType=="ene_a"or enemyDef.voiceType=="ene_b")or enemyDef.voiceType=="ene_c")or enemyDef.voiceType=="ene_d"then
              GameObject.SendCommand(soldierId,{id="SetVoiceType",voiceType=enemyDef.voiceType})
            end
          else
            local voiceTypes={"ene_a","ene_b","ene_c","ene_d"}
            local rnd=math.random(4)
            local randomVoiceType=voiceTypes[rnd]
            GameObject.SendCommand(soldierId,{id="SetVoiceType",voiceType=randomVoiceType})
          end
        end
        if enemyDef.bodyId or enemyDef.faceId then
          local faceId=enemyDef.faceId or false
          local bodyId=enemyDef.bodyId or false
          if IsTypeNumber(bodyId)and IsTypeNumber(faceId)then
            GameObject.SendCommand(soldierId,{id="ChangeFova",bodyId=bodyId,faceId=faceId})
          elseif IsTypeNumber(faceId)then
            GameObject.SendCommand(soldierId,{id="ChangeFova",faceId=faceId})
          elseif IsTypeNumber(bodyId)then
            GameObject.SendCommand(soldierId,{id="ChangeFova",bodyId=bodyId})
          end
        end
        if enemyDef.isBalaclava==true then
          if mvars.ene_questGetLoadedFaceTable~=nil then
            local e=mvars.ene_questGetLoadedFaceTable
            local e=#mvars.ene_questGetLoadedFaceTable
            if e>0 and mvars.ene_questBalaclavaId~=0 then
              local e=mvars.ene_questGetLoadedFaceTable[i]
              if mvars.ene_questGetLoadedFaceTable[i+1]then
                i=i+1
              else
                i=1
              end
              if enemyDef.soldierSubType=="PF_A"or enemyDef.soldierSubType=="PF_C"then
                GameObject.SendCommand(soldierId,{id="ChangeFova",isScarf=true})
              else
                GameObject.SendCommand(soldierId,{id="ChangeFova",balaclavaFaceId=mvars.ene_questBalaclavaId,faceId=e})
              end
            end
          end
        end
        if mvars.ene_isQuestSetup==false then
          if enemyDef.route_d then
            this.SetSneakRoute(soldierId,enemyDef.route_d)
          end
          if enemyDef.route_c then
            this.SetCautionRoute(soldierId,enemyDef.route_c)
          end
          if enemyDef.route_a then
            this.SetAlertRoute(soldierId,enemyDef.route_a)
          end
          if enemyDef.rideFromVehicleId then
            local vehicleId=enemyDef.rideFromVehicleId
            if IsTypeString(vehicleId)then
              vehicleId=GameObject.GetGameObjectId(vehicleId)
            end
            GameObject.SendCommand(soldierId,{id="SetRelativeVehicle",targetId=vehicleId,rideFromBeginning=true})
          end
          if enemyDef.isZombie then
            GameObject.SendCommand(soldierId,{id="SetZombie",enabled=true,isMsf=false,isZombieSkin=true,isHagure=true})
          end
          if enemyDef.isMsf then
            GameObject.SendCommand(soldierId,{id="SetZombie",enabled=true,isMsf=true})
          end
          if enemyDef.isZombieUseRoute then
            GameObject.SendCommand(soldierId,{id="SetZombieUseRoute",enabled=true})
          end
          if enemyDef.isBalaclava==true then
            GameObject.SendCommand(soldierId,{id="SetSoldier2Flag",flag="highRank",on=true})
          end
          GameObject.SendCommand(soldierId,{id="SetEnabled",enabled=true})
          this.SetQuestEnemy(soldierId,false)
        end
      else
        local isDisable=enemyDef.isDisable or false
        if isDisable==true then
          GameObject.SendCommand(soldierId,{id="SetEnabled",enabled=false})
        end
      end
    end
  end--Setup func

  for n,enemyDef in pairs(enemyList)do
    if enemyDef.enemyName then
      Setup(enemyDef,false)
    elseif enemyDef.setCp then
      local cpId=GetGameObjectId(enemyDef.setCp)
      if cpId==NULL_ID then
      else
        local cpId=nil
        for a,cp in pairs(mvars.ene_cpList)do
          if cp==enemyDef.setCp then
            cpId=a
          end
        end
        if cpId then
          for enemyName,t in pairs(mvars.ene_soldierIDList[cpId])do
            local e={enemyName=enemyName,isDisable=enemyDef.isDisable}
            Setup(e,true)
          end
        end
      end
    end
  end
end
function this.SetupActivateQuestHostage(hostageList)
  local isAfghan=TppLocation.IsAfghan()
  local isMiddleAfrica=TppLocation.IsMiddleAfrica()
  for t,hostageInfo in pairs(hostageList)do
    if hostageInfo.hostageName then
      local hostageId=hostageInfo.hostageName
      if IsTypeString(hostageId)then
        hostageId=GameObject.GetGameObjectId(hostageId)
      end
      if hostageId==NULL_ID then
      else
        if mvars.ene_isQuestSetup==false then
          if(hostageInfo.staffTypeId or hostageInfo.skill)or hostageInfo.uniqueTypeId then
            local staffTypeId=hostageInfo.staffTypeId or TppDefine.STAFF_TYPE_ID.NORMAL
            local skill=hostageInfo.skill or false
            local uniqueTypeId=hostageInfo.uniqueTypeId or false
            if skill==false and uniqueTypeId==false then
              TppMotherBaseManagement.RegenerateGameObjectStaffParameter{gameObjectId=hostageId,staffTypeId=staffTypeId}
            elseif skill~=false and IsTypeString(skill)then
              TppMotherBaseManagement.RegenerateGameObjectStaffParameter{gameObjectId=hostageId,staffTypeId=staffTypeId,skill=skill}
            elseif uniqueTypeId~=false then
              TppMotherBaseManagement.RegenerateGameObjectStaffParameter{gameObjectId=hostageId,staffType="Unique",uniqueTypeId=uniqueTypeId}
            end
          else
            if mvars.ene_questTargetList[hostageId]then
              TppMotherBaseManagement.RegenerateGameObjectQuestStaffParameter{gameObjectId=hostageId}
            end
          end
          if hostageInfo.voiceType then
            if IsTypeTable(hostageInfo.voiceType)then
              local e=#hostageInfo.voiceType
              local rnd=math.random(e)
              local rndVoice=hostageInfo.voiceType[rnd]
              if((rndVoice=="hostage_a"or rndVoice=="hostage_b")or rndVoice=="hostage_c")or rndVoice=="hostage_d"then
                GameObject.SendCommand(hostageId,{id="SetVoiceType",voiceType=rndVoice})
              end
            else
              local voiceType=hostageInfo.voiceType
              if((voiceType=="hostage_a"or voiceType=="hostage_b")or voiceType=="hostage_c")or voiceType=="hostage_d"then
                GameObject.SendCommand(hostageId,{id="SetVoiceType",voiceType=voiceType})
              end
            end
          else
            local voiceTable={"hostage_a","hostage_b","hostage_c","hostage_d"}
            local rnd=math.random(4)
            local rndVoice=voiceTable[rnd]
            GameObject.SendCommand(hostageId,{id="SetVoiceType",voiceType=rndVoice})
          end
          if hostageInfo.langType then
            GameObject.SendCommand(hostageId,{id="SetLangType",langType=hostageInfo.langType})
          else
            if this.IsFemaleHostage(hostageId)==false then
              if isAfghan==true then
                GameObject.SendCommand(hostageId,{id="SetLangType",langType="russian"})
              elseif isMiddleAfrica==true then
                GameObject.SendCommand(hostageId,{id="SetLangType",langType="afrikaans"})
              end
            else
              GameObject.SendCommand(hostageId,{id="SetLangType",langType="english"})
            end
          end
          if hostageInfo.path then
            GameObject.SendCommand(hostageId,{id="SpecialAction",action="PlayMotion",path=hostageInfo.path,autoFinish=false,enableMessage=true,commandId=Fox.StrCode32"CommandA",enableGravity=false,enableCollision=false})
          end
          this.SetQuestEnemy(hostageId,false)
        end
        if(hostageInfo.bodyId or hostageInfo.faceId)or hostageInfo.isFaceRandom then
          local faceId=hostageInfo.faceId or false
          local bodyId=hostageInfo.bodyId or false
          if hostageInfo.isFaceRandom then
            faceId=TppQuest.GetRandomFaceId()
          end
          if IsTypeNumber(bodyId)and IsTypeNumber(faceId)then
            GameObject.SendCommand(hostageId,{id="ChangeFova",bodyId=bodyId,faceId=faceId})
          elseif IsTypeNumber(faceId)then
            GameObject.SendCommand(hostageId,{id="ChangeFova",faceId=faceId})
          elseif IsTypeNumber(bodyId)then
            GameObject.SendCommand(hostageId,{id="ChangeFova",bodyId=bodyId})
          end
        end
      end
    end
  end
end
function this.OnDeactivateQuest(questTable)
  if mvars.ene_isQuestSetup==true then
    if(questTable.vehicleList and Tpp.IsTypeTable(questTable.vehicleList))and next(questTable.vehicleList)then
      this.SetupDeactivateQuestVehicle(questTable.vehicleList)
    end
    if(questTable.heliList and Tpp.IsTypeTable(questTable.heliList))and next(questTable.heliList)then
      this.SetupDeactivateQuestQuestHeli(questTable.heliList)
    end
    if(questTable.cpList and Tpp.IsTypeTable(questTable.cpList))and next(questTable.cpList)then
      this.SetupDeactivateQuestCp(questTable.cpList)
    end
    if questTable.isQuestZombie==true then
      local e={type="TppSoldier2"}
      GameObject.SendCommand(e,{id="UnregistSwarmEffect"})
    end
    if(questTable.enemyList and Tpp.IsTypeTable(questTable.enemyList))and next(questTable.enemyList)then
      this.SetupDeactivateQuestEnemy(questTable.enemyList)
    end
    if(questTable.hostageList and Tpp.IsTypeTable(questTable.hostageList))and next(questTable.hostageList)then
      this.SetupDeactivateQuestHostage(questTable.hostageList)
    end
    if not mvars.qst_isMissionEnd then
      local clearType=this.CheckQuestAllTarget(questTable.questType,nil,nil,true)
      TppQuest.ClearWithSave(clearType)
    end
  end
end
function this.SetupDeactivateQuestVehicle(e)
end
function this.SetupDeactivateQuestQuestHeli(heliList)
end
function this.SetupDeactivateQuestCp(e)
end
function this.SetupDeactivateQuestEnemy(n)
  for n,t in pairs(n)do
    if t.enemyName then
      local enemyId=t.enemyName
      if IsTypeString(enemyId)then
        enemyId=GameObject.GetGameObjectId(enemyId)
      end
      if enemyId==NULL_ID then
      else
        local a={type="TppCorpse"}
        if this.CheckQuestDistance(enemyId)then
          if TppMission.CheckMissionState(true,false,true,false)then
            this.AutoFultonRecoverNeutralizedTarget(enemyId,true)
          end
        end
        if t.bodyId or t.faceId then
          local e={id="ChangeFova",faceId=EnemyFova.INVALID_FOVA_VALUE,bodyId=EnemyFova.INVALID_FOVA_VALUE}
          GameObject.SendCommand(enemyId,e)
          local e={id="ChangeFovaCorpse",name=t.enemyName,faceId=EnemyFova.INVALID_FOVA_VALUE,bodyId=EnemyFova.INVALID_FOVA_VALUE}
          GameObject.SendCommand(a,e)
        end
        if this.CheckQuestDistance(enemyId)then
          if TppMission.CheckMissionState(true,false,true,false)then
            GameObject.SendCommand(enemyId,{id="RequestVanish"})
            GameObject.SendCommand(a,{id="RequestDisableWithFadeout",name=t.enemyName})
          end
        end
      end
    elseif t.setCp then
    end
  end
end
function this.SetupDeactivateQuestHostage(n)
  for n,t in pairs(n)do
    if t.hostageName then
      local hostageId=t.hostageName
      if IsTypeString(hostageId)then
        hostageId=GameObject.GetGameObjectId(hostageId)
      end
      if hostageId==NULL_ID then
      else
        if this.CheckQuestDistance(hostageId)then
          if TppMission.CheckMissionState(true,false,true,false)then
            local staffId=TppMotherBaseManagement.GetStaffIdFromGameObject{gameObjectId=hostageId}
            TppTerminal.OnFulton(hostageId,nil,nil,staffId,nil,true)
          end
        end
        if t.bodyId or t.faceId then
          local e={id="ChangeFova",faceId=EnemyFova.INVALID_FOVA_VALUE,bodyId=EnemyFova.INVALID_FOVA_VALUE}
          GameObject.SendCommand(hostageId,e)
        end
        if this.CheckQuestDistance(hostageId)then
          if TppMission.CheckMissionState(true,false,true,false)then
            GameObject.SendCommand(hostageId,{id="RequestVanish"})
          end
        end
      end
    end
  end
end
function this.OnTerminateQuest(questTable)
  if mvars.ene_isQuestSetup==true then
    if(questTable.vehicleList and Tpp.IsTypeTable(questTable.vehicleList))and next(questTable.vehicleList)then
      this.SetupTerminateQuestVehicle(questTable.vehicleList)
    end
    if(questTable.heliList and Tpp.IsTypeTable(questTable.heliList))and next(questTable.heliList)then
      this.SetupTerminateQuestHeli(questTable.heliList)
    end
    if(questTable.cpList and Tpp.IsTypeTable(questTable.cpList))and next(questTable.cpList)then
      this.SetupTerminateQuestCp(questTable.cpList)
    end
    if questTable.isQuestZombie==true then
      local e={type="TppSoldier2"}
      GameObject.SendCommand(e,{id="UnregistSwarmEffect"})
    end
    if(questTable.enemyList and Tpp.IsTypeTable(questTable.enemyList))and next(questTable.enemyList)then
      if GameObject.GetGameObjectIdByIndex("TppSoldier2",0)~=NULL_ID then
        this.SetupTerminateQuestEnemy(questTable.enemyList)
      end
    end
    if(questTable.hostageList and Tpp.IsTypeTable(questTable.hostageList))and next(questTable.hostageList)then
      this.SetupTerminateQuestHostage(questTable.hostageList)
    end
  end
  if GameObject.GetGameObjectIdByIndex("TppSoldier2",0)~=NULL_ID then
    local e={type="TppSoldier2"}
    GameObject.SendCommand(e,{id="FreeExtendFova"})
  end
  if GameObject.GetGameObjectIdByIndex("TppCorpse",0)~=NULL_ID then
    local e={type="TppCorpse"}
    GameObject.SendCommand(e,{id="FreeExtendFova"})
  end
  TppSoldierFace.ClearExtendFova()
  TppSoldierFace.ReserveExtendFovaForHostage{}
  mvars.ene_questTargetList={}
  mvars.ene_questVehicleList={}
  mvars.ene_isQuestSetup=false
end
function this.SetupTerminateQuestVehicle(n)
  this.DespawnVehicles(mvars.ene_questVehicleList)
end
function this.SetupTerminateQuestHeli(heliList)
  this.DeactivateQuestHeli()
  this.UnloadQuestHeli()
end
function this.SetupTerminateQuestCp(e)
end
function this.SetupTerminateQuestEnemy(i)
  local isAfghan=TppLocation.IsAfghan()
  local isMiddleAfrica=TppLocation.IsMiddleAfrica()
  local function SetupEnemy(setupInfo,RENAMEsomeBool)
    local enemyId=setupInfo.enemyName
    if IsTypeString(enemyId)then
      enemyId=GameObject.GetGameObjectId(enemyId)
    end
    if enemyId==NULL_ID then
    else
      if RENAMEsomeBool==false then
        local gameObjectCorpse={type="TppCorpse"}
        GameObject.SendCommand(enemyId,{id="SetEnabled",enabled=false})
        GameObject.SendCommand(enemyId,{id="SetCommandPost",cp="quest_cp"})
        GameObject.SendCommand(enemyId,{id="SetZombie",enabled=false,isMsf=false,isZombieSkin=true,isHagure=false})
        GameObject.SendCommand(enemyId,{id="SetZombieUseRoute",enabled=false})
        GameObject.SendCommand(enemyId,{id="SetEverDown",enabled=false})
        GameObject.SendCommand(enemyId,{id="SetSoldier2Flag",flag="highRank",on=false})
        GameObject.SendCommand(enemyId,{id="Refresh"})
        GameObject.SendCommand(gameObjectCorpse,{id="RequestVanish",name=setupInfo.enemyName})
        if setupInfo.powerSetting then
          for i,powerType in ipairs(setupInfo.powerSetting)do
            if powerType=="QUEST_ARMOR"then
              local command={id="ChangeFova",faceId=EnemyFova.INVALID_FOVA_VALUE,bodyId=EnemyFova.INVALID_FOVA_VALUE}
              GameObject.SendCommand(enemyId,command)
              local command={id="ChangeFovaCorpse",name=setupInfo.enemyName,faceId=EnemyFova.INVALID_FOVA_VALUE,bodyId=EnemyFova.INVALID_FOVA_VALUE}
              GameObject.SendCommand(gameObjectCorpse,command)
            end
          end
        end
        if isAfghan==true then
          GameObject.SendCommand(enemyId,{id="SetSoldier2Type",type=EnemyType.TYPE_SOVIET})
        elseif isMiddleAfrica==true then
          GameObject.SendCommand(enemyId,{id="SetSoldier2Type",type=EnemyType.TYPE_PF})
        end
      else
        local n=setupInfo.isDisable or false
        if n==true then
          GameObject.SendCommand(enemyId,{id="SetEnabled",enabled=true})
        end
      end
    end
  end
  for n,setupInfo in pairs(i)do
    if setupInfo.enemyName then
      SetupEnemy(setupInfo,false)
      TppUiCommand.UnRegisterIconUniqueInformation(GameObject.GetGameObjectId(setupInfo.enemyName))
    elseif setupInfo.setCp then
      local n=GetGameObjectId(setupInfo.setCp)
      if n==NULL_ID then
      else
        local cpId=nil
        for a,t in pairs(mvars.ene_cpList)do
          if t==setupInfo.setCp then
            cpId=a
          end
        end
        if cpId then
          for enemyName,a in pairs(mvars.ene_soldierIDList[cpId])do
            local setupInfo={enemyName=enemyName,isZombie=setupInfo.isZombie,isMsf=setupInfo.isMsf,isDisable=setupInfo.isDisable}
            SetupEnemy(setupInfo,true)
          end
        end
      end
    end
  end
end
function this.SetupTerminateQuestHostage(e)
end
function this.CheckQuestDistance(gameId)
  if Tpp.IsSoldier(gameId)or Tpp.IsHostage(gameId)then
    local playerPosition=Vector3(vars.playerPosX,vars.playerPosY,vars.playerPosZ)
    local checkDist=10
    local distSqr=checkDist*checkDist
    if CloserToPlayerThanDistSqr(distSqr,playerPosition,gameId)then
      return true
    end
  end
  return false
end
function this.CheckQuestNpcLifeStatus(gameId)
  if gameId~=nil then
    local lifeStatus=GameObject.SendCommand(gameId,{id="GetLifeStatus"})
    if lifeStatus==TppGameObject.NPC_LIFE_STATE_DEAD then
      return false
    else
      return true
    end
  end
end
function this.IsQuestInHelicopter()
  TppHelicopter.SetNewestPassengerTable()
  for e,n in pairs(mvars.ene_questTargetList)do
    if TppHelicopter.IsInHelicopter(e)then
      return true
    end
  end
  return false
end
function this.IsQuestInHelicopterGameObjectId(n)
  TppHelicopter.SetNewestPassengerTable()
  for e,t in pairs(mvars.ene_questTargetList)do
    if TppHelicopter.IsInHelicopter(e)then
      if e==n then
        return true
      end
    end
  end
  return false
end
function this.IsQuestTarget(e)
  if mvars.ene_isQuestSetup==false then
    return false
  end
  if not next(mvars.ene_questTargetList)then
    return false
  end
  for n,t in pairs(mvars.ene_questTargetList)do
    if t.isTarget==true then
      if e==n then
        return true
      end
    end
  end
  return false
end
function this.IsQuestNpc(n)
  for e,t in pairs(mvars.ene_questTargetList)do
    if n==e then
      return true
    end
  end
  return false
end
function this.GetQuestCount()
  local e=0
  local n=0
  for a,t in pairs(mvars.ene_questTargetList)do
    if t.isTarget==true then
      e=e+1
      if t.messageId~="None"then
        n=n+1
      end
    end
  end
  return n,e
end
function this.SetQuestEnemy(gameObjectId,isTarget)
  if IsTypeString(gameObjectId)then
    gameObjectId=GameObject.GetGameObjectId(gameObjectId)
  end
  if gameObjectId==NULL_ID then
  end
  if not mvars.ene_questTargetList[gameObjectId]then
    local n={messageId="None",isTarget=isTarget}
    mvars.ene_questTargetList[gameObjectId]=n
  end
end
function this.CheckDeactiveQuestAreaForceFulton()
  if mvars.ene_isQuestSetup==false then
    return
  end
  if not next(mvars.ene_questTargetList)then
    return
  end
  for n,t in pairs(mvars.ene_questTargetList)do
    if Tpp.IsSoldier(n)or Tpp.IsHostage(n)then
      if this.CheckQuestDistance(n)then
        if this.CheckQuestNpcLifeStatus(n)then
          GameObject.SendCommand(n,{id="RequestForceFulton"})
          TppRadio.Play"f1000_rtrg5140"
          TppSoundDaemon.PostEvent"sfx_s_rescue_pow"
        else
          GameObject.SendCommand(n,{id="RequestDisableWithFadeout"})
        end
      end
    end
  end
end
function this.CheckQuestAllTarget(questType,_messageId,gameId,t,a)
  local clearType=TppDefine.QUEST_CLEAR_TYPE.NONE
  local p=t or false
  local c=a or false
  local RENAMEinQuestTargetList=false
  local totalTargets=0
  local fultonedCount=0
  local failedFultonCount=0
  local killedOrDestroyedCount=0
  local vanishedCount=0
  local inHeliCount=0
  local RENAMEcountIncreased=true
  local d=false
  local currentQuestName=TppQuest.GetCurrentQuestName()
  if TppQuest.IsEnd(currentQuestName)then
    return clearType
  end
  if mvars.ene_questTargetList[gameId]then
    local questTarget=mvars.ene_questTargetList[gameId]
    if questTarget.messageId~="None"and questTarget.isTarget==true then
      d=true
    elseif questTarget.isTarget==false then
      d=true
    end
    questTarget.messageId=_messageId or"None"
    RENAMEinQuestTargetList=true
  end
  if(p==false and c==false)and RENAMEinQuestTargetList==false then
    return clearType
  end
  for gameId,questTarget in pairs(mvars.ene_questTargetList)do
    local d=false
    local T=questTarget.isTarget or false
    if p==true then
      if Tpp.IsSoldier(gameId)or Tpp.IsHostage(gameId)then
        if this.CheckQuestDistance(gameId)then
          questTarget.messageId="Fulton"
          fultonedCount=fultonedCount+1
          d=false
          RENAMEcountIncreased=true
        end
      end
    end
    if T==true then
      if d==false then
        local messageId=questTarget.messageId
        if messageId~="None"then
          if messageId=="Fulton"then
            fultonedCount=fultonedCount+1
            RENAMEcountIncreased=true
          elseif messageId=="InHelicopter"then
            inHeliCount=inHeliCount+1
            RENAMEcountIncreased=true
          elseif messageId=="FultonFailed"then
            failedFultonCount=failedFultonCount+1
            RENAMEcountIncreased=true
          elseif(messageId=="Dead"or messageId=="VehicleBroken")or messageId=="LostControl"then
            killedOrDestroyedCount=killedOrDestroyedCount+1
            RENAMEcountIncreased=true
          elseif messageId=="Vanished"then
            vanishedCount=vanishedCount+1
            RENAMEcountIncreased=true
          end
        end
        if p==true then
          RENAMEcountIncreased=false
        end
      end
      totalTargets=totalTargets+1
    end
  end
  if d==true then
    RENAMEcountIncreased=false
  end
  if totalTargets>0 then
    if questType==TppDefine.QUEST_TYPE.RECOVERED then
      if fultonedCount+inHeliCount>=totalTargets then
        clearType=TppDefine.QUEST_CLEAR_TYPE.CLEAR
      elseif failedFultonCount>0 or killedOrDestroyedCount>0 then
        clearType=TppDefine.QUEST_CLEAR_TYPE.FAILURE
      elseif fultonedCount+inHeliCount>0 then
        if RENAMEcountIncreased==true then
          clearType=TppDefine.QUEST_CLEAR_TYPE.UPDATE
        end
      end
    elseif questType==TppDefine.QUEST_TYPE.ELIMINATE then
      if((fultonedCount+failedFultonCount)+killedOrDestroyedCount)+inHeliCount>=totalTargets then
        clearType=TppDefine.QUEST_CLEAR_TYPE.CLEAR
      elseif((fultonedCount+failedFultonCount)+killedOrDestroyedCount)+inHeliCount>0 then
        if RENAMEcountIncreased==true then
          clearType=TppDefine.QUEST_CLEAR_TYPE.UPDATE
        end
      end
    elseif questType==TppDefine.QUEST_TYPE.MSF_RECOVERED then
      if fultonedCount>=totalTargets or inHeliCount>=totalTargets then
        clearType=TppDefine.QUEST_CLEAR_TYPE.CLEAR
      elseif(failedFultonCount>0 or killedOrDestroyedCount>0)or vanishedCount>0 then
        clearType=TppDefine.QUEST_CLEAR_TYPE.FAILURE
      end
    end
  end
  if c==true then
    if clearType==TppDefine.QUEST_CLEAR_TYPE.NONE or clearType==TppDefine.QUEST_CLEAR_TYPE.UPDATE then
      clearType=TppDefine.QUEST_CLEAR_TYPE.NONE
    end
  end
  return clearType
end
function this.ReserveQuestHeli()
  local e=GetGameObjectId("TppCommandPost2",questCp)
  TppRevenge.SetEnabledSuperReinforce(false)
  mvars.ene_isQuestHeli=true
end
function this.UnreserveQuestHeli()
  local cpId=GetGameObjectId("TppCommandPost2",questCp)
  TppReinforceBlock.FinishReinforce(cpId)
  TppReinforceBlock.UnloadReinforceBlock(cpId)
  TppRevenge.SetEnabledSuperReinforce(true)
  mvars.ene_isQuestHeli=false
end
function this.LoadQuestHeli(colorType)
  local cpId=GetGameObjectId("TppCommandPost2",questCp)
  TppReinforceBlock.LoadReinforceBlock(TppReinforceBlock.REINFORCE_TYPE.HELI,cpId,colorType)
end
function this.UnloadQuestHeli()
  local cpId=GetGameObjectId("TppCommandPost2",questCp)
  TppReinforceBlock.UnloadReinforceBlock(cpId)
end
function this.ActivateQuestHeli(colorType)
  local cpId=GetGameObjectId("TppCommandPost2",questCp)
  if not TppReinforceBlock.IsLoaded()then
    TppReinforceBlock.LoadReinforceBlock(TppReinforceBlock.REINFORCE_TYPE.HELI,cpId,colorType)
  end
  TppReinforceBlock.StartReinforce(cpId)
end
function this.DeactivateQuestHeli()
  local cpId=GetGameObjectId("TppCommandPost2",questCp)
  TppReinforceBlock.FinishReinforce(cpId)
end
function this.IsQuestHeli()
  return mvars.ene_isQuestHeli
end
function this.GetDDSuit()
  local eventArmor=TppDefine.FOB_EVENT_ID_LIST.ARMOR

  local eventId=TppServerManager.GetEventId()
  for a,n in ipairs(eventArmor)do
    if eventId==n then
      return this.FOB_PF_SUIT_ARMOR
    end
  end
  local sneakingSuit=this.weaponIdTable.DD.NORMAL.SNEAKING_SUIT
  if sneakingSuit and sneakingSuit>0 then
    return this.FOB_DD_SUIT_SNEAKING
  end
  local battleDress=this.weaponIdTable.DD.NORMAL.BATTLE_DRESS
  if battleDress and battleDress>0 then
    return this.FOB_DD_SUIT_BTRDRS
  end
  return this.FOB_DD_SUIT_ATTCKER
end
function this.IsHostageEventFOB()
  local eventIdList=TppDefine.FOB_EVENT_ID_LIST.HOSTAGE
  local eventId=TppServerManager.GetEventId()
  for t,e in ipairs(eventIdList)do
    if eventId==e then
      return true
    end
  end
  return false
end
function this.IsZombieEventFOB()--RETAILPATCH 1070>
  local eventIdList=TppDefine.FOB_EVENT_ID_LIST.ZOMBIE
  local eventId=TppServerManager.GetEventId()
  for t,e in ipairs(eventIdList)do
    if eventId==e then
      return true
    end
  end
  return false
end
function this.IsParasiteMetalEventFOB()
  local eventIdList=TppDefine.FOB_EVENT_ID_LIST.PARASITE_METAL
  local eventId=TppServerManager.GetEventId()
  for t,e in ipairs(eventIdList)do
    if eventId==e then
      return true
    end
  end
  return false
end
function this.IsSpecialEventFOB()
  return this.IsParasiteMetalEventFOB()
end
--<
function this._OnDead(gameId,attackerId)
  local isPlayer
  if attackerId then
    isPlayer=Tpp.IsPlayer(attackerId)
  end
  local isEliminateTarget=this.IsEliminateTarget(gameId)
  local isRescueTarget=this.IsRescueTarget(gameId)
  if isPlayer then
    if Tpp.IsHostage(gameId)then
      if this.IsChildHostage(gameId)then
        if TppMission.GetMissionID()~=10100 then
          TppMission.ReserveGameOverOnPlayerKillChild(gameId)
        end
      else
        if not isEliminateTarget and not isRescueTarget then
          TppRadio.PlayCommonRadio(TppDefine.COMMON_RADIO.HOSTAGE_DEAD)
        end
      end
    end
  end
  if Tpp.IsSoldier(gameId)then
    local soldierType=this.GetSoldierType(gameId)
    if(soldierType==EnemyType.TYPE_CHILD)then
      TppMission.ReserveGameOverOnPlayerKillChild(gameId)
    end
  end
  if Tpp.IsHostage(gameId)and TppMission.GetMissionID()~=10100 then
    local e=SendCommand(gameId,{id="IsChild"})
    if e then
      TppMission.ReserveGameOverOnPlayerKillChild(gameId)
    end
  end
  this.PlayTargetEliminatedRadio(gameId)
end
function this._OnRecoverNPC(n,t)
  this._PlayRecoverNPCRadio(n)
end
function this._PlayRecoverNPCRadio(n)
  local t=this.IsEliminateTarget(n)
  local a=this.IsRescueTarget(n)
  if Tpp.IsSoldier(n)and not t then
    TppRadio.PlayCommonRadio(TppDefine.COMMON_RADIO.ENEMY_RECOVERED)
  elseif Tpp.IsHostage(n)and not a then
    TppRadio.PlayCommonRadio(TppDefine.COMMON_RADIO.HOSTAGE_RECOVERED)
  else
    this.PlayTargetRescuedRadio(n)
  end
end
function this._OnFulton(n,a,a,t)
  this._OnRecoverNPC(n,t)
end
function this._OnDamage(gameId,attackId,attackerId)
  if this.IsRescueTarget(gameId)then
    this._OnDamageOfRescueTarget(attackId,attackerId)
  end
end
function this._OnDamageOfRescueTarget(attackId,attackerId)
  if TppDamage.IsActiveByAttackId(attackId)then
    if Tpp.IsPlayer(attackerId)then
      TppRadio.PlayCommonRadio(TppDefine.COMMON_RADIO.HOSTAGE_DAMAGED_FROM_PC)
    end
  end
end
function this._PlacedIntoVehicle(t,n,a)
  if Tpp.IsHelicopter(n)then
    this.PlayTargetRescuedRadio(t)
  end
end
function this._RideHelicopterWithHuman(t,n,t)
  this.PlayTargetRescuedRadio(n)
end
function this._AnnouncePhaseChange(cpId,phase)
  local cpSubType=this.GetCpSubType(cpId)
  local langId="cmmn_ene_soviet"
  if cpSubType=="SOVIET_A"or cpSubType=="SOVIET_B"then
    langId="cmmn_ene_soviet"
  elseif cpSubType=="PF_A"then
    langId="cmmn_ene_cfa"
  elseif cpSubType=="PF_B"then
    langId="cmmn_ene_zrs"
  elseif cpSubType=="PF_C"then
    langId="cmmn_ene_coyote"
  elseif cpSubType=="DD_A"then
    return
  elseif cpSubType=="DD_PW"then
    langId="cmmn_ene_pf"
  elseif cpSubType=="DD_FOB"then
    langId="cmmn_ene_pf"
  elseif cpSubType=="SKULL_AFGH"then
    langId="cmmn_ene_xof"
  elseif cpSubType=="SKULL_CYPR"then
    return
  elseif cpSubType=="CHILD_A"then
    return
  end
  if phase==TppGameObject.PHASE_ALERT then
    TppUiCommand.AnnounceLogViewLangId("announce_phase_to_alert",langId)
  elseif phase==TppGameObject.PHASE_EVASION then
    TppUiCommand.AnnounceLogViewLangId("announce_phase_to_evasion",langId)
  elseif phase==TppGameObject.PHASE_CAUTION then
    TppUiCommand.AnnounceLogViewLangId("announce_phase_to_caution",langId)
  elseif phase==TppGameObject.PHASE_SNEAK then
    TppUiCommand.AnnounceLogViewLangId("announce_phase_to_sneak",langId)
  end
end
function this._IsGameObjectIDValid(e)
  local e=GetGameObjectId(e)
  if(e==NULL_ID)then
    return false
  else
    return true
  end
end
function this._IsRouteSetTypeValid(n)
  if(n==nil or type(n)~="string")then
    return false
  end
  for t,t in paris(this.ROUTE_SET_TYPES)do
    if(n==this.ROUTE_SET_TYPES[i])then
      return true
    end
  end
  return false
end
function this._ShiftChangeByTime(t)
  for cpId,a in pairs(mvars.ene_cpList)do
    SendCommand(cpId,{id="ShiftChange",schedule=mvars.ene_shiftChangeTable[cpId][t]})
  end
end
function this._IsEliminated(lifeStatus,state)
  if(lifeStatus==this.LIFE_STATUS.DEAD)or(state==TppGameObject.NPC_STATE_DISABLE)then
    return true
  else
    return false
  end
end
function this._IsNeutralized(n,t)
  if(n>this.LIFE_STATUS.NORMAL)or(t>TppGameObject.NPC_STATE_NORMAL)then
    return true
  else
    return false
  end
end
function this._RestoreOnContinueFromCheckPoint_Hostage()
end
function this._RestoreOnContinueFromCheckPoint_Hostage2()
  if TppHostage2.SetSVarsKeyNames2 then
    local restoreGameIdTypes={
      "TppHostage2",
      "TppHostageUnique",
      "TppHostageUnique2",
      "TppHostageKaz",
      "TppOcelot2",
      "TppHuey2",
      "TppCodeTalker2",
      "TppSkullFace2",
      "TppMantis2"
    }
    for t,e in ipairs(restoreGameIdTypes)do
      if GameObject.GetGameObjectIdByIndex(e,0)~=NULL_ID then
        SendCommand({type=e},{id="RestoreFromSVars"})
      end
    end
  end
end
function this._RestoreOnMissionStart_Hostage()
end
function this._RestoreOnMissionStart_Hostage2()
  if TppHostage2.SetSVarsKeyNames2 then
    local n=EnemyFova.INVALID_FOVA_VALUE
    local t=EnemyFova.INVALID_FOVA_VALUE
    for e=0,TppDefine.DEFAULT_HOSTAGE_STATE_COUNT-1 do
      svars.hosName[e]=0
      svars.hosState[e]=0
      svars.hosFlagAndStance[e]=0
      svars.hosWeapon[e]=0
      svars.hosLocation[e*4+0]=0
      svars.hosLocation[e*4+1]=0
      svars.hosLocation[e*4+2]=0
      svars.hosLocation[e*4+3]=0
      svars.hosMarker[e]=0
      svars.hosFovaSeed[e]=0
      svars.hosFaceFova[e]=n
      svars.hosBodyFova[e]=t
      svars.hosScriptSneakRoute[e]=GsRoute.ROUTE_ID_EMPTY
      svars.hosRouteNodeIndex[e]=0
      svars.hosRouteEventIndex[e]=0
      svars.hosOptParam1[e]=0
      svars.hosOptParam2[e]=0
      svars.hosRandomSeed[e]=0
    end
  end
end
function this._StoreSVars_Hostage(markerOnly)
  local e={"TppHostage2","TppHostageUnique","TppHostageUnique2","TppHostageKaz","TppOcelot2","TppHuey2","TppCodeTalker2","TppSkullFace2","TppMantis2"}
  if TppHostage2.SetSVarsKeyNames2 then
    for t,e in ipairs(e)do
      if GameObject.GetGameObjectIdByIndex(e,0)~=NULL_ID then
        SendCommand({type=e},{id="ReadyToStoreToSVars"})
      end
    end
  end
  for i,e in ipairs(e)do
    if GameObject.GetGameObjectIdByIndex(e,0)~=NULL_ID then
      SendCommand({type=e},{id="StoreToSVars",markerOnly=markerOnly})
    end
  end
end
function this._DoRoutePointMessage(r,o,s,i)
  local n=mvars.ene_routePointMessage
  if not n then
    return
  end
  local t=TppSequence.GetCurrentSequenceName()
  local a=n.sequence[t]
  local t=""if a then
    this.ExecuteRoutePointMessage(a,r,o,s,i,t)
  end
  this.ExecuteRoutePointMessage(n.main,r,o,s,i,t)
end
function this.ExecuteRoutePointMessage(n,arg2,arg1,arg0,arg3,strLogText)
  local messageIdRecievers=n[arg3]
  if not messageIdRecievers then
    return
  end
  Tpp.DoMessageAct(messageIdRecievers,TppMission.CheckMessageOption,arg0,arg1,arg2,arg3,strLogText)
end
return this