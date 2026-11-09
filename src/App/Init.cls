Class App.Init
{

Parameter VARIABLE = "APP_MESSAGE";

/// Called by Developer Cloud after every successful IRIS start.
ClassMethod run() As %Status
{
    set variableValue = $system.Util.GetEnviron(..#VARIABLE)
    set event = ##class(App.Data.StartupEvent).%New()
    set event.StartedAt = ##class(%Library.UTC).NowUTC()
    set event.VariableName = ..#VARIABLE
    set event.VariableIsSet = (variableValue '= "")
    return event.%Save()
}

}

