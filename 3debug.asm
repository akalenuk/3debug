.386
.model	flat,stdcall
option	casemap:none

include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\shell32.inc
include \masm32\include\masm32.inc
include \masm32\include\gdi32.inc
include \masm32\include\opengl32.inc
include \masm32\include\glu32.inc

includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\shell32.lib
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\gdi32.lib
includelib \masm32\lib\opengl32.lib
includelib \masm32\lib\glu32.lib


; --------------- These constants are not defined in windows.inc
PFD_MAIN_PLANE		equ	0
PFD_TYPE_COLORINDEX	equ	1
PFD_TYPE_RGBA		equ	0
PFD_DOUBLEBUFFER	equ	1
PFD_DRAW_TO_WINDOW	equ	4
PFD_SUPPORT_OPENGL	equ	020h

; --------------- Data Section
.data
szDisplayName	db	"3Debuger", 0
szClassName		db	"Win32SDI_Class", 0
szDefaultPath	db	".", 0

even
PixFrm PIXELFORMATDESCRIPTOR <>

CommandLine		dd	0
hWnd			dd	0
MainHDC			dd	0
OpenDC			dd	0
hInstance		dd	0

; helpful constants made variables for loading
Value095Flt		dd	0.95
Value0Flt		dd	0.0
Value1Flt		dd	1.0
Value5Flt		dd	5.0

Value1Dbl		dq	1.0
Value45Dbl		dq	45.0
Value3Dbl		dq	0.1
Value7Dbl		dq	4096.0

; camera position and orientation
anX				dd	20.0
anY				dd	-20.0
anZ				dd	0.0
scZ				dd	-100.0
scX				dd	0.0
scY				dd	0.0

.data?
buffer			db	256		dup(?)
Path			db	4096	dup(?)

.code
; --------------- Procedures Declarations
MainInit PROTO :DWORD, :DWORD, :DWORD, :DWORD
MainLoop PROTO :DWORD, :DWORD, :DWORD, :DWORD
TopXY PROTO :DWORD, :DWORD
DrawScene PROTO
GlInit PROTO :DWORD, :DWORD
ResizeObject PROTO :DWORD, :DWORD
CreateSphere PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
SetLightSource PROTO :DWORD, :DWORD, :DWORD
RotateObject PROTO :DWORD, :DWORD, :DWORD, :DWORD
DeleteSpheres PROTO


start:
	invoke GetModuleHandle, NULL
	mov hInstance, eax
	invoke GetCommandLine
	mov CommandLine, eax
	invoke MainInit, hInstance, NULL, CommandLine, SW_SHOWDEFAULT
	invoke ExitProcess, eax

; --------------- Program main inits
	MainInit PROC hInst:DWORD, hPrevInst:DWORD, CmdLine:DWORD, CmdShow:DWORD
		LOCAL wc : WNDCLASSEX
		LOCAL msg : MSG
		LOCAL number_of_arguments: DWORD
		LOCAL array_of_arguments: DWORD
		LOCAL find_data : WIN32_FIND_DATA
		LOCAL find_handler : HANDLE

		; Argument
		mov edx, CommandLine
		mov al, [edx]
		.while al > 20h
			inc edx
			mov al, [edx]
		.endw
		invoke lstrcpy, ADDR Path, edx
		.if Path[0] == 0
			mov Path[0], '.'
			mov Path[1], 0
		.elseif Path[1] == 0
			mov Path[0], '.'
			mov Path[1], 0
		.endif

		invoke MessageBox, 0, ADDR Path, ADDR szDisplayName, MB_OK

		; File list
;		invoke FindFirstFile, ADDR Path, ADDR find_data
;		.if (eax != 0)
;			mov find_handler, eax
;			.repeat
;				invoke MessageBox, 0, ADDR find_data.cFileName, ADDR szDisplayName, MB_OK
;				invoke FindNextFile, find_handler, ADDR find_data
;			.until (eax == 0)
;		.endif

		mov wc.cbSize, sizeof WNDCLASSEX
		mov wc.style, 0
		mov wc.lpfnWndProc, offset MainLoop
		mov wc.cbClsExtra, NULL
		mov wc.cbWndExtra, NULL
		push hInst
		pop wc.hInstance
		mov wc.hbrBackground, COLOR_WINDOWTEXT + 1
		mov wc.lpszMenuName, NULL
		mov wc.lpszClassName, offset szClassName
		invoke LoadIcon, hInst, 500
		mov wc.hIcon, eax
		invoke LoadCursor, NULL, IDC_ARROW
		mov wc.hCursor, eax
		mov wc.hIconSm, 0
		invoke RegisterClassEx, ADDR wc
		invoke CreateWindowEx, 0, ADDR szClassName,
			ADDR szDisplayName,
			WS_OVERLAPPEDWINDOW or WS_CLIPSIBLINGS or WS_CLIPCHILDREN,
			CW_USEDEFAULT, CW_USEDEFAULT, 800, 600,
			NULL, NULL,
			hInst, NULL
		mov hWnd, eax
		invoke LoadMenu, hInst, 600
		invoke SetMenu, hWnd, eax
		invoke ShowWindow, hWnd, SW_SHOWNORMAL
		invoke UpdateWindow, hWnd

; --------------- Event loop
StartLoop:
		invoke PeekMessage, ADDR msg, 0, 0, 0, PM_NOREMOVE
		or eax, eax
		jz NoMsg
		invoke GetMessage, ADDR msg, NULL, 0, 0
		or eax, eax
		jz ExitLoop
		invoke TranslateMessage, ADDR msg
		invoke DispatchMessage, ADDR msg
		jmp StartLoop
NoMsg: ; No pending messages: draw the scene
		invoke DrawScene
		jmp StartLoop
ExitLoop:
		mov eax, msg.wParam
		ret
	MainInit ENDP

; --------------- Program main loop
	MainLoop PROC hWin:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
		LOCAL WINRect:RECT
		LOCAL rect:RECT
		LOCAL dWnd:HWND
		LOCAL PixFormat:DWORD
		.if uMsg == WM_COMMAND
			.if wParam == 1000
				invoke SendMessage, hWin, WM_SYSCOMMAND, SC_CLOSE,NULL
			.endif
			mov eax, 0
			ret
		.elseif uMsg == WM_CREATE
			invoke GetDC, hWin
			mov MainHDC, eax
			mov ax, SIZEOF PixFrm
			mov PixFrm.nSize, ax
			mov PixFrm.nVersion, 1
			mov PixFrm.dwFlags, PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER
			mov PixFrm.dwLayerMask, PFD_MAIN_PLANE
			mov PixFrm.iPixelType, PFD_TYPE_RGBA
			mov PixFrm.cColorBits, 8
			mov PixFrm.cDepthBits, 16
			mov PixFrm.cAccumBits, 0
			mov PixFrm.cStencilBits, 0
			invoke ChoosePixelFormat, MainHDC, ADDR PixFrm
			mov PixFormat, eax
			invoke SetPixelFormat, MainHDC, PixFormat, ADDR PixFrm
			or eax, eax
			jz NoPixelFmt
			invoke wglCreateContext, MainHDC
			mov OpenDC, eax
			invoke wglMakeCurrent, MainHDC, OpenDC
			invoke GetClientRect, hWin, ADDR WINRect
			invoke GlInit, WINRect.right, WINRect.bottom
NoPixelFmt:
			mov eax, 0
			ret
		.elseif uMsg == WM_SIZE
			invoke GetClientRect, hWin, ADDR WINRect
			invoke ResizeObject, WINRect.right, WINRect.bottom
			mov eax, 0
			ret

		.elseif uMsg == WM_KEYDOWN
			.if wParam == VK_ESCAPE
				invoke SendMessage, hWnd, WM_CLOSE,0,0
			.elseif wParam == VK_W
				FINIT
				FLD scZ
				FMUL Value095Flt
				FST scZ
			.elseif wParam == VK_S
				FINIT
				FLD scZ
				FDIV Value095Flt
				FST scZ
			.elseif wParam == VK_F
				FINIT
				FLD scX
				FADD Value5Flt
				FST scX
			.elseif wParam == VK_H
				FINIT
				FLD scX
				FSUB Value5Flt
				FST scX
			.elseif wParam == VK_T
				FINIT
				FLD scY
				FSUB Value5Flt
				FST scY
			.elseif wParam == VK_G
				FINIT
				FLD scY
				FADD Value5Flt
				FST scY
			.elseif wParam == VK_LEFT
				FINIT
				FLD anY
				FADD Value1Flt
				FST anY
			.elseif wParam == VK_RIGHT
				FINIT
				FLD anY
				FSUB Value1Flt
				FST anY
			.elseif wParam == VK_UP
				FINIT
				FLD anX
				FADD Value1Flt
				FST anX
			.elseif wParam == VK_DOWN
				FINIT
				FLD anX
				FSUB Value1Flt
				FST anX
			.elseif wParam == VK_D
				FINIT
				FLD anZ
				FSUB Value1Flt
				FST anZ
			.elseif wParam == VK_A
				FINIT
				FLD anZ
				FADD Value1Flt
				FST anZ
			.endif
		.elseif uMsg == WM_MOUSEMOVE
			; TBD
		.elseif uMsg == WM_CLOSE
			mov eax, OpenDC
			or eax, eax
			jz NoGlDC
			; Delete our objects
			invoke wglDeleteContext, OpenDC
NoGlDC: 
			invoke ReleaseDC, hWin, MainHDC
			invoke DestroyWindow, hWin
			mov eax, 0
			ret
		.elseif uMsg == WM_DESTROY
			invoke PostQuitMessage, NULL
			mov eax, 0
			ret
		.endif
		invoke DefWindowProc, hWin, uMsg, wParam, lParam
		ret
	MainLoop ENDP

; ------------------------------
; OpenGl related stuff
; ------------------------------

; --------------- Init the scene
	GlInit	PROC ParentW:DWORD, ParentH:DWORD
		; Set global flags
		invoke glClearColor, Value1Flt, Value1Flt, Value1Flt, Value1Flt
		invoke glEnable, GL_DEPTH_TEST
		invoke glEnable, GL_LIGHTING
		invoke glEnable, GL_CULL_FACE		; Don't render back faces
		invoke glShadeModel, GL_SMOOTH
		invoke glEnable, GL_NORMALIZE
		ret
	GlInit ENDP

; --------------- Display the scene
	DrawScene PROC
		invoke glClear, GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT
		invoke glPushMatrix
		invoke glLoadIdentity
		invoke glTranslatef, scX, scY, scZ
		invoke glRotatef, anX, Value1Flt, Value0Flt, Value0Flt
		invoke glRotatef, anY, Value0Flt, Value1Flt, Value0Flt
		invoke glRotatef, anZ, Value0Flt, Value0Flt, Value1Flt

		invoke glPointSize, Value1Flt
		invoke glBegin, GL_LINES
			invoke glColor3f, Value1Flt, Value0Flt, Value0Flt
			invoke glVertex3i, 0, 0, 0
			invoke glVertex3i, 32, 0, 0
			invoke glColor3f, Value0Flt, Value1Flt, Value0Flt
			invoke glVertex3i, 0, 0, 0
			invoke glVertex3i, 0, 32, 0
			invoke glColor3f, Value0Flt, Value0Flt, Value1Flt
			invoke glVertex3i, 0, 0, 0
			invoke glVertex3i, 0, 0, 32
		invoke glEnd

		invoke glPopMatrix
		invoke SwapBuffers,MainHDC
		ret
	DrawScene ENDP

; --------------- Resize the scene
	ResizeObject PROC ParentW:DWORD,ParentH:DWORD
		invoke glViewport, 0, 0, ParentW,ParentH
		invoke glMatrixMode, GL_PROJECTION
		invoke glLoadIdentity
		invoke gluPerspective, DWORD PTR Value45Dbl, DWORD PTR Value45Dbl+4, DWORD PTR Value1Dbl, DWORD PTR Value1Dbl+4, DWORD PTR Value3Dbl, DWORD PTR Value3Dbl+4, DWORD PTR Value7Dbl, DWORD PTR Value7Dbl+4
		invoke glMatrixMode, GL_MODELVIEW
		invoke glLoadIdentity
		ret
	ResizeObject ENDP

end start
