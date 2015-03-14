/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2014 Devisualization (Richard Andrew Cattermole)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
module devisualization.window.interfaces.eventable;
import std.string : toUpper;
import std.algorithm : filter, moveAll;

/**
 * Provides an interface version of an eventing mechanism.
 * 
 * See_Also:
 *         Eventing
 */
mixin template IEventing(string name, T...) {
    mixin("void add" ~ toUpper(name[0] ~ "") ~ name[1 ..$] ~ q{(bool delegate(T));});
    mixin("void add" ~ toUpper(name[0] ~ "") ~ name[1 ..$] ~ q{(void delegate(T));});

    mixin("void remove" ~ toUpper(name[0] ~ "") ~ name[1 ..$] ~ q{(bool delegate(T));});
    mixin("void remove" ~ toUpper(name[0] ~ "") ~ name[1 ..$] ~ q{(void delegate(T));});
    
    mixin("size_t count" ~ toUpper(name[0] ~ "") ~ name[1 ..$] ~ "();");

    mixin("void clear" ~ toUpper(name[0] ~ "") ~ name[1 ..$] ~ q{();});
    
    static if (__traits(compiles, typeof(this)) && is(typeof(this) : T[0])) {
        mixin("void " ~ name ~ q{(T[1 .. $] args);});
	} else {
		mixin("void " ~ name ~ q{(T args);});
	}
}


/**
 * Implements an eventable interface for something.
 * Includes support for bool delegate(T) and void delegate(T).
 * Will consume a call to all delegates if it returns true. Default false.
 * 
 * Example usage:
 *         mixin Eventing!("onNewListing", ListableObject);
 * 
 * If is(T[0] == typeof(this)) then it'll use this as being the first argument. 
 */
mixin template Eventing(string name, T...) {
    private {
        mixin(q{bool delegate(T)[] } ~ name ~ "_;");
        mixin(q{bool delegate(T)[void delegate(T)] } ~ name ~ "_assoc;");
    }

    mixin("void add" ~ toUpper(name[0] ~ "") ~ name[1 ..$] ~ q{(void delegate(T) value) {
        mixin(name ~ "_ ~= (T args) => {value(args); return false;}();");
        mixin(name ~ "_assoc[value] = " ~ name ~ "_[$-1];");
    }});

    mixin("void add" ~ toUpper(name[0] ~ "") ~ name[1 ..$] ~ q{(bool delegate(T) value) {
        mixin(name ~ "_ ~= value;"); 
    }});

    mixin("void remove" ~ toUpper(name[0] ~ "") ~ name[1 ..$] ~ q{(bool delegate(T) value) {
		import std.range : walkLength;
		
		mixin("auto t = filter!(a => a !is value)(" ~ name ~ "_);");
		t.moveAll(mixin(name ~ "_"));
		mixin(name ~ "_.length = t.walkLength;");
    }});

    mixin("void remove" ~ toUpper(name[0] ~ "") ~ name[1 ..$] ~ q{(void delegate(T) value) {
		import std.range : walkLength;
		
		mixin("auto t = filter!(a => a !is " ~ name ~ "_assoc[value])(" ~ name ~ "_);");
		t.moveAll(mixin(name ~ "_"));
		mixin(name ~ "_.length = t.walkLength;");

        mixin(name ~ "_assoc.remove(value);");
	}});
    
    mixin("size_t count" ~ toUpper(name[0] ~ "") ~ name[1 ..$] ~ q{(){
        return cast(size_t)(mixin(name ~ "_.length") + mixin(name ~ "_assoc.length")); 
    }});
    
    mixin("void clear" ~ toUpper(name[0] ~ "") ~ name[1 ..$] ~ q{() {
        mixin(name ~ "_") = [];
    }});
    
    static if (__traits(compiles, typeof(this)) && is(typeof(this) : T[0])) {
        mixin("void " ~ name ~ q{(T[1 .. $] args) {
            foreach (del; mixin(name ~ "_")) {
                if (del(this, args))
                    return;
            }
        }});
    } else {
        mixin("void " ~ name ~ q{(T args) {
            foreach (del; mixin(name ~ "_")) {
                if (del(args))
                    return;
            }
        }});
    }
}