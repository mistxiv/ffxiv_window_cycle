#Persistent
#SingleInstance Force
#WinActivateForce
SetWinDelay, -1

WindowWidthBig := A_ScreenWidth
WindowHeightBig := A_ScreenHeight
WindowWidthSmall := 1024
WindowHeightSmall := 720

idx := 0
XIVPIDs := Array()

SetTimer, FindFFXIVWindows, 1000

FindFFXIVWindows:
    XIVPIDsCount := 0
    WinGet, XIVWindows, List, ahk_class FFXIVGAME
    Loop, %XIVWindows%
    {
        this_id := XIVWindows%A_Index%
        WinGet, this_pid, PID, ahk_id %this_id%
        XIVPIDs[A_Index] := this_pid
        XIVPIDsCount++
    }

    SortArray(XIVPIDs)
    for index, pid in XIVPIDs
        WinSetTitle, ahk_pid %pid%,, XIV%index% - %pid%

    return

; Key names: https://www.autohotkey.com/docs/KeyList.htm
PgUp::
    idx++
    if (idx > XIVPIDsCount)
        idx := 1
    this_pid := XIVPIDs[idx]
	for pid in XIVPIDs {
		that_pid := XIVPIDs[pid]
        if (that_pid != this_pid) {
        	WinMove, ahk_pid %that_pid%,,,,%WindowWidthSmall%,%WindowHeightSmall%
        }
	}
	WinActivate, ahk_pid %this_pid%
	WinMove, ahk_pid %this_pid%,,,,%WindowWidthBig%,%WindowHeightBig%
    return
PgDn::
    idx--
    if (idx < 1)
        idx := XIVPIDsCount
    this_pid := XIVPIDs[idx]
    for pid in XIVPIDs {
		that_pid := XIVPIDs[pid]
        if (that_pid != this_pid) {
        	WinMove, ahk_pid %that_pid%,,,,%WindowWidthSmall%,%WindowHeightSmall%
        }
	}
	WinActivate, ahk_pid %this_pid%
	WinMove, ahk_pid %this_pid%,,,,%WindowWidthBig%,%WindowHeightBig%
    return

; https://sites.google.com/site/ahkref/custom-functions/sortarray
SortArray(Array, Order="A") {
    ;Order A: Ascending, D: Descending, R: Reverse
    MaxIndex := ObjMaxIndex(Array)
    If (Order = "R") {
        count := 0
        Loop, % MaxIndex
            ObjInsert(Array, ObjRemove(Array, MaxIndex - count++))
        Return
    }
    Partitions := "|" ObjMinIndex(Array) "," MaxIndex
    Loop {
        comma := InStr(this_partition := SubStr(Partitions, InStr(Partitions, "|", False, 0)+1), ",")
        spos := pivot := SubStr(this_partition, 1, comma-1) , epos := SubStr(this_partition, comma+1)
        if (Order = "A") {
            Loop, % epos - spos {
                if (Array[pivot] > Array[A_Index+spos])
                    ObjInsert(Array, pivot++, ObjRemove(Array, A_Index+spos))
            }
        } else {
            Loop, % epos - spos {
                if (Array[pivot] < Array[A_Index+spos])
                    ObjInsert(Array, pivot++, ObjRemove(Array, A_Index+spos))
            }
        }
        Partitions := SubStr(Partitions, 1, InStr(Partitions, "|", False, 0)-1)
        if (pivot - spos) > 1    ;if more than one elements
            Partitions .= "|" spos "," pivot-1        ;the left partition
        if (epos - pivot) > 1    ;if more than one elements
            Partitions .= "|" pivot+1 "," epos        ;the right partition
    } Until !Partitions
}
