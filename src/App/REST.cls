Class App.REST Extends %CSP.REST
{

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes> 
    <Route Url="/status" Method="GET" Call="getStatus" />
</Routes>
}

ClassMethod getStatus() As %Status
{
    set variableName = ##class(App.Init).#VARIABLE
    set variableValue = $system.Util.GetEnviron(variableName)
    set count = 0
    set lastRunAt = ""
    set sc = ##class(App.Data.StartupEvent).summary(.count, .lastRunAt)
    return:$system.Status.IsError(sc) sc

    set variable = {
        "name": (variableName),
        "value": (variableValue)
    }
    do variable.%Set("isSet", (variableValue '= ""), "boolean")

    set response = {
        "variable": (variable),
        "irisInit": {
            "runCount": (+count),
            "lastRunAt": (lastRunAt)
        }
    }

    set %response.ContentType = "application/json; charset=utf-8"
    write response.%ToJSON()
    return $$$OK
}

}

