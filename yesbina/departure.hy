(import [yesbina.common  [parallel-fetch]])

(def departure-link
  (+ "http://rp.tromskortet.no/scripts/TravelMagic/TravelMagicWE.dll"
     "/avgangsinfo?from={stopid}&linjer={line}&context=wap.xhtml"))

(defn departures-from-stops [line stops]
  (parallel-fetch
   (list-comp
    (apply departure-link.format []
           {"stopid" (stop.replace " " "+")
            "line" line})
    [stop stops])))
