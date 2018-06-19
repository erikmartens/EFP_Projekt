(ns chatbot.utils)

;; effect-print : x -> x
(defn effect-print [x]
  (do
    (println x)
    x))

(defn in?
  "true if coll contains elm"
  [coll elm]
  (some #(= elm %) coll))

(def not-nil? (complement nil?))