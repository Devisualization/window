gcc main.c -E -P > $1

echo $1 > temp
sed -i 's/.[a-zA-Z]$//g' temp
sed -i 's/\//./g' temp
module=`cat temp`

echo $1 > temp
sed -i 's/\//\\\//g' temp
fileDash=`cat temp`

rm temp

echo "Using module $module"

echo "Output file $1"

cp $1 $1.temp
cat $1.temp |
grep -v "#pragma.*" |
grep -v "__dllimport__" |
grep -v "__gnuc" |
grep -v "vector_size__" |
grep -v "__m128" > $1

sed -i 's/, /,/g' $1

sed -i 's/__extension__//g' $1
sed -i 's/__inline__//g' $1
sed -i 's/__inline//g' $1
sed -i 's/__volatile__//g' $1
sed -i 's/__restrict__//g' $1

sed -i 's/__attribute__[ ]*((__aligned__[ ]*(16)))//g' $1
sed -i 's/__attribute__[ ]*\([(__cdecl__)(__always_inline__)(__artificial__)(__gnu_inline__)(__returns_twice__)(__nothrow__)(__dllimport__),]*\)//g' $1

sed -i 's/align)/align_)/g' $1

sed -i '/^[ \t]*$/d' $1

sed -i 's/typedef EXCEPTION_DISPOSITION ( \*PEXCEPTION_ROUTINE)/typedef struct EXCEPTION_DISPOSITION\* PEXCEPTION_ROUTINE;/g' $1
sed -i 's/(PEXCEPTION_RECORD ExceptionRecord,/typedef struct PEXCEPTION_RECORD ExceptionRecord;/g' $1
sed -i 's/ULONG64 EstablisherFrame,/typedef ULONG64 EstablisherFrame;/g' $1
sed -i 's/PCONTEXT ContextRecord,/typedef struct PCONTEXT ContextRecord;/g' $1;

sed -i 's/(typedef struct PCONTEXT ContextRecord;/(PCONTEXT ContextRecord,/g' $1;
sed -i 's/,typedef struct PCONTEXT ContextRecord;PVOID/,PCONTEXT ContextRecord,PVOID/g' $1
sed -i 's/Ptypedef ULONG64 EstablisherFrame;PKNONVOLATILE_CONTEXT_POINTERS/PULONG64 EstablisherFrame,PKNONVOLATILE_CONTEXT_POINTERS/g' $1

sed -i 's/PDISPATCHER_CONTEXT DispatcherContext);/typedef struct PDISPATCHER_CONTEXT DispatcherContext;/g' $1

./htod $1 $1.d

sed -i 's/C func(/function(/g' $1.d
sed -i 's/ in)/)/g' $1.d
sed -i 's/alias ubyte byte;//g' $1.d
sed -i 's/BSTR version,/BSTR version_,/g' $1.d
sed -i "s/module $fileDash;/module $module;/g" $1.d

sed -i 's/lconv \*lconv;/struct lconv_;lconv_ \*lconv;/g' $1.d
sed -i 's/__lc_time_data \*lc_time_curr;/struct __lc_time_data; __lc_time_data \*lc_time_curr;/g' $1.d
sed -i 's/alias long INT_PTR;/alias ptrdiff_t INT_PTR;/g' $1.d
sed -i 's/alias long \*PINT_PTR;/alias ptrdiff_t \*PINT_PTR;/g' $1.d
sed -i 's/alias ulong UINT_PTR;/alias size_t UINT_PTR;/g' $1.d
sed -i 's/alias ulong \*PUINT_PTR;/alias size_t \*PUINT_PTR;/g' $1.d
sed -i 's/alias UINT_PTR WPARAM;/alias uint* WPARAM;/g' $1.d
sed -i 's/alias LONG_PTR LPARAM;/alias ulong* LPARAM;/g' $1.d
sed -i 's/alias LONG_PTR LRESULT;/alias ulong* LRESULT;/g' $1.d

sed -i 's/alias IDispatch \*LPDISPATCH;//g' $1.d
echo 'alias IDispatch *LPDISPATCH;' >> $1.d
sed -i 's/alias ITypeComp \*LPTYPECOMP;//g' $1.d
echo 'alias ITypeComp *LPTYPECOMP;' >> $1.d
sed -i 's/alias ITypeInfo \*LPTYPEINFO;//g' $1.d
echo 'alias ITypeInfo *LPTYPEINFO;' >> $1.d
sed -i 's/alias ITypeLib \*LPTYPELIB;//g' $1.d
echo 'alias ITypeLib *LPTYPELIB;' >> $1.d

sed -i 's/    DWORD RatePercent(DWORD value) { ( 0xffffffffffffff80) | (value << 0); return value; }//g' $1.d
sed -i 's/    DWORD Reserved0(DWORD value) { ( 0xffffffff0000007f) | (value << 7); return value; }//g' $1.d

sed -i 's/(...)/()/g' $1.d

sed -i 's/extern (C):/extern (System):/g' $1.d

sed -i 's/(Ê@H >> 0) & //g' $1.d
sed -i 's/Ê@H = (Ê@H &/(/g' $1.d
sed -i 's/(Ê@H >> 31) & //g' $1.d
sed -i 's/(Ê@H >> 7) & //g' $1.d

echo 'struct threadmbcinfostruct;' >> $1.d
echo 'struct EXCEPTION_DISPOSITION;' >> $1.d
echo 'struct _EXCEPTION_REGISTRATION_RECORD;' >> $1.d
echo 'struct _TEB;' >> $1.d
echo 'struct _NDR_ASYNC_MESSAGE;' >> $1.d
echo 'struct _NDR_CORRELATION_INFO;' >> $1.d
echo 'struct NDR_ALLOC_ALL_NODES_CONTEXT;' >> $1.d
echo 'struct NDR_POINTER_QUEUE_STATE;' >> $1.d
echo 'struct _NDR_PROC_CONTEXT;' >> $1.d
echo 'struct _PSP;' >> $1.d
echo 'pure HWND HWND_TOP() {return cast(HWND)0;}' >> $1.d
echo 'pure WORD LOWORD(T)(T l) {return cast(WORD)((cast(DWORD_PTR)l) & 0xffff);}' >> $1.d
echo 'pure WORD HIWORD(T)(T l) {return cast(WORD)((cast(DWORD_PTR)l) >> 16);}' >> $1.d
echo 'pure short GET_WHEEL_DELTA_WPARAM(DWORD wParam) {return cast(short)HIWORD(wParam);}' >> $1.d
echo 'alias GWLP_USERDATA GWL_USERDATA;' >> $1.d

cp $1.d $1.temp
cat $1.temp |
grep -v '(DWORD value) { __bitfield1 = ' |
grep -v '__bitfield1 = (__bitfield1' |
grep -v '(DWORD value) { ( 0x[a-fA-F0-9]*) | ' |
grep -v 'extern const GUID ' |
grep -v 'extern const IID '> $1.d

gcc main.c -E -P -dM > $1.vars
cp $1.vars $1.temp
cat $1.temp | awk '
function rindex(str,c) {
  return match(str,"\\" c "[^" c "]*$")? RSTART : 0
}
function ltrim(v) { 
   gsub(/^[ \t]+/, "", v); 
   return v; 
} 
function rtrim(v) { 
   gsub(/[ \t]+$/, "", v); 
   return v; 
} 
function trim(v) { 
   return ltrim(rtrim(v)); 
} 

/^.*#define [a-zA-Z0-9_]+ +-?[xA-F><0-9]+$/{
$line = substr($0, index($0, "#define"));
$n = split($line, vals, " ");
val="";
for(i=3;i<=$n;i++)
	val=val" "vals[i];
if (val != "" && index(vals[2], "(") == 0)
	print "const", vals[2], "="val";";
for(i in vals)
	delete vals[i];
};

/^.* [A-Za-z_0-9]+ *\( *-?[xA-F><0-9]+ *\)$/{
line = substr($0, index($0, "#define"));
n = split(line, vals, " ");
start = rindex(line, "(") + 1;
end = index($line, ")") - start
val = substr(line, start, end);
if (val != "" && index(vals[2], "(") == 0)
	print "const",vals[2],"=",val";";
};

/^.*#define [a-zA-Z0-9_]+ *\(int\) *-?[xA-F><0-9]+$/{
$line = substr($0, index($0, "#define"));
$n = split($line, vals, " ");
val="";
for(i=3;i<=$n;i++)
	val=val" "vals[i];
if (val != "" && index(vals[2], "(") == 0)
	print "const", vals[2], "=" substr(val, 7)";";
for(i in vals)
	delete vals[i];
};

/^ *#define [A-Za-z_0-9]+ *\( *\(int\) *-?[xA-F><0-9]+ *\)$/{
line = substr($0, index($0, "#define"));
n = split(line, vals, " ");
start = rindex(line, "(") + 5;
end = rindex(line, ")") - start
val = substr(line, start, end);
if (val != "")
	print "const",vals[2],"=",val";";
};

/^.*#define [a-zA-Z0-9_]+ [xA-F><0-9]+L$/{
$line = substr($0, index($0, "#define"));
$n = split($line, vals, " ");
val="";
for(i=3;i<=$n;i++)
	val=val" "vals[i];
if (val != "" && index(vals[2], "(") == 0)
	print "const", vals[2], "="substr(val, 0, length(val)-1)";";
for(i in vals)
	delete vals[i];
};

/^.* [A-Za-z_0-9]+\([xA-F><0-9]+L\)$/{
line = substr($0, index($0, "#define"));
n = split(line, vals, " ");
start = rindex(line, "(") + 1;
end = index($line, ")") - start
val = substr(line, start, end);
if (val != "" && index(vals[2], "(") == 0)
	print "const",vals[2],"=",substr(val, 0, length(val)-1)";";
};

/^.*#define [a-zA-Z0-9_]+ L?".*"$/{
$line = substr($0, index($0, "#define"));
$n = split($line, vals, " ");
val="";
for(i=3;i<=$n;i++)
	val=val" "vals[i];
val = trim(val);
if (match(val, "^L.*") > 0)
	val = substr(val, 2);
if (val != "" && index(vals[2], "(") == 0)
	print "const", vals[2], "=", val";";
for(i in vals)
	delete vals[i];
};

/^.*#define [a-zA-Z0-9_]+ [a-zA-Z_]+[A-Z][a-zA-Z_0-9+]$/{
$line = substr($0, index($0, "#define"));
$n = split($line, vals, " ");
val="";
for(i=3;i<=$n;i++)
	val=val" "vals[i];
val = trim(val);
if (val != "" && index(vals[2], "(") == 0)
	print "static if (__traits(compiles, typeof("val"))) static if (!__traits(isStaticFunction, "val")) static if (__traits(isPOD, typeof("val")))","const", vals[2], "=", val";";
for(i in vals)
	delete vals[i];
};

/^ *#define [a-zA-Z][a-zA-Z_0-9]*  *\( *([a-zA-Z][a-zA-Z_0-9]*( *\| *)*)+\)$/{
$line = substr($0, index($0, "#define"));
$n = split($line, vals, " ");
val="";
for(i=3;i<=$n;i++)
	val=val" "vals[i];
val = trim(val);
if (val != "" && index(vals[2], "(") == 0)
	print "static if (__traits(compiles, typeof("val"))) static if (!__traits(isStaticFunction, "val")) static if (__traits(isPOD, typeof("val")))","const", vals[2], "=", val";";
for(i in vals)
	delete vals[i];
};' |
grep -v "__VERSION__" | grep -v "GUID_DEVINTERFACE_STORAGEPORT" >> $1.d

rm $1.temp