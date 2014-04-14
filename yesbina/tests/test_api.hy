(import datetime)
(import dateutil.tz)

(import [bs4 [BeautifulSoup]])

(import yesbina.api)

(defn test-parse-timestamp []
  (assert
   (=
    (yesbina.api.parse-timestamp "2010-01-01T00:00:00Z")
    (datetime.datetime 2010 1 1 0 0 0 0
                       (dateutil.tz.gettz "Europe/Oslo")))))

(defn test-extract-date []
  (assert
   (=
    (yesbina.api.extract-date
     (.
      (BeautifulSoup "<a href=\"/scripts/TravelMagic/TravelMagicWE.dll/turinfo?context=wap.xhtml&amp;dep1=1&amp;from=19021483&amp;to=Wito+(Troms%C3%B8)&amp;direction=1&amp;date=22.04.2014&amp;time=10%3A02&amp;through=&amp;throughpause=&amp;lang=no&amp;referrer=www.tromskortet.no&amp;stophpl=19021053&amp;trip=11524&amp;starthpl=19021483&amp;startdate=22.04.2014\" data-ajax=\"false\" class=\"tm-li-avganger\"></a>")
      a))
    "22.04.2014")))
