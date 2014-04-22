(import json)

(import requests)

(def stop_url "http://rp.tromskortet.no/scripts/TravelMagic/TravelMagicWE.dll/mapjson?x1=18.460998017578163&x2=19.414061982421913&y1=69.50862788969137&y2=69.79513831078665")

(defn important-stops []
  (dict-comp
   (get obj "n") (get obj "l")
   [obj (json.loads
         (. (requests.get stop_url) text))]))

(defn important-stops-for-line [line]
  (let [[all-stops (important-stops)]
        [stops []]]
    (do (for [stop all-stops]
          (if (.__contains__ (get all-stops stop) (unicode line))
            (.append stops stop)))
        stops)))

