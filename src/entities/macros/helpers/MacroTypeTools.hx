package entities.macros.helpers;

#if macro

import haxe.macro.Type;

class MacroTypeTools {
    public static function hasInterface(type:Type, requestedInterface:String, lookInSuperClasses:Bool = true):Bool {
        switch (type) {
            case TInst(t, params):
                var classType = t.get();
                while (classType != null) {
                    if (classType.interfaces != null) {
                        for (i in classType.interfaces) {
                            if (i.t.toString() == requestedInterface) {
                                return true;
                            }
                        }
                    }
                    if (lookInSuperClasses) {
                        if (classType.superClass != null) {
                            classType = classType.superClass.t.get();
                        } else {
                            classType = null;
                        }
                    } else{
                        classType = null;
                    }
                }
            case _:    
        }

        return false;
    }
}

#end