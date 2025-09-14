module FactionPowerLock

public func FPL_IsMiniBoss(p: wref<ScriptedPuppet>) -> Bool {
  let n: wref<NPCPuppet> = p as NPCPuppet;
  if !IsDefined(n) { return false; }
  switch n.GetNPCRarity() {
    case gamedataNPCRarity.Officer:
    case gamedataNPCRarity.Elite:
      return true;
  };
  return false;
}

public func FPL_GetLockedPLForRarity(r: gamedataNPCRarity) -> Int32 {
  switch r {
    case gamedataNPCRarity.MaxTac: return 50;
  };
  return -1;
}

public func FPL_GetLockedPLForAffiliation(id: TweakDBID) -> Int32 {
  switch id {
    case t"Factions.Maelstrom": return 50;
    case t"Affiliation.Maelstrom": return 50;
    case t"Factions.TygerClaws": return 50;
    case t"Affiliation.TygerClaws": return 50;
    case t"Factions.Aldecaldos": return 40;
    case t"Affiliation.Aldecaldos": return 40;
    case t"Factions.SixthStreet": return 30;
    case t"Affiliation.SixthStreet": return 30;
    case t"Factions.VoodooBoys": return 25;
    case t"Affiliation.VoodooBoys": return 25;
    case t"Factions.Wraiths": return 20;
    case t"Affiliation.Wraiths": return 20;
    case t"Factions.Valentinos": return 15;
    case t"Affiliation.Valentinos": return 15;
    case t"Factions.Barghest": return 30;
    case t"Affiliation.Barghest": return 30;
    case t"Factions.Scavengers": return 5;
    case t"Affiliation.Scavengers": return 5;
  };
  return 15;
}

public func FPL_GetCyberpsychoPLForRecord(id: TweakDBID) -> Int32 {
  switch id {
    // Zaria — Bloody Ritual
    case t"Character.ma_wat_nid_15_psycho": return 40;
    case t"Character.ma_wat_nid_15_psycho_02": return 45;
    case t"Character.ma_wat_nid_15_psycho_03": return 50;

    case t"Character.ma_bls_ina_se1_07_cyberpsycho_1": return 50;
    case t"Character.ma_bls_ina_se1_08_cyberpsycho": return 50;
    case t"Character.ma_cct_dtn_03_cyberpsycho": return 25;
    case t"Character.ma_cct_dtn_07_cyberpsycho": return 25;
    case t"Character.ma_hey_spr_04_cyberpsycho": return 35;
    case t"Character.ma_hey_spr_06_cyberpsycho": return 35;
    case t"Character.ma_pac_cvi_15_cyberpsycho": return 35;
    case t"Character.ma_std_arr_06_cyberpsycho": return 40;
    case t"Character.ma_std_rcr_11_cyberpsycho": return 40;
    case t"Character.ma_wat_kab_02_cyberpsycho": return 15;
    case t"Character.ma_wat_kab_08_cyberpsycho": return 15;
    case t"Character.ma_wat_lch_06_cyberpsycho": return 15;
    case t"Character.mq030_cyberpsycho": return 35;
    case t"Character.rcr_05_cyberpsycho": return 40;
    case t"Character.sts_wat_nid_01_cyberpsycho": return 15;
  };
  return -1;
}

public func FPL_GetLockedPLForPuppet(p: wref<ScriptedPuppet>) -> Int32 {
  if !IsDefined(p) || p.IsPlayer() { return -1; }

  let recID: TweakDBID = p.GetRecordID();
  let cyPL: Int32 = FPL_GetCyberpsychoPLForRecord(recID);
  if cyPL > 0 { return cyPL; }

  if p.IsBoss() || FPL_IsMiniBoss(p) { return -1; }

  let n: wref<NPCPuppet> = p as NPCPuppet;
  if IsDefined(n) {
    let rLock: Int32 = FPL_GetLockedPLForRarity(n.GetNPCRarity());
    if rLock > 0 { return rLock; }
  };

  let cr: ref<Character_Record> = TweakDBInterface.GetCharacterRecord(recID);
  if !IsDefined(cr) { return 15; }
  let aff: wref<Affiliation_Record> = cr.Affiliation();
  if !IsDefined(aff) { return 15; }
  return FPL_GetLockedPLForAffiliation(aff.GetID());
}

@wrapMethod(ScriptedPuppet)
protected cb func OnGameAttached() -> Bool {
  wrappedMethod();
  let pl: Int32 = FPL_GetLockedPLForPuppet(this);
  if pl > 0 {
    let stats: ref<StatsSystem> = GameInstance.GetStatsSystem(this.GetGame());
    let sid: StatsObjectID = Cast<StatsObjectID>(this.GetEntityID());
    let cur: Float = stats.GetStatValue(sid, gamedataStatType.PowerLevel);
    let delta: Float = Cast<Float>(pl) - cur;
    let mod: ref<gameStatModifierData> = RPGManager.CreateStatModifier(gamedataStatType.PowerLevel, gameStatModifierType.Additive, delta);
    stats.AddSavedModifier(sid, mod);
  };
}

@wrapMethod(ScriptedPuppet)
public func AddRecordEquipment(equipmentPriority: EquipmentPriority, opt powerLevel: Int32) -> Void {
  let pl: Int32 = FPL_GetLockedPLForPuppet(this);
  if pl > 0 { wrappedMethod(equipmentPriority, pl); return; }
  wrappedMethod(equipmentPriority, powerLevel);
}
