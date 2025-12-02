class GoodOlHUDStatusBar : DoomStatusBar
{
    HUDFont mHUDFont2;
    HUDFont mIndexFont2;

    HUDFont GOHmHUDFont;
    InventoryBarState GOHdiparms0, GOHdiparms1;
    int GOHtheme, GOHcolorscheme;

    const INT_MIN = 0x80000000;
    const INT_MAX = 0x7FFFFFFF;

    // this clearly can't be the most convenient way to do this
    static const Name ColorSchemeDefinitions[] =
    {
        "default",      "[Untranslated]", "[Gold]",
        "doom",         "[Red]",          "[White]",
        "freedoom",     "[Red]",          "[White]",
        "raven",        "[Yellow]",       "[White]",
        "strife",       "[Yellow]",       "[White]",
        "blasphemer",   "[Red]",          "[White]",
        "chex",         "[Yellow]",       "[White]",
        "harmony",      "[MiamiRetro]",   "[WhiteBorder]",
        "hacx",         "[Green]",        "[White]",
        "square",       "[Red]",          "[White]",
        "woolball",     "[White]",        "[Gold]",
        "psxdoom",      "[DarkRed]",      "[White]",
        "psxfinaldoom", "[Red]",          "[White]",
        "rekkr",        "[Yellow]",       "[White]",
        "wolf3d",       "[White]",        "[Gold]",
        "duke3d",       "[Orange]",       "[White]",
        "duke64",       "[LightBlue]",    "[White]",
        "marathon1",    "[Green]",        "[White]",
        "marathon2",    "[Green]",        "[White]",
        "quake1",       "[DarkBrown]",    "[White]"
    };

    String theme;
    String colorschemebase;
    String colorschemetext, colorschemeactivetext;
    String barbase;
    String bar, barblank;
    String timerbase;
    String timerbaseleft, timerbaseright;

    override void Init()
    {
        Super.Init();

        Font fnt;

        // Create the fonts used for the status bar HUD
        fnt = "BIGFONT";

        mHUDFont = HUDFont.Create(fnt, fnt.GetCharWidth("0"), Mono_CellCenter, 1, 1);

        fnt = "SMALLFONT";

        mHUDFont2 = HUDFont.Create(fnt, fnt.GetCharWidth("0"), Mono_CellCenter, 1, 1);

        fnt = "INDEXFONT";

        mIndexFont2 = HUDFont.Create(fnt, fnt.GetCharWidth("0"), Mono_CellLeft);

        diparms = InventoryBarState.Create(mIndexFont2, Font.CR_GOLD, 1, "ARTIBOX", "SELECTBO", (0, 0), "INVGEML1", "INVGEMR1", (4, -9));

        // Create the fonts used for the fullscreen HUD
        fnt = "fonts/goodolhud_font.bmf";

        GOHmHUDFont = HUDFont.Create(fnt, fnt.GetCharWidth("0") + 2, Mono_CellCenter, 2, 2);

        GOHdiparms0 = InventoryBarState.CreateNoBox(GOHmHUDFont, Font.CR_UNTRANSLATED, 1, (40, 34), "graphics/hud/theme0/icons/goodolhud_icon_inventoryselector.png", (36, 30), "graphics/hud/theme0/icons/goodolhud_icon_inventoryleft.png", "graphics/hud/theme0/icons/goodolhud_icon_inventoryright.png", (44, -38), DI_SCREEN_CENTER_BOTTOM);
        GOHdiparms1 = InventoryBarState.CreateNoBox(GOHmHUDFont, Font.CR_UNTRANSLATED, 1, (40, 34), "graphics/hud/theme1/icons/goodolhud_icon_inventoryselector.png", (36, 30), "graphics/hud/theme1/icons/goodolhud_icon_inventoryleft.png", "graphics/hud/theme1/icons/goodolhud_icon_inventoryright.png", (44, -38), DI_SCREEN_CENTER_BOTTOM);
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
                GOHDrawFullScreenStuff ();
            }
        }
    }

    // SBARINFO conversion
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
                DrawString(mIndexFont, FormatNumber(goonadesamount, 1, 1), (319, 162), DI_TEXT_ALIGN_RIGHT|DI_NOSHADOW, Font.CR_WHITE);
            }
        }

        if (deathmatch || teamplay) { DrawString(mHUDFont, FormatNumber(CPlayer.FragCount, 3, 2 + (CPlayer.FragCount < 0)), (139, 170), DI_TEXT_ALIGN_RIGHT, Font.CR_RED); }
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

        CPlayer.inventorytics = 0;

        //if (isInventoryBarVisible()) { DrawInventoryBar(diparms, (155, 200), 7); }

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
                        double flashAlpha = bgalpha;

                        if (flags & DI_ARTIFLASH) { flashAlpha *= itemflashFade; }

                        DrawTexture(parms.selector, position + parms.selectofs + ((boxsize.X + boxseparator) * i, 0), flags|DI_ITEM_LEFT_TOP, flashAlpha);
                    }
                }
                else { DrawInventoryIcon(item, itempos + ((boxsize.X + boxseparator) * i, 0), flags|DI_DIMDEPLETED|DI_ITEM_OFFSETS); }
            }

            if (parms.amountfont && (item.Amount > 1 || (flags & DI_ALWAYSSHOWCOUNTERS))) { DrawString(parms.amountfont, FormatNumber(item.Amount, 0, 10), textpos + ((boxsize.X + boxseparator) * i, 0), flags|DI_TEXT_ALIGN_RIGHT, parms.cr, parms.itemalpha); }

            i++;
        }

        // Is there something to the left?
        if (CPlayer.mo.FirstInv() != CPlayer.mo.InvFirst) { DrawTexture(parms.left, position + (-parms.arrowoffset.X, parms.arrowoffset.Y), flags|DI_ITEM_RIGHT|DI_ITEM_VCENTER); }

        // Is there something to the right?
        if (item) { DrawTexture(parms.right, position + (parms.arrowoffset.X + 5, parms.arrowoffset.Y) + (width, 0), flags|DI_ITEM_LEFT|DI_ITEM_VCENTER); }
    }

    int bottomleftvertelements;
    int bottomleftverttimerrows;

    protected void GOHDrawFullScreenStuff ()
    {
        // HUD initialization
        Vector2 coordbase, coordnudge;

        // for powerup/status timer stuff
        bottomleftvertelements = 0; // label
        bottomleftverttimerrows = 0; // theme

        GOHtheme = CVar.FindCVar("goh_theme").GetInt();
        GOHcolorscheme = CVar.FindCVar("goh_colorscheme").GetInt();

        theme = "theme" .. GOHtheme;

        switch (GOHcolorscheme)
        {
          case -2:
          case -1:
            GOHcolorscheme = 9;
            break;
        }

        GOHcolorscheme = GOHcolorscheme * 3;

        colorschemebase = ColorSchemeDefinitions[GOHcolorscheme];
        colorschemetext = ColorSchemeDefinitions[GOHcolorscheme + 1];
        colorschemeactivetext = ColorSchemeDefinitions[GOHcolorscheme + 2];

        barbase = "graphics/hud/" .. theme .. "/bars/goodolhud_bar_base_" .. colorschemebase .. ".png";
        barblank = "graphics/hud/" .. theme .. "/bars/goodolhud_bar_blank.png";

        timerbase = "graphics/hud/" .. theme .. "/timers/goodolhud_timer_base_" .. colorschemebase .. ".png";
        timerbaseleft = "graphics/hud/" .. theme .. "/timers/goodolhud_timer_basesideleft_" .. colorschemebase .. ".png";
        timerbaseright = "graphics/hud/" .. theme .. "/timers/goodolhud_timer_basesideright_" .. colorschemebase .. ".png";

        let bargradients = CVar.FindCVar("goh_bargradients").GetBool();
        let canalwaysshowinvcounter = CVar.FindCVar("goh_alwaysshowinventorycounter").GetBool();

        // if you're bypassing 255, you're just asking for a crash anyway. let the VM abort serve as a warning
        let teamcolor = !teamplay || CPlayer.GetTeam() == 255 ? Font.CR_UNTRANSLATED : Teams[CPlayer.GetTeam()].GetTextColor();

        // HUD hiding
        if (CPlayer.mo.FindInventory("IntermissionModeItem") || CPlayer.mo.FindInventory("CutsceneModeItem"))
        {
            if (isInventoryBarVisible())
            {
                let GOHdiparms = GOHdiparms0;

                switch (GOHtheme)
                {
                  case 1: GOHdiparms = GOHdiparms1; break;
                }

                GOHDrawInventoryBar(GOHdiparms, (-13, 30), 7, DI_SCREEN_CENTER_BOTTOM|(canalwaysshowinvcounter ? DI_ALWAYSSHOWCOUNTERS : 0));
            }

            return;
        }

        // "Background".
        coordnudge = (0, 0);

        // Fishtank
        if (Powerup(CPlayer.mo.FindInventory("PowerNoDrown")))
        {
            coordbase = (0 + coordnudge.X, 0 + coordnudge.Y);

            DrawImage("BOWLSCRL", coordbase, DI_SCREEN_LEFT_TOP|DI_ITEM_OFFSETS);
            DrawImage("BOWLSCRR", (coordbase.X - 65, coordbase.Y - 201), DI_SCREEN_RIGHT_BOTTOM|DI_ITEM_OFFSETS);
        }

        // Bottom left.
        coordnudge = (0, 0);
        powerupnudge = (0, 0);

        // Team name
        if (CVar.FindCVar("goh_showteamname").GetBool() && teamplay)
        {
            coordbase = (4 + coordnudge.X, -17 + coordnudge.Y);

            Name teamname = CPlayer.GetTeam() == 255 ? StringTable.Localize("$GOODOLHUD_NOTEAM") : Teams[CPlayer.GetTeam()].mName;

            // only append "Team" to the end of the default team names
            switch (teamname)
            {
              case 'Blue':
              case 'Red':
              case 'Green':
              case 'Gold':
              case 'Black':
              case 'White':
              case 'Orange':
              case 'Purple':
                teamname = teamname .. " " .. StringTable.Localize("$GOODOLHUD_TEAM");
                break;
            }

            DrawString(GOHmHUDFont, (teamcolor == Font.CR_UNTRANSLATED ? "\c" .. colorschemetext : "") .. teamname, coordbase, DI_SCREEN_LEFT_BOTTOM|DI_TEXT_ALIGN_LEFT, teamcolor);

            coordnudge.Y -= 16;
            powerupnudge.Y -= 16;
        }

        // Player name
        if (CVar.FindCVar("goh_showplayername").GetBool())
        {
            GOHDrawPlayerName(4 + coordnudge.X, -17 + coordnudge.Y);

            coordnudge.Y -= 16;
            powerupnudge.Y -= 16;
        }

        // Mugshot
        let canshowmugshot = CVar.FindCVar("goh_showmugshot").GetBool() && GetMugShot(5).IsValid();

        if (canshowmugshot)
        {
            GOHDrawMugShot(4 + coordnudge.X, -39 + coordnudge.Y);

            coordnudge.X += 43;
            powerupnudge.X += 43;
        }

        // Stamina and accuracy
        let canshowstamina = CVar.FindCVar("goh_showstamina").GetBool();
        let canshowaccuracy = CVar.FindCVar("goh_showaccuracy").GetBool();

        if (canshowstamina || canshowaccuracy)
        {
            coordbase = (4 + coordnudge.X, -17 + coordnudge.Y);

            DrawString(GOHmHUDFont,
                       (canshowstamina ? "\c[Red]" .. StringTable.Localize("$GOODOLHUD_STAMINA") .. " " .. FormatNumber(CPlayer.mo.Stamina, 1, 3) .. " \c-" : "") ..
                       (canshowaccuracy ? "\c[Yellow]" .. StringTable.Localize("$GOODOLHUD_ACCURACY") .. " " .. FormatNumber(CPlayer.mo.Accuracy, 1, 3) .. " \c-" : ""),
                       coordbase, DI_SCREEN_LEFT_BOTTOM|DI_TEXT_ALIGN_LEFT);

            bottomleftvertelements++;

            coordnudge.Y -= 16;
            powerupnudge.Y -= 16;
        }

        // Armor
        let armor = BasicArmor(CPlayer.mo.FindInventory("BasicArmor", true)), hexenarmor = HexenArmor(CPlayer.mo.FindInventory("HexenArmor", true));
        let currenthexenarmor = hexenarmor.Slots[0] + hexenarmor.Slots[1] + hexenarmor.Slots[2] + hexenarmor.Slots[3] + hexenarmor.Slots[4];

        let swaphealtharmor = CVar.FindCVar("goh_swaphealtharmor").GetBool();

        if (armor && armor.Amount > 0)
        {
            if (swaphealtharmor) { coordnudge.Y -= 16; }

            coordbase = (99 + coordnudge.X, -4 + coordnudge.Y);
            let totalarmor = 100 + armor.BonusCount;

            let canshowarmortype = CVar.FindCVar("goh_showarmortype").GetBool();

            DrawImage(barbase, coordbase, DI_SCREEN_LEFT_BOTTOM);

            bar = "graphics/hud/" .. theme .. "/bars/goodolhud_bar_green.png";
            DrawBar(bar, barblank, armor.Amount, totalarmor, (coordbase.X, coordbase.Y - 1), 0, SHADER_HORZ, DI_SCREEN_LEFT_BOTTOM);

            bar = "graphics/hud/" .. theme .. "/bars/goodolhud_bar_armorovermax1.png";
            DrawBar(bar, barblank, armor.Amount - totalarmor, totalarmor, (coordbase.X, coordbase.Y - 1), 0, SHADER_HORZ, DI_SCREEN_LEFT_BOTTOM);

            bar = "graphics/hud/" .. theme .. "/bars/goodolhud_bar_armorovermax2.png";
            DrawBar(bar, barblank, armor.Amount - (totalarmor * 2), totalarmor, (coordbase.X, coordbase.Y - 1), 0, SHADER_HORZ, DI_SCREEN_LEFT_BOTTOM);

            DrawString(GOHmHUDFont, StringTable.Localize("$GOODOLHUD_ARMOR"), (coordbase.X - 79, coordbase.Y - 14), DI_SCREEN_LEFT_BOTTOM|DI_TEXT_ALIGN_RIGHT, Font.CR_GREEN);

            if (canshowarmortype)
            {
                String armorcolor = "darkbrown";

                switch (armor.ArmorType)
                {
                  // Tier 1 armor
                  case 'BasicArmorBonus': // ArtiBoostArmor
                  case 'ArmorBonus':
                  case 'SlimeRepellent':
                  case 'GreenArmor':
                  case 'ChexArmor':
                    armorcolor = "green";
                    break;

                  case 'SilverShield': armorcolor = "silver"; break;
                  case 'LeatherArmor': armorcolor = "brown"; break;

                  // Tier 2 armor
                  case 'BlueArmor':
                  case 'BlueArmorForMegasphere':
                  case 'SuperChexArmor':
                    armorcolor = "blue";
                    break;

                  case 'EnchantedShield': armorcolor = "gold"; break;
                  case 'MetalArmor': armorcolor = "silver"; break;
                  case 'ArmorWood': armorcolor = "yellow"; break;

                  // Tier 3 armor
                  case 'BasicArmorPickup': // cheat
                  case 'ArmorBrick':
                    armorcolor = "red";
                    break;

                  // Tier 4 armor
                  case 'ArmorDiamond': armorcolor = "cyan"; break;

                  // Tier 5 armor
                  case 'ArmorThunderbox': armorcolor = "darkgray"; break;
                }

                DrawImage("graphics/hud/" .. theme .. "/icons/goodolhud_icon_armor" .. armorcolor .. ".png", (coordbase.X + 83, coordbase.Y - 2), DI_SCREEN_LEFT_BOTTOM);
            }

            DrawString(GOHmHUDFont,
                       FormatNumber(armor.Amount, 1, 4) .. StringTable.Localize("$GOODOLHUD_SEPARATOR") .. FormatNumber(totalarmor, 1, 4) ..
                       (CVar.FindCVar("goh_showarmorsavepercent").GetBool() ? " " .. StringTable.Localize("$GOODOLHUD_EXTRA_START") .. String.Format("%.1f", armor.SavePercent * 100) .. StringTable.Localize("$GOODOLHUD_PERCENTAGE") .. StringTable.Localize("$GOODOLHUD_EXTRA_END") : ""),
                       (coordbase.X + 77 + (canshowarmortype ? 16 : 0), coordbase.Y - 14), DI_SCREEN_LEFT_BOTTOM|DI_TEXT_ALIGN_LEFT, Font.CR_GREEN);

            bottomleftvertelements++;

            coordnudge.Y -= 16;
            powerupnudge.Y -= 16;

            if (swaphealtharmor) { coordnudge.Y += 16; }
        }

        if (currenthexenarmor > 0)
        {
            if (swaphealtharmor) { coordnudge.Y -= 16; }

            coordbase = (99 + coordnudge.X, -4 + coordnudge.Y);

            let canshowarmorclass = CVar.FindCVar("goh_showarmorclass").GetBool();

            DrawImage(barbase, coordbase, DI_SCREEN_LEFT_BOTTOM);

            bar = "graphics/hud/" .. theme .. "/bars/goodolhud_bar_green.png";
            DrawBar(bar, barblank, currenthexenarmor, 100, (coordbase.X, coordbase.Y - 1), 0, SHADER_HORZ, DI_SCREEN_LEFT_BOTTOM);

            DrawString(GOHmHUDFont, StringTable.Localize("$GOODOLHUD_ARMORCLASS"), (coordbase.X - 79, coordbase.Y - 14), DI_SCREEN_LEFT_BOTTOM|DI_TEXT_ALIGN_RIGHT, Font.CR_GREEN);

            DrawString(GOHmHUDFont, FormatNumber(currenthexenarmor / (canshowarmorclass ? 5 : 1), 1, 3) .. StringTable.Localize("$GOODOLHUD_SEPARATOR") .. FormatNumber(100 / (canshowarmorclass ? 5 : 1), 1, 3), (coordbase.X + 77, coordbase.Y - 14), DI_SCREEN_LEFT_BOTTOM|DI_TEXT_ALIGN_LEFT, Font.CR_GREEN);

            bottomleftvertelements++;

            coordnudge.Y -= 16;
            powerupnudge.Y -= 16;

            if (swaphealtharmor) { coordnudge.Y += 16; }
        }

        // Health
        if (swaphealtharmor) { coordnudge.Y += 16 * (0 + (armor && armor.Amount > 0) + (currenthexenarmor > 0)); }

        coordbase = (99 + coordnudge.X, -4 + coordnudge.Y);

        let canshowberserk = CVar.FindCVar("goh_showberserk").GetBool() && Powerup(CPlayer.mo.FindInventory("PowerStrength"));
        let cancolorhealth = CVar.FindCVar("goh_colorhealthoninvuln").GetBool() && isInvulnerable();
        let canshownegativehealth = !CVar.FindCVar("goh_lowerhealthcap").GetBool() && CPlayer.mo.Health < 0;

        String invulnbarcolor = "white";
        let invulntextcolor = Font.CR_WHITE;

        DrawImage(barbase, coordbase, DI_SCREEN_LEFT_BOTTOM);

        bar = "graphics/hud/" .. theme .. "/bars/goodolhud_bar_" .. (cancolorhealth ? invulnbarcolor : "red") .. ".png";
        DrawBar(bar, barblank, CPlayer.Health, CPlayer.mo.GetMaxHealth(true), (coordbase.X, coordbase.Y - 1), 0, SHADER_HORZ, DI_SCREEN_LEFT_BOTTOM);

        if (!cancolorhealth) // do not overlap with multiple bars if invulned
        {
            bar = "graphics/hud/" .. theme .. "/bars/goodolhud_bar_healthovermax1.png";
            DrawBar(bar, barblank, CPlayer.Health - CPlayer.mo.GetMaxHealth(true), CPlayer.mo.GetMaxHealth(true), (coordbase.X, coordbase.Y - 1), 0, SHADER_HORZ, DI_SCREEN_LEFT_BOTTOM);

            bar = "graphics/hud/" .. theme .. "/bars/goodolhud_bar_healthovermax2.png";
            DrawBar(bar, barblank, CPlayer.Health - (CPlayer.mo.GetMaxHealth(true) * 2), CPlayer.mo.GetMaxHealth(true), (coordbase.X, coordbase.Y - 1), 0, SHADER_HORZ, DI_SCREEN_LEFT_BOTTOM);
        }

        DrawString(GOHmHUDFont, StringTable.Localize("$GOODOLHUD_HEALTH"), (coordbase.X - 79, coordbase.Y - 14), DI_SCREEN_LEFT_BOTTOM|DI_TEXT_ALIGN_RIGHT, cancolorhealth ? invulntextcolor : Font.CR_RED);

        if (canshowberserk) { DrawImage("graphics/hud/" .. theme .. "/icons/goodolhud_icon_berserk.png", (coordbase.X + 83, coordbase.Y - 2), DI_SCREEN_LEFT_BOTTOM); }

        DrawString(GOHmHUDFont, FormatNumber(canshownegativehealth ? CPlayer.mo.Health : CPlayer.Health, 1, 4 + canshownegativehealth) .. StringTable.Localize("$GOODOLHUD_SEPARATOR") .. FormatNumber(CPlayer.mo.GetMaxHealth(true), 1, 4), (coordbase.X + 77 + (canshowberserk ? 16 : 0), coordbase.Y - 14), DI_SCREEN_LEFT_BOTTOM|DI_TEXT_ALIGN_LEFT, cancolorhealth ? invulntextcolor : Font.CR_RED);

        coordnudge.Y -= 16;
        powerupnudge.Y -= 16;

        if (swaphealtharmor) { coordnudge.Y -= 16 * (0 + (armor && armor.Amount > 0) + (currenthexenarmor > 0)); }

        // Powerup timers
        haspowerup = false;

        if (CVar.FindCVar("goh_showpoweruptimers").GetBool()) { GOHDrawPowerupTimers(20 + coordnudge.X, -17 + coordnudge.Y); }

        if (haspowerup) { bottomleftvertelements += 2; }

        coordnudge.Y -= 32 * haspowerup;
        powerupnudge.Y -= 32 * haspowerup;

        // Status timers
        hasstatus = false;

        if (CVar.FindCVar("goh_showstatustimers").GetBool()) { GOHDrawStatusTimers(20 + coordnudge.X, -17 + coordnudge.Y); }

        if (hasstatus) { bottomleftvertelements += 2; }

        coordnudge.Y -= 32 * hasstatus;
        powerupnudge.Y -= 32 * hasstatus;

        // Hazard count
        if (CVar.FindCVar("goh_showhazardcount").GetBool() && CPlayer.HazardCount > 0)
        {
            coordbase = (99 + coordnudge.X, -4 + coordnudge.Y);
            int hazardcountamt = CPlayer.HazardCount, hazardcountmaxamt = 16 * TICRATE;

            DrawImage(barbase, coordbase, DI_SCREEN_LEFT_BOTTOM);

            bar = "graphics/hud/" .. theme .. "/bars/goodolhud_bar_darkgreen.png";
            DrawBar(bar, barblank, hazardcountamt, hazardcountmaxamt, (coordbase.X, coordbase.Y - 1), 0, SHADER_HORZ, DI_SCREEN_LEFT_BOTTOM);

            bar = "graphics/hud/" .. theme .. "/bars/goodolhud_bar_hazardovermax1.png";
            DrawBar(bar, barblank, hazardcountamt - hazardcountmaxamt, hazardcountmaxamt, (coordbase.X, coordbase.Y - 1), 0, SHADER_HORZ, DI_SCREEN_LEFT_BOTTOM);

            bar = "graphics/hud/" .. theme .. "/bars/goodolhud_bar_hazardovermax2.png";
            DrawBar(bar, barblank, hazardcountamt - (hazardcountmaxamt * 2), hazardcountmaxamt, (coordbase.X, coordbase.Y - 1), 0, SHADER_HORZ, DI_SCREEN_LEFT_BOTTOM);

            DrawString(GOHmHUDFont, StringTable.Localize("$GOODOLHUD_HAZARD" .. (canshowmugshot && bottomleftvertelements >= 2 ? "" : "_SHORT")), (coordbase.X - 79, coordbase.Y - 14), DI_SCREEN_LEFT_BOTTOM|DI_TEXT_ALIGN_RIGHT, Font.CR_DARKGREEN);

            DrawString(GOHmHUDFont, String.Format("%.1f", hazardcountamt * 100.0 / hazardcountmaxamt) .. StringTable.Localize("$GOODOLHUD_PERCENTAGE"), (coordbase.X + 77, coordbase.Y - 14), DI_SCREEN_LEFT_BOTTOM|DI_TEXT_ALIGN_LEFT, Font.CR_DARKGREEN);

            bottomleftvertelements++;

            coordnudge.Y -= 16;
            powerupnudge.Y -= 16;
        }

        // Bottom right.
        coordnudge = (0, 0);

        // Weapon name
        weaponnameamount = 0;

        if (CVar.FindCVar("goh_showweaponname").GetBool()) { GOHDrawWeaponName(-6 + coordnudge.X, -17 + coordnudge.Y); }

        coordnudge.Y -= 16 * weaponnameamount;

        // Ammo
        foundammotypes = 0;

        GOHDrawAmmo(-155 + coordnudge.X, -4 + coordnudge.Y);

        coordnudge.Y -= 16 * foundammotypes;

        // Ammo capacities
        foundammocapacities = 0;

        if (CVar.FindCVar("goh_showammocapacities").GetBool()) { GOHDrawAmmoCapacities(-234 + coordnudge.X, -17 + coordnudge.Y); }

        coordnudge.Y -= 16 * foundammocapacities;

        // Currencies
        if (CVar.FindCVar("goh_showcoincounter").GetBool())
        {
            coordbase = (-250 + coordnudge.X, -17 + coordnudge.Y);

            DrawString(GOHmHUDFont, StringTable.Localize("$GOODOLHUD_MONEY") .. FormatNumber(GetAmount("Coin"), 1, 10), coordbase, DI_SCREEN_RIGHT_BOTTOM|DI_TEXT_ALIGN_LEFT, Font.CR_GREEN);
        }

        // reset nudging at this point
        coordnudge = (0, 0 - (16 * weaponnameamount));

        // Selected inventory
        coordbase = (-274 + coordnudge.X, -4 + coordnudge.Y);

        if (!isInventoryBarVisible() && !Level.NoInventoryBar && CPlayer.mo.InvSel)
        {
            DrawImage("graphics/hud/" .. theme .. "/icons/goodolhud_icon_inventory_" .. colorschemebase .. ".png", coordbase, DI_SCREEN_RIGHT_BOTTOM);

            DrawInventoryIcon(CPlayer.mo.InvSel, (coordbase.X, coordbase.Y - 17), DI_DIMDEPLETED|DI_SCREEN_RIGHT_BOTTOM|DI_ITEM_CENTER, 1, (36, 30));

            DrawString(GOHmHUDFont, CPlayer.mo.InvSel.Amount > 1 || canalwaysshowinvcounter ? "\c" .. colorschemetext .. FormatNumber(CPlayer.mo.InvSel.Amount, 1, 5) : "", (coordbase.X - 1, coordbase.Y - 50), DI_SCREEN_RIGHT_BOTTOM|DI_TEXT_ALIGN_CENTER);
        }

        // Weapon bar
        if (CVar.FindCVar("goh_showweaponbar").GetBool()) { GOHDrawWeaponBar(-406 + coordnudge.X, -17 + coordnudge.Y); }

        // Top center.
        coordnudge = (0, 0);

        // Oxygen
        if (CVar.FindCVar("goh_showairtimer").GetBool() && CPlayer.mo.waterlevel >= 3)
        {
            coordbase = (0 + coordnudge.X, 20 + coordnudge.Y);

            coordbase.Y += 16 * (con_centernotify * con_notifylines);

            DrawImage(barbase, coordbase, DI_SCREEN_CENTER_TOP);

            bar = "graphics/hud/" .. theme .. "/bars/goodolhud_bar_blue.png";
            DrawBar(bar, barblank, CPlayer.air_finished - Level.maptime, Level.airsupply, (coordbase.X, coordbase.Y - 1), 0, SHADER_HORZ, DI_SCREEN_CENTER_TOP);

            DrawString(GOHmHUDFont, StringTable.Localize("$GOODOLHUD_OXYGEN"), (coordbase.X - 79, coordbase.Y - 14), DI_SCREEN_CENTER_TOP|DI_TEXT_ALIGN_RIGHT, Font.CR_BLUE);

            DrawString(GOHmHUDFont, FormatNumber(clamp((CPlayer.air_finished - Level.maptime + (TICRATE - 1)) / TICRATE, 0, INT_MAX), 1, 4), (coordbase.X + 77, coordbase.Y - 14), DI_SCREEN_CENTER_TOP|DI_TEXT_ALIGN_LEFT, Font.CR_BLUE);
        }

        // Top right.
        coordnudge = (0, 0);

        // Map/hub timer
        let canshowtimer = CVar.FindCVar("goh_showtimer").GetInt();

        if (canshowtimer >= 1)
        {
            coordbase = (-6 + coordnudge.X, 3 + coordnudge.Y);
            let timerflags = DI_SCREEN_RIGHT_TOP|DI_TEXT_ALIGN_RIGHT;

            if (canshowtimer >= 2 && deathmatch && timelimit)
            {
                int timeleft = int(timelimit * TICRATE * 60) - Level.maptime;
                int hours, minutes, seconds;

                if (timeleft < 0) { timeleft = 0; }

                hours = timeleft / (TICRATE * 3600);
                timeleft -= hours * TICRATE * 3600;
                minutes = timeleft / (TICRATE * 60);
                timeleft -= minutes * TICRATE * 60;
                seconds = timeleft / TICRATE;

                DrawString(GOHmHUDFont, "\c" .. colorschemetext .. String.Format("%02d:%02d:%02d", hours, minutes, seconds), coordbase, timerflags);
            } else {
                int hubsec = Level.time / 35;
                int mapsec = Level.maptime / 35;
                int parsec = Level.partime;

                DrawString(GOHmHUDFont, "\c" .. (CVar.FindCVar("goh_colortimerunderpar").GetBool() && mapsec < parsec && !deathmatch ? colorschemeactivetext : colorschemetext) .. String.Format("%02d:%02d:%02d", hubsec / 3600, (hubsec % 3600) / 60, hubsec % 60), coordbase, timerflags);
            }

            coordnudge.Y += 16;
        }

        // Total timer
        if (CVar.FindCVar("goh_showtimertotal").GetBool())
        {
            coordbase = (-6 + coordnudge.X, 3 + coordnudge.Y);

            int totalsec = Level.totaltime / 35;

            DrawString(GOHmHUDFont, "\c" .. colorschemetext .. String.Format("%02d:%02d:%02d", totalsec / 3600, (totalsec % 3600) / 60, totalsec % 60), coordbase, DI_SCREEN_RIGHT_TOP|DI_TEXT_ALIGN_RIGHT);

            coordnudge.Y += 16;
        }

        // Kill counts
        if (deathmatch)
        {
            let killcountflags = DI_SCREEN_RIGHT_TOP|DI_TEXT_ALIGN_RIGHT;

            // Individual frag count
            coordbase = (-6 + coordnudge.X, 3 + coordnudge.Y);

            DrawString(GOHmHUDFont, "\c" .. colorschemetext .. FormatNumber(CPlayer.FragCount, 1, 10 + (CPlayer.FragCount < 0)), coordbase, killcountflags);

            coordnudge.Y += 16;

            // Team frag count
            if (teamplay)
            {
                coordbase = (-6 + coordnudge.X, 3 + coordnudge.Y);

                int count = 0;

                for (uint i = 0; i < MAXPLAYERS; ++i)
                {
                    if (PlayerInGame[i] && players[i].GetTeam() == CPlayer.GetTeam()) { count += players[i].FragCount; }
                }

                DrawString(GOHmHUDFont, (teamcolor == Font.CR_UNTRANSLATED ? "\c" .. colorschemetext : "") .. FormatNumber(count, 1, 10 + (count < 0)), coordbase, killcountflags, teamcolor);

                coordnudge.Y += 16;
            }
        }

        // Level stats and keys
        if (!deathmatch)
        {
            // Monsters
            if (CVar.FindCVar("goh_showmonstercounter").GetBool())
            {
                coordbase = (-102 + coordnudge.X, 3 + coordnudge.Y);

                DrawString(GOHmHUDFont, StringTable.Localize("$GOODOLHUD_MONSTERS"), coordbase, DI_SCREEN_RIGHT_TOP|DI_TEXT_ALIGN_RIGHT, Font.CR_BRICK);

                DrawString(GOHmHUDFont, FormatNumber(Level.killed_monsters, 1, 5) .. StringTable.Localize("$GOODOLHUD_SEPARATOR"), (coordbase.X + 56, coordbase.Y), DI_SCREEN_RIGHT_TOP|DI_TEXT_ALIGN_RIGHT, Font.CR_BRICK);
                DrawString(GOHmHUDFont, FormatNumber(Level.total_monsters, 1, 5), (coordbase.X + 56, coordbase.Y), DI_SCREEN_RIGHT_TOP|DI_TEXT_ALIGN_LEFT, Font.CR_BRICK);

                coordnudge.Y += 16;
            }

            // Secrets
            if (CVar.FindCVar("goh_showsecretcounter").GetBool())
            {
                coordbase = (-102 + coordnudge.X, 3 + coordnudge.Y);

                DrawString(GOHmHUDFont, StringTable.Localize("$GOODOLHUD_SECRETS"), coordbase, DI_SCREEN_RIGHT_TOP|DI_TEXT_ALIGN_RIGHT, Font.CR_YELLOW);

                DrawString(GOHmHUDFont, FormatNumber(Level.found_secrets, 1, 5) .. StringTable.Localize("$GOODOLHUD_SEPARATOR"), (coordbase.X + 56, coordbase.Y), DI_SCREEN_RIGHT_TOP|DI_TEXT_ALIGN_RIGHT, Font.CR_YELLOW);
                DrawString(GOHmHUDFont, FormatNumber(Level.total_secrets, 1, 5), (coordbase.X + 56, coordbase.Y), DI_SCREEN_RIGHT_TOP|DI_TEXT_ALIGN_LEFT, Font.CR_YELLOW);

                coordnudge.Y += 16;
            }

            // Items
            if (CVar.FindCVar("goh_showitemcounter").GetBool())
            {
                coordbase = (-102 + coordnudge.X, 3 + coordnudge.Y);

                DrawString(GOHmHUDFont, StringTable.Localize("$GOODOLHUD_ITEMS"), coordbase, DI_SCREEN_RIGHT_TOP|DI_TEXT_ALIGN_RIGHT, Font.CR_LIGHTBLUE);

                DrawString(GOHmHUDFont, FormatNumber(Level.found_items, 1, 5) .. StringTable.Localize("$GOODOLHUD_SEPARATOR"), (coordbase.X + 56, coordbase.Y), DI_SCREEN_RIGHT_TOP|DI_TEXT_ALIGN_RIGHT, Font.CR_LIGHTBLUE);
                DrawString(GOHmHUDFont, FormatNumber(Level.total_items, 1, 5), (coordbase.X + 56, coordbase.Y), DI_SCREEN_RIGHT_TOP|DI_TEXT_ALIGN_LEFT, Font.CR_LIGHTBLUE);

                coordnudge.Y += 16;
            }

            // Keys
            GOHDrawFullscreenKeys(-4 + coordnudge.X, 4 + coordnudge.Y);

            // no vertical nudging done here; miscellaneous inventory is left of the key display
        }

        // Miscellaneous inventory
        GOHDrawMiscItems(-62 + coordnudge.X, 34 + coordnudge.Y);

        // Top priority.
        coordnudge = (0, 0);

        // Inventory bar
        if (isInventoryBarVisible())
        {
            let GOHdiparms = GOHdiparms0;

            switch (GOHtheme)
            {
              case 1: GOHdiparms = GOHdiparms1; break;
            }

            GOHDrawInventoryBar(GOHdiparms, (-13, 30), 7, DI_SCREEN_CENTER_BOTTOM|(canalwaysshowinvcounter ? DI_ALWAYSSHOWCOUNTERS : 0));
        }
    }

    protected virtual void GOHDrawPlayerName(int coordbasex, int coordbasey)
    {
        // if you're bypassing 255, you're just asking for a crash anyway. let the VM abort serve as a warning
        let teamcolor = !CVar.FindCVar("goh_playernameteamcolor").GetBool() || !teamplay || CPlayer.GetTeam() == 255 ? Font.CR_UNTRANSLATED : Teams[CPlayer.GetTeam()].GetTextColor();

        DrawString(GOHmHUDFont, (teamcolor == Font.CR_UNTRANSLATED ? "\c" .. colorschemetext : "") .. CPlayer.GetUserName(), (coordbasex, coordbasey), DI_SCREEN_LEFT_BOTTOM|DI_TEXT_ALIGN_LEFT, teamcolor);
    }

    protected virtual void GOHDrawMugShot(int coordbasex, int coordbasey)
    {
        DrawImage("graphics/hud/" .. theme .. "/icons/goodolhud_icon_mugshot_" .. colorschemebase .. ".png", (coordbasex, coordbasey), DI_SCREEN_LEFT_BOTTOM|DI_ITEM_OFFSETS);

        if (CPlayer.ReadyWeapon && CPlayer.ReadyWeapon.GetClassName() == "SauceWeapon") { DrawImage("graphics/hud/goodolhud_PF_YIKES.png", (coordbasex + 19.6, coordbasey + 17.5), DI_SCREEN_LEFT_BOTTOM|DI_ITEM_CENTER, 1, (35, 31)); }
        else { DrawTexture(GetMugShot(5), (coordbasex + 19.6, coordbasey + 17.5), DI_SCREEN_LEFT_BOTTOM|DI_ITEM_CENTER, 1, (35, 31)); }

        // powerup graphics stuff currently moved to powerup timers
    }

    bool haspowerup;

    protected virtual void GOHDrawPowerupTimers(int coordbasex, int coordbasey)
    {
        int maxpowerups = 7 * 3;

        static const Name PowerupDefinitions[] =
        {
            "HolySphere",        "white",    "[White]",
            "PowerInvulnerable", "white",    "[White]", // respawn protection
            "PowerEnviroSuit",   "yellow",   "[Yellow]",
            "PowerNoDrown",      "sapphire", "[Sapphire]",
            "Power2xDamage",     "red",      "[Red]",
            "PowerEnergyDrink",  "orange",   "[Orange]",
            "PowerScanner",      "purple",   "[Purple]"
        };

        int checkedpowerups = 0, activepowerups = 0;

        for (checkedpowerups = 0; checkedpowerups < maxpowerups; checkedpowerups += 3)
        {
            let currentpowerup = Powerup(CPlayer.mo.FindInventory(PowerupDefinitions[checkedpowerups]));

            switch (PowerupDefinitions[checkedpowerups])
            {
              default:
                if (!currentpowerup) { continue; }
                break;

              case 'HolySphere': // checks for both invuln and flight
                if (!Powerup(CPlayer.mo.FindInventory("PowerInvulnerable")) || !Powerup(CPlayer.mo.FindInventory("PowerFlight"))) { continue; }

                currentpowerup = Powerup(CPlayer.mo.FindInventory("PowerInvulnerable")); // displays invuln timer (which shares the same amount as flight timer)
                break;

              case 'PowerInvulnerable': // only used for sv_respawnprotect
                if (!currentpowerup || !CPlayer.mo.bRespawnInvul || Powerup(CPlayer.mo.FindInventory("PowerFlight"))) { continue; } // can be overridden by HolySphere
                break;

              case 'PowerFlight':
                if (!currentpowerup || (!multiplayer && Level.infinite_flight)) { continue; }
                break;
            }

            activepowerups++;
        }

        if (activepowerups > 0)
        {
            Vector2 powerup = (coordbasex + 6, coordbasey);

            int currentpowerupnum = 0;

            bottomleftverttimerrows++;

            let canshowmugshot = CVar.FindCVar("goh_showmugshot").GetBool() && GetMugShot(5).IsValid();

            DrawString(GOHmHUDFont, "\c" .. colorschemetext .. StringTable.Localize("$GOODOLHUD_POWERUPS" .. (canshowmugshot && bottomleftvertelements >= 2 ? "" : "_SHORT")), (coordbasex, coordbasey), DI_SCREEN_LEFT_BOTTOM|DI_TEXT_ALIGN_RIGHT);

            for (checkedpowerups = 0; checkedpowerups < maxpowerups; checkedpowerups += 3)
            {
                let currentpowerup = Powerup(CPlayer.mo.FindInventory(PowerupDefinitions[checkedpowerups]));

                switch (PowerupDefinitions[checkedpowerups])
                {
                  default:
                    if (!currentpowerup) { continue; }
                    break;

                  case 'HolySphere': // checks for both invuln and flight
                    if (!Powerup(CPlayer.mo.FindInventory("PowerInvulnerable")) || !Powerup(CPlayer.mo.FindInventory("PowerFlight"))) { continue; }

                    currentpowerup = Powerup(CPlayer.mo.FindInventory("PowerInvulnerable")); // displays invuln timer (which shares the same amount as flight timer)
                    break;

                  case 'PowerInvulnerable': // only used for sv_respawnprotect
                    if (!currentpowerup || !CPlayer.mo.bRespawnInvul || Powerup(CPlayer.mo.FindInventory("PowerFlight"))) { continue; } // can be overridden by HolySphere
                    break;

                  case 'PowerFlight':
                    if (!currentpowerup || (!multiplayer && Level.infinite_flight)) { continue; }
                    break;
                }

                currentpowerupnum++;

                DrawImage(bottomleftverttimerrows == 1 && ((currentpowerupnum <= 1 && TexMan.CheckForTexture(timerbaseleft).IsValid()) || (currentpowerupnum == 7 && TexMan.CheckForTexture(timerbaseright).IsValid())) ? (currentpowerupnum <= 1 ? timerbaseleft : timerbaseright) : timerbase, powerup, DI_SCREEN_LEFT_BOTTOM|DI_ITEM_OFFSETS);

                DrawImage("graphics/hud/" .. theme .. "/timers/goodolhud_timer_" .. PowerupDefinitions[checkedpowerups + 1] .. ".png", (powerup.X + 2, powerup.Y + 2), DI_SCREEN_LEFT_BOTTOM|DI_ITEM_OFFSETS);

                // really small-looking, but they're something
                switch (PowerupDefinitions[checkedpowerups])
                {
                  case 'HolySphere': DrawImage("PF_HALO", (powerup.X + 2, powerup.Y), DI_SCREEN_LEFT_BOTTOM|DI_ITEM_OFFSETS, 1, (9, 9)); break;
                  case 'PowerEnviroSuit': DrawImage("PF_SUIT", (powerup.X + 2.5, powerup.Y + 3.25), DI_SCREEN_LEFT_BOTTOM|DI_ITEM_OFFSETS, 1, (9, 9)); break; // looks a little off, but eh
                  case 'PowerNoDrown': DrawImage("PF_BOWL", (powerup.X + 3.25, powerup.Y - 6), DI_SCREEN_LEFT_BOTTOM|DI_ITEM_OFFSETS, 1, (9, 9)); break; // ditto (though worn more like a hat this time)
                  case 'Power2xDamage': DrawImage("PF_HORNS", powerup, DI_SCREEN_LEFT_BOTTOM|DI_ITEM_OFFSETS, 1, (17.75, 9)); break;
                  case 'PowerEnergyDrink': DrawImage("PF_BUBBL", (powerup.X + 2, powerup.Y), DI_SCREEN_LEFT_BOTTOM|DI_ITEM_OFFSETS, 1, (9, 9)); break;
                  case 'PowerScanner': DrawImage("PF_ANTEN", (powerup.X - 0.5, powerup.Y), DI_SCREEN_LEFT_BOTTOM|DI_ITEM_OFFSETS, 1, (9, 9)); break;
                }

                DrawString(GOHmHUDFont, "\c" .. PowerupDefinitions[checkedpowerups + 2] .. FormatNumber(currentpowerup.EffectTics / TICRATE, 1, 4), (powerup.X + 6, powerup.Y - 16), DI_SCREEN_LEFT_BOTTOM|DI_TEXT_ALIGN_CENTER);

                powerup.X += 22 + (!(currentpowerupnum % 4) ? 1 : 0); // !(currentpowerupnum % 4) is a lazy hack to make the powerups align with each 22.25 addition while following int rules
            }

            haspowerup = true;
        }
    }

    bool hasstatus;

    protected virtual void GOHDrawStatusTimers(int coordbasex, int coordbasey)
    {
        int maxstatuses = 1 * 3;

        static const Name StatusDefinitions[] =
        {
            "PoisonCount", "darkgreen", "[DarkGreen]"
        };

        let morphclass = CPlayer.mo.GetClass();

        int checkedstatuses = 0, activestatuses = 0;

        for (checkedstatuses = 0; checkedstatuses < maxstatuses; checkedstatuses += 3)
        {
            let currentstatus = Powerup(CPlayer.mo.FindInventory(StatusDefinitions[checkedstatuses]));

            switch (StatusDefinitions[checkedstatuses])
            {
              default:
                if (!currentstatus) { continue; }
                break;

              // special check for poison
              case 'PoisonCount':
                if (CPlayer.PoisonCount <= 0) { continue; }
                break;

              // special check for morphs
              case 'ChickenPlayer':
              case 'PigPlayer':
                if (!(morphclass is StatusDefinitions[checkedstatuses]) || CPlayer.MorphTics <= 0) { continue; }
                break;
            }

            activestatuses++;
        }

        if (activestatuses > 0)
        {
            Vector2 status = (coordbasex + 6, coordbasey);

            int currentstatusnum = 0;

            bottomleftverttimerrows++;

            let canshowmugshot = CVar.FindCVar("goh_showmugshot").GetBool() && GetMugShot(5).IsValid();

            DrawString(GOHmHUDFont, "\c" .. colorschemetext .. StringTable.Localize("$GOODOLHUD_STATUS" .. (canshowmugshot && bottomleftvertelements >= 2 ? "" : "_SHORT")), (coordbasex, coordbasey), DI_SCREEN_LEFT_BOTTOM|DI_TEXT_ALIGN_RIGHT);

            for (checkedstatuses = 0; checkedstatuses < maxstatuses; checkedstatuses += 3)
            {
                let currentstatus = Powerup(CPlayer.mo.FindInventory(StatusDefinitions[checkedstatuses]));

                bool checkingpoison = false, checkingmorph = false;

                switch (StatusDefinitions[checkedstatuses])
                {
                  default:
                    if (!currentstatus) { continue; }
                    break;

                  // special check for poison
                  case 'PoisonCount':
                    if (CPlayer.PoisonCount <= 0) { continue; }

                    checkingpoison = true;
                    break;

                  // special check for morphs
                  case 'ChickenPlayer':
                  case 'PigPlayer':
                    if (!(morphclass is StatusDefinitions[checkedstatuses]) || CPlayer.MorphTics <= 0) { continue; }

                    checkingmorph = true;
                    break;
                }

                currentstatusnum++;

                DrawImage(bottomleftverttimerrows == 1 && ((currentstatusnum <= 1 && TexMan.CheckForTexture(timerbaseleft).IsValid()) || (currentstatusnum == 7 && TexMan.CheckForTexture(timerbaseright).IsValid())) ? (currentstatusnum <= 1 ? timerbaseleft : timerbaseright) : timerbase, status, DI_SCREEN_LEFT_BOTTOM|DI_ITEM_OFFSETS);

                DrawImage("graphics/hud/" .. theme .. "/timers/goodolhud_timer_" .. StatusDefinitions[checkedstatuses + 1] .. ".png", (status.X + 2, status.Y + 2), DI_SCREEN_LEFT_BOTTOM|DI_ITEM_OFFSETS);

                DrawString(GOHmHUDFont, "\c" .. StatusDefinitions[checkedstatuses + 2] .. FormatNumber(checkingpoison && CPlayer.PoisonCount > 0 ? (CPlayer.PoisonCount - 5) / 10 : checkingmorph && CPlayer.MorphTics > 0 ? CPlayer.MorphTics / TICRATE : currentstatus.EffectTics / TICRATE, 1, 4), (status.X + 6, status.Y - 16), DI_SCREEN_LEFT_BOTTOM|DI_TEXT_ALIGN_CENTER);

                status.X += 22 + (!(currentstatusnum % 4) ? 1 : 0); // !(currentstatusnum % 4) is a lazy hack to make the statuses align with each 22.25 addition while following int rules
            }

            hasstatus = true;
        }
    }

    Vector2 powerupnudge;

    override void DrawPowerups ()
    {
        // The AltHUD specific adjustments have been removed here, because the AltHUD uses its own variant of this function
        // that can obey AltHUD rules - which this cannot.
        let fullscreenhudactive = screenblocks == 11 && !(automapactive && !viewactive);

        Vector2 pos = fullscreenhudactive ? (20 + powerupnudge.X, -6 + powerupnudge.Y) : (-20, POWERUPICONSIZE * 5 / 4);
        double maxpos = screen.GetWidth() / 2;

        for (let iitem = CPlayer.mo.Inv; iitem; iitem = iitem.Inv)
        {
            let item = Powerup(iitem);

            if (item)
            {
                let icon = item.GetPowerupIcon();

                if (icon.IsValid() && !item.IsBlinking())
                {
                    // Each icon gets a 32x32 block.
                    DrawTexture(icon, pos, fullscreenhudactive ? DI_SCREEN_LEFT_BOTTOM : DI_SCREEN_RIGHT_TOP, 1, (POWERUPICONSIZE, POWERUPICONSIZE));

                    pos.x += fullscreenhudactive ? POWERUPICONSIZE : -POWERUPICONSIZE;

                    if (fullscreenhudactive ? pos.x > maxpos : pos.x < -maxpos)
                    {
                        pos.x = fullscreenhudactive ? 20 + powerupnudge.X : -20;
                        pos.y += fullscreenhudactive ? -POWERUPICONSIZE : POWERUPICONSIZE * 3 / 2;
                    }
                }
            }
        }
    }

    // [tv50] yeah I know these changes aren't the best method, but they needed to be done
    void GOHDrawInventoryBar(InventoryBarState parms, Vector2 position, int numfields, int flags = 0, double bgalpha = 1.)
    {
        double width = parms.boxsize.X * numfields;
        [position, flags] = AdjustPosition(position, flags, width, parms.boxsize.Y);

        CPlayer.mo.InvFirst = ValidateInvFirst(numfields);

        if (!CPlayer.mo.InvFirst) { return; } // Player has no listed inventory items.

        Vector2 boxsize = parms.boxsize;
        int boxseparator = 11;

        // First draw all the boxes
        for (int i = 0; i < numfields; i++) { DrawTexture(TexMan.CheckForTexture("graphics/hud/" .. theme .. "/icons/goodolhud_icon_inventory_" .. colorschemebase .. ".png"), position + ((boxsize.X + boxseparator) * i, 0), flags, bgalpha); }

        // now the items and the rest
        Vector2 itempos = position + boxsize / 2;
        itempos += (-20, -34);

        Vector2 textpos = position + boxsize - (1, 1 + parms.amountfont.mFont.GetHeight());
        textpos += (-40, -70);

        parms.selectofs = (-9, -61);

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
                        double flashAlpha = bgalpha;

                        if (flags & DI_ARTIFLASH) { flashAlpha *= itemflashFade; }

                        if (item.Amount > 1 || (flags & DI_ALWAYSSHOWCOUNTERS)) { parms.selectofs.Y -= 15; }

                        DrawTexture(parms.selector, position + parms.selectofs + ((boxsize.X + boxseparator) * i, 0), flags|DI_ITEM_OFFSETS, flashAlpha);
                    }
                }
                else { DrawInventoryIcon(item, itempos + ((boxsize.X + boxseparator) * i, 0), flags|DI_DIMDEPLETED|DI_ITEM_CENTER, 1, (36, 30)); }
            }

            if (parms.amountfont && (item.Amount > 1 || (flags & DI_ALWAYSSHOWCOUNTERS))) { DrawString(parms.amountfont, "\c" .. colorschemetext .. FormatNumber(item.Amount, 1, 5), textpos + ((boxsize.X + boxseparator) * i, 0), flags|DI_TEXT_ALIGN_CENTER, parms.cr, parms.itemalpha); }

            i++;
        }

        // Is there something to the left?
        if (CPlayer.mo.FirstInv() != CPlayer.mo.InvFirst) { DrawTexture(parms.left, position + (-parms.arrowoffset.X, parms.arrowoffset.Y), flags|DI_ITEM_OFFSETS); }

        // Is there something to the right?
        if (item) { DrawTexture(parms.right, position + (parms.arrowoffset.X + 7, parms.arrowoffset.Y) + (width, 0), flags|DI_ITEM_OFFSETS); }
    }

    int weaponnameamount;

    protected virtual void GOHDrawWeaponName(int coordbasex, int coordbasey)
    {
        Name weaponname;

        String weaponalttag, weaponmode;

        bool usingdualweapon;

        if (CPlayer.ReadyWeapon)
        {
            weaponname = CPlayer.ReadyWeapon.GetClassName();

            switch (weaponname)
            {
              case 'StrifeCrossbow':
              case 'StrifeCrossbow2':
              case 'StrifeGrenadeLauncher':
              case 'StrifeGrenadeLauncher2':
              case 'Mauler':
              case 'Mauler2':
              case 'Sigil':
                weaponmode = "$GOODOLHUD_WEAPON_MODE_" .. weaponname .. (weaponname == "Sigil" ? FormatNumber(CPlayer.ReadyWeapon.Health) : "");
                break;

              case 'PaintGun':
              case 'PaintGuns':
              case 'Oozi':
              case 'Oozis':
                usingdualweapon = weaponname == "PaintGuns" || weaponname == "Oozis";

                if (usingdualweapon) { weaponalttag = "$GOODOLHUD_WEAPON_" .. weaponname; }
                weaponmode = "$GOODOLHUD_WEAPON_MODE_" .. (usingdualweapon ? "DUAL" : "SINGLE");
                break;

              // these have no tags
              case 'SquareDummyWeapon':
              case 'CrateWeapon':
              case 'TNTCrateWeapon':
              case 'NukageCrateWeapon':
              case 'FizzoPopCrateWeapon':
              case 'SauceWeapon':
                return;
            }

            DrawString(GOHmHUDFont,
                       "\c" .. colorschemetext ..
                       (weaponalttag != "" ? StringTable.Localize(weaponalttag) : CPlayer.ReadyWeapon.GetTag()) ..
                       (weaponmode != "" ? " " .. StringTable.Localize("$GOODOLHUD_EXTRA_START") .. StringTable.Localize(weaponmode) .. StringTable.Localize("$GOODOLHUD_EXTRA_END") : ""),
                       (coordbasex, coordbasey), DI_SCREEN_RIGHT_BOTTOM|DI_TEXT_ALIGN_RIGHT);

            weaponnameamount++;
        }
    }

    int foundammotypes;

    protected virtual void GOHDrawAmmo(int coordbasex, int coordbasey)
    {
        int maxammos = 28 * 3;

        static const Name AmmoDefinitions[] = // have to use Name for switch/case and DECORATE purposes
        {
            // Doom/Chex Quest
            "Clip",       "yellow",    "[Yellow]",
            "Shell",      "red",       "[Red]",
            "RocketAmmo", "brown",     "[Brown]",
            "Cell",       "lightblue", "[LightBlue]",
            "ID24Fuel",   "fire",      "[Fire]",
            // Heretic
            "GoldWandAmmo",   "yellow", "[Yellow]",
            "CrossbowAmmo",   "green",  "[Green]",
            "BlasterAmmo",    "blue",   "[Blue]",
            "SkullRodAmmo",   "red",    "[Red]",
            "PhoenixRodAmmo", "fire",   "[Fire]",
            "MaceAmmo",       "gray",   "[Gray]",
            // Hexen
            "Mana1", "blue",  "[Blue]",
            "Mana2", "green", "[Green]",
            // Strife
            "ClipOfBullets",           "yellow",    "[Yellow]",
            "PoisonBolts",             "green",     "[Green]",
            "ElectricBolts",           "blue",      "[Blue]",
            "HEGrenadeRounds",         "orange",    "[Orange]",
            "PhosphorusGrenadeRounds", "fire",      "[Fire]",
            "MiniMissiles",            "brown",     "[Brown]",
            "EnergyPod",               "lightblue", "[LightBlue]",
            // The Adventures of Square
            "PaintAmmo",         "blue",          "[Blue]",
            "OoziAmmo",          "green",         "[Green]",
            "ShotboltAmmo",      "yellow",        "[Yellow]",
            "HellshellAmmo",     "red",           "[Red]",
            "MarbleAmmo",        "purple",        "[Purple]",
            "NumberofGoonades",  "white",         "[White]",
            "GoonadeThrowCheck", "blueyellowred", "BlueYellowRed",
            "SauceBreath",       "blueyellowred", "BlueYellowRed"
        };

        Vector2 coordnudge;

        Inventory ammotype1, ammotype2, ammotype3, ammotype4;
        [ammotype1, ammotype2] = GetCurrentAmmo();

        bool ammo1goonadeshack = false, ammo2goonadeshack = false, ammo3goonadeshack = false, ammo4goonadeshack = false; // used because NumberofGoonades isn't checked until first pickup
        bool showammo1perc = false, showammo2perc = false, showammo3perc = false, showammo4perc = false;

        bool usingreload = false;

        if (CPlayer.ReadyWeapon)
        {
            Name weaponname = CPlayer.ReadyWeapon.GetClassName();

            bool usingaltammo = false;

            let goonades = Ammo(CPlayer.mo.FindInventory("NumberofGoonades"));

            let goonadethrowcheck = CPlayer.mo.FindInventory("GoonadeThrowCheck");
            int goonadethrowcheckamount = 0;

            if (goonadethrowcheck) { goonadethrowcheckamount = goonadethrowcheck.Amount; }

            switch (weaponname)
            {
              case 'StrifeCrossbow':
              case 'StrifeCrossbow2':
                usingaltammo = weaponname == "StrifeCrossbow2";

                ammotype2 = Ammo(usingaltammo ? ammotype1 : CPlayer.mo.FindInventory("PoisonBolts")); // not the most efficient way to handle it, but it's something
                if (usingaltammo) { ammotype1 = Ammo(CPlayer.mo.FindInventory("ElectricBolts")); }
                break;

              case 'StrifeGrenadeLauncher':
              case 'StrifeGrenadeLauncher2':
                usingaltammo = weaponname == "StrifeGrenadeLauncher2";

                ammotype2 = Ammo(usingaltammo ? ammotype1 : CPlayer.mo.FindInventory("PhosphorusGrenadeRounds"));
                if (usingaltammo) { ammotype1 = Ammo(CPlayer.mo.FindInventory("HEGrenadeRounds")); }
                break;

              case 'PaintGun':
              case 'Defibrillator':
                if (goonades) { ammotype1 = goonades; }
                else { ammo1goonadeshack = true; }

                if (goonadethrowcheckamount > 0)
                {
                    ammotype2 = goonadethrowcheck;
                    showammo2perc = true;
                }
                break;

              case 'PaintGuns':
              case 'Oozi':
              case 'Oozis':
              case 'Shotbow':
              case 'PaintCannon':
              case 'HellShellLauncher':
              case 'Sceptre':
                if (goonades) { ammotype2 = goonades; }
                else { ammo2goonadeshack = true; }

                if (goonadethrowcheckamount > 0)
                {
                    ammotype3 = goonadethrowcheck;
                    showammo3perc = true;
                }
                break;

              case 'Quadcannon':
                usingreload = true;

                ammotype2 = ammotype1;
                ammotype1 = Ammo(CPlayer.mo.FindInventory("QuadCheck"));

                if (goonades) { ammotype3 = goonades; }
                else { ammo3goonadeshack = true; }

                if (goonadethrowcheckamount > 0)
                {
                    ammotype4 = goonadethrowcheck;
                    showammo4perc = true;
                }
                break;

              case 'SauceWeapon': showammo1perc = true; break;
            }
        }

        for (int checkedammotypes = 1; checkedammotypes <= 4; checkedammotypes++)
        {
            Name weaponname;

            if (CPlayer.ReadyWeapon) { weaponname = CPlayer.ReadyWeapon.GetClassName(); }

            Inventory ammotype, ammotypereload;
            Name ammobarcolor;
            Name ammotextcolor;
            String ammostring;
            bool showgoonadeshack = false;
            bool showammoperc = false;

            let showingmagazinelabel = CVar.FindCVar("goh_reloadableammolabel").GetBool();

            switch (checkedammotypes)
            {
              case 1:
                if (!ammotype1 && !ammo1goonadeshack) { continue; }

                if (ammo1goonadeshack) { showgoonadeshack = true; }
                else { ammotype = ammotype1; }

                if (usingreload)
                {
                    if (ammotype2) { ammotypereload = ammotype2; }
                }

                ammobarcolor = "yellow";
                ammotextcolor = "[Yellow]";
                ammostring = "$GOODOLHUD_" .. (usingreload ? (showingmagazinelabel ? "MAGAZINE" : "CLIP") : "AMMO") .. "1";
                showammoperc = showammo1perc;
                break;

              case 2:
                if ((!ammotype2 || ammotype2 == ammotype1) && !ammo2goonadeshack) { continue; }

                if (ammo2goonadeshack) { showgoonadeshack = true; }
                else { ammotype = ammotype2; }

                ammobarcolor = "orange";
                ammotextcolor = "[Orange]";
                ammostring = "$GOODOLHUD_AMMO" .. (usingreload ? "1" : "2");
                showammoperc = showammo2perc;
                break;

              case 3:
                if (!ammotype3 && !ammo3goonadeshack) { continue; }

                if (ammo3goonadeshack) { showgoonadeshack = true; }
                else { ammotype = ammotype3; }

                ammobarcolor = "yellow";
                ammotextcolor = "[Yellow]";
                ammostring = "$GOODOLHUD_AMMO" .. (usingreload ? "2" : "3");
                showammoperc = showammo3perc;
                break;

              case 4:
                if ((!ammotype4 || ammotype4 == ammotype3) && !ammo4goonadeshack) { continue; }

                if (ammo4goonadeshack) { showgoonadeshack = true; }
                else { ammotype = ammotype4; }

                ammobarcolor = "orange";
                ammotextcolor = "[Orange]";
                ammostring = "$GOODOLHUD_AMMO" .. (usingreload ? "3" : "4");
                showammoperc = showammo4perc;
                break;
            }

            DrawImage(barbase, (coordbasex, (coordbasey + coordnudge.Y)), DI_SCREEN_RIGHT_BOTTOM);

            for (int checkedammos = 0; checkedammos < maxammos; checkedammos += 3)
            {
                if (ammotypereload)
                {
                    if ((!showgoonadeshack && ammotypereload is AmmoDefinitions[checkedammos]) || (showgoonadeshack && AmmoDefinitions[checkedammos] == "NumberofGoonades"))
                    {
                        ammobarcolor = AmmoDefinitions[checkedammos + 1];
                        ammotextcolor = AmmoDefinitions[checkedammos + 2];
                        break;
                    }
                } else {
                    if ((!showgoonadeshack && ammotype is AmmoDefinitions[checkedammos]) || (showgoonadeshack && AmmoDefinitions[checkedammos] == "NumberofGoonades"))
                    {
                        ammobarcolor = AmmoDefinitions[checkedammos + 1];
                        ammotextcolor = AmmoDefinitions[checkedammos + 2];
                        break;
                    }
                }
            }

            Name ammoname;
            int goonadesamt, goonadesmaxamt;

            if (showgoonadeshack)
            {
                ammoname = "NumberofGoonades";
                [goonadesamt, goonadesmaxamt] = GetAmount(ammoname);
            }
            else { ammoname = ammotype.GetClassName(); }

            switch (ammoname)
            {
              case 'NumberofGoonades': ammostring = "$GOODOLHUD_AMMO_" .. ammoname; break;
              case 'GoonadeThrowCheck': ammostring = "$GOODOLHUD_THROWPOWER"; break;
            }

            switch (ammobarcolor)
            {
              case 'blueyellowred':
              case 'rainbow':
              case 'rainbowreverse':
              case 'redyellowblue':
                ammobarcolor = ammobarcolor .. (CVar.FindCVar("goh_bargradients").GetBool() ? "_gradient" : "");
                break;
            }

            switch (ammotextcolor)
            {
              case 'BlueYellowRed':
              case 'RedYellowBlue':
                if ((showgoonadeshack ? goonadesamt : ammotype.Amount) <= (showgoonadeshack ? goonadesmaxamt : ammotype.MaxAmount) / 5) { ammotextcolor = "[" .. (ammotextcolor == "RedYellowBlue" ? "Red" : "Blue") .. "]"; }
                else if ((showgoonadeshack ? goonadesamt : ammotype.Amount) <= (showgoonadeshack ? goonadesmaxamt : ammotype.MaxAmount) / 2.5) { ammotextcolor = "[" .. (ammotextcolor == "RedYellowBlue" ? "Orange" : "LightBlue") .. "]"; }
                else if ((showgoonadeshack ? goonadesamt : ammotype.Amount) <= (showgoonadeshack ? goonadesmaxamt : ammotype.MaxAmount) / 1.66666) { ammotextcolor = "[Yellow]"; }
                else if ((showgoonadeshack ? goonadesamt : ammotype.Amount) <= (showgoonadeshack ? goonadesmaxamt : ammotype.MaxAmount) / 1.25) { ammotextcolor = "[" .. (ammotextcolor == "RedYellowBlue" ? "LightBlue" : "Orange") .. "]"; }
                else { ammotextcolor = "[" .. (ammotextcolor == "RedYellowBlue" ? "Blue" : "Red") .. "]"; }
                break;

              case 'Rainbow':
              case 'RainbowReverse':
                if ((showgoonadeshack ? goonadesamt : ammotype.Amount) <= (showgoonadeshack ? goonadesmaxamt : ammotype.MaxAmount) / 8) { ammotextcolor = "[Red]"; }
                else if ((showgoonadeshack ? goonadesamt : ammotype.Amount) <= (showgoonadeshack ? goonadesmaxamt : ammotype.MaxAmount) / 4) { ammotextcolor = "[" .. (ammotextcolor == "RainbowReverse" ? "Orange" : "Purple") .. "]"; }
                else if ((showgoonadeshack ? goonadesamt : ammotype.Amount) <= (showgoonadeshack ? goonadesmaxamt : ammotype.MaxAmount) / 2.66666) { ammotextcolor = "[" .. (ammotextcolor == "RainbowReverse" ? "Yellow" : "Blue") .. "]"; }
                else if ((showgoonadeshack ? goonadesamt : ammotype.Amount) <= (showgoonadeshack ? goonadesmaxamt : ammotype.MaxAmount) / 2) { ammotextcolor = "[" .. (ammotextcolor == "RainbowReverse" ? "Green" : "Cyan") .. "]"; }
                else if ((showgoonadeshack ? goonadesamt : ammotype.Amount) <= (showgoonadeshack ? goonadesmaxamt : ammotype.MaxAmount) / 1.6) { ammotextcolor = "[" .. (ammotextcolor == "RainbowReverse" ? "Cyan" : "Green") .. "]"; }
                else if ((showgoonadeshack ? goonadesamt : ammotype.Amount) <= (showgoonadeshack ? goonadesmaxamt : ammotype.MaxAmount) / 1.33333) { ammotextcolor = "[" .. (ammotextcolor == "RainbowReverse" ? "Blue" : "Yellow") .. "]"; }
                else if ((showgoonadeshack ? goonadesamt : ammotype.Amount) <= (showgoonadeshack ? goonadesmaxamt : ammotype.MaxAmount) / 1.14285) { ammotextcolor = "[" .. (ammotextcolor == "RainbowReverse" ? "Purple" : "Orange") .. "]"; }
                else { ammotextcolor = "[Red]"; }
                break;
            }

            bar = "graphics/hud/" .. theme .. "/bars/goodolhud_bar_" .. ammobarcolor .. ".png";
            DrawBar(bar, barblank, showgoonadeshack ? goonadesamt : ammotype.Amount, showgoonadeshack ? goonadesmaxamt : ammotype.MaxAmount, (coordbasex, (coordbasey + coordnudge.Y) - 1), 0, SHADER_HORZ, DI_SCREEN_RIGHT_BOTTOM);

            DrawString(GOHmHUDFont, "\c" .. ammotextcolor .. StringTable.Localize(ammostring), (coordbasex - 79, (coordbasey + coordnudge.Y) - 14), DI_SCREEN_RIGHT_BOTTOM|DI_TEXT_ALIGN_RIGHT);

            DrawString(GOHmHUDFont, "\c" .. ammotextcolor .. (showammoperc ? (String.Format("%.1f", ammotype.Amount * 100.0 / ammotype.MaxAmount) .. StringTable.Localize("$GOODOLHUD_PERCENTAGE")) : (FormatNumber(showgoonadeshack ? goonadesamt : ammotype.Amount, 1, 4) .. StringTable.Localize("$GOODOLHUD_SEPARATOR") .. FormatNumber(showgoonadeshack ? goonadesmaxamt : ammotype.MaxAmount, 1, 4))), (coordbasex + 77, (coordbasey + coordnudge.Y) - 14), DI_SCREEN_RIGHT_BOTTOM|DI_TEXT_ALIGN_LEFT);

            coordnudge.Y -= 16;

            foundammotypes++;
        }
    }

    int foundammocapacities;

    protected virtual void GOHDrawAmmoCapacities(int coordbasex, int coordbasey)
    {
        int maxammocapacities = 5 * 2;

        static const Name AmmoCapacityDefinitions[] =
        {
            "PaintAmmo",     "[Blue]",
            "OoziAmmo",      "[Green]",
            "ShotboltAmmo",  "[Yellow]",
            "HellshellAmmo", "[Red]",
            "MarbleAmmo",    "[Purple]"
        };

        Vector2 coordnudge;

        int currentammo, currentammomax;

        for (int checkedammocapacities = maxammocapacities - 1; checkedammocapacities >= 0; checkedammocapacities -= 2)
        {
            Name ammocapacity = AmmoCapacityDefinitions[checkedammocapacities - 1];

            [currentammo, currentammomax] = GetAmount(ammocapacity);

            Name ammocapacitycolor = AmmoCapacityDefinitions[checkedammocapacities];

            switch (ammocapacitycolor)
            {
              case 'BlueYellowRed':
              case 'RedYellowBlue':
                if (currentammo <= currentammomax / 5) { ammocapacitycolor = "[" .. (ammocapacitycolor == "RedYellowBlue" ? "Red" : "Blue") .. "]"; }
                else if (currentammo <= currentammomax / 2.5) { ammocapacitycolor = "[" .. (ammocapacitycolor == "RedYellowBlue" ? "Orange" : "LightBlue") .. "]"; }
                else if (currentammo <= currentammomax / 1.66666) { ammocapacitycolor = "[Yellow]"; }
                else if (currentammo <= currentammomax / 1.25) { ammocapacitycolor = "[" .. (ammocapacitycolor == "RedYellowBlue" ? "LightBlue" : "Orange") .. "]"; }
                else { ammocapacitycolor = "[" .. (ammocapacitycolor == "RedYellowBlue" ? "Blue" : "Red") .. "]"; }
                break;

              case 'Rainbow':
              case 'RainbowReverse':
                if (currentammo <= currentammomax / 8) { ammocapacitycolor = "[Red]"; }
                else if (currentammo <= currentammomax / 4) { ammocapacitycolor = "[" .. (ammocapacitycolor == "RainbowReverse" ? "Orange" : "Purple") .. "]"; }
                else if (currentammo <= currentammomax / 2.66666) { ammocapacitycolor = "[" .. (ammocapacitycolor == "RainbowReverse" ? "Yellow" : "Blue") .. "]"; }
                else if (currentammo <= currentammomax / 2) { ammocapacitycolor = "[" .. (ammocapacitycolor == "RainbowReverse" ? "Green" : "Cyan") .. "]"; }
                else if (currentammo <= currentammomax / 1.6) { ammocapacitycolor = "[" .. (ammocapacitycolor == "RainbowReverse" ? "Cyan" : "Green") .. "]"; }
                else if (currentammo <= currentammomax / 1.33333) { ammocapacitycolor = "[" .. (ammocapacitycolor == "RainbowReverse" ? "Blue" : "Yellow") .. "]"; }
                else if (currentammo <= currentammomax / 1.14285) { ammocapacitycolor = "[" .. (ammocapacitycolor == "RainbowReverse" ? "Purple" : "Orange") .. "]"; }
                else { ammocapacitycolor = "[Red]"; }
                break;
            }

            DrawString(GOHmHUDFont, "\c" .. ammocapacitycolor .. StringTable.Localize("$GOODOLHUD_AMMOCAPACITY_" .. ammocapacity), (coordbasex, (coordbasey + coordnudge.Y)), DI_SCREEN_RIGHT_BOTTOM|DI_TEXT_ALIGN_RIGHT);

            DrawString(GOHmHUDFont, "\c" .. ammocapacitycolor .. FormatNumber(currentammo, 1, 4) .. StringTable.Localize("$GOODOLHUD_SEPARATOR"), (coordbasex + 48, (coordbasey + coordnudge.Y)), DI_SCREEN_RIGHT_BOTTOM|DI_TEXT_ALIGN_RIGHT);
            DrawString(GOHmHUDFont, "\c" .. ammocapacitycolor .. FormatNumber(currentammomax, 1, 4), (coordbasex + 48, (coordbasey + coordnudge.Y)), DI_SCREEN_RIGHT_BOTTOM|DI_TEXT_ALIGN_LEFT);

            coordnudge.Y -= 16;

            foundammocapacities++;
        }
    }

    protected virtual void GOHDrawWeaponBar(int coordbasex, int coordbasey)
    {
        bool wepfound;
        int wepslot, wepindex;
        int slotlight = 0;

        if (CPlayer.ReadyWeapon)
        {
            Name curweapon = CPlayer.ReadyWeapon.bPOWERED_UP && CPlayer.ReadyWeapon.SisterWeapon ? CPlayer.ReadyWeapon.SisterWeapon.GetClassName() : CPlayer.ReadyWeapon.GetClassName();

            for (int curslot = 0; curslot < 10; curslot++)
            {
                int curslotsize = CPlayer.weapons.SlotSize(curslot);

                for (int curslotindex = 0; curslotindex < curslotsize; curslotindex++)
                {
                    Name scannedweapon = CPlayer.weapons.GetWeapon(curslot, curslotindex).GetClassName();

                    if (curweapon == scannedweapon)
                    {
                        slotlight |= 1 << curslot;
                        break; // don't scan for other weapons in the slot if we've already got the one we wanted
                    }
                }
            }
        }

        let weaponbarflags = DI_SCREEN_RIGHT_BOTTOM|DI_TEXT_ALIGN_LEFT;

        DrawString(GOHmHUDFont, CPlayer.HasWeaponsInSlot(1) ? "\c" .. (slotlight & 2 ? colorschemeactivetext : colorschemetext) .. FormatNumber(1, 1, 1) : "", (coordbasex, coordbasey), weaponbarflags);
        DrawString(GOHmHUDFont, CPlayer.HasWeaponsInSlot(2) ? "\c" .. (slotlight & 4 ? colorschemeactivetext : colorschemetext) .. FormatNumber(2, 1, 1) : "", (coordbasex + 10, coordbasey), weaponbarflags);
        DrawString(GOHmHUDFont, CPlayer.HasWeaponsInSlot(3) ? "\c" .. (slotlight & 8 ? colorschemeactivetext : colorschemetext) .. FormatNumber(3, 1, 1) : "", (coordbasex + 20, coordbasey), weaponbarflags);
        DrawString(GOHmHUDFont, CPlayer.HasWeaponsInSlot(4) ? "\c" .. (slotlight & 16 ? colorschemeactivetext : colorschemetext) .. FormatNumber(4, 1, 1) : "", (coordbasex + 30, coordbasey), weaponbarflags);
        DrawString(GOHmHUDFont, CPlayer.HasWeaponsInSlot(5) ? "\c" .. (slotlight & 32 ? colorschemeactivetext : colorschemetext) .. FormatNumber(5, 1, 1) : "", (coordbasex + 40, coordbasey), weaponbarflags);
        DrawString(GOHmHUDFont, CPlayer.HasWeaponsInSlot(6) ? "\c" .. (slotlight & 64 ? colorschemeactivetext : colorschemetext) .. FormatNumber(6, 1, 1) : "", (coordbasex + 50, coordbasey), weaponbarflags);
        DrawString(GOHmHUDFont, CPlayer.HasWeaponsInSlot(7) ? "\c" .. (slotlight & 128 ? colorschemeactivetext : colorschemetext) .. FormatNumber(7, 1, 1) : "", (coordbasex + 60, coordbasey), weaponbarflags);
        DrawString(GOHmHUDFont, CPlayer.HasWeaponsInSlot(8) ? "\c" .. (slotlight & 256 ? colorschemeactivetext : colorschemetext) .. FormatNumber(8, 1, 1) : "", (coordbasex + 70, coordbasey), weaponbarflags);
        DrawString(GOHmHUDFont, CPlayer.HasWeaponsInSlot(9) ? "\c" .. (slotlight & 512 ? colorschemeactivetext : colorschemetext) .. FormatNumber(9, 1, 1) : "", (coordbasex + 80, coordbasey), weaponbarflags);
        DrawString(GOHmHUDFont, CPlayer.HasWeaponsInSlot(0) ? "\c" .. (slotlight & 1 ? colorschemeactivetext : colorschemetext) .. FormatNumber(0, 1, 1) : "", (coordbasex + 90, coordbasey), weaponbarflags);
    }

    protected virtual void GOHDrawFullscreenKeys(int coordbasex, int coordbasey)
    {
        Vector2 keypos = (coordbasex, coordbasey);

        for (let i = CPlayer.mo.Inv; i; i = i.Inv)
        {
            if (i is "Key" && i.Icon.IsValid())
            {
                DrawTexture(i.Icon, keypos, DI_ITEM_RIGHT_TOP);

                Vector2 size = TexMan.GetScaledSize(i.Icon);

                keypos.Y += size.Y + 2;
            }
        }
    }

    protected virtual void GOHDrawMiscItems(int coordbasex, int coordbasey)
    {
        /*
        int maxmiscitems = 1 * 4;

        static const Name MiscItemDefinitions[] =
        {
            "", "", "", ""
        };

        Vector2 coordnudge;

        int checkedmiscitems = 0, activemiscitems = 0;

        for (checkedmiscitems = 0; checkedmiscitems < maxmiscitems; checkedmiscitems += 4)
        {
            let currentmiscitem = CPlayer.mo.FindInventory(MiscItemDefinitions[checkedmiscitems]);

            switch (MiscItemDefinitions[checkedmiscitems])
            {
              default:
                if (!currentmiscitem) { continue; }
                break;
            }

            activemiscitems++;
        }

        if (activemiscitems > 0)
        {
            for (checkedmiscitems = 0; checkedmiscitems < maxmiscitems; checkedmiscitems += 4)
            {
                let currentmiscitem = CPlayer.mo.FindInventory(MiscItemDefinitions[checkedmiscitems]);
                let currentmiscitemicon = MiscItemDefinitions[checkedmiscitems + 1];

                switch (MiscItemDefinitions[checkedmiscitems])
                {
                  default:
                    if (!currentmiscitem) { continue; }
                    break;

                  case 'Sigil':
                    if (!currentmiscitem) { continue; }

                    switch (currentmiscitem.Health)
                    {
                      case 1: currentmiscitemicon = currentmiscitemicon .. "A"; break;
                      case 2: currentmiscitemicon = currentmiscitemicon .. "B"; break;
                      case 3: currentmiscitemicon = currentmiscitemicon .. "C"; break;
                      case 4: currentmiscitemicon = currentmiscitemicon .. "D"; break;
                      default: currentmiscitemicon = currentmiscitemicon .. "E"; break;
                    }

                    currentmiscitemicon = currentmiscitemicon .. "0";
                    break;
                }

                if (TexMan.CheckForTexture(currentmiscitemicon).IsValid())
                {
                    DrawImage(currentmiscitemicon, (coordbasex, (coordbasey + coordnudge.Y)), DI_SCREEN_RIGHT_TOP|DI_ITEM_CENTER);

                    let currentmiscitemtimer = Powerup(CPlayer.mo.FindInventory(MiscItemDefinitions[checkedmiscitems + 2]));

                    if (currentmiscitemtimer) { DrawString(GOHmHUDFont, "\c" .. MiscItemDefinitions[checkedmiscitems + 3] .. FormatNumber(currentmiscitemtimer.EffectTics / TICRATE, 1, 4), (coordbasex - 23, (coordbasey + coordnudge.Y) - 6), DI_SCREEN_RIGHT_TOP|DI_TEXT_ALIGN_RIGHT); }

                    coordnudge.Y += 44;
                }
            }
        }
        */
    }
}
