.model	tiny
code segment	'code'
	assume	CS:code, DS:code
	org	100h
	_start:
	
	jmp _initTSR  ; �� ��砫� �ணࠬ��
    installed DW 8888 ; �㤥� ��⮬ �஢����,��⠭������ �ண� ��� ���
    ignoredChars DB 'abcdefghijklmnopqrstuvwxyz' ; ᯨ᮪ ������㥬�� ᨬ�����
	ignoredLength DW 26
	ignoreEnabled DB 0 ; 䫠� �㭪樨 �����஢���� �����
	translateFrom DB 'F<DUL' ;ᨬ���� ��� ������ (����� �� ����. �᪫����)
	translateTo DB '�����' ; ᨬ���� �� ����� �㤥� ��� ������
	translateLength DW 5 ; ����� ��ப� trasnlate_from
	translateEnabled DB 0 ; 䫠� �㭪樨 ��ॢ���
	
	signaturePrintingEnabled DB 0 ; 䫠� �㭪樨 �뢮�� ���ଠ樨 �� ����
	cursiveEnabled DB 0 ; 䫠� ��ॢ��� ᨬ���� � ���ᨢ
	
	true equ 0ffh ; ����⠭� ��⨭����
    old_int9hOffset DW ? ; ���� ��ண� ��ࠡ��稪� int 9h
    old_int9hSegment DW ? ; ᥣ���� ��ண� ��ࠡ��稪� int 9h
	
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

		;�஢�ઠ F1-F4
		in AL, 60h
		sub AL, 58
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
		mov	AX, 40h 	;40h-ᥣ����,��� �࠭���� 䫠�� ���-� �����,�����. ���� ����� 
		mov	ES, AX
		mov	BX, ES:[1Ch]	;���� 墮��
		dec	BX	;ᬥ�⨬�� ����� � ��᫥�����
		dec	BX	;����񭭮�� ᨬ����
		cmp	BX, 1Eh	;�� ��諨 �� �� �� �।��� ����?
		jae	_go
		mov	BX, 3Ch	;墮�� ��襫 �� �।��� ����, ����� ��᫥���� ������ ᨬ���
				;��室����	� ���� ����

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
		; �᫨ �� ��ਠ��� �㦭� �� �����஢��� ���� ᨬ����,
		; � �������� ���� ᨬ���� ��㣨��,
		; ������� ��ப� ��� ��ப��
		; mov ES:[BX], AX
		; �� ���� AX ����� ���� '*' ��� ������ ��� ᨬ����� ������⢠ ignoredChars �� ��񧤮窨
		; ���, ��� ��ॢ��� ����� ᨬ����� � ��㣨� - ������ ���ᨢ
		; replaceWith DB '...', ��� ����᫨�� ᨬ����, �� ����� ������ ������
		; � �᪮�����஢��� ��ப� ����:
		;   xor AX, AX
		; 	mov AL, replaceWith[SI]
		;	mov ES:[BX], AX	; ������ ᨬ����
		jmp _quit
	
	_check_translate:
		;����祭 �� ०�� ��ॢ���?
		cmp translateEnabled, true
		jne _quit
		
		; ��, ����祭
		mov SI, 0
		mov CX, translateLength ;���-�� ᨬ����� ��� ��ॢ���
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
			; ������� AX �� '*', �᫨ �㦭� �������� ᨬ���� �� ��񧤮��
			
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

_initTSR:                         ; ���� �᭮���� �ணࠬ��
    mov AX,3509h                    ; ������� � ES:BX ����� 09
    int 21h                         ; ���뢠���
    cmp word ptr ES:installed, 8888  ; �஢�ઠ ⮣�, ����㦥�� �� 㦥 �ணࠬ��
    je _remove                       ; �᫨ ����㦥�� - ���㦠��
    push ES
    mov AX, DS:[2Ch]                ; psp
    mov ES, AX
    mov AH, 49h                     ; 墠�� ����� �⮡ �������
    int 21h                         ; १����⮬?
    pop ES
    jc _notMem                      ; �� 墠⨫� - ��室��
	mov	word ptr CS:old_int9hOffset, BX
	mov	word ptr CS:old_int9hSegment, ES
    mov AX, 2509h                   ; ��⠭���� ����� �� 09
    mov DX, offset new_int9h            ; ���뢠���
    int 21h
    mov DX, offset installedMsg         ; �뢮��� �� �� ��
    mov AH, 9
    int 21h
    mov DX, offset _initTSR       ; ��⠥��� � ����� १����⮬
    int 27h                         ; � ��室��
    ; ����� �᭮���� �ணࠬ��  
_remove:                             ; ���㧪� �ணࠬ�� �� �����
    push ES
    push DS
    mov DX, ES:old_int9hOffset         ; �����頥� ����� ���뢠���
    mov DS, ES:old_int9hSegment        ; �� ����
    mov AX, 2509h
    int 21h
    pop DS
    pop ES
    mov AH, 49h                     ; �᢮������� ������
    int 21h
    jc _notRemove                   ; �� �᢮�������� - �訡��
    mov DX, offset removedMsg      ; �� ���
    mov AH, 9
    int 21h
    jmp _exit                        ; ��室�� �� �ணࠬ��
_notRemove:                         ; �訡�� � ��᢮��������� �����.
    mov DX, offset noRemoveMsg                     
    mov AH, 9
    int 21h
    jmp _exit
_notMem:                            ; �� 墠⠥� �����, �⮡� ������� १����⮬
    mov DX, offset noMemMsg
    mov AH, 9
    int 21h
_exit:                               ; ��室
    int 20h
installedMsg DB 'Installed$'
noMemMsg DB 'Out of memory$'
removedMsg DB 'Uninstalled$'
noRemoveMsg DB 'Error: cannot unload program$'

code ends
end _start