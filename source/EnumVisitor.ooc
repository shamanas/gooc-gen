use gi
import gi/[FunctionInfo, EnumInfo, Repository]
import OocWriter, Visitor, FunctionVisitor, Utils
import structs/ArrayList

EnumVisitor: class extends Visitor {
    info: EnumInfo
    init: func(=info)

    write: func(writer: OocWriter) {
        namespace := info getNamespace() toString()
        name := info oocType(namespace)
        // For some reason, the ctype of the enum is never populated and we cant directly get it as an attribute, so we fetch the prefix of the current namespace and prepend it to the name of the enum :D
        writer w("%s: extern(%s) enum {\n\n" format(name, info cType())) . indent()

        // Write our values
        first := true
        for(i in 0 .. info getNValues()) {
            if(first) first = false
            else writer uw(",\n")

            value := info getValue(i)
            writer w("%s: extern(%s)" format(value getName() toString() toCamelCase() escapeOoc(), value getAttribute("c:identifier")))
            value unref()
        }
        writer uw('\n')
        // Write our methods
        for(i in 0 .. info getNMethods()) {
            method := info getMethod(i)
            FunctionVisitor new(method, info) write(writer) . free()
            method unref()
        }

        writer uw('\n') . dedent() . w("}\n\n")
    }
}
