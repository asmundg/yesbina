(import json)
(import logging)
(import os)
(import re)

(import [sleekxmpp [ClientXMPP]])

(import yesbina.app)

(defclass YesbinaBot [ClientXMPP]
  [[__init__
    (fn [self jid password]
      (ClientXMPP.__init__ self jid password)
      (self.add_event_handler "session_start" self.session-start)
      (self.add_event_handler "message" self.message))]

   [session-start
    (fn [self event]
      (self.send_presence)
      (self.get_roster))]

   [message
    (fn [self msg]
      (if (.__contains__ ["chat" "normal"] (get msg "type"))
        (->
         (get msg "body")
         (.strip)
         (yesbina.app.interesting_departures)
         (. data)
         (json.loads)
         (fmt)
         (msg.reply)
         (.send))))]])

(defn fmt [data]
  (print data)
  (.join "\n"
         (list-comp (.format "{} -> {} @ {}"
                             (->
                              (re.match "(.+?)(?: \(Tromsø\))?$"
                                        (get entry "stop"))
                              (.group (int 1)))
                             (->
                              (re.match "(?:mot )?(.+)"
                                        (->
                                         (get entry "departure")
                                         (get "destination")))
                              (.group (int 1)))
                             (->
                              (re.match ".*T([0-9]+:[0-9]+)"
                                        (->
                                         (get entry "departure")
                                         (get "time")))
                              (.group (int 1))))
                    [entry data])))

(defn main []
   (apply logging.basicConfig [] {"level" logging.DEBUG
                                  "format" "%(levelname)s: %(message)s"})
   (let [[xmpp (YesbinaBot (get os.environ "YESBINA_BOT_JID")
                           (get os.environ "YESBINA_BOT_PASSWORD"))]]
     (xmpp.connect)
     (apply xmpp.process [] {"block" True})))
