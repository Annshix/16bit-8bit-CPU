library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL

-------------------------------
-------------------------------

entity cpu is
	Port(
		DB: inout std_logic_vector(7 downto 0); 	---数据总线
		AB: buffer std_logic_vector(15 downto 0);	---地址总线
		CI: buffer std_logic_vector(31 downto 0);	
		CO: in std_logic_vector(31 downto 0);

		CLK, RESET, RUN:			in std_logic;
		MWR, MRD, IOR, IOW, MCLK:	buffer std_logic;

		CTRL1, CTRL2, CTRL3, CTRL4:	buffer std_logic;
		MUX:						in std_logic_vector(2 downto 0);
		PRIX, KRIX:					in std_logic
		);
	end cpu;

-------------------------------
-------------------------------

architecture cpu_behave of cpu is

---MEM
	signal CWR, CRD:					std_logic;  ---读写控制脉冲
	signal CWRX, CRDX:					std_logic;

---ACC
	signal GA, CA:						std_logic;
	signal A:							std_logic_vector(7 downto 0);

---ACT
	signal ACT:							std_logic_vector(7 downto 0);
	signal GC, CC:						std_logic;

---TMP
	signal TMP:							std_logic_vector(7 downto 0);
	signal GT, CT:						std_logic;

---CTMP
	SIGNAL CYT, CPT, COT:				STD_LOGIC;

---Ai
	signal A3, A2, A1, A0, AOUT:		std_logic_vector(3 downto 0);
	signal WRE, WRC, RDE:				std_logic;
	signal AS:							std_logic_vector(1 downto 0);

---多路选择器

---MUXB
	SIGNAL OB:							STD_LOGIC;
	SIGNAL MUXB:						STD_LOGIC_VECTOR(1 DOWNTO 0);

---MUXC
	SIGNAL MUXC:						STD_LOGIC_VECTOR(1 DOWNTO 0);

---MUXD
	SIGNAL PLD:							STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL PCADD:						STD_LOGIC;

---ALU
	SIGNAL FA, FB, FF:					STD_LOGIC_VECTOR(8 DOWNTO 0);
	SIGNAL S:							STD_LOGIC_VECTOR(2 DOWNTO 0);

---CY
	SIGNAL CY, CP:						STD_LOGIC;

---PC
	SIGNAL PC:							STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL PCK:							STD_LOGIC;
	SIGNAL PINC, PRST:					STD_LOGIC;
	SIGNAL ADR:							STD_LOGIC_VECTOR(15 DOWNTO 0);	---	全地址

---IR
	SIGNAL IR:							STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL CCI, GI:						STD_LOGIC;

---ADRH
	SIGNAL ADRH:						STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL GA1, CA1, AHS:				STD_LOGIC;

---ADRL
	SIGNAL ADRL:						STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL GA2,CA2:						STD_LOGIC;

---MPC
	SIGNAL MPC,MD:						STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL MCLR, MPLD:					STD_LOGIC;
	SIGNAL MPCK:						STD_LOGIC;

---SP
	SIGNAL SP:							STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL SSP:							STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL SCK:							STD_LOGIC;

---MIR
	SIGNAL MIR:							STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL MICK:						STD_LOGIC;

---PRINT & KEY
	SIGNAL KOUT, POUT:					STD_LOGIC;


------------------------------------
------------------------------------
BEGIN
-----CLOCK & RESET
	PMCLK:
	PROCESS(MCLK, CLK, RESET, RUN)
	BEGIN
	IF(RUN = '0') OR (RESET = '0') THEN MCLK <= '0';
		ELSIF(CLK'EVENT AND CLK ='0') THEN MCLK <= NOT MCLK;
	END IF;
	END PROCESS PMCLK;

	MCLK	<= NOT MCLK AND CLK;
	MICK	<= NOT MPCK;

	WRC		<= MCLK;
	PCK 	<= MCLK;
	CA 		<= MCLK;
	CCTK	<= MCLK;
	CT 		<= MCLK;
	CC 		<= MCLK;
	CCI 	<= MCLK;
	CA1		<= MCLK;
	CA2 	<= MCLK;
	CCK 	<= MCLK;
	SCK		<= MCLK;


	PRST 	<= RESET;

	PMCLR:
	PROCESS(MCLK, RESET)
	BEGIN
		IF(RESET = '0') THEN MCLR <= '0';
			ELSIF(MCLK'EVENT AND MCLK = '1') THEN MCLR <= RUN;
		END IF;
	END PROCESS PMCLR;

	CWR 	<= CWRX OR NOT MCLK;
	CRD 	<= CRDX OR NOT MCLK;

	MRD 	<= CRD OR AB(15);
	MWR 	<= CWR OR AB(15) OR NOT CLK;
	IOW 	<= NOT AB(15) OR NOT AB(1) OR CWR OR NOT CLK;
	IOR 	<= NOT AB(15) OR NOT AB(0) OR CRD;

---------------------------FUNCTION--------------------------
-------------------------------------------------------------


---MPC
	PMPC:
	PROCESS(MPLD, MPCK, MCLR)
	BEGIN
		IF(MCLR = '0') THEN 
			MPC <= "0000000000";
		ELSIF(MPCK'EVENT AND MPCK = '1') THEN
			IF(MPLD = '0') THEN
				MPC <= MD;
			ELSE MPC <= MPC + 1;
			END IF;
		END IF;
	END PROCESS PMPC;

	CI(9 DOWNTO 0) <= MPC;

	MD(0) 			<= '1';
	MD(1) 			<= '1';
	MD(2) 			<= '1';
	MD(7 DOWNTO 3)	<= IR(7 DOWNTO 3);
	MD(9 DOWNTO 8)	<= "00";

---MIR
	PMIR:
	PROCESS(MICK)
	BEGIN
		IF(MICK'EVENT AND MICK = '1') THEN
			MIR <= CO;
		END IF;
	END PROCESS PMIR;

-----------------------------------
-----------------------------------
	GCT 			<=MIR(29);
	CRDX			<=MIR(28);
	CWRX			<=MIR(27);
	S(2)			<=MIR(26);
	S(1)			<=MIR(25);
	S(0)			<=MIR(24);
	COT				<=MIR(23);
	CP 				<=MIR(22);
	SSP(1)			<=MIR(21);
	SSP(0)			<=MIR(20);
	MPLD			<=MIR(19);
	PRST			<=MIR(18);
	PINC			<=MIR(17);
	PLD(2)			<=MIR(16);
	PLD(1)			<=MIR(15);
	PLD(0)			<=MIR(14);
	MXC(1)			<=MIR(13);
	MXC(0)			<=MIR(12);
	MXB(1)			<=MIR(11);
	MXB(0)			<=MIR(10);
	GA 				<=MIR(9);
	OB				<=MIR(8);
	AHS				<=MIR(7);
	GA2				<=MIR(6);
	GA1				<=MIR(5);
	GI				<=MIR(4);
	GT 				<=MIR(3);
	GC 				<=MIR(2);
	RDE 			<=MIR(1);
	WRE 			<=MIR(0);

---Ai
	AS(1 DOWNTO O)	<= IR(1 DOWNTO 0);

	PAI:
	PROCESS(WRE, WRC, AS):
	BEGIN
		IF(WRC'EVENT AND WRC = '0') THEN
			IF(WRE = '0') THEN
				CASE AS is
					WHEN "00" => A0 <= DB;
					WHEN "01" => A1 <= DB;
					WHEN "10" => A2 <= DB;
					WHEN "11" => A3 <= DB;
					WHEN OTHERS => NULL;
				END CASE;
			END IF;
		END IF;
	END PROCESS PRI;

	AOUT	<= A0 WHEN AS = "00" ELSE
			   A1 WHEN AS = "01" ELSE
			   A2 WHEN AS = "10" ELSE
			   A3;

---PMUXB
	PMUXB:
	PROCESS(OB, MXB)
	BEGIN
		IF(OB = '0') THEN
			CASE MXB is
		 		WHEN "00" => DB <= A(7 DOWNTO 0);
		 		WHEN "01" => DB <= PC(15 DOWNTO 8);
		 		WHEN "10" => DB <= PC(7 DOWNTO 0);
		 		WHEN OTHERS => DB <= AOUT;
		 	END CASE;
		ELSE
			DB <= "ZZZZZZZZ"
		END IF;
	END PROCESS PMUXB;

---MUXC
	AB <= PC 		WHEN MXC = "00" ELSE
		  ADRH&ADRL WHEN MXC = "01" ELSE
		  SP 		WHEN MXC = "10";

---MUXD
	PCADD <= CY			WHEN PLD = "001" ELSE
		     NOT KRIX	WHEN PLD = "011" ELSE
		     NOT PRIC 	WHEN PLD = "100" ELSE
		     '1' 		WHEN PLD = "101" ELSE
		     '0';

---A
	PA:
	PROCESS(CA)
		IF(CA'EVENT AND CA = '0') THEN
			IF(GA = '0') THEN
				A <= FF(7 DOWNTO 0);
			END IF;
		END IF;
	END PROCESS PA;


---TMP
	PTMP:
	PROCESS(CT, GT)
	BEGIN
		IF(CT'EVENT AND CT = '0') THEN
			IF(GT = '0') THEN
				TMP <= DB;
			END IF;
		END IF;
	END PROCESS PTMP;

---ACT
	PACT:
	PROCESS(CC, GC)
	BEGIN
		IF(CC'EVENT AND CC = '0') THEN
			IF(GC = '0') THEN
				ACT <= A;
			END IF;
		END IF;
	END PROCESS PACT;


---ALU
	ALU:
	FF <= FA + FB		WHEN S = "000" ELSE
	   <= FA - FB		WHEN S = "001" ELSE
	   <= FA << 1		WHEN S = "011" ELSE
	   <= ~FA			WHEN S = "100" ELSE
	   <= FA & FB		WHEN S = "101" ELSE
	   <= FA - FB - CY 	WHEN S = "110" ELSE
	   <= FA - 1		WHEN S = "111" ELSE
	   FA; 

	CY <= FF(8)
	CYT <= FF(8)
---CY
	PCY:
	PROCESS(CCK, CP, FF)
	BEGIN
		IF(CCK'EVENT AND CCK = '0') THEN
			IF(CP = '0')THEN
				CY <= CYD;
			END IF;
		END IF;
	END PROCESS PCY;

---CTMP
	PCTMP:
	PROCESS(CCTK, CPT, FF)
	BEGIN
		IF(CCTK'EVENT AND CCTK = '0')THEN
			IF(CPT = '0')THEN
				CYT <= CYD;
			END IF;
			IF(COT = '0')THEN
				DB <= CYT;
			END IF;
		END IF;
	END PROCESS PCTMP;


---PPC
	PROCESS(PCK, PRST, PCADD)
	BEGIN
		IF(PRST = '0') THEN
			PC <= "0000000000000000";
		ELSIF(PCK'EVENT AND PCK = '0') THEN
			IF(PCADD = '1')THEN
				PC <= AB;
			ELSIF(PINC = '0')THEN
				PC <= PC + 1;
			END IF;
		END IF;
	END PROCESS PPC;

---IR
	PIR:
	PROCESS(CCI, GI, DB)
	BEGIN
		IF(CCI'event and CCI = '0') then
			IF(GI = '0')THEN
				IR <= DB;
			END IF;
		END IF;
	END PROCESS PIR;

---ADRH
	PADRH:
	PROCESS(CA1, GA1, AHS, DB)
	BEGIN
		IF(CA1'EVENT AND CA1 = '0')THEN
			IF(AHS = '0')THEN ADRH <= "01111110";
				ELSIF(GA1 = '0')THEN
					ADRH <= DB;
			END IF;
		END IF;
	END PROCESS PADRH;

---ADRL
	PADRL:
	PROCESS(CA2, GA2, DB)
	BEGIN
		IF(CA2'EVENT AND CA2 = '0')THEN
			IF(GA2 = '0')THEN
					ADRH <= DB;
			END IF;
		END IF;
	END PROCESS PADRH;

---SP
	PSP:
	PROCESS(SCK, SSP)
	BEGIN
		IF(SCK'EVENT AND SCK = '0')THEN
			CASE SSP is
				WHEN "01" => SP <= SP - 1;
				WHEN "10" => SP <= SP + 1;
				WHEN "11" => SP <= "0111111111111111";
				WHEN OTHERS => NULL;
			END CASE;
		END IF;
	END PROCESS PSP;

--------------------

CI(31 DOWNTO 24)		<= A 				WHEN MUX = "000" ELSE
						   PC(15 DOWNTO 8)	WHEN MUX = "001" ELSE
						   ADRH				WHEN MUX = "010" ELSE
						   A0				WHEN MUX = "011" ELSE
						   A2				WHEN MUX = "100" ELSE
						   TMP;

CI(23 DOWNTO 16)		<= IR 				WHEN MUX = "000" ELSE
						   PC(7 DOWNTO 0)	WHEN MUX = "001" ELSE
						   ADRL				WHEN MUX = "010" ELSE
						   A1				WHEN MUX = "011" ELSE
						   A3				WHEN MUX = "100" ELSE
						   ACT;

CI(15 DOWNTO 12)		<= SP(15 DOWNTO 12)	WHEN MUX = "000" ELSE
						   SP(11 DOWNTO 8)	WHEN MUX = "001" ELSE
						   SP(7 DOWNTO 4)	WHEN MUX = "010" ELSE
						   SP(3 DOWNTO 0)	WHEN MUX = "011" ELSE
						   MIR(17 DOWNTO 14);

CI(11)					<= KRIX				WHEN MUX = "000" ELSE
						   PRIX				WHEN MUX = "001" ELSE
						   OB				WHEN MUX = "010" ELSE
						   MPLD				WHEN MUX = "011" ELSE
						   MIR(22);

CI(10)					<= PRIX				WHEN MUX = "000" ELSE
						   KRIX				WHEN MUX = "001" ELSE
						   PINC 			WHEN MUX = "010" ELSE
						   GI				WHEN MUX = "011" ELSE
						   CO(3)			WHEN MUX = "100" ELSE
						   CO(0);

END cpu_behave;






























