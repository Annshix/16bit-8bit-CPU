LOOP:
w0:
	BNPB W0
	MOV A0,#1AH
	ST A0,8002H
W1:
	BNPB W1
	MOV a0,#AH
	ST a0, 8002H
W2:
	BNPB W2
	ST a0, 8002H

; ‰»Î
L01:
	BNKB L01
	LD a0, 8001H
	ST a0, 6001H

L00:
	BNKB L00
	LD a0, 8001H
	ST a0, 6000H

L11:
	BNKB L11
	LD a0, 8001H
	ST a0, 6003H

L10:
	BNKB L10
	LD a0, 8001H
	ST a0, 6002H

ADD1:
	LD a0, 6000H
	LD a1, 6002H
	MOV a2,#0
	ADD a0,a1
	MOV a1,#9H
	SUB a1, a0
	JC JW1
	JMP ADD2

JW1:
	MOV a1,#0AH
	SUB a0, a1
	
	MOV a2, #1

ADD2:
	ST a0, 6010H
	LD a0, 6001H
	LD a1, 6003H
	MOV a3, #0
	ADD a0,a1
	MOV a1,#9H
	SUB a1,a0
	JC JW2
	JMP ADD3
JW2:
	MOV a1,#AH
	SUB a0, a1
	ST a0, 6011H
	MOV a3, #1

ADD3:
	ST a0, 6011H
	LD a0, 6011H
	ADD a0, a2
	MOV a1,#9H
	SUB a1, a0	
	JC JW3
	JMP OUT
JW3:
	MOV a1,#AH
	SUB a0, a1
	ST a0, 6011H
	MOV a3, #1

OUT:
	ST a0, 6011H
	ST a3, 6012H


; ‰≥ˆprint
N00:
	BNPB N00
	LD a0, 6000H
	ST a0, 8002H

N01:
	BNPB N01
	LD a0, 6001H
	MOV a1, #10H
	ADD a0, a1
	ST a0, 8002H

W10:
	BNPB W10
	MOV a0,#0H
	ST a0, 8002H

W11:
	BNPB W11
	MOV a0,#AH
	ST a0, 8002H

N10:
	BNPB N10
	LD a0, 6002H
	ST a0, 8002H

N11:
	BNPB N11
	LD a0, 6003H
	MOV a1, #10H
	ADD a0, a1
	ST a0, 8002H

W20:
	BNPB W20
	MOV a0,#AH
	ST a0, 8002H
W21:
	BNPB W21
	ST a0, 8002H

G0:
	BNPB G0
	ST a0, 8002H
G1:
	BNPB G1
	ST a0, 8002H

G2:
	BNPB G2
	ST a0, 8002H
G3:
	BNPB G3
	ST a0, 8002H
G4:
	BNPB G4
	MOV a1, #10H
	ADD a0,a1
	ST a0, 8002H

W30:
	BNPB W30
	MOV a0,#AH
	ST a0, 8002H
W31:
	BNPB W31
	ST a0, 8002H

O1:
	BNPB O1
	LD a0, 6010H
	ST a0, 8002H
O2:
	BNPB O2
	LD a0, 6011H
	ST a0, 8002H
O3:
	BNPB O3
	LD a0, 6012H
	MOV a1, #10H
	ADD a0,a1
	ST a0, 8002H	

	
jmp LOOP