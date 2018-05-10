(defproject chatbot "0.1.0-SNAPSHOT"
  :description "FIXME: write description"
  :url "http://example.com/FIXME"
  :license {:name "Eclipse Public License"
            :url "http://www.eclipse.org/legal/epl-v10.html"}
  :dependencies [[org.clojure/clojure "1.8.0"]
                 [compojure "1.6.0"]
                 [ring/ring-core "1.6.3"]
                 [ring/ring-jetty-adapter "1.6.3"]
                 [org.clojure/data.json "0.2.6"]
                 [ring-cors "0.1.12"]
                 [ring/ring-json "0.4.0"]]
  :main ^:skip-aot chatbot.core
  :target-path "target/%s"
  :profiles {:uberjar {:aot :all}})
