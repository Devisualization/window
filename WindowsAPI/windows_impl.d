module windows_impl;
import windows;
alias size_t = windows.size_t;//conflict with object.size_t

extern (System):
//C       static  void *Ptr32ToPtr(const void *p) { return (void *) (ULONG_PTR) p; }
struct _N10
{
    DWORD __bitfield1;
    DWORD BaseMid() { return (__bitfield1 >> 0) & 0xff; }
    DWORD Type() { return (__bitfield1 >> 8) & 0x1f; }
    DWORD Dpl() { return (__bitfield1 >> 13) & 0x3; }
    DWORD Pres() { return (__bitfield1 >> 15) & 0x1; }
    DWORD LimitHi() { return (__bitfield1 >> 16) & 0xf; }
    DWORD Sys() { return (__bitfield1 >> 20) & 0x1; }
    DWORD Reserved_0() { return (__bitfield1 >> 21) & 0x1; }
    DWORD Default_Big() { return (__bitfield1 >> 22) & 0x1; }
    DWORD Granularity() { return (__bitfield1 >> 23) & 0x1; }
    DWORD BaseHi() { return (__bitfield1 >> 24) & 0xff; }
}
struct _N15
{
    DWORD __bitfield1;
    DWORD RatePercent() { return (__bitfield1 >> 0) & 0x7f; }
    DWORD Reserved0() { return (__bitfield1 >> 7) & 0x1ffffff; }
}
union _RATE_QUOTA_LIMIT
{
    DWORD RateData;
    DWORD RatePercent() { return 0x7f; }
    DWORD Reserved0() { return 0x1ffffff; }
}
struct _PROCESSOR_POWER_POLICY_INFO
{
    DWORD TimeCheck;
    DWORD DemoteLimit;
    DWORD PromoteLimit;
    BYTE DemotePercent;
    BYTE PromotePercent;
    BYTE [2]Spare;
    DWORD __bitfield1;
    DWORD AllowDemotion() { return (__bitfield1 >> 0) & 0x1; }
    DWORD AllowPromotion() { return (__bitfield1 >> 1) & 0x1; }
    DWORD Reserved() { return (__bitfield1 >> 2) & 0x3fffffff; }
}
struct _PROCESSOR_POWER_POLICY
{
    DWORD Revision;
    BYTE DynamicThrottle;
    BYTE [3]Spare;
    DWORD __bitfield1;
    DWORD DisableCStates() { return (__bitfield1 >> 0) & 0x1; }
    DWORD Reserved() { return (__bitfield1 >> 1) & 0x7fffffff; }
    DWORD PolicyCount;
    PROCESSOR_POWER_POLICY_INFO [3]Policy;
}
struct _N45
{
    DWORD __bitfield1;
    DWORD NameOffset() { return (__bitfield1 >> 0) & 0x7fffffff; }
    DWORD NameIsString() { return (__bitfield1 >> 31) & 0x1; }
}
//C      DWORD Name;
//C      WORD Id;
//C           } ;
union _N44
{
    DWORD __bitfield1;
    DWORD NameOffset() { return (__bitfield1 >> 0) & 0x7fffffff; }
    DWORD NameIsString() { return (__bitfield1 >> 31) & 0x1; }
    DWORD Name;
    WORD Id;
}
struct _N47
{
    DWORD __bitfield1;
    DWORD OffsetToDirectory() { return (__bitfield1 >> 0) & 0x7fffffff; }
    DWORD DataIsDirectory() { return (__bitfield1 >> 31) & 0x1; }
}
//C           } ;
union _N46
{
    DWORD OffsetToData;
    DWORD OffsetToDirectory() { return 0x7fffffff; }
    DWORD DataIsDirectory() { return 0x1; }
}
struct _IMAGE_RESOURCE_DIRECTORY_ENTRY
{
    DWORD __bitfield1;
    DWORD NameOffset() { return (__bitfield1 >> 0) & 0x7fffffff; }
    DWORD NameIsString() { return (__bitfield1 >> 31) & 0x1; }
    DWORD Name;
    WORD Id;
    DWORD OffsetToData;
    DWORD OffsetToDirectory() { return (__bitfield1 >> 0) & 0x7fffffff; }
    DWORD DataIsDirectory() { return (__bitfield1 >> 31) & 0x1; }
}
struct _IMAGE_CE_RUNTIME_FUNCTION_ENTRY
{
    DWORD FuncStart;
    DWORD __bitfield1;
    DWORD PrologLen() { return (__bitfield1 >> 0) & 0xff; }
    DWORD FuncLen() { return (__bitfield1 >> 8) & 0x3fffff; }
    DWORD ThirtyTwoBit() { return (__bitfield1 >> 30) & 0x1; }
    DWORD ExceptionFlag() { return (__bitfield1 >> 31) & 0x1; }
}
struct _FPO_DATA
{
    DWORD ulOffStart;
    DWORD cbProcSize;
    DWORD cdwLocals;
    WORD cdwParams;
    WORD __bitfield1;
    WORD cbProlog() { return (__bitfield1 >> 0) & 0xff; }
    WORD cbRegs() { return (__bitfield1 >> 8) & 0x7; }
    WORD fHasSEH() { return (__bitfield1 >> 11) & 0x1; }
    WORD fUseBP() { return (__bitfield1 >> 12) & 0x1; }
    WORD reserved() { return (__bitfield1 >> 13) & 0x1; }
    WORD cbFrame() { return (__bitfield1 >> 14) & 0x3; }
}
struct _ImageArchitectureHeader
{
    uint __bitfield1;
    uint AmaskValue() { return (__bitfield1 >> 0) & 0x1; }
    int Adummy1() { return (__bitfield1 << 24) >> 25; }
    uint AmaskShift() { return (__bitfield1 >> 8) & 0xff; }
    int Adummy2() { return (__bitfield1 << 0) >> 16; }
    DWORD FirstEntryRVA;
}
struct IMPORT_OBJECT_HEADER
{
    WORD Sig1;
    WORD Sig2;
    WORD Version;
    WORD Machine;
    DWORD TimeDateStamp;
    DWORD SizeOfData;
    WORD Ordinal;
    WORD Hint;
    WORD __bitfield1;
    WORD Type() { return (__bitfield1 >> 0) & 0x3; }
    WORD NameType() { return (__bitfield1 >> 2) & 0x7; }
    WORD Reserved() { return (__bitfield1 >> 5) & 0x7ff; }
}
struct _COMSTAT
{
    DWORD __bitfield1;
    DWORD fCtsHold() { return (__bitfield1 >> 0) & 0x1; }
    DWORD fDsrHold() { return (__bitfield1 >> 1) & 0x1; }
    DWORD fRlsdHold() { return (__bitfield1 >> 2) & 0x1; }
    DWORD fXoffHold() { return (__bitfield1 >> 3) & 0x1; }
    DWORD fXoffSent() { return (__bitfield1 >> 4) & 0x1; }
    DWORD fEof() { return (__bitfield1 >> 5) & 0x1; }
    DWORD fTxim() { return (__bitfield1 >> 6) & 0x1; }
    DWORD fReserved() { return (__bitfield1 >> 7) & 0x1ffffff; }
    DWORD cbInQue;
    DWORD cbOutQue;
}
struct _DCB
{
    DWORD DCBlength;
    DWORD BaudRate;
    DWORD __bitfield1;
    DWORD fBinary() { return (__bitfield1 >> 0) & 0x1; }
    DWORD fParity() { return (__bitfield1 >> 1) & 0x1; }
    DWORD fOutxCtsFlow() { return (__bitfield1 >> 2) & 0x1; }
    DWORD fOutxDsrFlow() { return (__bitfield1 >> 3) & 0x1; }
    DWORD fDtrControl() { return (__bitfield1 >> 4) & 0x3; }
    DWORD fDsrSensitivity() { return (__bitfield1 >> 6) & 0x1; }
    DWORD fTXContinueOnXoff() { return (__bitfield1 >> 7) & 0x1; }
    DWORD fOutX() { return (__bitfield1 >> 8) & 0x1; }
    DWORD fInX() { return (__bitfield1 >> 9) & 0x1; }
    DWORD fErrorChar() { return (__bitfield1 >> 10) & 0x1; }
    DWORD fNull() { return (__bitfield1 >> 11) & 0x1; }
    DWORD fRtsControl() { return (__bitfield1 >> 12) & 0x3; }
    DWORD fAbortOnError() { return (__bitfield1 >> 14) & 0x1; }
    DWORD fDummy2() { return (__bitfield1 >> 15) & 0x1ffff; }
    WORD wReserved;
    WORD XonLim;
    WORD XoffLim;
    BYTE ByteSize;
    BYTE Parity;
    BYTE StopBits;
    char XonChar;
    char XoffChar;
    char ErrorChar;
    char EofChar;
    char EvtChar;
    WORD wReserved1;
}
struct tagMENUBARINFO
{
    DWORD cbSize;
    RECT rcBar;
    HMENU hMenu;
    HWND hwndMenu;
    WINBOOL __bitfield1;
    WINBOOL fBarFocused() { return (__bitfield1 << 31) >> 31; }
    WINBOOL fFocused() { return (__bitfield1 << 30) >> 31; }
}
struct _N88
{
    ushort __bitfield1;
    ushort bAppReturnCode() { return (__bitfield1 >> 0) & 0xff; }
    ushort reserved() { return (__bitfield1 >> 8) & 0x3f; }
    ushort fBusy() { return (__bitfield1 >> 14) & 0x1; }
    ushort fAck() { return (__bitfield1 >> 15) & 0x1; }
}
struct _N89
{
    ushort __bitfield1;
    ushort reserved() { return (__bitfield1 >> 0) & 0x3fff; }
    ushort fDeferUpd() { return (__bitfield1 >> 14) & 0x1; }
    ushort fAckReq() { return (__bitfield1 >> 15) & 0x1; }
    short cfFormat;
}
struct _N90
{
    ushort __bitfield1;
    ushort unused() { return (__bitfield1 >> 0) & 0xfff; }
    ushort fResponse() { return (__bitfield1 >> 12) & 0x1; }
    ushort fRelease() { return (__bitfield1 >> 13) & 0x1; }
    ushort reserved() { return (__bitfield1 >> 14) & 0x1; }
    ushort fAckReq() { return (__bitfield1 >> 15) & 0x1; }
    short cfFormat;
    BYTE [1]Value;
}
struct _N91
{
    ushort __bitfield1;
    ushort unused() { return (__bitfield1 >> 0) & 0x1fff; }
    ushort fRelease() { return (__bitfield1 >> 13) & 0x1; }
    ushort fReserved() { return (__bitfield1 >> 14) & 0x3; }
    short cfFormat;
    BYTE [1]Value;
}
struct _N92
{
    ushort __bitfield1;
    ushort unused() { return (__bitfield1 >> 0) & 0x1fff; }
    ushort fRelease() { return (__bitfield1 >> 13) & 0x1; }
    ushort fDeferUpd() { return (__bitfield1 >> 14) & 0x1; }
    ushort fAckReq() { return (__bitfield1 >> 15) & 0x1; }
    short cfFormat;
}
struct _N93
{
    ushort __bitfield1;
    ushort unused() { return (__bitfield1 >> 0) & 0xfff; }
    ushort fAck() { return (__bitfield1 >> 12) & 0x1; }
    ushort fRelease() { return (__bitfield1 >> 13) & 0x1; }
    ushort fReserved() { return (__bitfield1 >> 14) & 0x1; }
    ushort fAckReq() { return (__bitfield1 >> 15) & 0x1; }
    short cfFormat;
    BYTE [1]rgb;
}
struct _MIDL_STUB_MESSAGE
{
    PRPC_MESSAGE RpcMsg;
    ubyte *Buffer;
    ubyte *BufferStart;
    ubyte *BufferEnd;
    ubyte *BufferMark;
    uint BufferLength;
    uint MemorySize;
    ubyte *Memory;
    ubyte IsClient;
    ubyte Pad;
    ushort uFlags2;
    int ReuseBuffer;
    NDR_ALLOC_ALL_NODES_CONTEXT *pAllocAllNodesContext;
    NDR_POINTER_QUEUE_STATE *pPointerQueueState;
    int IgnoreEmbeddedPointers;
    ubyte *PointerBufferMark;
    ubyte fBufferValid;
    ubyte uFlags;
    ushort UniquePtrCount;
    ULONG_PTR MaxCount;
    uint Offset;
    uint ActualCount;
    void * function(size_t )pfnAllocate;
    void  function(void *)pfnFree;
    ubyte *StackTop;
    ubyte *pPresentedType;
    ubyte *pTransmitType;
    handle_t SavedHandle;
    _MIDL_STUB_DESC *StubDesc;
    _FULL_PTR_XLAT_TABLES *FullPtrXlatTables;
    uint FullPtrRefId;
    uint PointerLength;
    int __bitfield1;
    int fInDontFree() { return (__bitfield1 << 31) >> 31; }
    int fDontCallFreeInst() { return (__bitfield1 << 30) >> 31; }
    int fInOnlyParam() { return (__bitfield1 << 29) >> 31; }
    int fHasReturn() { return (__bitfield1 << 28) >> 31; }
    int fHasExtensions() { return (__bitfield1 << 27) >> 31; }
    int fHasNewCorrDesc() { return (__bitfield1 << 26) >> 31; }
    int fIsOicfServer() { return (__bitfield1 << 25) >> 31; }
    int fHasMemoryValidateCallback() { return (__bitfield1 << 24) >> 31; }
    int fUnused() { return (__bitfield1 << 16) >> 24; }
    int fUnused2() { return (__bitfield1 << 0) >> 16; }
    uint dwDestContext;
    void *pvDestContext;
    NDR_SCONTEXT *SavedContextHandles;
    int ParamNumber;
    IRpcChannelBuffer *pRpcChannelBuffer;
    PARRAY_INFO pArrayInfo;
    uint *SizePtrCountArray;
    uint *SizePtrOffsetArray;
    uint *SizePtrLengthArray;
    void *pArgQueue;
    uint dwStubPhase;
    void *LowStackMark;
    PNDR_ASYNC_MESSAGE pAsyncMsg;
    PNDR_CORRELATION_INFO pCorrInfo;
    ubyte *pCorrMemory;
    void *pMemoryList;
    CS_STUB_INFO *pCSInfo;
    ubyte *ConformanceMark;
    ubyte *VarianceMark;
    INT_PTR Unused;
    _NDR_PROC_CONTEXT *pContext;
    void *pUserMarshalList;
    INT_PTR Reserved51_2;
    INT_PTR Reserved51_3;
    INT_PTR Reserved51_4;
    INT_PTR Reserved51_5;
}
//C         return _Ptr;
pure HWND HWND_TOP() {return cast(HWND)0;}
pure WORD LOWORD(T)(T l) {return cast(WORD)((cast(DWORD_PTR)l) & 0xffff);}
pure WORD HIWORD(T)(T l) {return cast(WORD)((cast(DWORD_PTR)l) >> 16);}
pure short GET_WHEEL_DELTA_WPARAM(DWORD wParam) {return cast(short)HIWORD(wParam);}
static if (__traits(compiles, typeof(_CONST_RETURN))) static if (!__traits(isStaticFunction, _CONST_RETURN)) static if (__traits(isPOD, typeof(_CONST_RETURN))) const _WConst_return = _CONST_RETURN;
