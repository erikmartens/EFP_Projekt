(ns chatbot.mongo
  (:require [monger.core]
            [monger.collection])
  (:import [com.mongodb MongoOptions ServerAddress]))

(def connection (monger.core/connect {:host "efp-mongo" :port 27017}))

(def db (monger.core/get-db connection "efp"))

(defn save-request
  "Stores the user request with the corresponding answer in a mongo db."
  [ userId timeStamp intent userChatMessage ]
  (monger.collection/insert db "request" { :userId userId :timeStamp timeStamp :intent intent :userChatMessage userChatMessage}))

(defn list-user-messages
  "Finds all stored user requests with their corresponding answers for a given user id."
  [ userId ]
  (->> (monger.collection/find-maps db "request" { :userId userId })
       (map (fn [ doc ]
              (let [ answer (chatbot.recognition/answer-from-intent (:intent doc))]
                (assoc doc :_id (clojure.core/str (:_id doc)) :answer answer))))
       )
  )

  (defn list-user-ids
    []
    (->> (monger.collection/find-maps db "request")
         (map :userId)
         (distinct)
         ))
