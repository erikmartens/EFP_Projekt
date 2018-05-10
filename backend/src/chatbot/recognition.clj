
(ns cosine-similarity.core
  (:require [clojure.string :as str]
            [clojure.java.io :as io]))


(defn split-words
  [input]
  (clojure.string/split (clojure.string/lower-case input) #"\W+"))

(defn make-hash-of-words
  "Creates hash table [:word number-of-occurencies]"
  ([input] (make-hash-of-words input {}))
  ([input hash-table]
   (reduce
    (fn [hash word] (assoc hash word (inc (get hash word 0))))
    hash-table
    (split-words input))))

(defn hash-vec-length
  [hash]
  (Math/sqrt (reduce (fn [result [_ val]] (+ result (* val val))) 0 hash)))


(defn hash-vec-product
  [hash1 hash2]
  (reduce
   (fn [result [key val]] (+ result (* val (get hash2 key 0))))
   0
   hash1))

(defn cosine-similarity-of-hashes
  [hash1 hash2]
  (let [product (future (hash-vec-product hash1 hash2))
        len1 (future (hash-vec-length hash1))
        len2 (future (hash-vec-length hash2))]
    (/ @product (* @len1 @len2))))

(defn cosine-similarity-of-strings
  [string1 string2]
  (let [hash1 (future (make-hash-of-words string1))
        hash2 (future (make-hash-of-words string2))]
    (cosine-similarity-of-hashes @hash1 @hash2)))

(defn make-hash-of-words-from-file
  [file]
  (make-hash-of-words (slurp file)))

(defn cosine-similarity-of-files
  [file1 file2]
  (let [hash1 (future (make-hash-of-words-from-file file1))
        hash2 (future (make-hash-of-words-from-file file2))]
    (cosine-similarity-of-hashes @hash1 @hash2)))

(def questions [
                 "Wo finde ich ausführliche Informationen zum Praxissemester?"
                 "Muss ich mich selbst um eine geeignete Praktikantenstelle kümmern?"
                 "Wie finde ich eine Praktikumsstelle?"
                 "und im Ausland?"
                 "Nicht in's Ausland und trotzdem Erasmus - wie geht denn das?"
                 "Welche Formalien sind vor Antritt des Praxissemesters zu beachten?"
                 "Wie muss der Vertrag mit dem Unternehmen aussehen?"
                 "Mein Vertrag sieht einen Zeitraum vor, der genau 100 Präsenztagen entspricht. Was passiert, wenn ich mal krank werden sollte?"
                 "Gibt es vorgeschriebene Arbeitszeiten?"
                 "BAföG im Praxissemester?"
                 "Kann man das Praxissemester verschieben?"
                 "Gründe und Voraussetzungen für das Verschieben"
                 "IB RGS 6 (gültig ab WS 2014/2015), IMB RGS 4 (gültig ab WS 2014/2015), UIB RGS 3 (gültig ab SS 2015)"
                 "IB RGS 7 (gültig ab WS 2017/2018), IMB RGS 5 (gültig ab WS 2017/2018), UIB RGS 4 (gültig ab WS 2017/2018)"
                 "MEB RGS 1"
                 "Prüfungen und Lehrveranstaltungen während des Praxissemesters"
                 "Was ist beim Verschieben des Praxissemesters zu beachten?"
                 "Können im Praxissemester auch Klausuren geschrieben werden?"
                 "Schreibwerkstatt, wissenschaftliches Arbeiten (WIA), überfachliche Kompetenzen (UK)"
                 "Gibt es spezifische Vorgaben für das Layout des Praxissemesterberichts?"
                 "Wer hat die Rechte an Arbeitsergebnissen des Praxissemesters?"
                 "Müssen Arbeitszeiten erfasst werden?"
                 "Darf ich im Praxissemester remote arbeiten (Home Office)?"
                 "Wann ist das Praxissemester formal erbracht?"])

(defn get-answer [question]
  (first (sort-by :similarity >(map (fn [quest] (hash-map :question quest :similarity (cosine-similarity-of-strings quest question))) questions))))

