Class App.Data.StartupEvent Extends %Persistent
{

Property StartedAt As %TimeStamp [ Required ];

Property VariableName As %String(MAXLEN = 128) [ Required ];

Property VariableIsSet As %Boolean [ Required ];

ClassMethod summary(Output count As %Integer, Output lastRunAt As %TimeStamp) As %Status
{
    set count = 0
    set lastRunAt = ""

    &sql(
        SELECT COUNT(*), MAX(StartedAt)
        INTO :count, :lastRunAt
        FROM App_Data.StartupEvent
    )

    if SQLCODE < 0 {
        return $$$ERROR($$$SQLError, SQLCODE, $get(%msg))
    }
    return $$$OK
}

}

