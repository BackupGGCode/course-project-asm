;���஢��� �஥�� (igor)
IgorPart segment PARA
assume CS:IgorPart, DS:IgorPart
org 100h

;१����⭠� ����
_start:
	jmp _loadTSR
	old DD 0
	
	_endProgram
	_loadTSR:
		mov AH, 35h               
		mov AL, XXh					; ����祭�� ���� ��ண� ��ࠡ��稪�
		int 21h                     ; ���뢠��� �� ⠩���
		mov WORD ptr old, BX        ; ��࠭���� ᬥ饭�� ��ࠡ��稪�
		mov WORD ptr old + 2, ES    ; ��࠭���� ᥣ���� ��ࠡ��稪�
		mov AH, 25h
		mov AL, XXh					 ; ��⠭���� ���� ��襣� ��ࠡ��稪�
		;mov DX,  offset _proc        ; 㪠����� ᬥ饭�� ��襣� ��ࠡ��稪�
		int 21h                      ; �맮� DOS
		mov AX, 3100h                ; �㭪�� DOS �����襭�� १����⭮� �ணࠬ��
		mov DX, (_endProgram - _start + 10Fh) / 16 ; ��।������ ࠧ��� १����⭮�
												   ; ��� �ணࠬ�� � ��ࠣ���
		int 21h                  	; �맮� DOS
	
IgorPart ends					 	 ; ����� �������� ᥣ����
end _start							 ; ����� �ணࠬ��