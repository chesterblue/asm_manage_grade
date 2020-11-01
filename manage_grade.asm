STUDENT STRUC			;结构定义
		NAMES DB 20 DUP (?)
		SCORE dw ?
STUDENT ENDS
DATAS SEGMENT
    ;此处输入数据段代码
    CNT = 10
    CLASS STUDENT CNT DUP(<>)	;结构体数组
    MENU db "============================================================",13,10
		 db "Options:",13,10
		 db "1.Input student informations(name,score).Click ESC to exit.",13,10
		 db "2.Output student informations(name,score,ranking)",13,10
		 db "============================================================",13,10,"$"
    CN DW 10		;乘数  
    COUNT DW ?		;记录人数
    REAL_COUNT DW 0	;此变量值为提示正在输入第几个学生的信息
    CHN1 DW 2		;除数
    CHN2 DW 10		;除数
    OPT DB ?		;菜单选项的保存
    INSIDE DW ?		;排序时使用到的内循环
    OUTSIDE DW ?	;外循环
    FIXNUM DW 22
    NOWS DW 0		;记录当前输入信息的地址
    RANK DW 0		;记录当前排名
    TEMP1 DB 20 DUP(?)
    TEMP2 DB 20 DUP(?)
    ERROR DB 'INPUT ERROR!',13,10,'$'
    NAME_TIP DB 'Name:$'
    SCORE_TIP DB 'Score:$'
    INPUT_TIP1 DB 'NO.$'
    INPUT_TIP2 DB ' STUDENT',13,10,'$'
    CLR DB 13,10,'$'
    INPUT_TIP3 DB 'Click any key to continue,ESC to exit',13,10,'$'
    OUTPUT_TIP1 DB 'Name',15 DUP(' '),'$'
    OUTPUT_TIP2 DB 'Score',5 DUP(' '),'$'
    OUTPUT_TIP3 DB 'Rank','$'
    BLANK_ONE DB '          $'
    ERROR_MENU_TIP DB 'Please input again!',13,10,'$'
DATAS ENDS
 
STACKS SEGMENT
    ;此处输入堆栈段代码
STACKS ENDS
;定义附加段
extra segment
	
extra ends
;----宏指令字符串的输出----
PRINTS MACRO STR
	MOV AH,9
	LEA DX,STR
	INT 21H
	ENDM
;------宏指令输出不定位数的数字-----
PRINTN MACRO NUM
	LOCAL LP1,LP2
	 XOR CX,CX
	 MOV AX,NUM
	 CWD   
LP1:
	DIV CHN2
	PUSH DX
	INC CX
	CMP AX,0
	CWD       ;重点!!!!!!!
	JNZ LP1
LP2:
	POP DX
	ADD DL,30H
	MOV AH,2
	INT 21H
	LOOP LP2	
ENDM
CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS,ES:EXTRA
START:
    MOV AX,DATAS
    MOV DS,AX
    MOV ES,AX
    
    
MENUS:    
    PRINTS MENU
    MOV AH,1		;输入选择的选项
    INT 21H
    PRINTS CLR
    MOV OPT,AL
    CMP OPT,31H
    JZ OP1
    CMP OPT,32H
    JZ OP2
    CMP OPT,1BH
    JZ EXIT
    JMP ERROR_MENU
ERROR_MENU:
	PRINTS ERROR_MENU_TIP
	JMP MENUS
;------调用哪个功能-------
OP1:
	CALL STORE_INFOR
	PRINTS CLR
	JMP MENUS
OP2:
	CALL SORT_SCORE
	PRINTS CLR
	JMP MENUS 
;------子程序调用------   
STORE_INFOR PROC
;子程序名:STORE_INFOR
;子程序功能：存储学生信息 
	MOV CX,0		;初始化学生人数
	MOV BX,0		;初始化结构地址
OP1_NEW:
	MOV BX,NOWS
	ADD REAL_COUNT,1
	ADD CX,1
	PRINTS INPUT_TIP1 ;输出输入信息的操作提示
	PUSH CX
	PRINTN REAL_COUNT ;输出第几个学生的提示
	POP CX
	PRINTS INPUT_TIP2 ;
	PRINTS NAME_TIP   ;输出姓名提示：NAME:
    MOV si,0
LOOP1:
	MOV AH,1
	INT 21H
	CMP AL,0DH
	JZ NEXT1
	MOV CLASS[BX].NAMES[si],al
	INC SI
	JMP LOOP1
;------存储成绩-----	
NEXT1:
	MOV CLASS[BX].NAMES[19],'$'
	PUSH BX			;保护BX
LOOP_TIP:	
	PRINTS SCORE_TIP
	XOR DX,DX
	XOR BX,BX
LOOP2:
    MOV AH,1
    INT 21H
    CMP AL,0DH		;判断是否为回车退出
    JZ STORE
    SUB AL,30H
    
    JL    ERROR1         ; <0 报错 重新输入
    CMP   AL, 9
    JG    ERROR1         ; >9 报错 重新输入
    
    CBW
    XCHG AX,BX
    MUL CN
    ADD BX,AX
    JMP LOOP2    
ERROR1:
    PRINTS ERROR
    JMP LOOP_TIP
STORE:
	MOV DX,BX
	CMP DX,100			;判断输入的成绩是否有效
	JA ERROR1
	POP BX
	MOV CLASS[BX].SCORE,DX
    INC CX				;记录学生人数
    PRINTS CLR
    PRINTS INPUT_TIP3	;输出提示
    MOV COUNT,CX
    ADD BX,FIXNUM
    MOV NOWS,BX	;存储下一个学生信息的地址
    MOV AH,1
    INT 21H
    CMP AL,1BH			;判断是否为ESC
    JNZ OP1_NEW
    RET
STORE_INFOR ENDP
;------------------
;-------排序-------
SORT_SCORE PROC
;子程序名：STORE_INFOR
;子程序功能：按成绩排序
OP2_NEW:
	XOR BX,BX
	MOV CX,REAL_COUNT
	DEC CX
 	MOV OUTSIDE,CX	;使学生人数减一后给OUTSIDE
OUT_LOOP:
	MOV CX,OUTSIDE
	MOV INSIDE,CX
	MOV BX,0		;初始化地址
IN_LOOP:
	MOV CX,CLASS[BX].SCORE
	ADD BX,FIXNUM
	CMP CX,CLASS[BX].SCORE
	JL EXCHANGE
	;以下为循环条件
	DEC INSIDE
	CMP INSIDE,0
	JG IN_LOOP
	DEC OUTSIDE
	CMP OUTSIDE,0
	JG OUT_LOOP
	JMP NEXT
EXCHANGE:
;-----成绩位置交换------
	MOV DX,CLASS[BX].SCORE	;把小的数给DX
	SUB BX,FIXNUM
	MOV CLASS[BX].SCORE,DX	;把DX给原本存大数的位置
	ADD BX,FIXNUM
	MOV CLASS[BX].SCORE,CX	;把CX给原本存小数的位置
;-----姓名位置交换-------
	LEA SI,CLASS[BX].NAMES
	LEA DI,TEMP1			;串操作把小数的名字给临时变量一
	MOV CX,20
	REP MOVSB
	
	SUB BX,FIXNUM
	LEA SI,CLASS[BX].NAMES	;串操作把大数的名字给临时变量二
	LEA DI,TEMP2
	MOV CX,20
	REP MOVSB
	
	LEA SI,TEMP1
	LEA DI,CLASS[BX].NAMES	
	MOV CX,20
	REP MOVSB
	
	ADD BX,FIXNUM
	LEA SI,TEMP2
	LEA DI,CLASS[BX].NAMES
	MOV CX,20
	REP MOVSB
	;以下为循环条件
	DEC INSIDE
	CMP INSIDE,0
	JG IN_LOOP	
	DEC OUTSIDE
	CMP OUTSIDE,0
	JG OUT_LOOP
		
;-----按成绩大小顺序输出学生信息-----
NEXT:
	PRINTS OUTPUT_TIP1
	PRINTS OUTPUT_TIP2
	PRINTS OUTPUT_TIP3
	XOR BX,BX
	MOV RANK,0
	MOV CX,REAL_COUNT  ;保护真正的学生数目的值
	MOV COUNT,CX
LOOP3:
	INC RANK
	PRINTS CLR
	PRINTS CLASS[BX].NAMES
	PRINTN CLASS[BX].SCORE
	PRINTS BLANK_ONE
	PRINTN RANK
	ADD BX,FIXNUM
	DEC COUNT
	CMP COUNT,0
	JNZ LOOP3
	RET
SORT_SCORE ENDP	
EXIT:
    MOV AH,4CH
    INT 21H
 
 
CODES ENDS
    END START
