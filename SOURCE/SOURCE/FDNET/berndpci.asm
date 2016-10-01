; This is public domain software by Eric Auer 2007

; --------------

	cpu 8086
	org 100h

start:	mov ax,0b101h
	xor di,di
	int 1ah		; PCI BIOS install check, modifies e{a,b,c,d}x, edi
	cmp ah,0	; ... we ignore prot. mode entry point EDI ...
	jnz nopci
	cmp dx,4350h	; edx: 20494350h cl is now highest bus number
	jnz nopci
	test al,1	; config mechanism 1 okay?
	jnz okpci

	mov dx,oldpcimsg
giveup:	mov ah,9
	int 21h
	jmp helpme


nopci:	mov dx,nopcimsg
	jmp short giveup

; --------------

	cpu 386

okpci:	cld		; we know we have PCI, so we have 386+
	mov si,81h	; command line arguments
	xor ebx,ebx
	xor cx,cx
skipcl:	lodsb
	cmp al,'a'
	jb nolow
	cmp al,'z'
	ja nolow
	sub al,'a'-'A'	; toupper
nolow:	or al,al
	jz endcl
	cmp al,13	; cr
	jz endcl
	cmp al,' '
	jz skipcl
	cmp al,'/'
	jz skipcl
	cmp al,'-'
	jz skipcl
	cmp al,9	; tab
	jz skipcl
	sub al,'0'
	jc helpme
	cmp al,9
	jbe digit
	sub al,('A'-'0')-10	; turn 'A' into 10
	cmp al,15
	ja helpme
digit:	movzx eax,al
	shl ebx,4	; earlier digits are higher
	or ebx,eax	; insert hex digit
	inc cx		; digit count
	jmp short skipcl
endcl:	cmp cx,8	; need exactly 8 digits (whitespace ignored)
	jz scanit

helpme:	mov dx,helpmsg
	mov ah,9
	int 21h
	mov ax,4cffh
	int 21h

scanit:	mov cx,bx	; device
	shr ebx,16
	mov dx,bx	; vendor
	xor si,si	; first match
scan2:	mov ax,0b102h	; find device
	push cx
	push dx
	int 1ah
	pop dx
	pop cx
	jc nomore
	cmp ah,0
	jnz nomore
	; found device is at bus BH, dev/func BL (5+3 bits)
	inc si		; search for next match
	jmp short scan2

nomore:	mov ax,si	; device count
        aam             ; AH is 10 digit, AL is 1 digit
        add ax,'00'
        cmp ah,'0'
        jnz twodig
        mov ah,' '
twodig: xchg al,ah
        mov [devcntmsg],ax
        mov ah,9
        mov dx,devcntmsg
        int 21h
	mov ax,si	; device count
	mov ah,4ch	; exit
	int 21h		; done :-)

helpmsg		db "BerndPCI, the simple PCI device counter",13,10
		db "A Public Domain tool by Eric Auer 2007",13,10,13,10
		db "Usage: BERNDPCI abcd1234",13,10,13,10
		db "Returns the count of PCI devices which",13,10
		db "have vendor ID abcd and device ID 1234",13,10
		db "as errorlevel (or 255 on error)",13,10,"$"
oldpcimsg	db "PCI BIOS mechanism 1 required",13,10,"$"
nopcimsg	db "PCI BIOS required",13,10,"$"
devcntmsg	db "?? match(es) found",13,10,"$"

