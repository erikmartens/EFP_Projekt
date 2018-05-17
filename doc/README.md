# EFP SS2018 Chatbot

# Devops

Das System besteht aus drei ``Docker``-Container, die mittels `docker-compose` orchestiert werden.
Das System besteht aus einem Backendserver, der die Grundlagen der Intenterkennung liefert.
Daneben existiert ein Frontend, um das System benutzbar zu machen.
Aus Sicherheistgründen wurden dem Front- und Backend ein Reverse Proxy vorgeschaltet.

## Reverse Proxy

Der Proxy nimmt alle von außen an docker geleitete Requests an und leitet diese entsprechend des Pfades an die entsprechenden Mircoservices weiter.
Durch den Einsatz des Proxys muss nur ein Port für das Projekt geöffnet sein.
Des Weiteren kann nun im Frontend die Hostangabe für das Backend entfallen.
Darüber hinaus könnte man ihn zur Lastenverteilung einsetzen.

Alle Requests, die mit ``api/`` anfangen, werden an das Backend weitergeleitet, der Rest an das Frontend gesendet.
Der Mircoservice nutzt ``nginx`` als Server.
## Frontend

Das Frontend nimmt alle auf Port 80 ankommenden Requests entgegen und liefert die ensprechende Response zurück.
Der Mircoservice nutzt ``nginx`` als Server.
Alle Frontend Requests werden über ```/api/...``` an das Backend gesendet. 

## Backend

Das Backend nutzt einen ``jetty`` Server für Clojure und den Port 5000.

### REST

Das REST Interface ist von Dialogflow inspiriert.
Als einzige Resource steht ``/query`` zur Verfügung.

#### Request
- Resource: Query
- Body: 
	`{ 
		userId: String, 
		userChatMessage: String,
		timeStamp: Number 
	}`

#### Response
- Resource: Query
- StatusCode: HTTP-Status-Code
- Body: 
	`{ 
		statusCode: Number, 
		userId: String, 
		userChatMessage: String, 
		botChatMessage: String, 
		intentName: String, 
		timeStamp: Number 
	}`
	
Das REST Interface ist im ```backend```-Ordner (`rest.yaml`) mittels ``swagger`` annotiert.

## Mögliche Verbesserungen

Das Frontend sollte auf den Port 5000 verschoben werden und alle Mircorservices nicht mehr als ``root`` laufen. Die Erzeugungsartefakte werden noch in die Container übernommen. Dies sollte durch einen eigenen Build-Container behoben werden.

# Backend

## Eingesetzte Pattern

1. Chain of Operations
2. map, filter, reduce
3. ...

## Intenterkennung

Alle Praxissemsterfragen sind in einer JSON-Datei abgelegt.
Jeder Frage ist ein eindeutiger Intent zugeordnet.
Für jede Fragen können mehrere Varianten angegeben werden.

Wenn das Backend gestartet wird, werden die Fragen geladen und anschließend wie jede ankommende Nutzerfrage bearbeitet (``prepare-sentence``):

1. Alle Satz- und Sonderzeichen werden entfernt. (```remove-punctuation```)
2. Alle unnötigen Wörter (``stop words``) werden entfernt (`remove-stop-words).
    Alle in diesem Schritt entfernte Wörter tragen nichts zum Erkennen der Frage bei.
    Dies sind unter anderem der, die, das, ist, dessen (siehe ``backend/resources/stop-words.json``).
3. Alle Wörter werden auf den Grundtyp abgebildet (``stem-sentence``).
    Um alle Fragen grammatikalisch anzugleichen und ähnliche Wörter auf den Grundtyp abzubilden, wird ein Stemming genannter Vorgang ausgeführt.
    Während des Stemmings werden die Wordenden heuristisch abgeschnitten.
    
Nachdem die Nutzeranfrage auch bearbeitet wurde, wird mit allen Chatbot-Fragen die Kosinus-Ähnlichkeit errechnet und anschließend die Frage mit dem höchsten Wert zurückgeliefert.


# Frontend

Das Frontend ist in Elm, einer an Haskell orientierten funktionalen Programmiersprache implementiert.
Elm wird durch einen Compiler zu JavaScript transpiliert.


## Eingesetzte Pattern

1. Chain of Operations

    Das `Elm`-Äquivalent zum `Clojure` Threading-Makro `->>` ist `|>`.
    Als Beispiel ist die Funktion ```fetchChatbotRequest``` zu nenen:
    ```elm
    fetchChatbotMessage : String -> String -> Time.Time -> Cmd Msg
    fetchChatbotMessage userId userMessage timestamp =
        Http.post
            "/api/query"
            (Http.jsonBody (encodeUserChatMessageToJson userMessage userId timestamp))
            chatbotMessageDecoder
                |> RemoteData.sendRequest
                |> Cmd.map FetchChatbotMessage
    ``` 

2. Domain Specific Language

    ``Elm`` abstrahiert den ``DOM`` und `HTML`.
    Alle ``DOM``-Zugriffe werden von `Elm` erledigt.
    Das Layout wird mittels des ``Html``-Moduls erzeugt.
    Siehe die ```view```-Funktion.

3. filter, map, reduce