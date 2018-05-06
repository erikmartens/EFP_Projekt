# EFP_Projekt

## Chat Bot

### Aufgaben-Verteilung

__Erik__
- [ ] Fragen-Erkennen-Lösungen finden
- [ ] Dokumentation eigener Teil
- [ ] Telegram Schnittstelle
- [ ] Web-Frontend (Design)
- [ ] Präsentation

__Johannes__
- [ ] Fragen-Erkennen-Lösungen finden
- [ ] Dokumentation eigener Teil
- [ ] Email Schnittstelle

__Nico__
- [ ] Fragen-Erkennen-Lösungen finden
- [ ] Dokumentation eigener Teil
- [ ] Dev-Ops & Deployment
- [ ] Web-Frontend (Funktionen)


### Anforderungen

__Allgemein (Projekt)__
- [ ] muss bei der Abschlusspräsentation am 25.06. von mindestens einem Gruppenmitglied demonstriert werden.

__Nichtfunktional__
- [x] muss in Clojure programmiert sein.
- [ ] muss per REST angesprochen werden können.
- [ ] muss mindestens drei verschiedene Design Patterns für funktionale Programmierung verwenden.
- [ ] soll eine generische Lösung darstellen: Termine und Inhalt der Nachricht soll konfigurierbar sein.

__Funktional__
- [ ] muss für jeden eingeschriebenen Nutzer eines Moodle-Kurses einen Zustand verwalten.
- [ ] soll ein Web-Frontend haben, das ohne Moodle verwendbar ist.
- [ ] soll im verwalteten Zustand eines Moodle-Kurs-Nutzers den Stand des Kommunikationsablaufes repräsentieren.
- [ ] muss eine [Frage](https://jonathan.sv.hs-mannheim.de/mediawiki/index.php/Praxissemester_FAQ) zum Praxissemester beantworten können. Die Erkennung der Frage muss dabei flexibel sein.
- [ ] soll jeweils drei andere weitere Fragen zum Praxissemester flexibel erkennen und beantworten können (mehrfach möglich).
- [ ] muss eine Kommunikationsschnittstelle für Chats (bspw. IRC, Facebook) oder E-Mail unterstützen.
- [ ] soll zu mindestens drei vordefinierten Zeitpunkten im Semester von sich aus per E-Mail Nachrichten an die eingeschriebenen Nutzern eines Moodle-Kurses versenden und z.B. auf Fristen hinweisen.

__Dokumentation__
- [ ] muss bis 13.07. (COB) dokumentiert und im Quellcode abgegeben sein.

- [ ] muss über Moodle als PDF oder als Link auf ein PDF oder Markdown-Dokument in github oder vergleichbar abgegeben werden.
- [ ] muss die Schnittstelle des Micro-Service spezifizieren.
- [ ] soll den Aufbau des Micro-Service erläutern und die verwendeten Design Patterns für funktionale Programmierung aufzeigen.
- [ ] soll den Mechanismus, mit dem der entwickelte Micro-Service Benutzereingaben klassifiziert, beschreiben.