Class App.Init
{

Parameter VARIABLE = "APP_MESSAGE";

/// Called by Developer Cloud after every successful IRIS start.
/// APP:##class(App.Init).run()
ClassMethod run() As %Status
{
    set variableValue = $system.Util.GetEnviron(..#VARIABLE)
    set event = ##class(App.Data.StartupEvent).%New()
    set event.StartedAt = ##class(%Library.UTC).NowUTC()
    set event.VariableName = ..#VARIABLE
    set event.VariableIsSet = (variableValue '= "")
    set sc = event.%Save()
    return:$system.Status.IsError(sc) sc
    return ##class(App.Data.Todo).seed()
}

}

