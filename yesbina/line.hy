(import re)

(import [yesbina.common  [parallel-fetch]]
        [yesbina.departure [departures-from-stops]]
        [yesbina.bootstrap [important-stops-for-line]])

(def trip-info-url
  (+ "http://rp.tromskortet.no/scripts/TravelMagic/TravelMagicWE.dll"
     "/turinfo?context=wap.xhtml&trip={trip}"))

(defn find-tripno [page]
  """
   Given a departure page, return the trip id.
  """
  (->
   (re.match ".*trip=([0-9]+)"
             (->
              (page.select "a.tm-li-avganger")
              (get 0)
              (get "href")))
   (.group (int 1))))

(defn find-stops [page]
  """
   Given a trip info page, return all stop names.
  """
  (list-comp
    ((lambda [span]
      (do
       (for (s (span.select "span")) (s.decompose))
       (.strip (span.get_text))))
     span)
   [span (page.select "span.tm-hpl")]))

(defn trip-stops [trips]
  """
   For a list of trip numbers, return the set of all stops they pass.
  """
  (list
   (set
    (flatten
     (list-comp
      (find-stops page)
      [page
       (parallel-fetch
        (list-comp
         (apply trip-info-url.format [] {"trip" trip})
         [trip trips]))])))))

(defn all-stops-for-line [line]
  """
   For a line, return the set of all stops can pass. Hopefully.
  """
  (trip-stops
   (list-comp
    (find-tripno departure-page)
    [departure-page (departures-from-stops line (important-stops-for-line line))])))

