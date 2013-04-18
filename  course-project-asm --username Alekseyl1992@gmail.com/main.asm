;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main.asm
;
; ���ઠ:
;  tasm.exe /l main.asm
;  tlink /t /x main.obj
;
; �ਬ�砭��:
;  1) ��������ਨ, ��稭��騥�� � ᨬ���� @ - ����, ��� ��� ������ �� ��ਠ��
;  2) ...
;
; �����:
;  ���� ��. �.�. ��㬠��, ��5-44, 2013 �.
;   �����쥢 �.�.
;   ��⪨� �.�.
;   ����஢ �.�.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

code segment	'code'
	assume	CS:code, DS:code
	org	100h
	_start:
	
	jmp _initTSR ; �� ��砫� �ணࠬ��
	
	; �����
	installed					DW	8888						; �㤥� ��⮬ �஢����,��⠭����� TSR ��� ���
	ignoredChars 				DB	'abcdefghijklmnopqrstuvwxyz';@ ᯨ᮪ ������㥬�� ᨬ�����
	ignoredLength 				DW	26							;@ ����� ��ப� ignoredChars
	ignoreEnabled 				DB	0							; 䫠� �㭪樨 �����஢���� �����
	translateFrom 				DB	'F<DUL'						;@ ᨬ���� ��� ������ (����� �� ����. �᪫����)
	translateTo 				DB	'�����'						;@ ᨬ���� �� ����� �㤥� ��� ������
	translateLength				DW	5							;@ ����� ��ப� trasnlateFrom
	translateEnabled			DB	0							; 䫠� �㭪樨 ��ॢ���
	
	signaturePrintingEnabled 	DB	0							; 䫠� �㭪樨 �뢮�� ���ଠ樨 �� ����
	cursiveEnabled 				DB	0							; 䫠� ��ॢ��� ᨬ���� � ���ᨢ
	
	true 						equ	0ffh						; ����⠭� ��⨭����
	old_int9hOffset 			DW	?							; ���� ��ண� ��ࠡ��稪� int 9h
	old_int9hSegment 			DW	?							; ᥣ���� ��ண� ��ࠡ��稪� int 9h
	old_int1ChOffset 			DW	?							; ���� ��ண� ��ࠡ��稪� int 1Ch
	old_int1ChSegment 			DW	?							; ᥣ���� ��ண� ��ࠡ��稪� int 1Ch
	old_int2FhOffset 			DW	?							; ���� ��ண� ��ࠡ��稪� int 2Fh
	old_int2FhSegment 			DW	?							; ᥣ���� ��ண� ��ࠡ��稪� int 2Fh
	
	specialParamFlag			DW	0 							; 1 - ���㧨�� १�����, 2 - �� ����㦠��
	counter	  					DW	0
	printDelay					equ	2 							;@ ����প� ��। �뢮��� "������" � ᥪ㭤��
	printPos					DW	1 							;@ ��������� ������ �� �࠭�. 0 - ����, 1 - 業��, 2 - ���
	
	;@ �������� �� ᮡ�⢥��� �����. �ନ஢���� ⠡���� ���� �� ��ப� ����襩 ����� (1� ��ப�).
	;@ ����� �ନ஢��� �१ ���, �� �� ᫨誮� ᨫ쭮 㢥��稢��� ��� ��ꥬ ࠡ���, ⠪ � ��ꥬ ᠬ��� ����
	signatureLine1				DB	179, '����� ��⪨�', 179, 10
	Line1_length 				equ	$-signatureLine1
	signatureLine2				DB	179, '��5-44      ',179,  10
	Line2_length 				equ	$-signatureLine2
	signatureLine3				DB	179, '��ਠ�� #0  ', 179, 10
	Line3_length 				equ	$-signatureLine3
	helpMsg						DB	'some help', 10, 13
	helpMsg_length				equ $-helpMsg
	errorParamMsg				DB	10, 13, 'some error on param'
	errorParamMsg_length		equ	$-errorParamMsg
	
	tableTop					DB	218, Line1_length-3 dup (196), 191, 10
	tableTop_length 			equ	$-tableTop
	tableBottom					DB	192, Line1_length-3 dup (196), 217, 10
	tableBottom_length 			equ $-tableBottom
	
	; ᮮ�饭��		
	installedMsg				DB 'Installed$'
	alreadyInstalledMsg			DB 'Already Installed$'
	noMemMsg					DB 'Out of memory$'
	removedMsg					DB 'Uninstalled$'
	noRemoveMsg					DB 'Error: cannot unload program$'
	
    ;���� ��ࠡ��稪
    new_int9h proc far
		; ��࠭塞 ���祭�� ���, �����塞�� ॣ���஢ � ���
		push SI
		push AX
		push BX
		push CX
		push DX
		push ES
		push DS
		; ᨭ�஭����㥬 CS � DS
		push CS
		pop	DS

		mov	AX, 40h ; 40h-ᥣ����,��� �࠭���� 䫠�� ���-� ����������, �����. ���� ����� 
		mov	ES, AX
		in	AL, 60h	; �����뢠�� � AL ᪠�-��� ����⮩ ������
		
		;@ �஢�ઠ �� Ctrl+U, ⮫쪮 ��� ��5-41
		cmp	AL, 22	; �뫠 ����� ������ U?
		jne	_test_Fx
		mov	AH, ES:[17h]     ; 䫠�� ����������
		and	AH, 00001111b
		cmp	AH, 00000100b	; �� �� ����� ctrl?
		jne	_test_Fx
		; ���㧪�
			mov AH, 0FFh
			mov AL, 01h
			; ES = CS
			push CS
			pop ES
			int 2Fh
			; �����蠥� ��ࠡ��� ������
			pushf
			call dword ptr CS:[old_int9hOffset]
			;��室��
			jmp _quit
		
		;@ ����� - ��� ��� ��� ��ਠ�⮢
		
		;�஢�ઠ F1-F4
		_test_Fx:
		sub AL, 58 ; � AL ⥯��� ����� �㭪樮���쭮� ������
		_F1:
			cmp AL, 1 ; F1
			jne _F2
			not signaturePrintingEnabled
			jmp _translate_or_ignore
		_F2:
			cmp AL, 2 ; F2
			jne _F3
			not cursiveEnabled
			jmp _translate_or_ignore
		_F3:
			cmp AL, 3 ; F3
			jne _F4
			not translateEnabled
			jmp _translate_or_ignore
		_F4:
			cmp AL, 4 ; F4
			jne _translate_or_ignore
			not ignoreEnabled
			jmp _translate_or_ignore
				
		;�����஢���� � ��ॢ��
		_translate_or_ignore:
		
		pushf
		call dword ptr CS:[old_int9hOffset]
		mov	AX, 40h 	; 40h-ᥣ����,��� �࠭���� 䫠�� ���-� �����,�����. ���� ����� 
		mov	ES, AX
		mov	BX, ES:[1Ch]	; ���� 墮��
		dec	BX	; ᬥ�⨬�� ����� � ��᫥�����
		dec	BX	; ����񭭮�� ᨬ����
		cmp	BX, 1Eh	; �� ��諨 �� �� �� �।��� ����?
		jae	_go
		mov	BX, 3Ch	; 墮�� ��襫 �� �।��� ����, ����� ��᫥���� ������ ᨬ���
				    ; ��室����	� ���� ����

	_go:		
		mov DX, ES:[BX] ; � DX 0 ������ ᨬ���
		;����祭 �� ०�� �����஢�� �����?
		cmp ignoreEnabled, true
		jne _check_translate
		
		; ��, ����祭
		mov SI, 0
		mov CX, ignoredLength ;���-�� ������㥬�� ᨬ�����
		
		; �஢��塞, ��������� �� ⥪�騩 ᨬ��� � ᯨ᪥ ������㥬��
	_check_ignored:
		cmp DL,ignoredChars[SI]
		je _block
		inc SI
	loop _check_ignored
		jmp _check_translate
		
	; ������㥬
	_block:
		mov ES:[1Ch], BX ;�����஢�� ����� ᨬ����
		;@ �᫨ �� ��ਠ��� �㦭� �� �����஢��� ���� ᨬ����,
		;@ � �������� ���� ᨬ���� ��㣨��,
		;@ ������� ��ப� ��� ��ப��
		;@  mov ES:[BX], AX
		;@ �� ���� AX ����� ���� '*' ��� ������ ��� ᨬ����� ������⢠ ignoredChars �� ��񧤮窨
		;@ ���, ��� ��ॢ��� ����� ᨬ����� � ��㣨� - ������ ���ᨢ
		;@ replaceWith DB '...', ��� ����᫨�� ᨬ����, �� ����� ������ ������
		;@ � �᪮�����஢��� ��ப� ����:
		;@  xor AX, AX
		;@  mov AL, replaceWith[SI]
		;@  mov ES:[BX], AX	; ������ ᨬ����
		jmp _quit
	
	_check_translate:
		; ����祭 �� ०�� ��ॢ���?
		cmp translateEnabled, true
		jne _quit
		
		; ��, ����祭
		mov SI, 0
		mov CX, translateLength ; ���-�� ᨬ����� ��� ��ॢ���
		; �஢��塞, ��������� �� ⥪�騩 ᨬ��� � ᯨ᪥ ��� ��ॢ���
		_check_translate_loop:
			cmp DL, translateFrom[SI]
			je _translate
			inc SI
		loop _check_translate_loop
		jmp _quit
		
		; ��ॢ����
		_translate:		
			xor AX, AX
			mov AL, translateTo[SI]
			mov ES:[BX], AX	; ������ ᨬ����
			
	_quit:
		; ����⠭�������� �� ॣ�����
		pop	DS
		pop	ES
		pop DX
		pop CX
		pop	BX
		pop	AX
		pop SI
		iret
new_int9h endp  

;=== ��ࠡ��稪 ���뢠��� int 1Ch ===;
;=== ��뢠���� ����� 55 �� ===;
new_int1Ch proc far
	push AX
	push CS
	pop DS
	
	pushf
	call dword ptr CS:[old_int1ChOffset]
	
	cmp signaturePrintingEnabled, true ; �᫨ ����� �ࠢ����� ������ (� ������ ��砥 F1)
	jne _notToPrint		
	
		cmp counter, printDelay*1000/55 + 1 ; �᫨ ���-�� "⠪⮢" �������⭮ %printDelay% ᥪ㭤��
		je _letsPrint
		
		jmp _dontPrint
		
		_letsPrint:
			not signaturePrintingEnabled
			mov counter, 0
			call printSignature
		
		_dontPrint:
			add counter, 1
		
	_notToPrint:
	
	pop AX
	
	iret
new_int1Ch endp

new_int2Fh	proc
	cmp	AH, 0FFh	;��� �㭪��?
	jne	_2Fh_std	;��� - �� ���� ��ࠡ��稪
	cmp	AL, 0	;����㭪�� �஢�ન, ����㦥� �� १����� � ������?
	je	_already_installed
	cmp	AL, 1	;����㭪�� ���㧪� �� �����?
	je	_uninstall	
	jmp	_2Fh_std	;��� - �� ���� ��ࠡ��稪
	
_already_installed:
		mov	AX, 'SS'	;���� SS, �᫨ १����� ����㦥�	� ������
		iret
	
_uninstall:
	push	DS
	push	ES
	push	DX
	
	mov	AX, 2509h
	mov DX, ES:old_int9hOffset         ; �����頥� ����� ���뢠���
    mov DS, ES:old_int9hSegment        ; �� ����
	int	21h
	
	mov	AX, 251Ch
	mov DX, ES:old_int1ChOffset         ; �����頥� ����� ���뢠���
    mov DS, ES:old_int1ChSegment        ; �� ����
	int	21h

	mov	AX, 252Fh
	mov DX, ES:old_int2FhOffset         ; �����頥� ����� ���뢠���
    mov DS, ES:old_int2FhSegment        ; �� ����
	int	21h

	mov	ES, CS:2Ch	;����㧨� � ES ���� ���㦥���			
	mov	AH, 49h		;���㧨� �� ����� ���㦥���
	int	21h
	jc _notRemove
	
	push	CS
	pop	ES	;� ES - ���� १����⭮� �ண�
	mov	AH, 49h  ;���㧨� �� ����� १�����
	int	21h
	jc _notRemove
	jmp _unloaded
	
_notRemove: ; �� 㤠���� �믮����� ���㧪�
    mov DX, offset noRemoveMsg                     
    mov AH, 9
    int 21h

_unloaded: ; ���㧪� ��諠 �ᯥ譮
    mov DX, offset removedMsg                     
    mov AH, 9
    int 21h
	
_2Fh_exit:
	pop	DX
	pop	ES
	pop	DS
	iret

_2Fh_std:
	jmp	dword ptr CS:[old_int2FhOffset]	;�맮� ��ண� ��ࠡ��稪�
new_int2Fh	endp

printSignature proc
	push AX
	push DX
	push CX
	push BX
	push ES
	push SP
	push BP
	push SI
	push DI

	xor AX, AX
	xor DX, DX
	
	mov AH, 03h						;�⥭�� ⥪�饩 ����樨 �����
	int 10h
	push DX							;����頥� ���ଠ�� � ��������� ����� � �⥪
	
	cmp printPos, 0
	je _printTop
	
	cmp printPos, 1
	je _printCenter
	
	cmp printPos, 2
	je _printBottom
	
	;�� �᫠ �����࠭� �� ����...
	_printTop:
		mov DH, 0
		mov DL, 1Fh
		jmp _actualPrint
	
	_printCenter:
		mov DH, 9
		mov DL, 1Fh
		jmp _actualPrint
		
	_printBottom:
		mov DH, 19
		mov DL, 1Fh
		jmp _actualPrint
		
	_actualPrint:	
		mov AH, 0Fh					;�⥭�� ⥪�饣� �����०���. � BH - ⥪��� ��࠭��
		int 10h

		push CS						
		pop ES						;㪠�뢠�� ES �� CS
		
		;�뢮� '�����誨' ⠡����
		lea BP, tableTop				;����頥� � BP 㪠��⥫� �� �뢮����� ��ப�
		mov CX, tableTop_length		;� CX - ����� ��ப�
		mov BL, 0111b 				;梥� �뢮������ ⥪�� ref: http://en.wikipedia.org/wiki/BIOS_color_attributes
		mov AX, 1301h					;AH=13h - ����� �-��, AL=01h - ����� ��६�頥��� �� �뢮�� ������� �� ᨬ����� ��ப�
		int 10h
		
		;�뢮� ��ࢮ� �����
		lea BP, signatureLine1
		mov CX, Line1_length
		mov BL, 0111b
		sub DL, tableTop_length-1	;ᬥ頥� ��砫� ����� �� "�㦭��"
		mov AX, 1301h
		int 10h
		
		;�뢮� ��ன �����
		lea BP, signatureLine2
		mov CX, Line2_length
		mov BL, 0111b
		sub DL, Line1_length-1		;ᬥ頥� ��砫� ����� �� "�㦭��"
		mov AX, 1301h
		int 10h
		
		;�뢮� ���쥩 �����
		lea BP, signatureLine3
		mov CX, Line3_length
		mov BL, 0111b
		sub DL, Line2_length-1
		mov AX, 1301h
		int 10h
		
		;�뢮� '����' ⠡����
		lea BP, tableBottom
		mov CX, tableBottom_length
		mov BL, 0111b
		sub DL, Line3_length-1		;ᬥ頥� ��砫� ����� �� "�㦭��"
		mov AX, 1301h
		int 10h
		
		pop DX						;����⠭�������� �� �⥪� �०��� ��������� �����
		mov AH, 02h					;���塞 ��������� ����� �� ��ࢮ��砫쭮�
		int 10h
		
	pop DI
	pop SI
	pop BP
	pop SP
	pop ES
	pop BX
	pop CX
	pop DX
	pop AX
	
	ret
printSignature endp

unload proc
    push ES
    push DS
    mov DX, ES:old_int9hOffset         ; �����頥� ����� ���뢠���
    mov DS, ES:old_int9hSegment        ; �� ����
    mov AX, 2509h
    int 21h
	mov DX, ES:old_int1ChOffset         ; �����頥� ����� ���뢠���
    mov DS, ES:old_int1ChSegment        ; �� ����
    mov AX, 251Ch
    int 21h
	
    mov	ES, CS:2Ch	;����㧨� � ES ���� ���㦥���			
	mov	AH, 49h		;���㧨� �� ����� ���㦥���
	int	21h

	push	CS
	pop	ES	;� ES - ���� १����⭮� �ண�
	mov	AH, 49h  ;���㧨� �� ����� १�����
	int	21h
	int 20h
	
    ret
unload endp

_initTSR:                         	; ���� १�����
    call commandParamsHandler    
	mov AX,3509h                    ; ������� � ES:BX ����� 09
    int 21h                         ; ���뢠���
	
	;@ === �������� १����� �� ����� ===
	;@ �᫨ �� ��ਠ��� ����室��� ���㦠�� १����� �� ����୮�� ������ �ਫ������, 
	;@ �㦭� ���������஢��� ᫥���騥 3 ��ப�, � ⠪��
	;@ ᮤ�ন��� ��⪨ _finishTSR �-�� commandParamsHandler, �� �� ᠬ� ����!
	cmp specialParamFlag, 1
	je removingOnParameter
	jmp no_removing_now
	
	removingOnParameter:
	cmp word ptr ES:installed, 8888  ; �஢�ઠ ⮣�, ����㦥�� �� 㦥 �ணࠬ��
     je _remove                       
	 
	 no_removing_now:
	 
	 ;@ �᫨ �� ��ਠ��� ����室��� ���㦠�� १����� �� ����୮�� ������, � ��������㥬 ��� ��ப�;
	 ;@ �᫨ ����室��� ���㦠�� �� ��ࠬ���� ���������� ��ப�, � ��⠢�塞 ��
	 cmp word ptr ES:installed, 8888  ; �஢�ઠ ⮣�, ����㦥�� �� 㦥 �ணࠬ��
	 je _alreadyInstalled
    
	cmp specialParamFlag, 2		; �᫨ �뫠 �뢥���� �ࠢ��
	je _exit						; ���� ��室��
	
	push ES
    mov AX, DS:[2Ch]                ; psp
    mov ES, AX
    mov AH, 49h                     ; 墠�� ����� �⮡ �������
    int 21h                         ; १����⮬?
    pop ES
    jc _notMem                      ; �� 墠⨫� - ��室��
	
	;== int 09h ==;

	mov	word ptr CS:old_int9hOffset, BX
	mov	word ptr CS:old_int9hSegment, ES
    mov AX, 2509h                   ; ��⠭���� ����� �� 09
    mov DX, offset new_int9h            ; ���뢠���
    int 21h
	
	;== int 1Ch ==;
	mov AX,351Ch                    ; ������� � ES:BX ����� 1C
    int 21h                         ; ���뢠���
	mov	word ptr CS:old_int1ChOffset, BX
	mov	word ptr CS:old_int1ChSegment, ES
	mov AX, 251Ch                   ; ��⠭���� ����� �� 1C
	mov DX, offset new_int1Ch            ; ���뢠���
	int 21h
	
	;== int 2Fh ==;
	mov AX,352Fh                    ; ������� � ES:BX ����� 1C
    int 21h                         ; ���뢠���
	mov	word ptr CS:old_int2FhOffset, BX
	mov	word ptr CS:old_int2FhSegment, ES
	mov AX, 252Fh                   ; ��⠭���� ����� �� 2F
	mov DX, offset new_int2Fh            ; ���뢠���
	int 21h

    mov DX, offset installedMsg         ; �뢮��� �� �� ��
    mov AH, 9
    int 21h
    mov DX, offset _initTSR       ; ��⠥��� � ����� १����⮬
    int 27h                         ; � ��室��
    ; ����� �᭮���� �ணࠬ��  
_remove:                             ; ���㧪� �ணࠬ�� �� �����
	call unload
	jmp _exit
_alreadyInstalled:
	mov AH, 09h
	lea DX, alreadyInstalledMsg
	int 21h
	jmp _exit
_notMem:                            ; �� 墠⠥� �����, �⮡� ������� १����⮬
    mov DX, offset noMemMsg
    mov AH, 9
    int 21h
_exit:                               ; ��室
    int 20h

	
commandParamsHandler proc
	push CS
	pop ES
	mov SI, 80h   				;SI=ᬥ饭�� ��������� ��ப�.
	lodsb        					;����稬 ���-�� ᨬ�����.
	or AL, AL     				;�᫨ 0 ᨬ����� �������, 
	jz Got_cmd   					;� �� � ���浪�. 

	inc SI       					;������ SI 㪠�뢠�� �� ���� ᨬ��� ��ப�.

	Next_char:
		lodsw       				;����砥� ��� ᨬ����
		cmp AX, '?/' 				;�� '/?' ? ����� ���� �������!
		je _question
		cmp AX, 'u/'
		je _finishTSR
		
		jmp No_string
		ret

	Got_cmd:
		xor AL, AL 				;������ ⮣�, �� ��祣� �� ����� � ��������� ��ப�
		ret  					;��室�� �� ��楤���

	No_string:
		;mov AL, 3 				;������ ����୮�� ����� ��������� ��ப�
		ret
   
	_question:
		; �뢮� ��ப� �����
			mov AH,03
			int 10h	
			lea BP, helpMsg
			mov CX, helpMsg_length
			mov BL, 0111b
			mov AX, 1301h
			int 10h
		; ����� �뢮�� ��ப� �����
		mov specialParamFlag, 2      ;䫠� ⮣�, �� ����室��� �� ����㦠�� १�����
		inc SI
		jmp Next_char
	
	;@ === �������� १����� �� ����� ===
	;@ �᫨ �� ��ਠ��� ����室��� ���㦠�� १����� �� ��ࠬ���� '/u' ���������� ��ப�, 
	;@ �㦭� �ᯮ�짮���� ᫥���騩 ���, ��祬 ��� ���� (� ����㧪� १�����),
	;@ ����祭���� ��宦�� �������ਥ� ����室��� �᪮�����஢���
	_finishTSR:
		mov specialParamFlag, 1      ;䫠� ⮣�, �� ����室��� ��㧨�� १�����
		inc SI
		jmp Next_char

	jmp exitHelp

	errorParam:
		;�뢮� ��ப�
			mov AH,03
			int 10h	
			lea BP, CS:errorParamMsg
			mov CX, errorParamMsg_length
			mov BL, 0111b
			mov AX, 1301h
			int 10h
		;����� �뢮�� ��ப�
	exitHelp:
	ret
commandParamsHandler endp

code ends
end _start