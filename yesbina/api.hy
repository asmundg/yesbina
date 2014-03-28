(import re)
(import urllib)

(import [bs4 [BeautifulSoup]])
(import dateutil.parser)
(import dateutil.tz)
(import requests)


(def root_url "http://rp.tromskortet.no/scripts/TravelMagic/TravelMagicWE.dll")
(def departure_link "/avgangsinfo?from={stopid}&linjer={line}&context=wap.xhtml")


(defn fetch-page [link]
  (let [[url (+ root_url link)]]
    (BeautifulSoup
     (getattr
      (requests.get url)
      "text"))))

(defn parse-timestamp [time]
  (let [[tz (dateutil.tz.gettz "Europe/Oslo")]]
    (kwapply
     ((getattr
       (dateutil.parser.parse
        (.strip time))
       "replace")) {"tzinfo" tz})))

(defn extract-date [tag]
  ((getattr
    (re.match ".*startdate=([0-9\.]+)"
              (get tag "href"))
    "group") (int 1)))

(defn custom-quote [url]
  (.replace url " " "+"))

(defn get-departures [stopid line]
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
         (fetch-page
          (kwapply (departure_link.format)
                   {"stopid" (custom-quote stopid)
                             "line" line}))
         "a.tm-li-avganger")]))

(defn line-stops [line]
  (cond [(= line "28") ["Hamna skole øst (Tromsø)"
                        "Giæverbukta (Tromsø)"
                        "Sjøgata S2 (Tromsø)"
                        "Fr. Langes Gate F4 (Tromsø)"
                        "Solligården (Tromsø)"]]
        [(= line "32") ["Fiskekroken (Tromsø)"
                        "Fr. Langes gate F6 (Tromsø)"]]))

(defn interesting-departures [line]
  (list-comp
   {"stop" stop
    "departure" (get (get-departures stop line) 0)}
   [stop (line-stops line)]))
