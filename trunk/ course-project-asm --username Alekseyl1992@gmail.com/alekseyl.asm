.model	tiny
code segment	'code'
	assume	CS:code, DS:code
	org	100h
	_start:
	
	jmp real_start  ; �� ��砫� �ணࠬ��
    installed dw 8888 ; �㤥� ��⮬ �஢����,��⠭������ �ண� ��� ���
    ignored_chars db 'abcdefghijklmnopqrstuvwxyz' ; ᯨ᮪ ������㥬�� ᨬ�����
	ignored_length dw 26
	ignore_enabled db 0 ; 䫠� �㭪樨 �����஢���� �����
	translate_from db 'F<DUL' ;ᨬ���� ��� ������ (����� �� ����. �᪫����)
	translate_to db '�����' ; ᨬ���� �� ����� �㤥� ��� ������
	translate_length dw 5 ; ����� ��ப� trasnlate_from
	translate_enabled db 0 ; 䫠� �㭪樨 ��ॢ���
	
	signaturePrintingEnabled db 0 ; 䫠� �㭪樨 �뢮�� ���ଠ樨 �� ����
	cursiveEnabled db 0 ; 䫠� ��ॢ��� ᨬ���� � ���ᨢ
	
	true equ 0ffh ; ����⠭� ��⨭����
    old_int9h_offset dw ?
    old_int9h_segment dw ?
	old_09h dd 0
	
    ;���� ��ࠡ��稪
    new_int9h proc far
		push SI
		push	AX
		push	BX
		push	CX
		push	DX
		push	ES
		push	DS
		push	CS
		pop	DS

		;�஢�ઠ F1-F4
		in AL, 60h
		sub AL, 58
		_F1:
			cmp al, 1 ; F1
			jne _F2
			not signaturePrintingEnabled
			jmp _translate_or_ignore
		_F2:
			cmp al, 2 ; F2
			jne _F3
			not cursiveEnabled
			jmp _translate_or_ignore
		_F3:
			cmp al, 3 ; F3
			jne _F4
			not translate_enabled
			jmp _translate_or_ignore
		_F4:
			cmp al, 4 ; F4
			jne _translate_or_ignore
			not ignore_enabled
			jmp _translate_or_ignore
			
		
		;�����஢���� � ��ॢ��
		_translate_or_ignore:
		
		pushf
		call dword ptr cs:[old_int9h_offset]
		mov	AX, 40h 	;40h-ᥣ����,��� �࠭���� 䫠�� ���-� �����,�����. ���� ����� 
		mov	ES, AX
		mov	BX, ES:[1Ch]	;���� 墮��
		dec	BX	;ᬥ�⨬�� ����� � ��᫥�����
		dec	BX	;����񭭮�� ᨬ����
		cmp	BX, 1Eh	;�� ��諨 �� �� �� �।��� ����?
		jae	go
		mov	BX, 3Ch	;墮�� ��襫 �� �।��� ����, ����� ��᫥���� ������ ᨬ���
				;��室����	� ���� ����

	go:		
		mov DX, ES:[BX] ; � DX 0 ������ ᨬ���
		;����祭 �� ०�� �����஢�� �����?
		cmp ignore_enabled, true
		jne _check_translate
		
		; ��, ����祭
		mov si, 0
		mov cx, ignored_length ;���-�� ������㥬�� ᨬ�����
				
	_check_ignored:
		cmp dl,ignored_chars[si]
		je _block
		inc si
	loop _check_ignored
		jmp _check_translate
		
	_block:
		mov es:[1ch], bx ;�����஢�� �뢮�� ᨬ����
		jmp _quit
	
	_check_translate:
		;����祭 �� ०�� ��ॢ���?
		cmp translate_enabled, true
		jne _quit
		
		; ��, ����祭
		mov si, 0
		mov cx, translate_length ;���-�� ᨬ����� ��� ��ॢ���
		
		_check_translate_loop:
			cmp dl, translate_from[SI]
			je _translate
			inc SI
		loop _check_translate_loop
		jmp _quit
		
		_translate:		
			xor ax, ax
			mov al, translate_to[SI]
			mov es:[bx], ax	; ������ ᨬ����
			
	_quit:
		pop	DS
		pop	ES
		pop DX
		pop CX
		pop	BX
		pop	AX
		pop SI
		iret
new_int9h endp  

real_start:                         ; ���� �᭮���� �ணࠬ��
    mov ax,3509h                    ; ������� � ES:BX ����� 09
    int 21h                         ; ���뢠���
    cmp word ptr es:installed,8888  ; �஢�ઠ ⮣�, ����㦥�� �� 㦥 �ணࠬ��
    je remove                       ; �᫨ ����㦥�� - ���㦠��
    push es
    mov ax, ds:[2Ch]                ; psp
    mov es, ax
    mov ah, 49h                     ; 墠�� ����� �⮡ �������
    int 21h                         ; १����⮬?
    pop es
    jc not_mem                      ; �� 墠⨫� - ��室��
	mov	word ptr CS:old_int9h_offset, BX
	mov	word ptr CS:old_int9h_segment, ES
    mov ax, 2509h                   ; ��⠭���� ����� �� 09
    mov dx, offset new_int9h            ; ���뢠���
    int 21h
    mov dx, offset ok_installed         ; �뢮��� �� �� ��
    mov ah, 9
    int 21h
    mov dx, offset real_start       ; ��⠥��� � ����� १����⮬
    int 27h                         ; � ��室��
    ; ����� �᭮���� �ணࠬ��  
remove:                             ; ���㧪� �ணࠬ�� �� �����
    push es
    push ds
    mov dx, es:old_int9h_offset         ; �����頥� ����� ���뢠���
    mov ds, es:old_int9h_segment        ; �� ����
    mov ax, 2509h
    int 21h
    pop ds
    pop es
    mov ah, 49h                     ; �᢮������� ������
    int 21h
    jc not_remove                   ; �� �᢮�������� - �訡��
    mov dx, offset removed_msg      ; �� ���
    mov ah, 9
    int 21h
    jmp exit                        ; ��室�� �� �ணࠬ��
not_remove:                         ; �訡�� � ��᢮��������� �����.
    mov dx, offset noremove_msg                     
    mov ah, 9
    int 21h
    jmp exit
not_mem:                            ; �� 墠⠥� �����, �⮡� ������� १����⮬
    mov dx, offset nomem_msg
    mov ah, 9
    int 21h
exit:                               ; ��室
    int 20h
ok_installed db 'Installed$'
nomem_msg db 'Out of memory$'
removed_msg db 'Uninstalled$'
noremove_msg db 'Error: cannot unload program$'

code ends
end _start