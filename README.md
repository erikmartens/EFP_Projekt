# EFP_Projekt - Chat Bot

---

## Aufgaben-Verteilung

- [ ] Speicherung der Nutzerdaten: Pro Anfrage neuer Eintrag in MongoDB Datenbank -> (userID, timeStamp, intent)

__Erik__
- [x] Fragen-Erkennen-Lösungen finden
- [ ] Dokumentation eigener Teil
- [ ] Telegram Schnittstelle
- [ ] Web-Frontend (Design)
- [ ] Präsentation

__Johannes__
- [x] Fragen-Erkennen-Lösungen finden
- [ ] Dokumentation eigener Teil
- [ ] Email Schnittstelle

__Nico__
- [x] Fragen-Erkennen-Lösungen finden
- [ ] Dokumentation eigener Teil
- [x] Dev-Ops & Deployment
- [ ] Web-Frontend (Funktionen)

---

## Anforderungen

__Allgemein (Projekt)__
- [ ] muss bei der Abschlusspräsentation am 25.06. von mindestens einem Gruppenmitglied demonstriert werden.

__Nichtfunktional__
- [x] Muss in Clojure programmiert sein.
- [x] Muss per REST angesprochen werden können.
- [ ] Muss mindestens drei verschiedene Design Patterns für funktionale Programmierung verwenden.
- [ ] Soll eine generische Lösung darstellen (Email): Termine und Inhalt der Email-Nachricht soll konfigurierbar sein.

__Funktional__
- [ ] Muss für jeden eingeschriebenen Nutzer eines Moodle-Kurses einen Zustand verwalten.
- [x] Soll ein Web-Frontend haben, das ohne Moodle verwendbar ist.
- [ ] Soll im verwalteten Zustand eines Moodle-Kurs-Nutzers den Stand des Kommunikationsablaufes repräsentieren.
- [x] Muss eine [Frage](https://jonathan.sv.hs-mannheim.de/mediawiki/index.php/Praxissemester_FAQ) zum Praxissemester beantworten können. Die Erkennung der Frage muss dabei flexibel sein.
- [x] Soll jeweils drei andere weitere Fragen zum Praxissemester flexibel erkennen und beantworten können (mehrfach möglich).
- [ ] Muss eine Kommunikationsschnittstelle für Chats (bspw. IRC, Facebook) oder E-Mail unterstützen.
- [ ] Soll zu mindestens drei vordefinierten Zeitpunkten im Semester von sich aus per E-Mail Nachrichten an die eingeschriebenen Nutzern eines Moodle-Kurses versenden und z.B. auf Fristen hinweisen.

__Dokumentation__
- [ ] Muss bis 13.07. (COB) dokumentiert und im Quellcode abgegeben sein.
- [ ] Muss über Moodle als PDF oder als Link auf ein PDF oder Markdown-Dokument in github oder vergleichbar abgegeben werden.
- [x] Muss die Schnittstelle des Micro-Service spezifizieren.
- [ ] Soll den Aufbau des Micro-Service erläutern und die verwendeten Design Patterns für funktionale Programmierung aufzeigen.
- [x] Soll den Mechanismus, mit dem der entwickelte Micro-Service Benutzereingaben klassifiziert, beschreiben.

---

## REST-Schnittstelle

### Chat Nachricht zum Bot schicken

#### Request
- Resource: Query
- Body: 
	`{ 
		userId: String, 
		userChatMessage: String,
		timeStamp: Number 
	}`

#### Response
- Resource:
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

## Telegram Bot

> Beschreibung der Telegram Bot API: https://core.telegram.org/bots/api

- __Bot User Name:__ HSMAPraxisSemesterBot
- __URL:__ https://t.me/HSMAPraxisSemesterBot
- __Token:__ `619166619:AAETbQdzarQiXd9yKUlmhs3zlVmzTceHPJU`



---