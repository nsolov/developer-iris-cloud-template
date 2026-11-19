Class App.REST Extends %CSP.REST
{

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes> 
    <Route Url="/status" Method="GET" Call="getStatus" />
    <Route Url="/todos" Method="GET" Call="getTodos" />
    <Route Url="/todos" Method="POST" Call="createTodo" />
    <Route Url="/todos/:id" Method="DELETE" Call="deleteTodo" />
</Routes>
}

ClassMethod getTodos() As %Status
{
    set todos = []
    set result = ##class(%ResultSet).%New("App.Data.Todo:List")
    set sc = result.Execute()
    return:$system.Status.IsError(sc) sc

    while result.Next() {
        do todos.%Push({
            "id": (+(result.Get("ID"))),
            "text": (result.Get("Text")),
            "createdAt": (result.Get("CreatedAt"))
        })
    }

    set %response.ContentType = "application/json; charset=utf-8"
    write todos.%ToJSON()
    return $$$OK
}

ClassMethod createTodo() As %Status
{
    try {
        set payload = {}.%FromJSON(%request.Content)
    } catch exception {
        return ..writeError(400, "Request body must be valid JSON")
    }

    set text = $zstrip(payload.%Get("text", ""), "<>W")
    return:text="" ..writeError(400, "Todo text is required")
    return:$length(text)>200 ..writeError(400, "Todo text must be 200 characters or fewer")

    set sc = ##class(App.Data.Todo).create(text, .id)
    return:$system.Status.IsError(sc) sc

    set todo = {
        "id": (+id),
        "text": (text)
    }
    set %response.Status = "201 Created"
    set %response.ContentType = "application/json; charset=utf-8"
    write todo.%ToJSON()
    return $$$OK
}

ClassMethod deleteTodo(id As %Integer) As %Status
{
    return:id<1 ..writeError(400, "Invalid todo id")
    set todo = ##class(App.Data.Todo).%OpenId(id)
    return:todo="" ..writeError(404, "Todo item not found")

    set sc = ##class(App.Data.Todo).%DeleteId(id)
    return:$system.Status.IsError(sc) sc
    set %response.Status = "204 No Content"
    return $$$OK
}

ClassMethod writeError(status As %Integer, message As %String) As %Status
{
    set %response.Status = status
    set %response.ContentType = "application/json; charset=utf-8"
    write {"error": (message)}.%ToJSON()
    return $$$OK
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

