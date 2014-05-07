(import heapq)
(import json)
(import re)

(import dateutil.parser)
(import dateutil.tz)
(import [Levenshtein [jaro-winkler]])

(import [yesbina.bootstrap [important-stops-for-line]])
(import yesbina.line)
(import [yesbina.departure [departures-from-stops]])

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

(defn interesting-departures [line]
  (let [[stops (important-stops-for-line line)]
        [departures (departures-from-stops line stops)]]
    (list-comp
     {"stop" stop
      "departure" (get (formatted-departures page) 0)}
     [[stop page] (zip stops departures)])))


(defn stop-at-line [name line]
  """
   Given a name, find the stop that most closely matches this along the given
   line
  """
  (let [[stops (yesbina.line.all-stops-for-line line)]]
    (get (heapq.nlargest 1 stops (lambda [n] (jaro-winkler name n))) 0)))

(defn departures-from-stop [name line]
  """
   Given a name, find the stop that most closely matches this along the given
   line and format the next departures from it
  """
  (let [[stop (stop-at-line name line)]]
    [{"stop" stop
      "departure" (-> (departures-from-stops line [stop])
                      (get 0)
                      (formatted-departures)
                      (get 0))}]))
