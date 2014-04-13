(import logging)
(import os)

(import [sleekxmpp [ClientXMPP]])

(import yesbina.api)

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
        (.send
         (msg.reply
          (fmt
           (yesbina.api.interesting_departures
            (.strip (get msg "body"))))))))]])

(defn fmt [data]
  (.join "\n"
         (list-comp (.format "From: {} to {} at {}"
                             (get entry "stop")
                             (-> (get entry "departure")
                                 (get "destination"))
                             (get
                              (.split (-> (get entry "departure")
                                          (get "time"))
                                      "T") 1))
                    [entry data])))

(defn main []
   (apply logging.basicConfig [] {"level" logging.DEBUG
                                  "format" "%(levelname)s: %(message)s"})
   (let [[xmpp (YesbinaBot (get os.environ "YESBINA_BOT_JID")
                           (get os.environ "YESBINA_BOT_PASSWORD"))]]
     (xmpp.connect)
     (apply xmpp.process [] {"block" True})))
