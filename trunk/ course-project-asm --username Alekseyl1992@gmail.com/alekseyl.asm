;���஢��� �஥�� (Alekseyl)

;   === ��砫� �ணࠬ��: ===
cseg segment
assume CS:cseg,  DS:cseg,  SS:cseg,  ES:cseg
org 100h

_begin:
    jmp _init ; �� ���� ���樠����樨


; === ��ࠡ��稪 21h-��� ���뢠��� ===
int_21h_proc proc
; ---
	cmp AX,  9988h  ;�஢�ઠ �� ������� ����㧪�?
    jne _skip_test
    xchg AH,  AL    ;���� ��� "�⪫��".
    iret          ;� �����⠫쭮 ��室�� �� ���뢠���...

; ---
_skip_test:
    cmp AX,  9999h  ;����砥� ���ଠ�� � ��襬 १�����?
    jne _work
    mov AX,  9998h  ;���� �⪫�� �...

    push CS       ;...��।��� � ES ᥣ���� १�����...
    pop ES
    mov DX,  offset int_21h_proc ;...� DX ᬥ饭��...

;...BX - ᬥ饭�� �ਣ����쭮�� ��ࠡ��稪�...
    mov BX,  word ptr CS:[int_21h_vect]
;...CX - ᥣ���� �ਣ����쭮�� ��ࠡ��稪�...
    mov CX,  word ptr CS:[int_21h_vect+2]
    iret ;...� ��室�� �� १�����.

; ---
_work:
;������ int 21h(AH=2),  �뢮� Z,  ����� A
    cmp AH, 02h
    jne _call_original
    cmp DL, 'a'
    jne _call_original

    mov DL, 'Z'

_call_original:
;��।��� �ࠢ����� �।��饬� (�ਣ����쭮��) ��ࠡ��稪�

    jmp dword ptr CS:[int_21h_vect]

	int_21h_vect dd ?
int_21h_proc endp




;   === ���樠������ (�����⮢�� � ����ன�� १�����) ===
_init:
       mov ES,  word ptr CS:[2Ch] ;����稬 ᥣ���� ���㦥��� DOS.
       mov AH,  49h               ;�㭪�� �᢮�������� �����.
       int 21h                  ;�᢮������� ������...

       call Get_cmd  ;�஢�ਬ ��������� ��ப�

;�⠪, 
;�᫨ ��祣� � ��������� ��ப� �� �������,  ⮣�� �஡㥬 ��⠭����� १�����.
       or AL, AL
       jz Ok_cmd  ;

;�᫨ � ��������� ��ப� ������� '/u',  � �஡㥬 㤠���� �ணࠬ�� �� �����.
       cmp AL, 1
       je Remove  ;

;� ��⨢��� ��砥 �뢥��� ᮮ�饭�� � ����୮� ��������� ��ப�
;� �����訬��...
Bad_cmd:
       mov DX, offset Mess_badcmd
       call Out_mess
       ret


;�� ��楤��� 㤠����� �ணࠬ�� �� �����...
Remove:
       jmp Remove_prog   ;


;��⠭�������� १�����.
Ok_cmd:
       mov AX, 9988h ;�஢�ઠ �� ������� ����㧪�.
       int 21h
       cmp AX, 8899h ;����稫� ��� �⪫��?
       jne Next_step2  ;���. �����

;�� 㦥 � �����! �뢥��� ᮮ⢥�������� ��ப�.
       mov DX, offset Mess_memory
       call Out_mess   ;������ᠫ쭠� ��楤�� �뢮�� ��ப�.
       ret   ;�멤�� � DOS...

Next_step2:
; === 21h ===
;�� ��⮢� ��� ���墠� ���뢠��� � ��⠭���� १�����.

       mov AX, 3521h
       int 21h ;����稬 � ��࠭�� ���� (�����) 21h ���뢠���
       mov word ptr CS:[int_21h_vect], BX ;���饭��...
       mov word ptr CS:[int_21h_vect+2], ES ;�������...

       mov AX, 2521h
       mov DX, offset int_21h_proc
       int 21h  ;"����ᨬ" ���� ��楤��� �� 21h ���뢠���

;�뢥��� ᮮ�饭��,  ��,  ���,  �� � ���浪�!!! �ணࠬ�� ����㦥�� � ������!
       mov DX, offset Mess_hello
       call Out_mess

;��⠢�塞 १������� ���� � ����� � ��室�� � DOS.
       mov DX, offset _init
       int 27h


; ======= ��諨 ����ணࠬ�� =======

; --- ����稬 ��ࠬ���� � ��������� ��ப� ---
Get_cmd proc
       mov SI, 80h   ;SI=ᬥ饭�� ��������� ��ப�.
       lodsb        ;����稬 ���-�� ᨬ�����.
       or AL, AL     ;�᫨ 0 ᨬ����� �������, 
       jz Got_cmd   ;� �� � ���浪�. 
       cmp AL, 3     ;���� ����� �� 3 ᨬ����? (�஡�� + /u)
       jne No_string ;�� - �� ���� No_string 

       inc SI       ;������ SI 㪠�뢠�� �� ���� ᨬ��� ��ப�.

Next_char:
       loDSw       ;����砥� ��� ᨬ����
       cmp AX, 'u/' ;�� /u? ������,  �� ����� ���� �������!!!
       jne No_string ;�� - �� ��室... 

       mov AL, 1    ;������ ⮣�,  �� ��� 㤠���� �ணࠬ�� �� �����
       ret

Got_cmd:
       xor AL, AL ;������ ⮣�,  �� ��祣� �� ����� � ��������� ��ப�
       ret  ;��室�� �� ��楤���

No_string:
       mov AL, 3 ;������ ����୮�� ����� ��������� ��ப�
       ret  ;��室�� �� ��楤���
Get_cmd endp


; === ����塞 �ணࠬ�� �� ����� ===
Remove_prog:
;�०�� ���뫠�� ᨣ��� 21h-��� ���뢠���,  �.�. 9999h.
       mov AX, 9999h
       int 21h

;�᫨ � �⢥� ����砥� 9998h,  � ��� १����� "ᨤ��" � �����.
       cmp AX, 9998h
       je In_mem     ;��३��� �� ᮮ⢥�������� ����.

;�᫨ �� �� ����稫� �⪫�� (9998h),  � ��� १����� �� ����㦥�.
;����騬 �� �⮬ ���짮��⥫� � �멤�� � DOS.
       mov DX, offset Mess_badmem
       call Out_mess
       ret


;�⠪,  ��� १����� ᨤ�� � �����.

;������ �⪫��� �� ��襣� १����� �� ⠪�� ����砥� (�. ��楤���
;��ࠡ��� ���뢠��� 21h ���):
;* ES = ᥣ����,  � ����� ����㧨��� १�����;
;* DX = ᬥ饭�� १����� � ������ ᥣ����;
;* CX = ᥣ���� �ਭ����쭮�� (�०����) ��ࠡ��稪� ���뢠��� 21h;
;* BX = ᬥ饭�� �ਭ����쭮�� (�०����) ��ࠡ��稪� ���뢠��� 21h.

In_mem:
       push ES    ;���࠭�� ������� ॣ����� � �⥪�, ..
       push BX

       mov Seg_21h, ES ;...� ⠪�� � ��६�����.
       mov Off_21h, DX

       push BX
       push CX

       mov AX, 3521h
       int 21h     ;����稬 ���� ��ࠡ��稪� 21h-���뢠���.

;����� �� �� ⮬�,  �㤠 ����㦥� ��� ��ࠡ��稪?
;�᫨ ⠪,  � ���� �� "�����" ��� ����. �.�. ����� ᬥ�� 㤠���� ����
;�ணࠬ�� �� �����.
       mov AX, ES
       cmp AX, Seg_21h
       jne Cannot_remove

       cmp BX, Off_21h
       jne Cannot_remove

;��� � 㤠�塞. �����⥫쭮 ��᫥���,  �� �� ����㦠�� � ॣ�����!
       cli
       mov AX, 2521h
       pop DS
       pop DX
       int 21h

       push CS
       pop DS

       mov AH, 49h
       int 21h
       sti

;�ணࠬ�� 㤠����! �뢥��� ᮮ�饭�� �� �ᯥ譮� 㤠����� � ��୥��� � DOS.
       mov DX, offset Remove_okmess

Exit_prog:
       call Out_mess
       int 20h


;���������� 㤠���� �ணࠬ��,  �.�. ��-� "�����" ��� ����.
Cannot_remove:
;����騬 � ��稢襩�� ���� ���짮��⥫� � �멤�� � DOS...
       mov DX, offset Mess_cantremove
       jmp short Exit_prog

Seg_21h dw ?
Off_21h dw ?


; === �뢮� ��ப� �� �࠭ ===
Out_mess proc
       mov AH, 9 ;�뢮��� ��ப�. DX 㦥 ������ ᮤ�ঠ�� �� ����!
       int 21h

       mov AH, 9 ;�뢮��� ᮮ�饭�� ⨯� "������ ���� �������".
       mov DX, offset Any_key
       int 21h

       xor AH, AH ;���� ������ �� �������...
       int 16h

       ret
Out_mess endp


;  === ����饭�� ===
Mess_hello db '�������� ����㦥�!',  13,  10,  '$'

Mess_memory db 13, 10, '�ணࠬ�� 㦥 ����㦥�� � ������!', 13, 10
            db '��� �� 㤠����� �� ����� 㪠��� /u � ��������� ��ப�!', 13, 10, '$'

Mess_badcmd db 13, 10, '����୮ 㪠��� ��ࠬ��� � ��������� ��ப�!!!', 13, 10
            db '������ /u,  �᫨ ��� 㤠���� �ணࠬ�� �� �����!', 13, 10, '$'

Mess_badmem db 13, 10, '��... �ணࠬ�� ���� ��� � �����!!! ��� � ���� �� 㤠����???', 13, 10, '$'

Remove_okmess db 13, 10, '�ணࠬ�� �ᯥ譮 㤠���� �� �����!!! ��!!!', 13, 10, '$'

Mess_cantremove db 13, 10, '�� ���� 㤠���� १����� �� �����!!!', 13, 10, 13
                db '���� � ⮬,  �� �����-� �ணࠬ�� ���墠⨫� 21h-�� ���뢠��� ��᫥ ⮣�, ', 13, 10
                db '��� ����㦥� �� RESID27.COM. �०�� ����室��� 㤠���� �� �� �����, ', 13, 10
                db '� ��⮬ 㦥 㤠���� RESID27.COM!', 13, 10, '$'

Any_key db 13, '��� �த������� ������ ���� �������...$'

cseg ends
end _begin