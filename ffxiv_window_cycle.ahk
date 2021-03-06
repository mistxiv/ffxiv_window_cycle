#Persistent
#SingleInstance Force
#WinActivateForce
SetWinDelay, 0

DoWindowResize := false
DoWindowTitleAddPid := true

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

    for index, pid in XIVPIDs {
      if DoWindowTitleAddPid {
        WinGetTitle, Title, ahk_pid %pid%
          if (not InStr(Title, pid)) {
            WinSetTitle, ahk_pid %pid%,, %Title% - %pid%
          }
      }
      if DoWindowResize {
        if WinActive("ahk_pid" pid) {
          WinMaximize, ahk_pid %pid%
        } else {
          WinMove, ahk_pid %pid%,,,,%WindowWidthSmall%,%WindowHeightSmall%
          WinRestore, ahk_pid %pid%
        }
      }
    }

    return

; Key names: https://www.autohotkey.com/docs/KeyList.htm
#IfWinActive ahk_class FFXIVGAME
PgUp::
  idx++
  if (idx > XIVPIDsCount) {
    idx := 1
  }
  this_pid := XIVPIDs[idx]
  WinActivate, ahk_pid %this_pid%
  if DoWindowResize {
    WinMaximize, ahk_pid %this_pid%
    for pid in XIVPIDs {
      that_pid := XIVPIDs[pid]
      if (that_pid != this_pid) {
        WinRestore, ahk_pid %that_pid%
        WinMove, ahk_pid %that_pid%,,,,%WindowWidthSmall%,%WindowHeightSmall%
      }
    }
  }

  return


#IfWinActive ahk_class FFXIVGAME
PgDn::
  idx--
  if (idx < 1) {
    idx := XIVPIDsCount
  }
  this_pid := XIVPIDs[idx]
  WinActivate, ahk_pid %this_pid%
  if DoWindowResize {
    WinMaximize, ahk_pid %this_pid%
    for pid in XIVPIDs {
      that_pid := XIVPIDs[pid]
      if (that_pid != this_pid) {
        WinRestore, ahk_pid %that_pid%
        WinMove, ahk_pid %that_pid%,,,,%WindowWidthSmall%,%WindowHeightSmall%
      }
    }
  }

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
