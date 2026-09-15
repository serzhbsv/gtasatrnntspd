.386
      .model flat, stdcall
      option casemap :none
;###############################################################################
      include \masm32\include\windows.inc
      include \masm32\include\masm32.inc
      include \masm32\include\kernel32.inc
      include \masm32\include\user32.inc
      include \masm32\include\shell32.inc
      include \masm32\include\Fpu.inc

	  includelib \masm32\lib\masm32.lib
      includelib \masm32\lib\kernel32.lib
      includelib \masm32\lib\user32.lib
      includelib \masm32\lib\shell32.lib
      includelib \masm32\lib\fpu.lib
;###############################################################################
; Manual tlhelp32 definitions (no tlhelp32.inc needed)
;###############################################################################
TH32CS_SNAPPROCESS  equ 00000002h
CBN_SELCHANGE      equ 1

PROCESSENTRY32 STRUCT
  dwSize              DWORD ?
  cntUsage            DWORD ?
  th32ProcessID       DWORD ?
  th32DefaultHeapID   DWORD ?
  th32ModuleID        DWORD ?
  cntThreads          DWORD ?
  th32ParentProcessID DWORD ?
  pcPriClassBase      DWORD ?
  dwFlags             DWORD ?
  szExeFile           BYTE 260 dup(?)
PROCESSENTRY32 ENDS

CreateToolhelp32Snapshot PROTO :DWORD, :DWORD
Process32First           PROTO :DWORD, :DWORD
Process32Next            PROTO :DWORD, :DWORD
;###############################################################################
        szText MACRO Name, Text:VARARG
          LOCAL lbl
            jmp lbl
              Name db Text,0
            lbl:
          ENDM
          
        DialogProc PROTO :DWORD,:DWORD,:DWORD,:DWORD
        TimerProc PROTO :DWORD,:DWORD,:DWORD,:DWORD
        GetCorVecAddress PROTO :BYTE
        PatchGame PROTO	:DWORD,:DWORD,:DWORD,:DWORD
        LoadFromGame PROTO	:DWORD,:DWORD,:DWORD
;###############################################################################
.data
	hInstance		dd 0
	hWinHandle		dd 0
	hIcon			dd 0
	hStatusBar		dd 0
	hComboBox		dd 0
	hProcCombo		dd 0
	dwGamePid		dd 0
	pe32			PROCESSENTRY32 <>
	CopyPos			db 0
	MYTEMP			dd 0
	MyStr			db 21h dup (?)
	MyXStr			db 21h dup (?)
	MyYStr			db 21h dup (?)
	MyZStr			db 21h dup (?)
	SpeedBoost		dd 1.50
	Heght			dd 2.00
	TeleportZ		dd 3.00
	Muscle			dd 1000.00
	Staminea		dd 1000.00
	Fat				dd 200.00
	Respect			dd 6000.00
	GamblingSkill	dd 1000.00
	HitmanWeapon	dd 1000.00
	AllComplete		dd 1000.00
	LungCapacity	dd 1000
	GoodDriver		dd 1000
	Tags			dd 100
	Oysters			dd 50
	Snaphots		dd 50
	HorsesShoes		dd 50 
	ZeroVelocity	dd 0.00, 0.00, 0.00
	MachineCode		dd 0
					dd 0
					dd 0
					dd 2787392
					dw 220
					dw 0
					dw 1087
					dw 65535
					dw 65535
					dw 65535
					dw 65535
					dw 65535
					dw 65535
					dw 65535
					dw 65535
					dw 65535
					dw 65535
					dw 65535
					dw 65535
					dw 65535
					db 7Ch
					db 7Ch
					db 0
					db 0
					db 12
					db 255
					db 255
					db 0
					db 255
					db 10
					db 0
					db 157
					db 4
					db 0
	Positions		dd 2494.96, -1679.62, 13.5	,\
					   322.05 , -1773.72, 5.0	,\
					   1338.64,  -623.98, 109.20,\
					   1287.12,  2529.44, 10.90	,\
					  -2106.77,   903.77, 76.70 ,\
					  -2024.59,   147.31, 28.90 ,\
					  -2460.11,  -132.53, 26.00 ,\
					   2443.32,   697.24, 11.60 ,\
					   -353.58,  1173.26, 20.00 ,\
					    162.52,  1914.43, 18.65
	GiveMachine1	db 0E9h
					dd 00359B87h
	GiveMachine2	db 068h
					dd 08E2F3Ah
					db 0E8h
					dd 0FFB65617h
					db 0C3h
	GiveMachineB	db 0C3h
	GiveHealth1		db 0C7h,80h,40h,5,0,0,0,0,0C8h,42h,0D9h,80h,40h,5h,0,0,0E9h,89h,0B2h,8Eh,0FFh
	GiveHealth2		db 0E9h
					dd 00714D63h
					db 90h
	GiveHealthB		db 0D9h,80h,40h,5,0,0
	GiveArmor		db 90h,90h,90h
	GiveArmorB		db 0D8h,66h,04h
	InfiniteAmmo 	db 0EBh
	InfiniteAmmoB	db 75h
	NoPolice		db 0E9h,84h,1,0,0,90h,90h
	NoPoliceB		db 7Ch,3Ah,0B8h,6,0,0,0
	Run				db 90h,90h,90h
	RunB			db 0D8h,6Eh,18h
	MoneyValue		dd 100000000
	FreezeTime		db 90h,90h,90h,90h,90h,90h
	FreezeTimeB		db 0FEh,5,52h,1,0B7h,0
	CarHealth1		db 0E9h,1Ch,0Eh,0,0,90h
	CarHealth2		db 0E9h,0D6h,5,0,0,90h
	CarHealth1B		db 0Fh,84h,1Bh,0Eh,0,0
	CarHealth2B		db 0Fh,84h,0D5h,5,0,0
	Mission			db 90h,90h
	MissionB		db 2Bh,0CDh
	Nitro1			db 90h,90h
	Nitro2			db 0EBh
	Nitro1B			db 0FEh,0C8h
	Nitro2B			db 7Ah
	Breath			db 0EBh
	BreathB			db 74h
;################################################################################
.code

start:
	invoke GetModuleHandle, NULL
	mov	   hInstance, eax
	szText WinResName,"MAINFORM"	
	invoke DialogBoxParam,hInstance,addr WinResName, NULL, addr DialogProc, NULL
	invoke ExitProcess,hInstance
;################################################################################
DialogProc proc hWin   :DWORD,
             	uMsg   :DWORD,
             	wParam :DWORD,
             	lParam :DWORD
	mov	eax, hWin
	mov hWinHandle, eax
	.if uMsg == WM_INITDIALOG
		szText WinTitle,"GTA-SanAndreas Trainer by NetSpider"
		invoke  SendMessage,hWin,WM_SETTEXT,0,addr WinTitle
		szText  IconResName,"MAINICON"
		invoke	LoadIcon,hInstance, addr IconResName
		mov		hIcon, eax
		invoke	SendMessage, hWin,WM_SETICON, 1, hIcon
		invoke	SendMessage, hWin,WM_SETICON, 0, hIcon
		invoke	GetDlgItem, hWin, 1031
		mov		hStatusBar, eax
		invoke	GetDlgItem, hWin, 1028
		mov 	hComboBox, eax
		invoke	GetDlgItem, hWin, 1041
		mov 	hProcCombo, eax

		invoke	SetTimer,hWin,1,300,addr TimerProc
		; Loading vehicle names from resources
		mov ebx, 400
		.repeat
			invoke LoadString,hInstance,ebx,addr MyStr,20h
			invoke SendMessage,hComboBox,CB_ADDSTRING,0,addr MyStr
			inc ebx
		.until ebx==612
		invoke SendMessage,hComboBox,CB_SETCURSEL,11,NULL
	.elseif uMsg == WM_COMMAND
		; --- Handle process ComboBox selection change ---
		mov eax, wParam
		shr eax, 16
		.if ax == CBN_SELCHANGE
			mov eax, wParam
			and eax, 0FFFFh
			.if eax == 1041
				invoke SendMessage, hProcCombo, CB_GETCURSEL, 0, 0
				.if eax != CB_ERR
					invoke SendMessage, hProcCombo, CB_GETITEMDATA, eax, 0
					mov dwGamePid, eax
					szText StatSel,"Process selected. Trainer active."
					invoke SendMessage,hStatusBar,WM_SETTEXT,0,addr StatSel
				.endif
			.endif
		.endif
		; --- Handle buttons ---
        .if wParam == 1040
            ; Refresh process list
            invoke SendMessage, hProcCombo, CB_RESETCONTENT, 0, 0
            mov pe32.dwSize, SIZEOF PROCESSENTRY32
            invoke CreateToolhelp32Snapshot, TH32CS_SNAPPROCESS, 0
            mov esi, eax
            invoke Process32First, esi, addr pe32
            .if eax != 0
            @@nextproc:
                invoke SendMessage, hProcCombo, CB_ADDSTRING, 0, addr pe32.szExeFile
                invoke SendMessage, hProcCombo, CB_GETCOUNT, 0, 0
                dec eax
                invoke SendMessage, hProcCombo, CB_SETITEMDATA, eax, pe32.th32ProcessID
                invoke Process32Next, esi, addr pe32
                .if eax != 0
                    jmp @@nextproc
                .endif
            .endif
            invoke CloseHandle, esi
            szText StatRef,"Process list updated. Select a process."
            invoke SendMessage,hStatusBar,WM_SETTEXT,0,addr StatRef
        .elseif wParam == 1032
            szText InfoText,"Author NetSpider. Trainer from http://www.chemax.ru"
            invoke	ShellAbout, hWin, addr WinTitle, addr InfoText, hIcon
        .elseif wParam == 1019
        	mov	CopyPos,1
        ;Set CoolBoy
        .elseif wParam == 2015
        	invoke PatchGame,0B793DCh,addr Muscle,4,0
        	invoke PatchGame,0B793D8h,addr Staminea,4,0
        	invoke PatchGame,0B793D4h,addr Fat,4,0
        	invoke PatchGame,0B79480h,addr Respect,4,0
        	invoke PatchGame,0B794C4h,addr GamblingSkill,4,0
        	mov ebx, 0B79494h
        	.repeat
        	invoke PatchGame,ebx,addr HitmanWeapon,4,0
        	add	ebx, 4
        	.until ebx==00B794C0h
        	invoke PatchGame,0B79380h,addr AllComplete,4,0
        	invoke PatchGame,0B791A4h,addr LungCapacity,4,0
        	invoke PatchGame,0B791B4h,addr GoodDriver,4,0
        	invoke PatchGame,0B790A0h,addr GoodDriver,4,0
        	invoke PatchGame,0B791B8h,addr GoodDriver,4,0
        	invoke PatchGame,0B7919Ch,addr GoodDriver,4,0
        	invoke PatchGame,0A9AD74h,addr Tags,4,0
			invoke PatchGame,0B791ECh,addr Oysters,4,0
			invoke PatchGame,0B791BCh,addr Snaphots,4,0
			invoke PatchGame,0B791E4h,addr HorsesShoes,4,0
        .elseif wParam == 2005
        	invoke PatchGame,0B7CE50h,addr MoneyValue,4,0
        .elseif wParam == 1027
        	invoke IsDlgButtonChecked,hWin,1027
        	.if eax==1
        		invoke PatchGame,08E2F2Fh,addr GiveMachine2,11,0
        	    invoke PatchGame,08E2F3Ah,addr MachineCode,40h,0
        		invoke PatchGame,05893A3h,addr GiveMachine1,5,0
        	.else
   				invoke PatchGame,05893A3h,addr GiveMachineB,1,0
        	.endif
        .elseif wParam == 2001
        	invoke IsDlgButtonChecked,hWin,2001
        	.if eax==1
        		invoke PatchGame,0C9E006h,addr GiveHealth1,21,0
        		invoke PatchGame,058929Eh,addr GiveHealth2,6,0
        	.else
        		invoke PatchGame,058929Eh,addr GiveHealthB,6,0
        	.endif
        .elseif wParam == 2003
        	invoke IsDlgButtonChecked,hWin,2003
        	.if eax==1
        		invoke PatchGame,04AD5C7h,addr GiveArmor,3,0
        	.else
        		invoke PatchGame,04AD5C7h,addr GiveArmorB,3,0
        	.endif
        .elseif wParam == 2002
        	invoke IsDlgButtonChecked,hWin,2002
        	.if eax==1
        		invoke PatchGame,07428A6h,addr InfiniteAmmo,1,0
        		invoke PatchGame,073FA7Ch,addr InfiniteAmmo,1,0
        	.else
        		invoke PatchGame,07428A6h,addr InfiniteAmmoB,1,0
        		invoke PatchGame,073FA7Ch,addr InfiniteAmmoB,1,0
        	.endif
        .elseif wParam == 2004
        	invoke IsDlgButtonChecked,hWin,2004
        	.if eax==1
        		invoke PatchGame,0561CABh,addr NoPolice,7,0
        	.else
        		invoke PatchGame,0561CABh,addr NoPoliceB,7,0
        	.endif
        .elseif wParam == 2006
        	invoke IsDlgButtonChecked,hWin,2006
        	.if eax==1
        		invoke PatchGame,060A5AAh,addr Run,3,0
        	.else
        		invoke PatchGame,060A5AAh,addr RunB,3,0
        	.endif
        .elseif wParam == 2007
        	invoke IsDlgButtonChecked,hWin,2007
        	.if eax==1
        		invoke PatchGame,052CF53h,addr FreezeTime,6,0
        	.else
        		invoke PatchGame,052CF53h,addr FreezeTimeB,6,0
        	.endif
        .elseif wParam == 2008
        	invoke IsDlgButtonChecked,hWin,2008
        	.if eax==1
        		invoke PatchGame,06A7682h,addr CarHealth1,6,0
        		invoke PatchGame,06D7CCEh,addr CarHealth2,6,0
        	.else
        		invoke PatchGame,06A7682h,addr CarHealth1B,6,0
        		invoke PatchGame,06D7CCEh,addr CarHealth2B,6,0
        	.endif
        .elseif wParam == 2009
        	invoke IsDlgButtonChecked,hWin,2009
        	.if eax==1
        		invoke PatchGame,044CB56h,addr Mission,2,0
        	.else
        		invoke PatchGame,044CB56h,addr MissionB,2,0
        	.endif
        .elseif wParam == 2010
        	invoke IsDlgButtonChecked,hWin,2010
        	.if eax==1
        		invoke PatchGame,06A3FB9h,addr Nitro1,2,0
        		invoke PatchGame,06A3FFAh,addr Nitro2,1,0
        	.else
        		invoke PatchGame,06A3FB9h,addr Nitro1B,2,0
        		invoke PatchGame,06A3FFAh,addr Nitro2B,1,0
        	.endif
        .elseif wParam == 2011
        	invoke IsDlgButtonChecked,hWin,2011
        	.if eax==1
        		invoke PatchGame,060A8D9h,addr Breath,1,0
        	.else
        		invoke PatchGame,060A8D9h,addr BreathB,1,0
        	.endif
        .endif
	.elseif uMsg == WM_CLOSE
	    invoke EndDialog,hWin,0
    .else
    	xor eax, eax
    .endif
    ret
DialogProc endp
;#######################################################################################
GiveMachine	proc ModelNumber: WORD
	invoke GetCorVecAddress,0
	mov	   esi, eax
	invoke LoadFromGame, esi,addr MYTEMP,0
	invoke PatchGame,008E2F3Ah,addr MYTEMP,4,0
	add	   esi, 4
	invoke LoadFromGame, esi,addr MYTEMP,0
	invoke PatchGame,008E2F3Eh,addr MYTEMP,4,0
	add	   esi, 4
	invoke LoadFromGame, esi,addr MYTEMP,0
	finit
	fld  Heght
	fld  MYTEMP
	fadd
	fstp MYTEMP
	invoke PatchGame,008E2F42h,addr MYTEMP,4,0
	invoke Sleep,500h
	invoke PatchGame,008E2F4Ch,addr ModelNumber,2,0
	Ret
GiveMachine EndP
;#######################################################################################
TeleportToUserPos proc
	invoke GetCorVecAddress,0
	mov	   esi, eax
	invoke GetDlgItemText,hWinHandle,1013,addr MyStr,20h
	invoke FpuAtoFL,addr MyStr, 0, DEST_FPU
	fstp   MYTEMP
	invoke PatchGame,esi,addr MYTEMP,4,0
	invoke GetDlgItemText,hWinHandle,1014,addr MyStr,20h
	invoke FpuAtoFL,addr MyStr, 0, DEST_FPU
	fstp   MYTEMP
	add	   esi,4
	invoke PatchGame,esi,addr MYTEMP,4,0
	invoke GetDlgItemText,hWinHandle,1015,addr MyStr,20h
	invoke FpuAtoFL,addr MyStr, 0, DEST_FPU
	fstp  MYTEMP
	add	   esi,4
	invoke PatchGame,esi,addr MYTEMP,4,0
	Ret
TeleportToUserPos EndP
;#######################################################################################
IndicatePosVec proc
	invoke GetCorVecAddress,0
	mov	   esi, eax
	invoke LoadFromGame,esi,addr MYTEMP,0
	finit
	fld MYTEMP
	invoke FpuFLtoA, 0, 2, addr MyXStr, SRC1_FPU or SRC2_DIMM
	invoke SetDlgItemText,hWinHandle,1007,addr MyXStr
	add	   esi, 4
	invoke LoadFromGame,esi,addr MYTEMP,0
	fld MYTEMP
	invoke FpuFLtoA, 0, 2, addr MyYStr, SRC1_FPU or SRC2_DIMM
	invoke SetDlgItemText,hWinHandle,1008,addr MyYStr
	add	   esi, 4
	invoke LoadFromGame,esi,addr MYTEMP,0
	fld MYTEMP
	invoke FpuFLtoA, 0, 2, addr MyZStr, SRC1_FPU or SRC2_DIMM
	invoke SetDlgItemText,hWinHandle,1009,addr MyZStr
	.if CopyPos==1
		invoke SetDlgItemText,hWinHandle,1013,addr MyXStr
		invoke SetDlgItemText,hWinHandle,1014,addr MyYStr
		invoke SetDlgItemText,hWinHandle,1015,addr MyZStr
		mov CopyPos,0
	.endif
	invoke GetCorVecAddress,1
	mov	   esi, eax
	invoke LoadFromGame,esi,addr MYTEMP,0
	fld MYTEMP
	invoke FpuFLtoA, 0, 2, addr MyStr, SRC1_FPU or SRC2_DIMM
	invoke SetDlgItemText,hWinHandle,1010,addr MyStr
	add	   esi, 4
	invoke LoadFromGame,esi,addr MYTEMP,0
	fld MYTEMP
	invoke FpuFLtoA, 0, 2, addr MyStr, SRC1_FPU or SRC2_DIMM
	invoke SetDlgItemText,hWinHandle,1011,addr MyStr
	add	   esi, 4
	invoke LoadFromGame,esi,addr MYTEMP,0
	fld MYTEMP
	invoke FpuFLtoA, 0, 2, addr MyStr, SRC1_FPU or SRC2_DIMM
	invoke SetDlgItemText,hWinHandle,1012,addr MyStr
	Ret
IndicatePosVec EndP
;#######################################################################################
TimerProc proc	hWnd: 		DWORD,
				uMsg: 		DWORD,
				idEvent: 	DWORD,
				Time: 		DWORD
	.if dwGamePid == 0
		szText StatMsg," Select a process from the list."
		invoke SendMessage,hStatusBar,WM_SETTEXT,0,addr StatMsg
	.else
		szText StatMsg1," Trainer active."
		invoke SendMessage,hStatusBar,WM_SETTEXT,0,addr StatMsg1
		; Scanning keys for Teleport Mode
		mov ebx, 48
		.repeat
			invoke GetAsyncKeyState,ebx
			.if eax!=0
				mov eax, ebx
				sub eax, 48
				mov edx, 12
				mov esi, eax
				imul esi, edx
				lea edi, Positions
				add edi, esi
				invoke GetCorVecAddress,1
				invoke PatchGame,eax,addr ZeroVelocity,12,0
				invoke GetCorVecAddress,0
				mov	esi, eax
				invoke PatchGame,esi,edi,4,0
				add edi, 4
				add esi, 4
				invoke PatchGame,esi,edi,4,0
				add edi, 4
				add esi, 4
				invoke PatchGame,esi,edi,4,0
			.endif
		inc    ebx
		.until ebx==58
		; Scanning key T for give machine
		invoke GetAsyncKeyState,"T"
		.if eax!=0
			invoke SendMessage,hComboBox,CB_GETCURSEL, 0, NULL
			add	   eax,400
			invoke GiveMachine,ax
		.endif
		; Scanning for SPEED BOOST
		invoke GetAsyncKeyState,"M"
		.if eax!=0
				invoke GetCorVecAddress,1
				mov	   esi, eax
				invoke LoadFromGame, esi, addr MYTEMP,0
				finit
				fld	   SpeedBoost
				fld    MYTEMP
				fmul
				fstp   MYTEMP
				invoke PatchGame, esi, addr MYTEMP,4,0
				add    esi, 4
				invoke LoadFromGame, esi, addr MYTEMP,0
				fld	   SpeedBoost
				fld    MYTEMP
				fmul
				fstp   MYTEMP
				invoke PatchGame, esi, addr MYTEMP,4,0
		.endif
		; Scanning key B for SuperBrakes
		invoke GetAsyncKeyState,"B"
		.if eax!=0
				invoke GetCorVecAddress,1
				invoke PatchGame,eax,addr ZeroVelocity,12,0
		.endif
		; Scanning key U for give Rhino
		invoke GetAsyncKeyState,"U"
		.if eax!=0
			invoke GiveMachine,432
		.endif
		; Scanning key O for give Hunter
		invoke GetAsyncKeyState,"O"
		.if eax!=0
			invoke GiveMachine,425
		.endif
		; Scanning key I for teleport up
		invoke GetAsyncKeyState,"I"
		.if eax!=0
			invoke GetCorVecAddress,0
			mov	   esi, eax
			add	   esi, 8
			invoke LoadFromGame, esi,addr MYTEMP,0
			finit
			fld  TeleportZ
			fld  MYTEMP
			fadd
			fstp MYTEMP
			invoke PatchGame, esi,addr MYTEMP,4,0
			invoke GetCorVecAddress,1
			add eax,8
			invoke PatchGame,eax,addr ZeroVelocity,4,0
		.endif
		; Scanning key P for user teleport
		invoke GetAsyncKeyState,"P"
		.if eax!=0
			invoke GetCorVecAddress,1
			add	   eax, 8
			invoke PatchGame,eax,addr ZeroVelocity,4,0
			invoke TeleportToUserPos
		.endif
		invoke GetActiveWindow
		.if eax!=0
				invoke IndicatePosVec
		.endif
	.endif
	xor eax, eax
	ret
TimerProc endp
;#######################################################################################
GetCorVecAddress proc CorVec: BYTE
LOCAL MYTEMP2:DWORD
	push	esi
	push	edi
	invoke 	LoadFromGame,0B7CD74h,addr MYTEMP,0
	xor		esi, esi
	movzx 	esi, byte ptr MYTEMP
	imul 	esi, esi, 190h
	add		esi, 0B7CD98h
	invoke  LoadFromGame,esi,addr MYTEMP,0
	mov	edi, MYTEMP
	add edi, 46Ch
	invoke LoadFromGame,edi,addr MYTEMP2,0
	mov	edx, MYTEMP2
	test dh,1
	jz @nocar
	add edi, 120h
	invoke LoadFromGame,edi,addr MYTEMP,0
@nocar:
	.if CorVec==0
		add		MYTEMP, 14h
		invoke	LoadFromGame,MYTEMP,addr MYTEMP,0
		mov		eax, 30h
	.else
		mov		eax, 44h
	.endif
	add		eax, MYTEMP
	pop		edi
	pop		esi
	Ret
GetCorVecAddress EndP
;#######################################################################################
PatchGame proc	Address:	DWORD,
				MyValueAddr:DWORD,
				CodeSize: 	DWORD,
				WithPointer:DWORD
Local	ExRead:DWORD
	push esi
	push edi
	cmp dwGamePid, 0
	jz	@@exit
	invoke OpenProcess,001F0FFFh,FALSE,dwGamePid
	cmp	eax, 0
	jz	@@close
	mov	edi, eax
	cmp WithPointer,0
	jz	@@nobasepointer
	invoke ReadProcessMemory,edi, Address,addr Address,4,addr ExRead
	cmp	eax, 0
	jz	@@error
	mov	esi, WithPointer
	add	Address, esi
@@nobasepointer:
	invoke WriteProcessMemory,edi,Address,MyValueAddr,CodeSize,addr ExRead
	cmp	eax, 1
	jz	@@close
@@error:
	szText ErMessage,"Can't read/write to memory!"
	invoke MessageBox,hWinHandle,addr ErMessage, addr WinTitle, MB_OK
@@close:
	invoke CloseHandle,edi
@@exit:
	pop edi
	pop esi
	Ret
PatchGame EndP
;#######################################################################################
LoadFromGame proc Address:	DWORD,
				  MyValueAddr:DWORD,
				  WithPointer:DWORD
Local	ExRead:DWORD
	push esi
	push edi
	cmp dwGamePid, 0
	jz	@@exit
	invoke OpenProcess,001F0FFFh,FALSE,dwGamePid
	cmp	eax, 0
	jz	@@close
	mov	edi, eax
	cmp WithPointer,0
	jz	@@nobasepointer
	invoke ReadProcessMemory,edi, Address,addr Address,4,addr ExRead
	cmp	eax, 0
	jz	@@error
	mov	esi, WithPointer
	add	Address, esi
@@nobasepointer:
	invoke ReadProcessMemory,edi,Address,MyValueAddr,4,addr ExRead
	cmp	eax, 1
	jz	@@close
@@error:
	mov	eax,-1
@@close:
	invoke CloseHandle,edi
@@exit:
	pop edi
	pop esi
	Ret
LoadFromGame EndP

end start
