let
    Server = "https://influx.example.net:8086",
    Database = "homeassistant",
    Source = HomeAssistantInflux.History(
        Server,
        Database,
        {"sensor.living_room_temperature", "sensor.living_room_humidity"},
        RangeStart,
        RangeEnd,
        "mean",
        #duration(0, 1, 0, 0)
    )
in
    Source
