;���஢��� �஥�� (ky4er)

;;;;;; OFFTOPIC
; ��-⠪� �⠭����� ���� 8x16... my bad
; ���� ������ ���䨪��� keyrus (���檨�)
; ����� � ����� ���짮�����
; ��� ���������, �� �� ᮢᥬ ���४⭮ ࠡ�⠥� �
; ⠡��楩 ᨬ����� (�� ��� � ��ࠪ, �)
; � ��饬 � ���䨪��஬ rkm (ᯠᨡ� �.�.)
; �� ࠡ�⠥� ���
;;;;;; OFFTOPIC

code segment 'code'
assume CS:code, DS:code, ES:code

org 100h

start:
	push CS
	pop DS
	push CS
	pop ES

	not cursiveEnabled
	call setCursive

; > ������ ��� ��������!!!!
	not cursiveEnabled
; > ���� ������ �� ������	
	mov ah, 07h
	int 21h
; > ��ॢ�� ���⭮
	call setCursive
; > END

; ��室
	mov AX, 4c00h
	int 21h

setCursive proc
	cmp cursiveEnabled, true
	jne _restoreSymbol
; �᫨ 䫠� ࠢ�� true, �믮��塞 ������ ᨬ���� �� ���ᨢ�� ��ਠ��,
; �।���⥫쭮 ��࠭�� ���� ᨬ��� � savedSymbol
	
	call saveFont
	mov CL, charToCursiveIndex
_shifTtable:
; �� ����砥� � bp ⠡���� ��� ᨬ�����. ���� 㪠�뢠�� �� ᨬ��� 0
; ���⮬� ��� ᮢ����� ᤢ�� 16*X - ��� X - ��� ᨬ����
	add bp, 16
	loop _shiftTable
	
; �p� savefont ᬥ頥��� p�����p ES
; ���⮬y �p�室���� ������ ⠪�� ��娭�樨, �⮡� 
; ������� ���y祭�� ����� �㤠, �㤠 ��� �㦭� (� stored_symbol)
;
; ��� ��������, ����� ���譥� ᤥ����, �� � �� �ࠡ =(
;
	push DS
	pop AX
	push ES
	pop DS
	push AX
	pop ES
	push AX
;	
	mov SI, BP
	lea DI, savedSymbol
; ��p��塞 � ��p�����y� stored_symbol
; ⠡���y �y����� ᨬ����
	mov CX, 16
; ��� ᥡ�
; movsb �� DS:si � ES:di
	rep movsb
; ��室�� ����樨 ᥣ���⮢ ����p�饭�	
	pop DS	
;>!!!

; ������� ����ᠭ�� ᨬ���� �� �ypᨢ
	mov CX, 1
	mov DH, 0
	mov DL, charToCursiveIndex
	lea BP, cursiveSymbol
	call changeFont
	jmp _exitSetCursive
	
_restoreSymbol:	
; �᫨ 䫠� ࠢ�� 0, �믮��塞 ������ ���ᨢ���� ᨬ���� �� ���� ��ਠ��

	mov CX, 1
	mov DH, 0
	mov DL, charToCursiveIndex
	lea bp, savedSymbol
	call changeFont
	
_exitSetCursive:
	ret
setCursive endp	
	
	
; *** �室�� �����
; dl = ����� ᨬ���� ��� ������
; CX = ���-�� ᨬ����� �����塞�� ����ࠦ���� ᨬ�����
; (��稭�� � ᨬ���� 㪠������� � DX)
; ES:bp = ���� ⠡����
;
; *** ���ᠭ�� ࠡ��� ��楤���
; �ந�室�� �맮� int 10h (������ࢨ�)
; � �㭪樥� AH = 11h (�㭪樨 ������������)
; ��ࠬ��� AL = 0 ᮮ�頥�, �� �㤥� �������� ����ࠦ����
; ᨬ���� ��� ⥪�饣� ����
; � �����, ����� AL = 1 ��� 2, �㤥� �������� ����ࠦ����
; ⮫쪮 ��� ��।������� ���� (8x14 � 8x8 ᮮ⢥��⢥���)
; ��ࠬ��� BH = 0Eh ᮮ�頥�, �� �� ��।����� ������� ����ࠦ���� ᨬ����
; ��室���� �� 14 ���� (०�� 8x14 ��� ��� ࠧ 14 ����)
; ��ࠬ��� BL = 0 - ���� ���� ��� ����㧪� (�� 0 �� 4)
; ??? �� ᮢᥬ ���� ���� ������� ��ࠬ���
;
; *** १����
; ����ࠦ���� 㪠�������(��) ᨬ����(��) �㤥� ��������
; �� �।�������� ���짮��⥫��.
; ��������� �����࣭���� �� ᨬ����, ��室�騥�� �� �࠭�,
; � ���� �᫨ ����ࠦ���� ��������, ���� ��ਠ�� ����� 㦥 �� �����

changeFont proc
	push AX
	push BX
	mov AX, 1100h
	mov BX, 1000h
	int 10h
	pop AX
	pop BX
	ret
changeFont endp

; *** �室�� �����
; bh - ⨯ �����頥��� ᨬ���쭮� ⠡����
;   0 - ⠡��� �� int 1fh
;   1 - ⠡��� �� int 44h
;   2-5 - ⠡��� �� 8x14, 8x8, 8x8 (top), 9x14
;   6 - 8x16
;;;; OFFTOP
; �� ���� ������
; ����� �� ����ᠭ� , �� 8x16 - �� bh=6
; ��襫 ⮫쪮 ��� http://www.htl-steyr.ac.at/~morg/pcinfo/hardware/interrupts/inte6rg0.htm
; ����� ��ࠧ��, � �� ����.
; �᫨ ������ ��� �� ���ଠ�� ���-���� �� ��� ᠩ�
; � ����� � �� 㬥� �㣫���, �������
;;;; OFFTOP
;
; *** ���ᠭ�� ࠡ��� ��楤���
; �ந�室�� �맮� int 10h (������ࢨ�)
; � �㭪樥� AH = 11h (�㭪樨 ������������)
; ��ࠬ��� AL = 30 - ����㭪�� ����祭�� ���ଠ樨 � EGA
; �� bl ��祣� �� ����ᠭ�, �� ���� �������
; � ���� �த� ��������, ����� � bl �뫨 ࠭����� ���祭��
; �� �� �� 100% ���
;
; *** १����
; � ES:bp ��室���� ⠡��� ᨬ����� (������)
; � CX ��室���� ���� �� ᨬ���
; � dl ������⢮ �࠭��� ��ப
; �����! �ந�室�� ᤢ�� ॣ���� ES
; ( ES �⠭������ ࠢ�� C000h )

saveFont proc
	push AX
	push BX
	mov AX, 1130h
	mov BX, 0600h
	int 10h
	pop AX
	pop BX
	ret
saveFont endp

; �� ���孥� ��ப�, �� ������
cursiveSymbol DB 00000000b
       DB 00000000b
       DB 00000000b
       DB 00111110b
       DB 00111111b
       DB 00110011b
       DB 01100110b
       DB 01100110b
       DB 01111100b
       DB 11000110b
       DB 11000110b
       DB 11000110b
       DB 11111100b
       DB 00000000b
       DB 00000000b
       DB 00000000b
	
; ᨬ��� ��� ������	
charToCursiveIndex DB '�'
; ��६����� ��� �࠭���� ��ண� ᨬ����
savedSymbol DB 16 dup(0ffh)
cursiveEnabled DB 0
true 						equ	0ffh							; ����⠭� ��⨭����

code enDS
end start