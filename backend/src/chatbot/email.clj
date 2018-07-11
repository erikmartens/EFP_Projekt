(ns chatbot.email
  (:require [postal.core :refer [send-message]]
            [chatbot.mongo]
            [clojure.data.json :as json]))

(def datesJson (json/read-str (slurp (clojure.java.io/resource "dates.json")) :key-fn keyword))

(defn send-mails
  []
	(def matrikelnummern (chatbot.mongo/list-user-ids))
	(def now (.format (new java.text.SimpleDateFormat "yyyy-MM-dd") (java.util.Date.))) ;Heutiges Datum im Format tt.mm.jjjj
	(loop [x (- (count datesJson) 1)]
	(when (> x -1)
		(if (= ((datesJson x) :date) now)
		(loop [i (- (count matrikelnummern) 1)]
		(when (> i -1)
			(send-message {:host "mail.gmx.net"
				    		 		 :port 465
			           		 :ssl true
			           		 :user "ChatBotPs@gmx.de"
			           		 :pass "ChatBotPs"}
								  	{:from "ChatBotPs@gmx.de"
		                 :to (str (nth matrikelnummern i) "@stud.hs-mannheim.de")
		                 :subject ((datesJson x) :subject)
		                 :body ((datesJson x) :body)})
			(recur (- i 1))))
			)
		(recur (- x 1))))
  )

(defn set-interval
  [callback ms]
  (future (while true (do (Thread/sleep ms) (callback))))
	)

(def job (set-interval (send-mails) 86400000))
