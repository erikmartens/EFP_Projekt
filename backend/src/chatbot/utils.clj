(ns chatbot.utils)

;; effect-print : x -> x
(defn effect-print
  "Prints the value on the commando line and returns it."
  [x]
  (do
    (println x)
    x))

(defn in?
  "true if collection contains the element"
  [coll elm]
  (some #(= elm %) coll))

(def not-nil? (complement nil?))

(defn get-thread-last
  "Use this version if you need to use the first-thread macro inside the last-thread macro."
  [ _key ]
  (fn [ _map ]
    (get _map (keyword _key))))