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
