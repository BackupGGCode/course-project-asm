;ॠ������ ���㯮�ॡ�⥫쭮�� �㭪樮����, �㭪樨 ⨯� writeln � ������

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ������
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;�맮� �㭪樨 fun � ��㬥�⮬ arg
run macro fun, arg
	push BX
		push arg
		call fun
		pop BX
	pop BX
endm

;�맮� �㭪樨 fun � ��㬥�⮬-���ᮬ arg (��� ��ப��� �㭪権)
runs macro fun, arg
	push BX
		push offset arg
		call fun
		pop BX
	pop BX
endm

;�뢮� ��ப� �� ����� arg
write macro arg
	push BX
		push offset arg
		call print
		pop BX
	pop BX
endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; �㭪樨
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;�뢮� ��ப�
print proc c uses AX DX, string:word
	mov		AH, 09h
	mov		DX, [string]
	int		21h
	ret
print endp	

;�뢮� ᨬ����
putch proc c uses AX DX, char:byte		
	mov		AH, 02h
	mov		DL, [char]
	int		21h		
	ret
putch endp

;���⪠ ��࠭�
cls proc c uses AX DX
	;clear
	mov    AH, 00h
	mov    AL, 02h
	int    10H       
	
	;place cursor
	mov    AH, 02h
	mov    DX, 00h ;at 0,0
	int    10h
	ret
cls endp

;��ॢ�� ��ப�
clrf proc c uses AX DX
	mov		AH, 02h
	mov		DL, 13
	int		21h
	mov		DL, 10
	int		21h
	ret
clrf endp

;���� ᨬ����
getch proc
	mov     AH, 01h
	int     21h
	xor 	AH, AH
	ret
getch endp