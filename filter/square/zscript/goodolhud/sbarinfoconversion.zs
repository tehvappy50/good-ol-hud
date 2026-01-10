// [tv50] This is as close to a complete SBARINFO conversion as I can manage.

class GoodOlHUDSquareStatusBar : DoomStatusBar
{
    HUDFont mHUDFont2;
    HUDFont mIndexFont2;

    override void Init()
    {
        Super.Init();

        Font fnt;

        // Create the fonts used for the HUDs
        fnt = "BIGFONT";

        mHUDFont = HUDFont.Create(fnt, fnt.GetCharWidth("0"), Mono_CellCenter, 1, 1);

        fnt = "SMALLFONT";

        mHUDFont2 = HUDFont.Create(fnt, fnt.GetCharWidth("0"), Mono_CellCenter, 1, 1);

        fnt = "INDEXFONT";

        mIndexFont2 = HUDFont.Create(fnt, fnt.GetCharWidth("0"), Mono_CellLeft);

        diparms = InventoryBarState.Create(mIndexFont2, Font.CR_GOLD, 1, "ARTIBOX", "SELECTBO", (0, 0), "INVGEML1", "INVGEMR1", (4, -9));
    }

    override void Draw (int state, double TicFrac)
    {
        BaseStatusBar.Draw (state, TicFrac);

        if (state == HUD_StatusBar)
        {
            BeginStatusBar();
            DrawMainBar (TicFrac);
        } else {
            if (state == HUD_Fullscreen)
            {
                BeginHUD();
                DrawFullScreenStuff ();
            }
        }
    }

    protected void DrawMainBar (double TicFrac)
    {
        let intermissionmode = CPlayer.mo.FindInventory("IntermissionModeItem");
        let cutscenemode = CPlayer.mo.FindInventory("CutsceneModeItem");

        if (intermissionmode) { DrawImage("SQSTBRI", (0, 168), DI_TRANSLATABLE|DI_ITEM_OFFSETS); }

        if (cutscenemode) { DrawImage("SQSTBRC", (0, 168), DI_TRANSLATABLE|DI_ITEM_OFFSETS); }

        if (intermissionmode || cutscenemode) { return; }

        DrawImage("SQSTBAR", (0, 168), DI_TRANSLATABLE|DI_ITEM_OFFSETS);
        DrawString(mHUDFont, FormatNumber(CPlayer.Health, 3, 3), (102, 170), DI_TEXT_ALIGN_RIGHT|DI_NOSHADOW, Font.CR_RED);
        DrawString(mHUDFont, FormatNumber(GetArmorAmount(), 3, 3), (224, 170), DI_TEXT_ALIGN_RIGHT|DI_NOSHADOW, Font.CR_RED);

        Inventory a1, a2;
        [a1, a2] = GetCurrentAmmo();

        if (a1) { DrawString(mHUDFont, FormatNumber(a1.Amount, 3, 3), (49, 170), DI_TEXT_ALIGN_RIGHT|DI_NOSHADOW, Font.CR_RED); }
        if (a2) { DrawString(mHUDFont2, FormatNumber(a2.Amount, 3, 3), (16, 177), DI_TEXT_ALIGN_RIGHT|DI_NOSHADOW, Font.CR_RED); }

        let goonadethrowcheck = CPlayer.mo.FindInventory("GoonadeThrowCheck");

        if (goonadethrowcheck) { DrawImage("GNMETER" .. clamp(goonadethrowcheck.Amount, 1, goonadethrowcheck.MaxAmount), (128, 152), DI_ITEM_OFFSETS); }

        DrawBarKeys();
        DrawBarAmmo();

        let goonades = Ammo(CPlayer.mo.FindInventory("NumberofGoonades"));

        if (goonades)
        {
            let goonadesamount = goonades.Amount;

            if (goonadesamount > 0)
            {
                DrawImage("FS_NADES", (304, 156), DI_ITEM_OFFSETS);
                DrawString(mIndexFont, FormatNumber(goonadesamount, 3, 1), (319, 162), DI_TEXT_ALIGN_RIGHT|DI_NOSHADOW, Font.CR_WHITE);
            }
        }

        if (multiplayer && deathmatch) { DrawString(mHUDFont, FormatNumber(CPlayer.FragCount, 3, 2 + (CPlayer.FragCount < 0)), (139, 170), DI_TEXT_ALIGN_RIGHT, Font.CR_RED); }
        else { DrawBarWeapons(); }

        if (CPlayer.mo.InvSel && !Level.NoInventoryBar)
        {
            DrawInventoryIcon(CPlayer.mo.InvSel, (143, 168), DI_DIMDEPLETED|DI_ITEM_OFFSETS);

            if (CPlayer.mo.InvSel.Amount > 1) { DrawString(mAmountFont, FormatNumber(CPlayer.mo.InvSel.Amount), (172, 198 - mIndexFont.mFont.GetHeight()), DI_TEXT_ALIGN_RIGHT, Font.CR_GOLD); }
        } else {
            let hasenvirosuit = Powerup(CPlayer.mo.FindInventory("PowerEnviroSuit"));

            if (hasenvirosuit) { DrawImage("PF_SUIT", (143, 168), DI_ITEM_OFFSETS); }
            DrawTexture(GetMugShot(5), (143, 168), DI_ITEM_OFFSETS);

            if (CPlayer.ReadyWeapon && CPlayer.ReadyWeapon.GetClassName() == "SauceWeapon")
            {
                DrawImage("PF_YIKES", (143, 168), DI_TRANSLATABLE|DI_ITEM_OFFSETS);
                if (hasenvirosuit) { DrawImage("PF_SUIT", (143, 168), DI_ITEM_OFFSETS); }
            }
        }

        // Not ideal. The bar graphic overlaps itself if you get more than two items.
        let hasscanner = Powerup(CPlayer.mo.FindInventory("PowerScanner"));
        let hasenvirosuit = Powerup(CPlayer.mo.FindInventory("PowerEnviroSuit"));
        let hasnodrown = Powerup(CPlayer.mo.FindInventory("PowerNoDrown"));
        let hasenergydrink = Powerup(CPlayer.mo.FindInventory("PowerEnergyDrink"));
        let has2xdamage = Powerup(CPlayer.mo.FindInventory("Power2xDamage"));
        let hasinvulnerable = Powerup(CPlayer.mo.FindInventory("PowerInvulnerable"));
        let hasflight = Powerup(CPlayer.mo.FindInventory("PowerFlight"));

        if (hasscanner || hasenvirosuit) { DrawImage("FS_POWER", (0, 141), DI_ITEM_OFFSETS); }
        if (hasnodrown) { DrawImage("FS_POWER", (0, 141), DI_ITEM_OFFSETS); }
        if (hasenergydrink || has2xdamage) { DrawImage("FS_POWER", (0, 141), DI_ITEM_OFFSETS); }
        if (hasinvulnerable && hasflight) { DrawImage("FS_POWER", (0, 141), DI_ITEM_OFFSETS); }

        // [tv50] bar alignment's not perfect, but it'll do for now
        if (hasscanner)
        {
            DrawImage("PF_ANTEN", (143, 168), DI_ITEM_OFFSETS);
            DrawBar("PW_SCAN", "PW_NULL", hasscanner.EffectTics, 30 * TICRATE, (3, 156), 0, SHADER_HORZ, DI_ITEM_OFFSETS);
        }

        if (hasinvulnerable && hasflight)
        {
            DrawImage("PF_HALO", (143, 168), DI_ITEM_OFFSETS);
            DrawBar("PW_ANGEL", "PW_NULL", hasinvulnerable.EffectTics, 40 * TICRATE, (3, 156), 0, SHADER_HORZ, DI_ITEM_OFFSETS);
        }

        if (has2xdamage)
        {
            DrawImage("PF_HORNS", (143, 168), DI_ITEM_OFFSETS);
            DrawBar("PW_DEVIL", "PW_NULL", has2xdamage.EffectTics, 40 * TICRATE, (3, 156), 0, SHADER_HORZ, DI_ITEM_OFFSETS);
        }

        if (hasenergydrink)
        {
            DrawImage("PF_BUBBL", (143, 168), DI_ITEM_OFFSETS);
            DrawBar("PW_SPEED", "PW_NULL", hasenergydrink.EffectTics, 45 * TICRATE, (3, 156), 0, SHADER_HORZ, DI_ITEM_OFFSETS);
        }

        if (hasenvirosuit)
        {
            DrawImage("PF_SUIT", (143, 168), DI_ITEM_OFFSETS);
            DrawBar("PW_SUIT", "PW_NULL", hasenvirosuit.EffectTics, 90 * TICRATE, (3, 156), 0, SHADER_HORZ, DI_ITEM_OFFSETS);
        }

        if (hasnodrown)
        {
            DrawImage("PF_BOWL", (143, 168), DI_ITEM_OFFSETS);
            DrawImage("BOWLSCRL", (0, 0), DI_ITEM_OFFSETS);
            DrawImage("BOWLSCRR", (255, 30), DI_ITEM_OFFSETS);
            DrawBar("PW_AIR", "PW_NULL", hasnodrown.EffectTics, 90 * TICRATE, (3, 156), 0, SHADER_HORZ, DI_ITEM_OFFSETS);
        }

        CPlayer.inventorytics = 0;

        //if (isInventoryBarVisible()) { DrawInventoryBar(diparms, (155, 200), 7); }
    }

    override void DrawBarKeys()
    {
        if (CPlayer.mo.CheckKeys(2, false, true)) { DrawImage("STKEYS0", (230, 171), DI_ITEM_OFFSETS); }
        if (CPlayer.mo.CheckKeys(3, false, true)) { DrawImage("STKEYS1", (230, 181), DI_ITEM_OFFSETS); }
        if (CPlayer.mo.CheckKeys(1, false, true)) { DrawImage("STKEYS2", (230, 191), DI_ITEM_OFFSETS); }
        if (CPlayer.mo.CheckKeys(5, false, true)) { DrawImage("STKEYS3", (230, 171), DI_ITEM_OFFSETS); }
        if (CPlayer.mo.CheckKeys(6, false, true)) { DrawImage("STKEYS4", (230, 181), DI_ITEM_OFFSETS); }
        if (CPlayer.mo.CheckKeys(4, false, true)) { DrawImage("STKEYS5", (230, 191), DI_ITEM_OFFSETS); }

        if (CPlayer.mo.CheckKeys(8, false, true)) { DrawImage("STKEYSF1", (230, 171), DI_ITEM_OFFSETS); }
        if (CPlayer.mo.CheckKeys(9, false, true)) { DrawImage("STKEYSF2", (230, 181), DI_ITEM_OFFSETS); }
        if (CPlayer.mo.CheckKeys(10, false, true)) { DrawImage("STKEYSF3", (230, 191), DI_ITEM_OFFSETS); }

        if (CPlayer.mo.CheckKeys(11, false, true)) { DrawImage("STKEYSS", (230, 171), DI_ITEM_OFFSETS); }
        if (CPlayer.mo.CheckKeys(12, false, true)) { DrawImage("STKEYSC", (230, 181), DI_ITEM_OFFSETS); }
        if (CPlayer.mo.CheckKeys(13, false, true)) { DrawImage("STKEYSD", (230, 191), DI_ITEM_OFFSETS); }
        if (CPlayer.mo.CheckKeys(14, false, true)) { DrawImage("STKEYSCD", (230, 171), DI_ITEM_OFFSETS); }

        if (CPlayer.mo.CheckKeys(16, false, true)) { DrawImage("STKEYS6", (230, 171), DI_ITEM_OFFSETS); }
        if (CPlayer.mo.CheckKeys(17, false, true)) { DrawImage("STKEYSO", (230, 171), DI_ITEM_OFFSETS); }

        if (CPlayer.mo.CheckKeys(7, false, true)) { DrawImage("STKEYS7", (230, 181), DI_ITEM_OFFSETS); }
        if (CPlayer.mo.CheckKeys(15, false, true)) { DrawImage("STKEYS8", (230, 191), DI_ITEM_OFFSETS); }
    }

    override void DrawBarAmmo()
    {
        int amt1, maxamt;

        [amt1, maxamt] = GetAmount("PaintAmmo");
        DrawString(mIndexFont, FormatNumber(amt1, 3, 3), (263, 169), DI_TEXT_ALIGN_RIGHT);
        DrawBar("AMMHBAR1", "AMMHBARE", amt1, maxamt, (265, 170), 0, SHADER_HORZ, DI_ITEM_OFFSETS);

        [amt1, maxamt] = GetAmount("OoziAmmo");
        DrawString(mIndexFont, FormatNumber(amt1, 3, 3), (263, 175), DI_TEXT_ALIGN_RIGHT);
        DrawBar("AMMHBAR2", "AMMHBARE", amt1, maxamt, (265, 176), 0, SHADER_HORZ, DI_ITEM_OFFSETS);

        [amt1, maxamt] = GetAmount("ShotboltAmmo");
        DrawString(mIndexFont, FormatNumber(amt1, 3, 3), (263, 181), DI_TEXT_ALIGN_RIGHT);
        DrawBar("AMMHBAR3", "AMMHBARE", amt1, maxamt, (265, 182), 0, SHADER_HORZ, DI_ITEM_OFFSETS);

        [amt1, maxamt] = GetAmount("HellshellAmmo");
        DrawString(mIndexFont, FormatNumber(amt1, 3, 3), (263, 187), DI_TEXT_ALIGN_RIGHT);
        DrawBar("AMMHBAR4", "AMMHBARE", amt1, maxamt, (265, 188), 0, SHADER_HORZ, DI_ITEM_OFFSETS);

        [amt1, maxamt] = GetAmount("MarbleAmmo");
        DrawString(mIndexFont, FormatNumber(amt1, 3, 3), (263, 193), DI_TEXT_ALIGN_RIGHT);
        DrawBar("AMMHBAR5", "AMMHBARE", amt1, maxamt, (265, 194), 0, SHADER_HORZ, DI_ITEM_OFFSETS);
    }

    override void DrawBarWeapons()
    {
        DrawImage("SQSTARMS", (104, 168), DI_TRANSLATABLE|DI_ITEM_OFFSETS);
        DrawImage((Ammo(CPlayer.mo.FindInventory("NumberofGoonades")) && Ammo(CPlayer.mo.FindInventory("NumberofGoonades")).Amount > 0) || Weapon(CPlayer.mo.FindInventory("Oozi")) ? "STYNUM2" : "STNNUM2", (111, 172), DI_ITEM_OFFSETS);
        DrawImage(CPlayer.HasWeaponsInSlot(3) ? "STYNUM3" : "STNNUM3", (122, 172), DI_ITEM_OFFSETS);
        DrawImage(CPlayer.HasWeaponsInSlot(4) ? "STYNUM4" : "STNNUM4", (133, 172), DI_ITEM_OFFSETS);
        DrawImage(CPlayer.HasWeaponsInSlot(5) ? "STYNUM5" : "STNNUM5", (111, 182), DI_ITEM_OFFSETS);
        DrawImage(CPlayer.HasWeaponsInSlot(6) ? "STYNUM6" : "STNNUM6", (122, 182), DI_ITEM_OFFSETS);
        DrawImage(CPlayer.HasWeaponsInSlot(7) ? "STYNUM7" : "STNNUM7", (133, 182), DI_ITEM_OFFSETS);
    }

    protected void DrawFullScreenStuff ()
    {
        let intermissionmode = CPlayer.mo.FindInventory("IntermissionModeItem");
        let cutscenemode = CPlayer.mo.FindInventory("CutsceneModeItem");

        if (intermissionmode || cutscenemode) { return; }

        // health
        DrawImage("FS_HELTH", (0, -27), DI_TRANSLATABLE|DI_ITEM_OFFSETS);
        DrawString(mHUDFont, FormatNumber(CPlayer.Health, 1, 3), (2, -25), DI_TEXT_ALIGN_LEFT|DI_NOSHADOW, Font.CR_RED);

        // armor
        DrawImage("FS_ARMOR", (0, -53), DI_TRANSLATABLE|DI_ITEM_OFFSETS);

        let armor = CPlayer.mo.FindInventory("BasicArmor", true);

        if (armor != null && armor.Amount > 0) { DrawString(mHUDFont, FormatNumber(armor.Amount, 1, 3), (2, -51), DI_TEXT_ALIGN_LEFT|DI_NOSHADOW, Font.CR_RED); }

        DrawImage("FS_ARMIC", (50, -52), DI_TRANSLATABLE|DI_ITEM_OFFSETS);
        if (armor != null && armor.Amount > 0) { DrawInventoryIcon(armor, (50, -52), DI_ITEM_OFFSETS); }

        // ammo
        DrawImage("FS_AMMO", (-70, -52), DI_TRANSLATABLE|DI_ITEM_OFFSETS);

        Inventory ammotype1, ammotype2;
        [ammotype1, ammotype2] = GetCurrentAmmo();

        int invY = -20;

        // primary
        if (ammotype1 != null)
        {
            DrawString(mHUDFont, FormatNumber(ammotype1.Amount, 3, 3), (-1, -25), DI_TEXT_ALIGN_RIGHT|DI_NOSHADOW, Font.CR_RED);

            invY -= 18;
        }

        // goonades
        DrawImage("FS_ARMIC", (-93, -52), DI_TRANSLATABLE|DI_ITEM_OFFSETS);

        let goonades = Ammo(CPlayer.mo.FindInventory("NumberofGoonades"));

        if (goonades)
        {
            let goonadesamount = goonades.Amount;

            if (goonadesamount > 0)
            {
                DrawImage("FS_NADES", (-88, -48), DI_ITEM_OFFSETS);
                DrawString(mIndexFont, FormatNumber(goonadesamount, 3, 1), (-73, -40), DI_TEXT_ALIGN_RIGHT|DI_NOSHADOW, Font.CR_RED);
            }
        }

        // arms (base)
        DrawImage("SQKEYBAR", (-93, -31), DI_ITEM_OFFSETS);

        // keys
        DrawImage("SQKEYBAR", (50, -31), DI_ITEM_OFFSETS);
        DrawFullscreenKeys();

        // arms (weapon displays)
        DrawFullscreenWeapons();

        // ammo capacities
        DrawFullscreenAmmo();

        // goonade throw power
        let goonadethrowcheck = CPlayer.mo.FindInventory("GoonadeThrowCheck");

        if (goonadethrowcheck) { DrawImage("GNMETER" .. clamp(goonadethrowcheck.Amount, 1, goonadethrowcheck.MaxAmount), (-31, -48), DI_SCREEN_CENTER_BOTTOM|DI_ITEM_OFFSETS); }

        // secondary
        if (ammotype2 != null && ammotype2 != ammotype1)
        {
            DrawString(mHUDFont, FormatNumber(ammotype2.Amount, 3, 1), (-51, -25), DI_TEXT_ALIGN_RIGHT|DI_NOSHADOW, Font.CR_RED);

            invY -= 18;
        }

        // mugshot/selected inventory (latter recreated because ???)
        if (!Level.NoInventoryBar && CPlayer.mo.InvSel)
        {
            if (!isInventoryBarVisible() && (ammotype1 != null || (ammotype2 != null && ammotype2 != ammotype1)))
            {
                DrawInventoryIcon(CPlayer.mo.InvSel, (-14, invY + 17), DI_ALWAYSSHOWCOUNT|DI_DIMDEPLETED);
                DrawString(mHUDFont, FormatNumber(CPlayer.mo.InvSel.Amount, 3), (-26, invY), DI_TEXT_ALIGN_RIGHT|DI_NOSHADOW);
            }

            DrawInventoryIcon(CPlayer.mo.InvSel, (143, 168), DI_ALWAYSSHOWCOUNT|DI_DIMDEPLETED|DI_ITEM_OFFSETS);
            DrawString(mAmountFont, FormatNumber(CPlayer.mo.InvSel.Amount, 3), (182, 192), DI_TEXT_ALIGN_RIGHT|DI_NOSHADOW);
        } else {
            DrawImage("SQSTFACE", (-17, -32), DI_TRANSLATABLE|DI_SCREEN_CENTER_BOTTOM|DI_ITEM_OFFSETS);

            let hasenvirosuit = Powerup(CPlayer.mo.FindInventory("PowerEnviroSuit"));

            if (hasenvirosuit) { DrawImage("PF_SUIT", (-17, -32), DI_SCREEN_CENTER_BOTTOM|DI_ITEM_OFFSETS); }
            DrawTexture(GetMugShot(5), (-17, -32), DI_SCREEN_CENTER_BOTTOM|DI_ITEM_OFFSETS);

            if (CPlayer.ReadyWeapon && CPlayer.ReadyWeapon.GetClassName() == "SauceWeapon")
            {
                DrawImage("PF_YIKES", (-17, -32), DI_TRANSLATABLE|DI_SCREEN_CENTER_BOTTOM|DI_ITEM_OFFSETS);
                if (hasenvirosuit) { DrawImage("PF_SUIT", (-17, -32), DI_SCREEN_CENTER_BOTTOM|DI_ITEM_OFFSETS); }
            }
        }

        // frags
        if (deathmatch) { DrawString(mHUDFont, FormatNumber(CPlayer.FragCount, 3, 3 + (CPlayer.FragCount < 0)), (-3, 1), DI_TEXT_ALIGN_RIGHT|DI_NOSHADOW, Font.CR_RED); }

        // powerup timers
        // Not ideal. The bar graphic overlaps itself if you get more than two items.
        let hasscanner = Powerup(CPlayer.mo.FindInventory("PowerScanner"));
        let hasenvirosuit = Powerup(CPlayer.mo.FindInventory("PowerEnviroSuit"));
        let hasnodrown = Powerup(CPlayer.mo.FindInventory("PowerNoDrown"));
        let hasenergydrink = Powerup(CPlayer.mo.FindInventory("PowerEnergyDrink"));
        let has2xdamage = Powerup(CPlayer.mo.FindInventory("Power2xDamage"));
        let hasinvulnerable = Powerup(CPlayer.mo.FindInventory("PowerInvulnerable"));
        let hasflight = Powerup(CPlayer.mo.FindInventory("PowerFlight"));

        if (hasscanner || hasenvirosuit) { DrawImage("FS_POWER", (0, -79), DI_ITEM_OFFSETS); }
        if (hasnodrown) { DrawImage("FS_POWER", (0, -79), DI_ITEM_OFFSETS); }
        if (hasenergydrink || has2xdamage) { DrawImage("FS_POWER", (0, -79), DI_ITEM_OFFSETS); }
        if (hasinvulnerable && hasflight) { DrawImage("FS_POWER", (0, -79), DI_ITEM_OFFSETS); }

        if (hasscanner)
        {
            DrawImage("PF_ANTEN", (-17, -32), DI_SCREEN_CENTER_BOTTOM|DI_ITEM_OFFSETS);
            DrawBar("PW_SCAN", "PW_NULL", hasscanner.EffectTics, 30 * TICRATE, (3, -64), 0, SHADER_HORZ, DI_ITEM_OFFSETS);
        }

        if (hasinvulnerable && hasflight)
        {
            DrawImage("PF_HALO", (-17, -32), DI_SCREEN_CENTER_BOTTOM|DI_ITEM_OFFSETS);
            DrawBar("PW_ANGEL", "PW_NULL", hasinvulnerable.EffectTics, 40 * TICRATE, (3, -64), 0, SHADER_HORZ, DI_ITEM_OFFSETS);
        }

        if (has2xdamage)
        {
            DrawImage("PF_HORNS", (-17, -32), DI_SCREEN_CENTER_BOTTOM|DI_ITEM_OFFSETS);
            DrawBar("PW_DEVIL", "PW_NULL", has2xdamage.EffectTics, 40 * TICRATE, (3, -64), 0, SHADER_HORZ, DI_ITEM_OFFSETS);
        }

        if (hasenergydrink)
        {
            DrawImage("PF_BUBBL", (-17, -32), DI_SCREEN_CENTER_BOTTOM|DI_ITEM_OFFSETS);
            DrawBar("PW_SPEED", "PW_NULL", hasenergydrink.EffectTics, 45 * TICRATE, (3, -64), 0, SHADER_HORZ, DI_ITEM_OFFSETS);
        }

        if (hasenvirosuit)
        {
            DrawImage("PF_SUIT", (-17, -32), DI_SCREEN_CENTER_BOTTOM|DI_ITEM_OFFSETS);
            DrawBar("PW_SUIT", "PW_NULL", hasenvirosuit.EffectTics, 90 * TICRATE, (3, -64), 0, SHADER_HORZ, DI_ITEM_OFFSETS);
        }

        if (hasnodrown)
        {
            DrawImage("PF_BOWL", (-17, -32), DI_SCREEN_CENTER_BOTTOM|DI_ITEM_OFFSETS);
            DrawImage("BOWLSCRL", (0, 0), DI_ITEM_OFFSETS);
            DrawImage("BOWLSCRR", (-65, -201), DI_ITEM_OFFSETS);
            DrawBar("PW_AIR", "PW_NULL", hasnodrown.EffectTics, 90 * TICRATE, (3, -64), 0, SHADER_HORZ, DI_ITEM_OFFSETS);
        }

        // inventory bar
        CPlayer.inventorytics = 0;

        //if (isInventoryBarVisible()) { DrawInventoryBar(diparms, (-1, -1), 7, DI_SCREEN_CENTER_BOTTOM, HX_SHADOW); }
    }

    override void DrawFullscreenKeys()
    {
        if (CPlayer.mo.CheckKeys(2, false, true)) { DrawImage("STKEYS0", (53, -28), DI_ITEM_OFFSETS); }
        if (CPlayer.mo.CheckKeys(3, false, true)) { DrawImage("STKEYS1", (53, -18), DI_ITEM_OFFSETS); }
        if (CPlayer.mo.CheckKeys(1, false, true)) { DrawImage("STKEYS2", (53, -8), DI_ITEM_OFFSETS); }
        if (CPlayer.mo.CheckKeys(5, false, true)) { DrawImage("STKEYS3", (53, -28), DI_ITEM_OFFSETS); }
        if (CPlayer.mo.CheckKeys(6, false, true)) { DrawImage("STKEYS4", (53, -18), DI_ITEM_OFFSETS); }
        if (CPlayer.mo.CheckKeys(4, false, true)) { DrawImage("STKEYS5", (53, -8), DI_ITEM_OFFSETS); }

        if (CPlayer.mo.CheckKeys(8, false, true)) { DrawImage("STKEYSF1", (53, -28), DI_ITEM_OFFSETS); }
        if (CPlayer.mo.CheckKeys(9, false, true)) { DrawImage("STKEYSF2", (53, -18), DI_ITEM_OFFSETS); }
        if (CPlayer.mo.CheckKeys(10, false, true)) { DrawImage("STKEYSF3", (53, -8), DI_ITEM_OFFSETS); }

        if (CPlayer.mo.CheckKeys(11, false, true)) { DrawImage("STKEYSS", (53, -28), DI_ITEM_OFFSETS); }
        if (CPlayer.mo.CheckKeys(12, false, true)) { DrawImage("STKEYSC", (53, -18), DI_ITEM_OFFSETS); }
        if (CPlayer.mo.CheckKeys(13, false, true)) { DrawImage("STKEYSD", (53, -8), DI_ITEM_OFFSETS); }
        if (CPlayer.mo.CheckKeys(14, false, true)) { DrawImage("STKEYSCD", (53, -28), DI_ITEM_OFFSETS); }

        if (CPlayer.mo.CheckKeys(16, false, true)) { DrawImage("STKEYS6", (53, -28), DI_ITEM_OFFSETS); }
        if (CPlayer.mo.CheckKeys(17, false, true)) { DrawImage("STKEYSO", (53, -28), DI_ITEM_OFFSETS); }

        if (CPlayer.mo.CheckKeys(7, false, true)) { DrawImage("STKEYS7", (53, -18), DI_ITEM_OFFSETS); }
        if (CPlayer.mo.CheckKeys(15, false, true)) { DrawImage("STKEYS8", (53, -8), DI_ITEM_OFFSETS); }
    }

    protected virtual void DrawFullscreenWeapons()
    {
        DrawImage(CPlayer.HasWeaponsInSlot(2) ? "STYNUM2" : "STNNUM2", (-89, -28), DI_ITEM_OFFSETS);
        DrawImage(CPlayer.HasWeaponsInSlot(3) ? "STYNUM3" : "STNNUM3", (-89, -18), DI_ITEM_OFFSETS);
        DrawImage(CPlayer.HasWeaponsInSlot(4) ? "STYNUM4" : "STNNUM4", (-89, -8), DI_ITEM_OFFSETS);
        DrawImage(CPlayer.HasWeaponsInSlot(5) ? "STYNUM5" : "STNNUM5", (-78, -28), DI_ITEM_OFFSETS);
        DrawImage(CPlayer.HasWeaponsInSlot(6) ? "STYNUM6" : "STNNUM6", (-78, -18), DI_ITEM_OFFSETS);
        DrawImage(CPlayer.HasWeaponsInSlot(7) ? "STYNUM7" : "STNNUM7", (-78, -8), DI_ITEM_OFFSETS);
    }

    protected virtual void DrawFullscreenAmmo()
    {
        int amt1, maxamt;

        [amt1, maxamt] = GetAmount("PaintAmmo");
        DrawBar("AMMOBAR1", "AMMOBARE", amt1, maxamt, (-67, -49), 0, SHADER_VERT|SHADER_REVERSE, DI_ITEM_OFFSETS);
        if (amt1 > 0) { DrawString(mIndexFont, FormatNumber(amt1, 1, 3), (-63, -32), DI_TEXT_ALIGN_CENTER); }

        [amt1, maxamt] = GetAmount("OoziAmmo");
        DrawBar("AMMOBAR2", "AMMOBARE", amt1, maxamt, (-53, -49), 0, SHADER_VERT|SHADER_REVERSE, DI_ITEM_OFFSETS);
        if (amt1 > 0) { DrawString(mIndexFont, FormatNumber(amt1, 1, 3), (-49, -32), DI_TEXT_ALIGN_CENTER); }

        [amt1, maxamt] = GetAmount("ShotboltAmmo");
        DrawBar("AMMOBAR3", "AMMOBARE", amt1, maxamt, (-39, -49), 0, SHADER_VERT|SHADER_REVERSE, DI_ITEM_OFFSETS);
        if (amt1 > 0) { DrawString(mIndexFont, FormatNumber(amt1, 1, 3), (-35, -32), DI_TEXT_ALIGN_CENTER); }

        [amt1, maxamt] = GetAmount("HellshellAmmo");
        DrawBar("AMMOBAR4", "AMMOBARE", amt1, maxamt, (-25, -49), 0, SHADER_VERT|SHADER_REVERSE, DI_ITEM_OFFSETS);
        if (amt1 > 0) { DrawString(mIndexFont, FormatNumber(amt1, 1, 3), (-21, -32), DI_TEXT_ALIGN_CENTER); }

        [amt1, maxamt] = GetAmount("MarbleAmmo");
        DrawBar("AMMOBAR5", "AMMOBARE", amt1, maxamt, (-11, -49), 0, SHADER_VERT|SHADER_REVERSE, DI_ITEM_OFFSETS);
        if (amt1 > 0) { DrawString(mIndexFont, FormatNumber(amt1, 1, 3), (-7, -32), DI_TEXT_ALIGN_CENTER); }
    }

    void DrawInventoryBar(InventoryBarState parms, Vector2 position, int numfields, int flags = 0, double bgalpha = 1.)
    {
        double width = parms.boxsize.X * numfields;
        [position, flags] = AdjustPosition(position, flags, width, parms.boxsize.Y);

        CPlayer.mo.InvFirst = ValidateInvFirst(numfields);

        if (!CPlayer.mo.InvFirst) { return; } // Player has no listed inventory items.

        Vector2 boxsize = parms.boxsize;
        int boxseparator = 1;

        // First draw all the boxes
        for (int i = 0; i < numfields; i++) { DrawTexture(parms.box, position + ((boxsize.X + boxseparator) * i, 0), flags|DI_ITEM_LEFT_TOP, bgalpha); }

        // now the items and the rest
        Vector2 itempos = position + boxsize / 2;
        itempos += (-15, -15);

        Vector2 textpos = position + boxsize - (1, 1 + parms.amountfont.mFont.GetHeight());
        textpos += (-3, -1);

        int i = 0;

        Inventory item;

        for (item = CPlayer.mo.InvFirst; item && i < numfields; item = item.NextInv())
        {
            for (int j = 0; j < 2; j++)
            {
                if (j ^ !!(flags & DI_DRAWCURSORFIRST))
                {
                    if (item == CPlayer.mo.InvSel)
                    {
                        double flashAlpha = 1.; //bgalpha;

                        if (flags & DI_ARTIFLASH) { flashAlpha *= itemflashFade; }

                        DrawTexture(parms.selector, position + parms.selectofs + ((boxsize.X + boxseparator) * i, 0), flags|DI_ITEM_LEFT_TOP, flashAlpha);
                    }
                }
                else { DrawInventoryIcon(item, itempos + ((boxsize.X + boxseparator) * i, 0), flags|DI_DIMDEPLETED|DI_ITEM_OFFSETS); }
            }

            if (parms.amountfont && (item.Amount > 1 || (flags & DI_ALWAYSSHOWCOUNTERS))) { DrawString(parms.amountfont, FormatNumber(item.Amount), textpos + ((boxsize.X + boxseparator) * i, 0), flags|DI_TEXT_ALIGN_RIGHT, parms.cr, parms.itemalpha); }

            i++;
        }

        // Is there something to the left?
        if (CPlayer.mo.FirstInv() != CPlayer.mo.InvFirst) { DrawTexture(parms.left, position + (-parms.arrowoffset.X, parms.arrowoffset.Y), flags|DI_ITEM_RIGHT|DI_ITEM_VCENTER); }

        // Is there something to the right?
        if (item) { DrawTexture(parms.right, position + (parms.arrowoffset.X + 5, parms.arrowoffset.Y) + (width, 0), flags|DI_ITEM_LEFT|DI_ITEM_VCENTER); }
    }
}
