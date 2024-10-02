package entities.macros;

class Library {
    macro static function printInfo() {
        #if entities_as_externs
        Sys.println('entities    > using entities as externs (entities_as_externs)');
        #end
        #if (modular && !modular_host)
        Sys.println('entities    > using entities as externs (modular detected without modular-host)');
        #end
        return null;
    }
}