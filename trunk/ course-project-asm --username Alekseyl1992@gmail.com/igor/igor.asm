;���஢��� �஥�� (igor)
IgorPart segment 'code'
assume CS:IgorPart, DS:IgorPart, SS:IgorPart
org 100h


;१����⭠� ����
_start:
	jmp _loadTSR
	
	msg2	  				DB	'resident has been loaded', 13, 10, '$'
	mess_load 				DB  'Program has already loaded !!!','$'
	old_09h   				DD	0
	old_1Ch   				DD	0
	counter	  				DW	0
	isPrintingSignature		DW	0
	printDelay				equ	2 ; ����প� ��। �뢮��� "������" � ᥪ㭤��
	printPos				DW	1 ; ��������� ������ �� �࠭�. 0 - ����, 1 - 業��, 2 - ���
	
	;;;;�������� �� ᮡ�⢥��� �����. �ନ஢���� ⠡���� ���� �� ��ப� ����襩 �����.
	;;;;����� �ନ஢��� �१ ���, �� �� ᫨誮� ᨫ쭮 㢥��稢��� ��� ��ꥬ ࠡ���, ⠪ � ��ꥬ ᠬ��� ����
	signatureLine1			DB	179, '����� ��⪨�', 179, 10
	Line1_length 			equ	$-signatureLine1
	signatureLine2			DB	179, '��5-44      ',179,  10
	Line2_length 			equ	$-signatureLine2
	signatureLine3			DB	179, '��ਠ�� #0  ', 179, 10
	Line3_length 			equ	$-signatureLine3
	helpMsg					DB	10, 13, 'some help', 10, 13
	helpMsg_length			equ $-helpMsg
	errorParamMsg			DB	10, 13, 'some error on param', 10, 13
	errorParamMsg_length	equ	$-errorParamMsg
	tmpMsg					DB	10, 13, 'temp message', 10, 13
	tmpMsg_length			equ $-tmpMsg
	
	tableTop				DB	218, Line1_length-3 dup (196), 191, 10
	tableTop_length 		equ	$-tableTop
	tableBottom				DB	192, Line1_length-3 dup (196), 217, 10
	tableBottom_length 		equ $-tableBottom
	
	;=== ��ࠡ��稪 ���뢠��� int 09h ===
	new_09h proc
		push AX
		push DX
		
		pushf
		call CS:old_09h
		
		push CS
		pop DS
		
		in AL,60h
		cmp AL,3Bh
		jne _noF1
		
		mov isPrintingSignature, 1

		_noF1:
		pop DX
		pop AX
		
		iret
	new_09h endp
	
	;=== ��ࠡ��稪 ���뢠��� int 1Ch ===;
	;=== ��뢠���� ����� 55 �� ===;
	new_1Ch proc
		push AX
		push CS
		pop DS
		
		pushf
		call CS:old_1Ch
		
		cmp isPrintingSignature, 1 ;�᫨ ����� �ࠢ����� ������ (� ������ ��砥 F1)
		jne _notToPrint		
		
			cmp counter, printDelay*1000/55 + 1 ;�᫨ ���-�� "⠪⮢" �������⭮ %printDelay% ᥪ㭤��
			je _letsPrint
			
			jmp _dontPrint
			
			_letsPrint:
				mov isPrintingSignature, 0
				mov counter, 0
				call printSignature
			
			_dontPrint:
				add counter, 1
			
		_notToPrint:
		
		pop AX
		
		iret
	new_1Ch endp
	
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
	
			push CS						;
			pop ES						;㪠�뢠�� ES �� CS
			
			;�뢮� '�����誨' ⠡����
			lea BP, CS:tableTop			;����頥� � BP 㪠��⥫� �� �뢮����� ��ப�
			mov CX, tableTop_length		;� CX - ����� ��ப�
			mov BL, 0111b 				;梥� �뢮������ ⥪�� ref: http://en.wikipedia.org/wiki/BIOS_color_attributes
			mov AX, 1301h				;AH=13h - ����� �-��, AL=01h - ����� ��६�頥��� �� �뢮�� ������� �� ᨬ����� ��ப�
			int 10h
			
			;�뢮� ��ࢮ� �����
			lea BP, CS:signatureLine1
			mov CX, Line1_length
			mov BL, 0111b
			sub DL, tableTop_length-1	;ᬥ頥� ��砫� ����� �� "�㦭��"
			mov AX, 1301h
			int 10h
			
			;�뢮� ��ன �����
			lea BP, CS:signatureLine2
			mov CX, Line2_length
			mov BL, 0111b
			sub DL, Line1_length-1		;ᬥ頥� ��砫� ����� �� "�㦭��"
			mov AX, 1301h
			int 10h
			
			;�뢮� ���쥩 �����
			lea BP, CS:signatureLine3
			mov CX, Line3_length
			mov BL, 0111b
			sub DL, Line2_length-1
			mov AX, 1301h
			int 10h
			
			;�뢮� '����' ⠡����
			lea BP, CS:tableBottom
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
	
	
	showHelp proc
		push CS
		pop ES
		mov SI, 80h   				;SI=ᬥ饭�� ��������� ��ப�.
		lodsb        					;����稬 ���-�� ᨬ�����.
		or AL, AL     				;�᫨ 0 ᨬ����� �������, 
		jz Got_cmd   					;� �� � ���浪�. 
		cmp AL, 3     				;���� ����� �� 3 ᨬ����? (�஡�� + /X)
		jne No_string 				;�� - �� ���� No_string 

		inc SI       					;������ SI 㪠�뢠�� �� ���� ᨬ��� ��ப�.

		Next_char:
			lodsw       				;����砥� ��� ᨬ����
			cmp AX, '?/' 				;�� '/?' ? ����� ���� �������!
			je _question 				;�� - �� ��室... 
			cmp AX, 'u/'
			je _finishTSR
			
			jmp No_string
			;mov AL, 1    			;������ ⮣�,  �� ��� 㤠���� �ணࠬ�� �� �����
			ret

		Got_cmd:
			xor AL, AL 				;������ ⮣�, �� ��祣� �� ����� � ��������� ��ப�
			ret  					;��室�� �� ��楤���

		No_string:
			mov AL, 3 				;������ ����୮�� ����� ��������� ��ப�
			ret
	   
		_question:
			; �뢮� ��ப� �����
				mov AH,03
				int 10h	
				lea BP, CS:helpMsg
				mov CX, helpMsg_length
				mov BL, 0111b
				mov AX, 1301h
				int 10h
			; ����� �뢮�� ��ப� �����
			jmp Next_char
		
		_finishTSR:
			; do something smart
			; �뢮� ��ப�
				mov AH,03
				int 10h	
				lea BP, CS:tmpMsg
				mov CX, tmpMsg_length
				mov BL, 0111b
				mov AX, 1301h
				int 10h
			; ����� �뢮�� ��ப�
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
	showHelp endp

		
	_loadTSR:
		;---------------�஢�ઠ ����㧪� �ணࠬ�� � ��--
		mov AX, 0FF00h      
		int 2Fh
		cmp AL, 0AAh
		je already_load             

		;---------------��⠭���� ⥪�⮢��� ०���-------
		mov AH,03
		int 10h	
		
		mov AH,00h
		mov AL,83h
		int 10h
		
		mov AH,02
		int 10h	
		
		call showHelp
		
		;===== int 09h loading =====;
		mov AX, 3509h
		int 21h
		mov WORD ptr CS:old_09h, BX
		mov WORD ptr CS:old_09h + 2, ES
		mov AX, 2509h
		lea DX, new_09h
		int 21h
		
		;===== int 1Ch loading =====;
		mov AX, 351Ch
		int 21h
		mov WORD ptr CS:old_1Ch, BX
		mov WORD ptr CS:old_1Ch + 2, ES
		mov AX, 251Ch
		lea DX, new_1Ch
		int 21h
		
		;===== Terminate and stay resident =====;	
		mov AH, 09h
		mov DX, offset msg2
		int 21h
		
		mov DX, (_loadTSR - _start + 10Fh) / 16
		mov AX, 3100h
		int 21h
		jmp _exit
		
		already_load:                            
			mov AH, 09h
			mov DX, offset mess_load     
			int 21h
		
		_exit:
			mov AX, 4C00h
			int 21h
	

IgorPart ends					 	 ; ����� �������� ᥣ����
end _start							 ; ����� �ணࠬ��