# Intenterkennung

Statisch:

    eine Liste aller möglichen Fragen, zusammen mit dem Intent
    mehrere Varianten aller Fragen (optional)

## Erkennungsalgorithmus:

Input: Chat-Nachricht des Benutzers als String

Output: Chat-Nachricht des Bots als String

1. Rechtschreibüberprüfung (optional)
2. Entfernung aller unnötigen Wörter (ist, der/die/das, sei, ...)
3. Entfernung aller Satzeichen
4. alle Wörter werden auf ihre Grundwörter abgebildet
5. der Cosine Similarity wird für alle Fragen ermittelt, und die Frage mit dem größten Wert zurückgegeben


Rechtschreibüberprüfung:
 
[Norvig Spelling Corrector](https://en.wikibooks.org/wiki/Clojure_Programming/Examples/Norvig_Spelling_Corrector)

[Snowball Stemmer](https://clojars.org/org.clojars.gnarmis/snowball-stemmer)

Cosine Similariy:

[cosine-similarity](https://github.com/WojciechKarpiel/cosine-similarity/blob/master/core.clj)

Anmerkung:

Mit der cosine-similarity ohne Rechtschreibprüfung und mehreren Fragen getestet. Es funktioniert überraschend gut.
Es sollte ausreichen wenn wir mehrere Versionen der Frage und eine Rechtschreibüberprüfung haben.