#Requires AutoHotkey v2.0

$F2::
{
    KeyWait "F2"
    Send "{Ctrl up}{Alt up}{Shift up}"

    ; Recordar la ventana desde donde se copia (para volver luego)
    origen := WinExist("A")

    ; Copiar desde Excel Online
    A_Clipboard := ""
    Send "^c"
    if !ClipWait(2) {
        ToolTip "No se pudo copiar. Haz clic en la celda de Excel Online y vuelve a intentar."
        SetTimer () => ToolTip(), -2500
        return
    }

    raw := A_Clipboard

    ; Dejar solo digitos
    num := RegExReplace(raw, "\D", "")
    if (num = "") {
        ToolTip "El texto copiado no contiene números: [" . raw . "]"
        SetTimer () => ToolTip(), -3000
        return
    }

    ; Agregar 57 siempre, salvo que ya venga con prefijo (57 + 10 digitos = 12 o mas)
    if !(SubStr(num, 1, 2) = "57" && StrLen(num) >= 12)
        num := "57" . num

    win := "ahk_exe Wave.exe"
    if !WinExist(win) {
        A_Clipboard := num
        ToolTip "Wave no encontrado. Número en portapapeles: " . num
        SetTimer () => ToolTip(), -2500
        return
    }

    if (WinGetMinMax(win) = -1)
        WinRestore win

    WinActivate win
    if !WinWaitActive(win, , 2) {
        ToolTip "Wave tardó demasiado en activarse."
        SetTimer () => ToolTip(), -2500
        return
    }

    Sleep 400

    ; Poner el numero en el portapapeles justo antes de pegar y verificarlo
    ok := false
    Loop 3 {
        A_Clipboard := num
        if ClipWait(1) && (A_Clipboard = num) {
            ok := true
            break
        }
        Sleep 100
    }
    if !ok {
        ToolTip "No se pudo preparar el portapapeles."
        SetTimer () => ToolTip(), -2500
        return
    }

    ; Deseleccionar cualquier lista o elemento que haya quedado marcado en azul
    Send "{Esc}"
    Sleep 100

    ; Asegurar que Wave se encuentre en la seccion de llamadas
    Send "^3"
    Sleep 150

    ; Enfocar directamente el campo de marcacion 'Enter name or number'
    ; (Ctrl+Shift+F es el atajo interno de Wave para abrir y enfocar el marcador)
    Send "^+f"
    Sleep 200

    ; Ahora que el foco esta garantizado en la caja de texto, seleccionamos texto previo si habia
    Send "^a"
    Sleep 100

    ; Pegar el nuevo numero en el campo de marcacion
    Send "^v"
    Sleep 300

    ; Iniciar la llamada
    Send "{Enter}"

    ; Mostrar que se copio y que se marco
    ToolTip "Copiado: [" . raw . "]`nMarcando: " . num
    SetTimer () => ToolTip(), -3000
}
