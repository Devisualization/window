module dwc.interfaces.eventable;
import std.string : toUpper;
import std.algorithm : filter, moveAll;

/**
 * Provides an interface version of an eventing mechanism.
 * 
 * See_Also:
 * 		Eventing
 */
mixin template IEventing(string name, T...) {
	mixin("void add" ~ toUpper(name[0] ~ "") ~ name[1 ..$] ~ q{(bool delegate(T));});
	mixin("void add" ~ toUpper(name[0] ~ "") ~ name[1 ..$] ~ q{(void delegate(T));});

	mixin("void remove" ~ toUpper(name[0] ~ "") ~ name[1 ..$] ~ q{(bool delegate(T));});
	mixin("void remove" ~ toUpper(name[0] ~ "") ~ name[1 ..$] ~ q{(void delegate(T));});
	
    mixin("size_t count" ~ toUpper(name[0] ~ "") ~ name[1 ..$] ~ "();");

	mixin("void " ~ name ~ q{(T args);});
	mixin("void clear" ~ toUpper(name[0] ~ "") ~ name[1 ..$] ~ q{(T args);});
	
	static if (T.length > 0) {
		static if (__traits(compiles, typeof(this)) && is(typeof(this) : T[0])) {
			mixin("void " ~ name ~ q{(T[1 .. $] args);});
		}
	}
}


/**
 * Implements an eventable interface for something.
 * Includes support for bool delegate(T) and void delegate(T).
 * Will consume a call to all delegates if it returns true. Default false.
 * 
 * Example usage:
 * 		mixin Eventing!("onNewListing", ListableObject);
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
			mixin("moveAll(filter!(a => a !is value)(" ~ name ~ "_), " ~ name ~ "_);"); 
		}});
	mixin("void remove" ~ toUpper(name[0] ~ "") ~ name[1 ..$] ~ q{(void delegate(T) value) {
			mixin("moveAll(filter!(a => a !is " ~ name ~ "_assoc.get(value, null))(" ~ name ~ "_), " ~ name ~ "_);"); 
		}});
	
    mixin("size_t count" ~ toUpper(name[0] ~ "") ~ name[1 ..$] ~ q{(){
            return cast(size_t)(mixin(name ~ "_.length") + mixin(name ~ "_assoc.length")); 
        }});

	mixin("void " ~ name ~ q{(T args) {
			foreach (del; mixin(name ~ "_")) {
				del(args);
			}
		}});
	
	mixin("void clear" ~ toUpper(name[0] ~ "") ~ name[1 ..$] ~ q{(T args) {
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