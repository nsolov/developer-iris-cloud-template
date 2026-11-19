Class App.Data.Todo Extends %Persistent
{

Property Text As %String(MAXLEN = 200) [ Required ];

Property CreatedAt As %TimeStamp [ Required ];

Query List() As %SQLQuery
{
    SELECT ID, Text, CreatedAt
    FROM App_Data.Todo
    ORDER BY ID DESC
}

ClassMethod create(text As %String, Output id As %Integer) As %Status
{
    set todo = ..%New()
    set todo.Text = text
    set todo.CreatedAt = ##class(%Library.UTC).NowUTC()
    set sc = todo.%Save()
    set:$system.Status.IsOK(sc) id = todo.%Id()
    return sc
}

ClassMethod remove(id As %Integer) As %Status
{
    set todo = ..%OpenId(id)
    return:todo="" $$$ERROR($$$GeneralError, "Todo item not found")
    return todo.%DeleteId(id)
}

/// Populate a fresh persistent database so the first page is useful immediately.
/// The marker is stored in APP-DATA, so deleting every item does not seed again.
ClassMethod seed() As %Status
{
    return:$get(^App.Metadata("todoSeeded")) $$$OK

    set sc = ..create("Explore the Developer Sandbox example", .id)
    return:$system.Status.IsError(sc) sc
    set sc = ..create("Add your first task", .id)
    return:$system.Status.IsError(sc) sc
    set sc = ..create("Delete this sample item", .id)
    return:$system.Status.IsError(sc) sc

    set ^App.Metadata("todoSeeded") = 1
    return $$$OK
}

}
