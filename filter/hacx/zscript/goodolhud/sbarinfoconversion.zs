class GoodOlHUDHacxStatusBar : DoomStatusBar
{
    override void Init()
    {
        Super.Init();

        Font fnt;

        // Create the fonts used for the HUDs
        fnt = "HUDFONT_DOOM";

        mHUDFont = HUDFont.Create(fnt, fnt.GetCharWidth("0"), Mono_CellCenter, 2, 2);

        fnt = "INDEXFONT";

        mIndexFont = HUDFont.Create(fnt, fnt.GetCharWidth("0"), Mono_CellLeft);

        diparms = InventoryBarState.Create(mIndexFont, Font.CR_GOLD, 1, "ARTIBOX", "SELECTBO", (0, 0), "INVGEML1", "INVGEMR1", (4, -9));
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
        DrawImage("STBAR", (0, 168), DI_ITEM_OFFSETS);
        DrawImage("STTPRCNT", (90, 171), DI_ITEM_OFFSETS);
        DrawImage("STTPRCNT", (221, 171), DI_ITEM_OFFSETS);

        Inventory a1 = GetCurrentAmmo();

        if (a1) { DrawString(mHUDFont, FormatNumber(a1.Amount, 3, 3), (44, 171), DI_TEXT_ALIGN_RIGHT|DI_NOSHADOW); }

        DrawString(mHUDFont, FormatNumber(CPlayer.Health, 3, 3), (90, 171), DI_TEXT_ALIGN_RIGHT|DI_NOSHADOW);
        DrawString(mHUDFont, FormatNumber(GetArmorAmount(), 3, 3), (221, 171), DI_TEXT_ALIGN_RIGHT|DI_NOSHADOW);

        DrawBarKeys();
        DrawBarAmmo();

        if (multiplayer && deathmatch) { DrawString(mHUDFont, FormatNumber(CPlayer.FragCount, 3, 2 + (CPlayer.FragCount < 0)), (138, 171), DI_TEXT_ALIGN_RIGHT|DI_NOSHADOW); }
        else { DrawBarWeapons(); }

        if (multiplayer || deathmatch || teamplay) { DrawImage("STFBANY", (143, 169), DI_TRANSLATABLE|DI_ITEM_OFFSETS); }

        if (CPlayer.mo.InvSel && !Level.NoInventoryBar)
        {
            DrawInventoryIcon(CPlayer.mo.InvSel, (143, 168), DI_DIMDEPLETED|DI_ITEM_OFFSETS);

            if (CPlayer.mo.InvSel.Amount > 1) { DrawString(mAmountFont, FormatNumber(CPlayer.mo.InvSel.Amount), (172, 198 - mIndexFont.mFont.GetHeight()), DI_TEXT_ALIGN_RIGHT, Font.CR_GOLD); }
        }
        else { DrawTexture(GetMugShot(5), (143, 168), DI_ITEM_OFFSETS); }

        if (isInventoryBarVisible()) { DrawInventoryBar(diparms, (155, 200), 7); }
    }

    override void DrawBarAmmo()
    {
        int amt1, maxamt;

        [amt1, maxamt] = GetAmount("HacxRounds");
        DrawString(mIndexFont, FormatNumber(amt1, 3, 3), (288, 173), DI_TEXT_ALIGN_RIGHT, Font.CR_GOLD);
        DrawString(mIndexFont, FormatNumber(maxamt, 3, 3), (314, 173), DI_TEXT_ALIGN_RIGHT, Font.CR_GOLD);

        [amt1, maxamt] = GetAmount("HacxCartridges");
        DrawString(mIndexFont, FormatNumber(amt1, 3, 3), (288, 179), DI_TEXT_ALIGN_RIGHT, Font.CR_GOLD);
        DrawString(mIndexFont, FormatNumber(maxamt, 3, 3), (314, 179), DI_TEXT_ALIGN_RIGHT, Font.CR_GOLD);

        [amt1, maxamt] = GetAmount("HacxTorpedo");
        DrawString(mIndexFont, FormatNumber(amt1, 3, 3), (288, 185), DI_TEXT_ALIGN_RIGHT, Font.CR_GOLD);
        DrawString(mIndexFont, FormatNumber(maxamt, 3, 3), (314, 185), DI_TEXT_ALIGN_RIGHT, Font.CR_GOLD);

        [amt1, maxamt] = GetAmount("HacxMolecules");
        DrawString(mIndexFont, FormatNumber(amt1, 3, 3), (288, 191), DI_TEXT_ALIGN_RIGHT, Font.CR_GOLD);
        DrawString(mIndexFont, FormatNumber(maxamt, 3, 3), (314, 191), DI_TEXT_ALIGN_RIGHT, Font.CR_GOLD);
    }

    protected void DrawFullScreenStuff ()
    {
        // health
        DrawImage("MEDIA0", (20, -2));
        DrawString(mHUDFont, FormatNumber(CPlayer.Health, 3), (82, -20), DI_TEXT_ALIGN_RIGHT);

        // armor
        let armor = CPlayer.mo.FindInventory("BasicArmor", true);

        if (armor != null && armor.Amount > 0)
        {
            DrawInventoryIcon(armor, (20, -24));
            DrawString(mHUDFont, FormatNumber(armor.Amount, 3), (82, -39), DI_TEXT_ALIGN_RIGHT);
        }

        // ammo
        Inventory ammotype1, ammotype2;
        [ammotype1, ammotype2] = GetCurrentAmmo();

        int invY = -20;

        // primary
        if (ammotype1 != null)
        {
            DrawInventoryIcon(ammotype1, (-14, -4));
            DrawString(mHUDFont, FormatNumber(ammotype1.Amount, 3), (-25, -20), DI_TEXT_ALIGN_RIGHT);

            invY -= 18;
        }

        // secondary
        if (ammotype2 != null && ammotype2 != ammotype1)
        {
            DrawInventoryIcon(ammotype2, (-14, invY + 16));
            DrawString(mHUDFont, FormatNumber(ammotype2.Amount, 3), (-25, invY), DI_TEXT_ALIGN_RIGHT);

            invY -= 18;
        }

        // selected inventory
        if (!isInventoryBarVisible() && !Level.NoInventoryBar && CPlayer.mo.InvSel)
        {
            DrawInventoryIcon(CPlayer.mo.InvSel, (-14, invY + 17), DI_DIMDEPLETED);
            DrawString(mHUDFont, FormatNumber(CPlayer.mo.InvSel.Amount, 3), (-26, invY), DI_TEXT_ALIGN_RIGHT);
        }

        // frags/keys
        if (deathmatch) { DrawString(mHUDFont, FormatNumber(CPlayer.FragCount, 3), (-3, 1), DI_TEXT_ALIGN_RIGHT); }
        else { DrawFullscreenKeys(); }

        // inventory bar
        if (isInventoryBarVisible()) { DrawInventoryBar(diparms, (-1, -1), 7, DI_SCREEN_CENTER_BOTTOM, HX_SHADOW); }
    }

    override void DrawFullscreenKeys()
    {
        Vector2 keypos = (-10, 2);
        int rowc = 0;
        double roww = 0;
        int curkeys = 0;

        for (let i = CPlayer.mo.Inv; i != null; i = i.Inv)
        {
            if (i is "Key" && i.Icon.IsValid())
            {
                if (++curkeys > 100) { break; }

                DrawTexture(i.Icon, keypos, DI_SCREEN_RIGHT_TOP|DI_ITEM_OFFSETS);

                Vector2 size = TexMan.GetScaledSize(i.Icon);

                keypos.Y += size.Y + 2;
                roww = max(roww, size.X);

                if (++rowc == 3)
                {
                    keypos.Y = 2;
                    keypos.X -= roww + 2;
                    roww = 0;
                    rowc = 0;
                }
            }
        }
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
