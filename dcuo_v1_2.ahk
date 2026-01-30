#Requires AutoHotkey v2.0
#SingleInstance Force

; ==========================================================
; CONFIGURATION
; ==========================================================
global CFG := {
    App: {
        Exe: "DCGAME.EXE",
        HoldKey: "XButton2"
    },

    Combat: {
        ComboChance: 60,
        SkillPriorityChance: 80,
        PulseBeamMinHold: 2000,
        PulseBeamMaxHold: 4500
    },

    Timing: {
        LoopMin: 80,
        LoopMax: 150,

        TapDownMin: 60,
        TapDownMax: 120,
        TapGapMin: 80,
        TapGapMax: 150
    },

    Skills: {
        Active: [1,2,3],
        SlotY: 1308,
        SlotX: [779, 886, 993, 1100, 1207, 1314],
        ReadyColor: "0x9A64C5",
        Tolerance: 50
    },

    Power: {
        X: 192,
        Y: 101,
        Color: "0x3387A6",
        Tolerance: 50
    },

    Debug: {
        MarkerSize: 8,
        MarkerColor: "Red",
        MarkerTimeout: 3000
    }
}

; Auto mode states
global AUTO_OFF := 0
global AUTO_COMBAT := 1   ; skills + attacks
global AUTO_ATTACK := 2   ; attacks only
global AutoMode := AUTO_OFF

; ==========================================================
; INIT
; ==========================================================
CoordMode "Pixel", "Client"
CoordMode "Mouse", "Client"

if !WinExist("ahk_exe " . CFG.App.Exe) {
    MsgBox "App is not running!"
    ExitApp
}

WinActivate "ahk_exe " . CFG.App.Exe

; ==========================================================
; MAIN LOOP
; ==========================================================
Loop {
    if !WinExist("ahk_exe " . CFG.App.Exe)
        ExitApp

    if WinActive("ahk_exe " . CFG.App.Exe) {
        ; HoldKey pressed → normal combat
        if (GetKeyState(CFG.App.HoldKey, "P") && HasEnoughPower())
            DecideCombatAction()
        ; Full auto (skills + attacks)
        else if (AutoMode = AUTO_COMBAT && HasEnoughPower())
            DecideCombatAction()
        ; Attack-only auto
        else if (AutoMode = AUTO_ATTACK)
            PerformRangedCombat()
    }

    Sleep Random(CFG.Timing.LoopMin, CFG.Timing.LoopMax)
}

; ==========================================================
; DETECTION
; ==========================================================
IsSlotReady(x, y) {
    return PixelSearch(&fx, &fy, x-2, y-2, x+2, y+2, CFG.Skills.ReadyColor, CFG.Skills.Tolerance)
}

AnySkillReady() {
    for idx in CFG.Skills.Active {
        if IsSlotReady(CFG.Skills.SlotX[idx], CFG.Skills.SlotY)
            return true
    }
    return false
}

HasEnoughPower() {
    return PixelSearch(&fx, &fy,
        CFG.Power.X-3, CFG.Power.Y-3,
        CFG.Power.X+3, CFG.Power.Y+3,
        CFG.Power.Color,
        CFG.Power.Tolerance)
}

; ==========================================================
; INPUT PRIMITIVES
; ==========================================================
RMB_Down() {
	Click "Right Down" 
}

RMB_Up() {
	Click "Right Up"
}

RangeTap() {
    RMB_Down()
    Sleep Random(CFG.Timing.TapDownMin, CFG.Timing.TapDownMax)
    RMB_Up()
    Sleep Random(CFG.Timing.TapGapMin, CFG.Timing.TapGapMax)
}

RangeHold(ms := 800) {
    RMB_Down()
    Sleep ms
    RMB_Up()
}

RangeHold_Forced(minHold := 3000, maxHold := 4500) {
    RMB_Down()
    start := A_TickCount

    ; Hold at least minHold
    while (A_TickCount - start < minHold) {
        Sleep 50
    }

    ; Continue holding until maxHold
    while (A_TickCount - start < maxHold) {
        Sleep 50
    }

    RMB_Up()
    Sleep Random(100, 180)
}

; ==========================================================
; COMBO TAIL
; ==========================================================
ComboTailBasicAttack(taps := 3) {
    Loop taps
        RangeTap()
}

; ==========================================================
; COMBOS
; ==========================================================
Combo_SolarFlame() {
    RangeHold(800)
    RangeTap()
    ComboTailBasicAttack()
}

Combo_ScissorKick() {
    Loop 3
        RangeTap()
    RangeHold(800)
    ComboTailBasicAttack()
}

Combo_PulseBeam() {
    RangeTap()
    RangeTap()
    RangeHold_Forced(CFG.Combat.PulseBeamMinHold, CFG.Combat.PulseBeamMaxHold)
    ComboTailBasicAttack()
}

Combo_ChargedBlast() {
    RangeHold(1000)
    ComboTailBasicAttack()
}

Combo_MeteorBlast() {
    RangeHold(400)
    Sleep 120
    RangeHold(400)
    ComboTailBasicAttack()
}

TryRangedCombo() {
    if (Random(1,100) <= 35) {
		Combo_SolarFlame() ; top priority
        return true
    }
    if (Random(1,100) <= 30) {
		Combo_ScissorKick()
        return true
    }
    if (Random(1,100) <= 25) {
		Combo_PulseBeam()
        return true
    }

    roll := Random(1,100)
    if (roll <= 10) {
		Combo_ChargedBlast()
        return true
    } else if (roll <= 18) {
		Combo_MeteorBlast()
        return true
    }

    return false
}

; ==========================================================
; COMBAT DECISION
; ==========================================================
PerformRangedCombat() {
    if Random(1,100) <= CFG.Combat.ComboChance
        if TryRangedCombo()
            return

    Loop Random(1,4)
        RangeTap()
}

DecideCombatAction() {
    if AutoMode = AUTO_ATTACK {
        PerformRangedCombat()
        return
    }

    if AnySkillReady() && Random(1,100) <= CFG.Combat.SkillPriorityChance {
        UseSkillsIfReady()
        return
    }

    PerformRangedCombat()
}

UseSkillsIfReady() {
    skills := ShuffleArray(CFG.Skills.Active)

    for idx in skills {
        if IsSlotReady(CFG.Skills.SlotX[idx], CFG.Skills.SlotY) {
            Send idx
            Sleep Random(60, 140)
            return
        }
    }
}

ShuffleArray(arr) {
    out := arr.Clone()
    Loop out.Length {
        i := A_Index
        j := Random(1, out.Length)
        tmp := out[i]
        out[i] := out[j]
        out[j] := tmp
    }
    return out
}

; ==========================================================
; MANUAL PULSE BEAM (Z)
; ==========================================================
Combo_PulseBeam_Chained() {
    while GetKeyState("z","P") {
        RangeTap()
        RangeTap()
        RangeHold_Forced(CFG.Combat.PulseBeamMinHold, CFG.Combat.PulseBeamMaxHold)
        Sleep Random(20, 40)
    }
}

$*z:: {
    if WinActive("ahk_exe " . CFG.App.Exe)
        Combo_PulseBeam_Chained()
}

; ==========================================================
; DEBUG / TOOLS
; ==========================================================
CreateMarker(x, y) {
    mx := x - (CFG.Debug.MarkerSize / 2)
    my := y - (CFG.Debug.MarkerSize / 2)

    g := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20") ; click-through
    g.BackColor := CFG.Debug.MarkerColor
    g.Show("x" mx " y" my " w" CFG.Debug.MarkerSize " h" CFG.Debug.MarkerSize " NoActivate")

    ; Bind GUI instance into the timer closure
    SetTimer ( () => g.Destroy() ), -CFG.Debug.MarkerTimeout
}

F5:: {
    MouseGetPos &x, &y
    c := PixelGetColor(x, y)
    msg := "X: " x " Y: " y " Color: " c
    A_Clipboard := msg
    ToolTip msg
    SetTimer () => ToolTip(), -3000
}

F6:: {
    report := "--- SLOT COLOR REPORT ---`n`n"
    for idx, x in CFG.Skills.SlotX {
        ready := IsSlotReady(x, CFG.Skills.SlotY)
        col := PixelGetColor(x, CFG.Skills.SlotY)
        report .= "Slot " idx ": " col " | Ready: " ready "`n"
        CreateMarker(x, CFG.Skills.SlotY)
    }
    A_Clipboard := report
    ToolTip "Slot report copied"
    SetTimer () => ToolTip(), -3000
}

; ==========================================================
; HOTKEYS
; ==========================================================
F7:: {
    global AutoMode, AUTO_COMBAT, AUTO_OFF
    AutoMode := (AutoMode = AUTO_COMBAT) ? AUTO_OFF : AUTO_COMBAT
    ToolTip AutoMode = AUTO_COMBAT ? "AUTO: COMBAT" : "AUTO: OFF"
    SoundBeep AutoMode = AUTO_COMBAT ? 750 : 500, 200
    SetTimer () => ToolTip(), -2000
}

F8:: {
    global AutoMode, AUTO_ATTACK, AUTO_OFF
    AutoMode := (AutoMode = AUTO_ATTACK) ? AUTO_OFF : AUTO_ATTACK
    ToolTip AutoMode = AUTO_ATTACK ? "AUTO: ATTACK ONLY" : "AUTO: OFF"
    SoundBeep AutoMode = AUTO_ATTACK ? 700 : 500, 200
    SetTimer () => ToolTip(), -2000
}

F9::ExitApp
