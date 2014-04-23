(import re)
(import urllib)

(import [bs4 [BeautifulSoup]])
(import dateutil.parser)
(import dateutil.tz)
(import requests)

(import yesbina.stops)

(def root_url "http://rp.tromskortet.no/scripts/TravelMagic/TravelMagicWE.dll")
(def departure_link "/avgangsinfo?from={stopid}&linjer={line}&context=wap.xhtml")

(defn fetch-page [link]
  (let [[url (+ root_url link)]]
    (->
     (requests.get url)
     (. text)
     (BeautifulSoup))))

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

(defn custom-quote [url]
  (.replace url " " "+"))

(defn get-departures-url [stopid line]
  (apply departure_link.format []
         {"stopid" (custom-quote stopid)
          "line" line}))

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

(defn interesting-departures [line]
  (list-comp
   {"stop" stop
    "departure"
    (->
     (get-departures-url stop line)
     (fetch-page)
     (formatted-departures)
     (get 0))}
   [stop (yesbina.stops.important-stops-for-line line)]))
