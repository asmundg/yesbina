(import [bs4 [BeautifulSoup]])
(import grequests)

(defn parse-page [page]
  (->
   (. page text)
   (BeautifulSoup)))

(defn parallel-fetch [urls]
  (list-comp
   (parse-page page)
   [page
    (grequests.map
     (list-comp
      (grequests.get
       (url.encode "utf-8"))
      [url urls]))]))
