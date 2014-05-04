(import json)
(import re)

(import [bs4 [BeautifulSoup]])
(import dateutil.parser)
(import dateutil.tz)
(import grequests)

(import [yesbina.bootstrap [important-stops-for-line]])

(def departure-link
  (+ "http://rp.tromskortet.no/scripts/TravelMagic/TravelMagicWE.dll"
     "/avgangsinfo?from={stopid}&linjer={line}&context=wap.xhtml"))

(defn parse-page [page]
  (->
   (. page text)
   (BeautifulSoup)))

(defn parallel-fetch [urls]
  (print urls)
  (list-comp
   (parse-page page)
   [page
    (grequests.map
     (list-comp
      (grequests.get
       (url.encode "utf-8"))
      [url urls]))]))

(defn parse-timestamp [time]
  (let [[tz (dateutil.tz.gettz "Europe/Oslo")]]
    (apply
     (->
      (.strip time)
      (dateutil.parser.parse)
      (. replace))
     [] {"tzinfo" tz})))

(defn extract-date [tag]
  ((.
    (re.match ".*startdate=([0-9\.]+)"
              (get tag "href"))
    group) (int 1)))

(defn formatted-departures [page]
  (list-comp
   {"time" (->
            (.join "T"
                   [(extract-date tag)
                    (->
                     (apply tag.find ["span"] {"class_" "tm-time"})
                     (.get_text))])
            (parse-timestamp)
            (.isoformat))
    "line" (->
            (apply tag.find ["span"] {"class_" "tm-line-nr"})
            (.get_text))
    "destination" (->
                   (apply tag.find ["span"] {"class_" "tm-line-destination"})
                   (.get_text)
                   (.strip))}
   [tag (.select
         page
         "a.tm-li-avganger")]))

(defn departures-for-stop [line stops]
  (parallel-fetch
   (list-comp
    (apply departure-link.format []
           {"stopid" (stop.replace " " "+")
            "line" line})
    [stop stops])))

(defn interesting-departures [line]
  (let [[stops (important-stops-for-line line)]
        [departures (departures-for-stop line stops)]]
    (list-comp
     {"stop" stop
      "departure" (get (formatted-departures page) 0)}
     [[stop page] (zip stops departures)])))
