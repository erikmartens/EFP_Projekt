(ns chatbot.mongo
  (:require [monger.core]
            [monger.collection])
  (:import [com.mongodb MongoOptions ServerAddress]))

(def connection (monger.core/connect {:host "efp-mongo" :port 27017}))

(def db (monger.core/get-db connection "efp"))

(defn save-request [ userId timeStamp intent ]
  (monger.collection/insert db "request" { :userId userId :timeStamp timeStamp :intent intent }))