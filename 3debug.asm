.386
.model	flat,stdcall
option	casemap:none

include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc
include \masm32\include\gdi32.inc
include \masm32\include\opengl32.inc
include \masm32\include\glu32.inc

includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\gdi32.lib
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
Value0_5Flt		dd	0.5
Value1Flt		dd	1.0
Value2Flt		dd	2.0
Value5Flt		dd	5.0
Value255Flt		dd	255.0
Value_5Flt		dd	-5.0
Value_100Flt	dd	-100.0

Value1Dbl		dq	1.0
Value45Dbl		dq	45.0
Value3Dbl		dq	0.1
Value7Dbl		dq	4096.0

; initial data
PointCount	dd	0
anX 		dd	20.0
anY 		dd	-20.0
anZ 		dd	0.0
scZ 		dd	-100.0
scX 		dd	0.0
scY 		dd	0.0

CTable  dd 0.0,0.00392156862745098,0.00784313725490196,0.0117647058823529,0.0156862745098039,0.0196078431372549,0.0235294117647059,0.0274509803921569,0.0313725490196078,0.0352941176470588,0.0392156862745098,0.0431372549019608,0.0470588235294118,0.0509803921568627,0.0549019607843137,0.0588235294117647
CTable1 dd 0.0627450980392157,0.0666666666666667,0.0705882352941176,0.0745098039215686,0.0784313725490196,0.0823529411764706,0.0862745098039216,0.0901960784313725,0.0941176470588235,0.0980392156862745,0.101960784313725,0.105882352941176,0.109803921568627,0.113725490196078,0.117647058823529,0.12156862745098
CTable2 dd 0.125490196078431,0.129411764705882,0.133333333333333,0.137254901960784,0.141176470588235,0.145098039215686,0.149019607843137,0.152941176470588,0.156862745098039,0.16078431372549,0.164705882352941,0.168627450980392,0.172549019607843,0.176470588235294,0.180392156862745,0.184313725490196
CTable3 dd 0.188235294117647,0.192156862745098,0.196078431372549,0.2,0.203921568627451,0.207843137254902,0.211764705882353,0.215686274509804,0.219607843137255,0.223529411764706,0.227450980392157,0.231372549019608,0.235294117647059,0.23921568627451,0.243137254901961,0.247058823529412
CTable4 dd 0.250980392156863,0.254901960784314,0.258823529411765,0.262745098039216,0.266666666666667,0.270588235294118,0.274509803921569,0.27843137254902,0.282352941176471,0.286274509803922,0.290196078431373,0.294117647058824,0.298039215686275,0.301960784313725,0.305882352941176,0.309803921568627
CTable5 dd 0.313725490196078,0.317647058823529,0.32156862745098,0.325490196078431,0.329411764705882,0.333333333333333,0.337254901960784,0.341176470588235,0.345098039215686,0.349019607843137,0.352941176470588,0.356862745098039,0.36078431372549,0.364705882352941,0.368627450980392,0.372549019607843
CTable6 dd 0.376470588235294,0.380392156862745,0.384313725490196,0.388235294117647,0.392156862745098,0.396078431372549,0.4,0.403921568627451,0.407843137254902,0.411764705882353,0.415686274509804,0.419607843137255,0.423529411764706,0.427450980392157,0.431372549019608,0.435294117647059
CTable7 dd 0.43921568627451,0.443137254901961,0.447058823529412,0.450980392156863,0.454901960784314,0.458823529411765,0.462745098039216,0.466666666666667,0.470588235294118,0.474509803921569,0.47843137254902,0.482352941176471,0.486274509803922,0.490196078431373,0.494117647058824,0.498039215686275
CTable8 dd 0.501960784313725,0.505882352941176,0.509803921568627,0.513725490196078,0.517647058823529,0.52156862745098,0.525490196078431,0.529411764705882,0.533333333333333,0.537254901960784,0.541176470588235,0.545098039215686,0.549019607843137,0.552941176470588,0.556862745098039,0.56078431372549
CTable9 dd 0.564705882352941,0.568627450980392,0.572549019607843,0.576470588235294,0.580392156862745,0.584313725490196,0.588235294117647,0.592156862745098,0.596078431372549,0.6,0.603921568627451,0.607843137254902,0.611764705882353,0.615686274509804,0.619607843137255,0.623529411764706
CTableA dd 0.627450980392157,0.631372549019608,0.635294117647059,0.63921568627451,0.643137254901961,0.647058823529412,0.650980392156863,0.654901960784314,0.658823529411765,0.662745098039216,0.666666666666667,0.670588235294118,0.674509803921569,0.67843137254902,0.682352941176471,0.686274509803922
CTableB dd 0.690196078431373,0.694117647058824,0.698039215686275,0.701960784313725,0.705882352941176,0.709803921568627,0.713725490196078,0.717647058823529,0.72156862745098,0.725490196078431,0.729411764705882,0.733333333333333,0.737254901960784,0.741176470588235,0.745098039215686,0.749019607843137
CTableC dd 0.752941176470588,0.756862745098039,0.76078431372549,0.764705882352941,0.768627450980392,0.772549019607843,0.776470588235294,0.780392156862745,0.784313725490196,0.788235294117647,0.792156862745098,0.796078431372549,0.8,0.803921568627451,0.807843137254902,0.811764705882353
CTableD dd 0.815686274509804,0.819607843137255,0.823529411764706,0.827450980392157,0.831372549019608,0.835294117647059,0.83921568627451,0.843137254901961,0.847058823529412,0.850980392156863,0.854901960784314,0.858823529411765,0.862745098039216,0.866666666666667,0.870588235294118,0.874509803921569
CTableE dd 0.87843137254902,0.882352941176471,0.886274509803922,0.890196078431373,0.894117647058824,0.898039215686275,0.901960784313725,0.905882352941176,0.909803921568627,0.913725490196078,0.917647058823529,0.92156862745098,0.925490196078431,0.929411764705882,0.933333333333333,0.937254901960784
CTableF dd 0.941176470588235,0.945098039215686,0.949019607843137,0.952941176470588,0.956862745098039,0.96078431372549,0.964705882352941,0.968627450980392,0.972549019607843,0.976470588235294,0.980392156862745,0.984313725490196,0.988235294117647,0.992156862745098,0.996078431372549,1.0

Xflag		db	0
Yflag		db	0
Zflag		db	0

coma		db	',',0

.data?
temp	dd	?
temp1	dd	?
tempX	dd	?
tempY	dd	?
tempZ	dd	?
X		dd	4096	dup(?)
Y		dd	4096	dup(?)
Z		dd	4096	dup(?)
R		dd	4096	dup(?)
G		dd	4096	dup(?)
B		dd	4096	dup(?)
Flags	db	4096	dup(?)
buffer	db	256		dup(?)
minibuf	db	16		dup(?)

hand	dd	?
addre	dd	?
hEdit	dd	?
sHWND	db	16	dup(?)


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
		LOCAL wc:WNDCLASSEX
		LOCAL msg:MSG
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
			.elseif wParam == VK_X
				xor Xflag, 1
			.elseif wParam == VK_Y
				xor Yflag, 1
			.elseif wParam == VK_Z
				xor Zflag, 1
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
