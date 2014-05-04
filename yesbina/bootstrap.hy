(import json)

(import requests)

(def stop-url
  (+ "http://rp.tromskortet.no/scripts/TravelMagic/TravelMagicWE.dll"
     "/mapjson?x1=18.460998017578163&x2=19.414061982421913"
     "&y1=69.50862788969137&y2=69.79513831078665"))

(defn important-stops []
  (dict-comp
   (get obj "n") (get obj "l")
   [obj (->
         (requests.get stop-url)
         (. text)
         (json.loads))]))

(defn important-stops-for-line [line]
  (let [[stops (important-stops)]]
    (list-comp stop
               [stop stops]
               (.__contains__ (get stops stop) (unicode line)))))
