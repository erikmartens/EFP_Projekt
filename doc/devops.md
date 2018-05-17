# devops

## Reverse Proxy

Der Proxy nimmt alle von außen an docker geleitete Requests an und leitet diese entsprechend des Pfades an die entsprechenden Mircoservices weiter.
Durch den Einsatz des Proxys muss nur ein Port für das Projekt geöffnet sein. Des Weiteren kann nun im Frontend die Hostangabe für das Backend entfallen.

Alle Requests, die mit ``<host>:<port>/api/`` anfangen, werden an das Backend weitergeleitet, der Rest an das Frontend gesendet. Der Mircoservice nutzt ``nginx`` als Server.
## Frontend

Das Frontend nimmt alle auf Port 80 ankommenden Requests entgegen und liefert die ensprechende Response zurück. Der Mircoservice nutzt ``nginx`` als Server.

## Backend

Das Backend nutzt einen ``jetty`` Server für Clojure und den Port 5000.

## Mögliche Verbesserungen

Das Frontend sollte auf den Port 5000 verschoben werden und alle Mircorservices nicht mehr als ``root`` laufen. Die Erzeugungsartefakte werden noch in die Container übernommen. Dies sollte durch einen eigenen Build-Container behoben werden.

## build-Skripte

Diese Skripte dienen der Bequemlichkeit, um nicht immer den langen ```docker-compose```-Befehl eintippen zu müssen.

### build.sh

Generiert für das Back- und Frontend nach Änderungen neue Images.

### build-backend.sh

Generiert ein neues Backend Image.

### build-frontend.sh

Generiert ein neues Frontend Image.

### init.sh

Generiert das reverse-proxy Image. Dies ist nicht in build.sh erhalten, da das Image nur einmal erzeugt werden muss und daran keine Änderungen nötig sein sollten.

## docker-Skripte

Das System wird mittels ```docker-compose``` orchestriert. In ``efp-yaml`` werden die drei Microservices definiert. Falls der Port 8080 auf dem Host schon vergeben ist, kann man ihn dort ändern.

### down.sh

Stoppt die Mircoservices und entfernt die Container.

### logs.sh

Zeigt den Inhalt der  Standardausgabe der Container an.
### stop.sh

Stoppt die Container.

### up.sh

Startet alle Container

### update.sh

Stoppt und Entfernt die bestehenden Container und Startet die aktualisierten Images.

### logs/stop/up

Die Skripte können auch für einen einzelnen Container benutzt werden.
    ```./<script>.sh <container-name>```
    
### Ergänzend

Muss in einen Container eingeriffen werden, kann man ```docker exec -ti <extenden-container-name> sh``` nutzen. Dies öffnet eine ```sh```-Konsole im Container.

Bsp.:
    
    container-name: efp-frontend
    extended-container-name: efp_efp-frontend_1

## Deployment

Das System nutzt die lokale Registry.

1. init.sh ausführen
2. build.sh ausführen
3. up.sh ausführen