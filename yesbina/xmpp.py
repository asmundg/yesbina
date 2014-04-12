import json
import logging
import os

from sleekxmpp import ClientXMPP

import hy
import yesbina.api


def fmt(data):
    return '\n'.join(['From: {} to {} at {}'
                      .format(entry['stop'],
                              entry['departure']['destination'],
                              entry['departure']['time'].split('T')[1])
                      for entry in data])


class YesbinaBot(ClientXMPP):
    def __init__(self, jid, password):
        ClientXMPP.__init__(self, jid, password)
        self.add_event_handler('session_start', self.session_start)
        self.add_event_handler('message', self.message)

    def session_start(self, event):
        self.send_presence()
        self.get_roster()

    def message(self, msg):
        if msg['type'] in ('chat', 'normal'):
            busline = msg['body'].strip()
            msg.reply(fmt(yesbina.api.interesting_departures(busline))).send()


def main():
    logging.basicConfig(level=logging.DEBUG,
                        format='%(levelname)s: %(message)s')
    xmpp = YesbinaBot(
        os.environ['YESBINA_BOT_JID'],
        os.environ['YESBINA_BOT_PASSWORD'])
    xmpp.connect()
    xmpp.process(block=True)
