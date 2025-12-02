// General

class GoodOlHUDThemeSettingClamper : CustomIntCVar
{
    override int ModifyValue(name CVarName, int val) { return clamp(val, 0, 1); }
}

class GoodOlHUDColorSchemeSettingClamper : CustomIntCVar
{
    override int ModifyValue(name CVarName, int val) { return clamp(val, -2, 19); }
}

// Top right

class GoodOlHUDShowTimerSettingClamper : CustomIntCVar
{
    override int ModifyValue(name CVarName, int val) { return clamp(val, 0, 2); }
}
