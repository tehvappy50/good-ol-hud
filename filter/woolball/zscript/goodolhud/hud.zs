class GoodOlHUDStatusBar : DoomStatusBar
{
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
        fnt = "HUDFONT_DOOM";

        mHUDFont = HUDFont.Create(fnt, fnt.GetCharWidth("0"), Mono_CellCenter, 1, 1);

        fnt = "INDEXFONT";

        mIndexFont = HUDFont.Create(fnt, fnt.GetCharWidth("0"), Mono_CellLeft);

        diparms = InventoryBarState.Create(mIndexFont, Font.CR_GOLD, 1, "ARTIBOX", "SELECTBO", (0, 0), "INVGEML1", "INVGEMR1", (4, -9));

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

    // SBARINFO conversion (including inventory)
    protected void DrawMainBar (double TicFrac)
    {
        if (!CPlayer.mo.FindInventory("IsPlaying"))
        {
            DrawImage("STBLR", (0, 168), DI_ITEM_OFFSETS);

            if (isInventoryBarVisible()) { DrawInventoryBar(diparms, (155, 200), 7); }

            return;
        }

        DrawImage("STBAR", (0, 168), DI_ITEM_OFFSETS);
        DrawImage("STTPRCNT", (90, 171), DI_ITEM_OFFSETS);
        DrawImage("STTPRCNT", (221, 171), DI_ITEM_OFFSETS);

        Inventory a1 = GetCurrentAmmo();

        if (a1) { DrawString(mHUDFont, FormatNumber(a1.Amount, 3, 3), (44, 171), DI_TEXT_ALIGN_RIGHT|DI_NOSHADOW); }

        DrawString(mHUDFont, FormatNumber(CPlayer.Health, 3, 3), (90, 171), DI_TEXT_ALIGN_RIGHT|DI_NOSHADOW);
        DrawString(mHUDFont, FormatNumber(GetArmorAmount(), 3, 3), (221, 171), DI_TEXT_ALIGN_RIGHT|DI_NOSHADOW);

        DrawBarKeys();

        if (CPlayer.ReadyWeapon) { DrawInventoryIcon(CPlayer.ReadyWeapon, (281, 184), DI_ITEM_CENTER); }

        if (deathmatch || teamplay) { DrawString(mHUDFont, FormatNumber(CPlayer.FragCount, 3, 2 + (CPlayer.FragCount < 0)), (138, 171), DI_TEXT_ALIGN_RIGHT); }
        else { DrawBarWeapons(); }

        if (multiplayer) { DrawImage("STFBANY", (143, 169), DI_TRANSLATABLE|DI_ITEM_OFFSETS); }

        if (CPlayer.mo.InvSel && !Level.NoInventoryBar)
        {
            DrawInventoryIcon(CPlayer.mo.InvSel, (143, 168), DI_DIMDEPLETED|DI_ITEM_OFFSETS);

            if (CPlayer.mo.InvSel.Amount > 1) { DrawString(mAmountFont, FormatNumber(CPlayer.mo.InvSel.Amount), (172, 198 - mIndexFont.mFont.GetHeight()), DI_TEXT_ALIGN_RIGHT, Font.CR_GOLD); }
        }
        else { DrawTexture(GetMugShot(5), (143, 168), DI_ITEM_OFFSETS); }

        if (isInventoryBarVisible()) { DrawInventoryBar(diparms, (155, 200), 7); }
    }

    override void DrawBarWeapons()
    {
        DrawImage("STARMS", (104, 168), DI_ITEM_OFFSETS);
        DrawImage(CPlayer.HasWeaponsInSlot(2) ? "STYSNUM2" : "STGNUM2", (111, 172), DI_ITEM_OFFSETS);
        DrawImage(CPlayer.HasWeaponsInSlot(3) ? "STYSNUM3" : "STGNUM3", (123, 172), DI_ITEM_OFFSETS);
        DrawImage(CPlayer.HasWeaponsInSlot(4) ? "STYSNUM4" : "STGNUM4", (135, 172), DI_ITEM_OFFSETS);
        DrawImage(CPlayer.HasWeaponsInSlot(5) ? "STYSNUM5" : "STGNUM5", (116, 182), DI_ITEM_OFFSETS);
        DrawImage(CPlayer.HasWeaponsInSlot(6) ? "STYSNUM6" : "STGNUM6", (128, 182), DI_ITEM_OFFSETS);
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
            GOHcolorscheme = 10;
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
        if (!CPlayer.mo.FindInventory("IsPlaying"))
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
        let canshowmugshot = CVar.FindCVar("goh_showmugshot").GetBool() && GetMugShot(5).IsValid(); // currently hides when invulnerable

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
                String armorcolor = "green";

                switch (armor.ArmorType)
                {
                  // Tier 1 armor
                  case 'SilverShield': armorcolor = "silver"; break;
                  case 'LeatherArmor': armorcolor = "brown"; break;

                  // Tier 2 armor
                  case 'BasicArmorPickup': // cheat
                  case 'BlueArmor':
                  case 'BlueArmorForMegasphere':
                  case 'SuperChexArmor':
                  case 'HugeCoffee':
                    armorcolor = "blue";
                    break;

                  case 'EnchantedShield': armorcolor = "gold"; break;
                  case 'MetalArmor': armorcolor = "silver"; break;
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

        DrawTexture(GetMugShot(5), (coordbasex + 19.6, coordbasey + 17.5), DI_SCREEN_LEFT_BOTTOM|DI_ITEM_CENTER, 1, (35, 31));
    }

    bool haspowerup;

    protected virtual void GOHDrawPowerupTimers(int coordbasex, int coordbasey)
    {
        int maxpowerups = 4 * 3;

        static const Name PowerupDefinitions[] =
        {
            "PowerInvulnerable", "white", "[White]",
            "PowerIronFeet",     "green", "[Green]",
            "PowerLightAmp",     "brick", "[Brick]",
            "PowerInvisibility", "gray",  "[Gray]"
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

            let canshowmugshot = CVar.FindCVar("goh_showmugshot").GetBool() && GetMugShot(5).IsValid(); // currently hides when invulnerable

            DrawString(GOHmHUDFont, "\c" .. colorschemetext .. StringTable.Localize("$GOODOLHUD_POWERUPS" .. (canshowmugshot && bottomleftvertelements >= 2 ? "" : "_SHORT")), (coordbasex, coordbasey), DI_SCREEN_LEFT_BOTTOM|DI_TEXT_ALIGN_RIGHT);

            for (checkedpowerups = 0; checkedpowerups < maxpowerups; checkedpowerups += 3)
            {
                let currentpowerup = Powerup(CPlayer.mo.FindInventory(PowerupDefinitions[checkedpowerups]));

                switch (PowerupDefinitions[checkedpowerups])
                {
                  default:
                    if (!currentpowerup) { continue; }
                    break;

                  case 'PowerFlight':
                    if (!currentpowerup || (!multiplayer && Level.infinite_flight)) { continue; }
                    break;
                }

                currentpowerupnum++;

                DrawImage(bottomleftverttimerrows == 1 && ((currentpowerupnum <= 1 && TexMan.CheckForTexture(timerbaseleft).IsValid()) || (currentpowerupnum == 7 && TexMan.CheckForTexture(timerbaseright).IsValid())) ? (currentpowerupnum <= 1 ? timerbaseleft : timerbaseright) : timerbase, powerup, DI_SCREEN_LEFT_BOTTOM|DI_ITEM_OFFSETS);

                DrawImage("graphics/hud/" .. theme .. "/timers/goodolhud_timer_" .. PowerupDefinitions[checkedpowerups + 1] .. ".png", (powerup.X + 2, powerup.Y + 2), DI_SCREEN_LEFT_BOTTOM|DI_ITEM_OFFSETS);

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

            let canshowmugshot = CVar.FindCVar("goh_showmugshot").GetBool() && GetMugShot(5).IsValid(); // currently hides when invulnerable

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

        String weaponmode;

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
            }

            DrawString(GOHmHUDFont,
                       "\c" .. colorschemetext ..
                       CPlayer.ReadyWeapon.GetTag() ..
                       (weaponmode != "" ? " " .. StringTable.Localize("$GOODOLHUD_EXTRA_START") .. StringTable.Localize(weaponmode) .. StringTable.Localize("$GOODOLHUD_EXTRA_END") : ""),
                       (coordbasex, coordbasey), DI_SCREEN_RIGHT_BOTTOM|DI_TEXT_ALIGN_RIGHT);

            weaponnameamount++;
        }
    }

    int foundammotypes;

    protected virtual void GOHDrawAmmo(int coordbasex, int coordbasey)
    {
        int maxammos = 25 * 3;

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
            // Rise of the Wool Ball
            "ClipNew",        "yellow", "[Yellow]",
            "LowResClipNew",  "yellow", "[Yellow]",
            "ShellNew",       "red",    "[Red]",
            "LowResShellNew", "red",    "[Red]",
            "RocketAmmoNew",  "brown",  "[Brown]"
        };

        Vector2 coordnudge;

        Inventory ammotype1, ammotype2;
        [ammotype1, ammotype2] = GetCurrentAmmo();

        if (CPlayer.ReadyWeapon)
        {
            Name weaponname = CPlayer.ReadyWeapon.GetClassName();

            bool usingaltammo = false;

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
            }
        }

        for (int checkedammotypes = 1; checkedammotypes <= 2; checkedammotypes++)
        {
            Inventory ammotype;
            Name ammobarcolor;
            Name ammotextcolor;
            String ammostring;

            switch (checkedammotypes)
            {
              case 1:
                if (!ammotype1) { continue; }

                ammotype = ammotype1;
                ammobarcolor = "yellow";
                ammotextcolor = "[Yellow]";
                ammostring = "$GOODOLHUD_AMMO1";
                break;

              case 2:
                if (!ammotype2 || ammotype2 == ammotype1) { continue; }

                ammotype = ammotype2;
                ammobarcolor = "orange";
                ammotextcolor = "[Orange]";
                ammostring = "$GOODOLHUD_AMMO2";
                break;
            }

            DrawImage(barbase, (coordbasex, (coordbasey + coordnudge.Y)), DI_SCREEN_RIGHT_BOTTOM);

            for (int checkedammos = 0; checkedammos < maxammos; checkedammos += 3)
            {
                if (ammotype is AmmoDefinitions[checkedammos])
                {
                    ammobarcolor = AmmoDefinitions[checkedammos + 1];
                    ammotextcolor = AmmoDefinitions[checkedammos + 2];
                    break;
                }
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
                if (ammotype.Amount <= ammotype.MaxAmount / 5) { ammotextcolor = "[" .. (ammotextcolor == "RedYellowBlue" ? "Red" : "Blue") .. "]"; }
                else if (ammotype.Amount <= ammotype.MaxAmount / 2.5) { ammotextcolor = "[" .. (ammotextcolor == "RedYellowBlue" ? "Orange" : "LightBlue") .. "]"; }
                else if (ammotype.Amount <= ammotype.MaxAmount / 1.66666) { ammotextcolor = "[Yellow]"; }
                else if (ammotype.Amount <= ammotype.MaxAmount / 1.25) { ammotextcolor = "[" .. (ammotextcolor == "RedYellowBlue" ? "LightBlue" : "Orange") .. "]"; }
                else { ammotextcolor = "[" .. (ammotextcolor == "RedYellowBlue" ? "Blue" : "Red") .. "]"; }
                break;

              case 'Rainbow':
              case 'RainbowReverse':
                if (ammotype.Amount <= ammotype.MaxAmount / 8) { ammotextcolor = "[Red]"; }
                else if (ammotype.Amount <= ammotype.MaxAmount / 4) { ammotextcolor = "[" .. (ammotextcolor == "RainbowReverse" ? "Orange" : "Purple") .. "]"; }
                else if (ammotype.Amount <= ammotype.MaxAmount / 2.66666) { ammotextcolor = "[" .. (ammotextcolor == "RainbowReverse" ? "Yellow" : "Blue") .. "]"; }
                else if (ammotype.Amount <= ammotype.MaxAmount / 2) { ammotextcolor = "[" .. (ammotextcolor == "RainbowReverse" ? "Green" : "Cyan") .. "]"; }
                else if (ammotype.Amount <= ammotype.MaxAmount / 1.6) { ammotextcolor = "[" .. (ammotextcolor == "RainbowReverse" ? "Cyan" : "Green") .. "]"; }
                else if (ammotype.Amount <= ammotype.MaxAmount / 1.33333) { ammotextcolor = "[" .. (ammotextcolor == "RainbowReverse" ? "Blue" : "Yellow") .. "]"; }
                else if (ammotype.Amount <= ammotype.MaxAmount / 1.14285) { ammotextcolor = "[" .. (ammotextcolor == "RainbowReverse" ? "Purple" : "Orange") .. "]"; }
                else { ammotextcolor = "[Red]"; }
                break;
            }

            bar = "graphics/hud/" .. theme .. "/bars/goodolhud_bar_" .. ammobarcolor .. ".png";
            DrawBar(bar, barblank, ammotype.Amount, ammotype.MaxAmount, (coordbasex, (coordbasey + coordnudge.Y) - 1), 0, SHADER_HORZ, DI_SCREEN_RIGHT_BOTTOM);

            DrawString(GOHmHUDFont, "\c" .. ammotextcolor .. StringTable.Localize(ammostring), (coordbasex - 79, (coordbasey + coordnudge.Y) - 14), DI_SCREEN_RIGHT_BOTTOM|DI_TEXT_ALIGN_RIGHT);

            DrawString(GOHmHUDFont, "\c" .. ammotextcolor .. FormatNumber(ammotype.Amount, 1, 4) .. StringTable.Localize("$GOODOLHUD_SEPARATOR") .. FormatNumber(ammotype.MaxAmount, 1, 4), (coordbasex + 77, (coordbasey + coordnudge.Y) - 14), DI_SCREEN_RIGHT_BOTTOM|DI_TEXT_ALIGN_LEFT);

            coordnudge.Y -= 16;

            foundammotypes++;
        }
    }

    int foundammocapacities;

    protected virtual void GOHDrawAmmoCapacities(int coordbasex, int coordbasey)
    {
        int maxammocapacities = 6 * 2;

        static const Name AmmoCapacityDefinitions[] =
        {
            "ClipNew",        "[Yellow]",
            "LowResClipNew",  "[Yellow]",
            "ShellNew",       "[Red]",
            "LowResShellNew", "[Red]",
            "RocketAmmoNew",  "[Brown]",
            "Cell",           "[LightBlue]"
        };

        Vector2 coordnudge;

        int currentammo, currentammomax;

        let hasPistol = CPlayer.mo.FindInventory("PistolNew");
        let hasLowResPistol = CPlayer.mo.FindInventory("LowResPistolNew");
        let hasShotgun = CPlayer.mo.FindInventory("ShotgunNew");
        let hasLowResShotgun = CPlayer.mo.FindInventory("LowResShotgunNew");

        for (int checkedammocapacities = maxammocapacities - 1; checkedammocapacities >= 0; checkedammocapacities -= 2)
        {
            Name ammocapacity = AmmoCapacityDefinitions[checkedammocapacities - 1];

            switch (ammocapacity)
            {
              case 'ClipNew':
                if (!hasPistol && hasLowResPistol) { continue; }
                break;

              case 'LowResClipNew':
                if (!hasLowResPistol) { continue; }
                break;

              case 'ShellNew':
                if (!hasShotgun && hasLowResShotgun) { continue; }
                break;

              case 'LowResShellNew':
                if (!hasLowResShotgun) { continue; }
                break;
            }

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
