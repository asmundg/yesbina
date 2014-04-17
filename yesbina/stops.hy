(require hy.contrib.anaphoric)
(import json)

(import memcache)
(import requests)

(def search_url "http://www.tromskortet.no/autocompleteproxy.php?limit=25&q={}")

(defn alphabet []
  (list-comp
   (chr x) (x (range (ord "a") (+ (ord "z") 1)))))

(defn all-stops []
  (list-comp
   (stops-with-prefix prefix)
   (prefix (alphabet))))

(defn online-stops [prefix]
  (print prefix)
  (json.loads
   (. (requests.get (.format search_url prefix)) text)))

(defn cached [func]
  (fn [prefix]
    (let [[mc (memcache.Client ["127.0.0.1:11211"])]
          [value (mc.get prefix)]]
      (if (none? value)
        (let [[result (func prefix)]]
          (mc.set prefix result)
          result)
        value))))

(with-decorator cached
  (defn stops-with-prefix [prefix]
    (let [[stops (online-stops prefix)]]
      (if (= (len stops) 25)
        (ap-reduce (+ it acc)
                   (list-comp (stops-with-prefix (+ prefix subprefix))
                              (subprefix (alphabet))))
        stops))))

(print (all-stops))
