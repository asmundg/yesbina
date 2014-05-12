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
         (dispatch (get msg "body"))
         (. data)
         (json.loads)
         (fmt)
         (msg.reply)
         (.send))))]])

(defn dispatch [body]
  (let [[msg (body.strip)]]
    (cond [(re.match "^[0-9]+$" msg)
           (yesbina.app.interesting-departures msg)]
          [(re.match "^[0-9]+ .*$" msg)
           (yesbina.app.departures
            (.decode (get (msg.split) 1) "utf-8")
            (get (msg.split) 0))])))

(defn fmt [data]
  (.join "\n"
         (flatten
          (list-comp
           (list-comp
            (.format "{} -> {} @ {}"
                     (->
                      (re.match "(.+?)(?: \(Tromsø\))?$"
                                (get stop "stop"))
                      (.group (int 1)))
                     (->
                      (re.match "(?:mot )?(.+)"
                                (get departure "destination"))
                      (.group (int 1)))
                     (->
                      (re.match ".*T([0-9]+:[0-9]+)"
                                (get departure "time"))
                      (.group (int 1))))
            [departure (get stop "departures")])
           [stop data]))))

(defn main []
   (apply logging.basicConfig [] {"level" logging.DEBUG
                                  "format" "%(levelname)s: %(message)s"})
   (let [[xmpp (YesbinaBot (get os.environ "YESBINA_BOT_JID")
                           (get os.environ "YESBINA_BOT_PASSWORD"))]]
     (xmpp.connect)
     (apply xmpp.process [] {"block" True})))
