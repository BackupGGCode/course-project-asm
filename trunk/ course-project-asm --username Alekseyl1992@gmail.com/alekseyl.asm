.model tiny
.code
.startup
.386
	jmp real_start  ;�� ��砫� �ணࠬ��
    installed dw 8888 ;�㤥� ��⮬ �஢����,��⠭������ �ண� ��� ���
    ignored_chars db 'abcdefghijklmnopqrstuvwxyz' ; ᯨ᮪ ������㥬�� ᨬ�����
	ignored_length dw 26
	translate_from db 'F<DUL' ;ᨬ���� ��� ������ (����� �� ����. �᪫����)
	translate_to db '�����' ;ᨬ���� �� ����� �㤥� ��� ������
	translate_length dw 5 ;����� ��ப� trasnlate_from
    old_int9h_offset dw ?
    old_int9h_segment dw ?
	
    ;���� ��ࠡ��稪
    new_int9h proc far
		; ��࠭塞 �� ॣ�����
		pusha ; push AX, BX, CX, DX
		push es
		push ds
		push cs
		pop ds
		pushf ; push flags
		
		mov bx,0
		mov dx,0	 
		
		call dword ptr cs:[old_int9h_offset]
		mov ax, 40h ;���� ����������
		mov es, ax
		mov bx, es:[1ch] ;墮�� �����
		cmp bl, 30 ;��砫� ���� ����������
		jne _continue
		mov bl, 60 ;�����
		_continue:
		sub bl, 2 ;��� ����
		mov ax, es:[bx]; ��� ᨬ��� �㤥� �஢�����
		mov dx, ax
		
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
		mov si, 0
		mov cx, translate_length ;���-�� ������㥬�� ᨬ�����
		
		_check_translate_loop:
			cmp dl, translate_from[SI]
			je _translate
			inc SI
		loop _check_translate_loop
		jmp _quit
		
		_translate:
			xor ax, ax
			mov al, translate_to[SI]
			mov es:[bx], ax	;������塞 �뢮���� ᨬ���
		
	_quit:
		;����⠭�������� �� ॣ����� � ���⭮� ���浪�
		pop ds
		pop es
		popa
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
    mov cs:old_int9h_offset, bx         ; �������� ���� ���� 09
    mov cs:old_int9h_segment, es        ; ���뢠���
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
end